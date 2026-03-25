# 23 — Algorithme de répartition des groupes

## Concept

L'algorithme de matching est **volontairement simple** : pas d'IA, pas de scoring de compatibilité. On prend les inscriptions confirmées, on respecte les buddy pairs, et on répartit en groupes de taille cible.

La complexité future (IA, compatibilité par allure, by gender balance, etc.) pourra être greffée sur cette base sans changer l'architecture.

---

## Déclenchement

L'algorithme est déclenché **manuellement par un admin** via une action Django Admin sur un `RunDateEvent`. Il ne tourne pas automatiquement.

```
Django Admin → RunDateEvent → Action "Créer les groupes"
  → GroupMatchingService.run(event)
  → Crée N RunGroup + N Conversation + envoie les notifications
```

Ou via une commande de management :

```bash
python manage.py events_rungroup_create --event-id <uuid> --group-size 6
```

---

## Format d'entrée (JSON interne)

L'algorithme travaille avec une liste de registrations sérialisée depuis la base. Le format JSON est utilisé dans les tests et dans la commande CLI pour simuler des données sans passer par la DB.

```json
{
  "event_id": "uuid-de-l-evenement",
  "target_group_size": 6,
  "registrations": [
    {
      "user_id": "uuid-u1",
      "first_name": "Sophie",
      "pace_label": "renard_ruse",
      "distance_label": "tour_du_quartier",
      "buddy_user_id": "uuid-u2",
      "is_lievre": false,
      "registered_at": "2026-03-20T09:00:00Z"
    },
    {
      "user_id": "uuid-u2",
      "first_name": "Marc",
      "pace_label": "road_runner",
      "distance_label": "demi_folie",
      "buddy_user_id": "uuid-u1",
      "is_lievre": true,
      "registered_at": "2026-03-20T09:05:00Z"
    }
  ]
}
```

---

## Algorithme (étapes)

### Étape 1 — Charger et valider

```python
registrations = EventRegistration.objects.filter(
    event=event, status="confirmed"
).select_related("user", "buddy_user").order_by("registered_at")
```

Conditions préalables :
- Minimum `event.min_threshold` inscriptions confirmées
- L'événement ne doit pas avoir de `RunGroup` existant (`RunGroup.objects.filter(event=event).exists()`)

### Étape 2 — Extraire les Lièvres confirmés

```python
def extract_confirmed_lievres(registrations):
    """
    Separates confirmed Lièvres (accepted invitation) from regular runners.
    Returns: (lievres, others)
    """
    lievres = [r for r in registrations if r.is_priority_lievre]
    others = [r for r in registrations if not r.is_priority_lievre]
    return lievres, others
```

Les Lièvres confirmés sont garantis d'être **leaders d'un groupe** — ils ne sont pas mélangés dans le pool normal.

### Étape 3 — Pré-grouper les buddy pairs

```python
def pair_buddies(registrations):
    """
    Groups buddy pairs together before random assignment.
    Returns: (paired_groups, unpaired_registrations)
    """
    used = set()
    pairs = []
    solo = []

    for reg in registrations:
        if reg.id in used:
            continue
        if reg.buddy_user_id:
            buddy_reg = next(
                (r for r in registrations if r.user_id == reg.buddy_user_id and r.id not in used),
                None
            )
            if buddy_reg:
                pairs.append([reg, buddy_reg])
                used.add(reg.id)
                used.add(buddy_reg.id)
                continue
        solo.append(reg)
        used.add(reg.id)

    return pairs, solo
```

### Étape 4 — Mélanger et répartir

```python
import random

def build_groups(pairs, solo, target_size):
    """
    Distributes buddy pairs and solo runners into groups of target_size.
    """
    random.shuffle(pairs)
    random.shuffle(solo)

    # Flatten: pairs first, then solo
    all_slots = []
    for pair in pairs:
        all_slots.extend(pair)
    all_slots.extend(solo)

    # Slice into groups of target_size
    groups = [
        all_slots[i:i + target_size]
        for i in range(0, len(all_slots), target_size)
    ]

    # Merge last group if too small (< target_size / 2)
    min_group_size = max(2, target_size // 2)
    if len(groups) > 1 and len(groups[-1]) < min_group_size:
        last = groups.pop()
        # Distribute last members across other groups
        for i, member in enumerate(last):
            groups[i % len(groups)].append(member)

    return groups
```

### Étape 5 — Distribuer les Lièvres dans les groupes

```python
def distribute_lievres(lievres, groups):
    """
    Assigns one confirmed Lièvre per group (priority placement).
    If more Lièvres than groups: extra Lièvres are distributed as regular members.
    If fewer Lièvres than groups: remaining groups get a fallback Lièvre (is_lievre=True profile).
    Returns groups with Lièvre prepended as first member.
    """
    for i, lievre in enumerate(lievres):
        if i < len(groups):
            groups[i].insert(0, lievre)   # Lièvre en premier dans le groupe
        else:
            groups[i % len(groups)].append(lievre)  # excédent redistribué

    return groups

def assign_fallback_lievre(group_members):
    """Fallback: picks the first is_lievre=True profile member if no confirmed Lièvre."""
    for reg in group_members:
        if reg.user.is_lievre and not reg.is_priority_lievre:
            return reg.user
    return None
```

### Étape 6 — Créer les `RunGroup`, conversations et notifications

```python
def create_run_groups(event, groups):
    neighborhood = event.neighborhood.name if event.neighborhood else "RunDate"

    for i, group_regs in enumerate(groups, start=1):
        group_number = i
        members = [reg.user for reg in group_regs]

        # Confirmed Lièvre first, then fallback to is_lievre profile
        confirmed_lievre = next(
            (reg.user for reg in group_regs if reg.is_priority_lievre), None
        )
        lievre_user = confirmed_lievre or assign_fallback_lievre(group_regs)

        # Create RunGroup
        run_group = RunGroup.objects.create(
            event=event,
            lievre=lievre_user,
            status="confirmed",
        )
        run_group.members.set(members)

        # Create Conversation (signal auto-triggered — see doc 20)
        # Signal handles: Conversation + ConversationMember + icebreaker Message

        # Notify each member
        for user in members:
            AppNotification.objects.create(
                user=user,
                type="matchFound",
                title="Ton groupe est formé! 🏃",
                body=f"Tu cours avec {len(members)} personnes ce run. Check les détails!",
                event=event,
                run_group=run_group,
            )
            # FCM push via signal post_save on AppNotification
```

---

## Service complet

```python
# apps/events/services/group_matching.py

class GroupMatchingService:

    def run(self, event: RunDateEvent) -> list[RunGroup]:
        """
        Main entry point. Returns the list of created RunGroups.
        Raises ValueError if preconditions are not met.

        Order of operations:
          1. Extract confirmed Lièvres (priority placement)
          2. Pair buddy codes among regular runners
          3. Shuffle and build groups
          4. Distribute confirmed Lièvres (one per group)
          5. Create RunGroup + Conversation + Notifications
        """
        self._validate(event)
        registrations = self._load_registrations(event)
        lievres, others = self._extract_confirmed_lievres(registrations)
        pairs, solo = self._pair_buddies(others)
        groups = self._build_groups(pairs, solo, event.target_group_size)
        groups = self._distribute_lievres(lievres, groups)
        return self._create_run_groups(event, groups)

    def run_from_json(self, payload: dict) -> list[dict]:
        """
        Dry run from JSON payload (for CLI testing, no DB writes).
        Returns a list of group dicts for inspection.
        """
        registrations = payload["registrations"]
        target_size = payload.get("target_group_size", 6)
        pairs, solo = self._pair_buddies_from_dicts(registrations)
        groups = self._build_groups(pairs, solo, target_size)
        return [
            {"group": i + 1, "members": [r["first_name"] for r in g]}
            for i, g in enumerate(groups)
        ]

    def _validate(self, event):
        confirmed_count = EventRegistration.objects.filter(
            event=event, status="confirmed"
        ).count()
        if confirmed_count < event.min_threshold:
            raise ValueError(f"Not enough registrations: {confirmed_count} < {event.min_threshold}")
        if RunGroup.objects.filter(event=event).exists():
            raise ValueError("Groups already created for this event")

    # ... autres méthodes privées
```

---

## Commande de management

```python
# apps/events/management/commands/events_rungroup_create.py

class Command(BaseCommand):
    help = 'Create run groups for a confirmed event'

    def add_arguments(self, parser):
        parser.add_argument('--event-id', required=True)
        parser.add_argument('--group-size', type=int, default=6)
        parser.add_argument('--dry-run', action='store_true')
        parser.add_argument('--json-file', help='Path to JSON file for dry run')

    def handle(self, *args, **options):
        if options['json_file']:
            with open(options['json_file']) as f:
                payload = json.load(f)
            result = GroupMatchingService().run_from_json(payload)
            self.stdout.write(json.dumps(result, indent=2, ensure_ascii=False))
            return

        event = RunDateEvent.objects.get(id=options['event_id'])
        if options['dry_run']:
            self.stdout.write(f"Dry run: {event} — would create groups of {options['group_size']}")
            return

        groups = GroupMatchingService().run(event)
        self.stdout.write(
            self.style.SUCCESS(f"{len(groups)} groups created for {event}")
        )
```

### Utilisation

```bash
# Dry run sur un événement réel
python manage.py events_rungroup_create --event-id <uuid> --dry-run

# Simuler depuis un fichier JSON (sans accès DB)
python manage.py events_rungroup_create --json-file registrations.json

# Créer les groupes pour de vrai
python manage.py events_rungroup_create --event-id <uuid> --group-size 6
```

---

## Action Django Admin

```python
# apps/events/admin/run_date_event_admin.py

@admin.action(description="Créer les groupes de run")
def create_run_groups(modeladmin, request, queryset):
    for event in queryset:
        try:
            groups = GroupMatchingService().run(event)
            modeladmin.message_user(
                request,
                f"{event}: {len(groups)} groupes créés.",
                messages.SUCCESS,
            )
        except ValueError as e:
            modeladmin.message_user(request, f"{event}: {e}", messages.ERROR)
```

---

## Exemple de résultat pour 15 inscrits (target_size=6)

```
Input : 15 inscrits
  - 2 Lièvres confirmés (invitation acceptée) : Alex, Marie-Claude
  - 2 buddy pairs : Sophie↔Marc, Julie↔Samir
  - 9 réguliers : Émilie, Thomas, Jordan, Olivier, Chloé, Lara, Kim, Félix, Nadia

Étape 2 → lievres = [Alex, Marie-Claude]
           others  = [Sophie, Marc, Julie, Samir, Émilie, Thomas, Jordan, Olivier, Chloé, Lara, Kim, Félix, Nadia]

Étape 3 → pairs = [[Sophie, Marc], [Julie, Samir]]
           solo  = [Émilie, Thomas, Jordan, Olivier, Chloé, Lara, Kim, Félix, Nadia]

Étape 4 → après mélange (sans les Lièvres) :
  Groupe 1 (5) : Sophie, Marc + 3 solo
  Groupe 2 (5) : Julie, Samir + 3 solo

  → Kim (dernier solo) → fusionné dans groupe 1

  Avant Lièvres :
  Groupe 1 (6) : Sophie, Marc, Émilie, Thomas, Jordan, Kim
  Groupe 2 (6) : Julie, Samir, Olivier, Chloé, Lara, Félix
  Groupe 3 (3) : Nadia, ... → trop petit → fusionné dans groupe 2

  Après fusion :
  Groupe 1 (7) : Sophie, Marc, Émilie, Thomas, Jordan, Kim, Nadia
  Groupe 2 (8) : Julie, Samir, Olivier, Chloé, Lara, Félix + ...

Étape 5 → distribution Lièvres (un par groupe, en tête) :
  Groupe 1 → Alex en premier  (Lièvre confirmé, invitation acceptée)
  Groupe 2 → Marie-Claude en premier (Lièvre confirmée, invitation acceptée)

Résultat final :
  Groupe 1 (8) : 🐇 Alex [LIÈVRE], Sophie, Marc, Émilie, Thomas, Jordan, Kim, Nadia
  Groupe 2 (9) : 🐇 Marie-Claude [LIÈVRE], Julie, Samir, Olivier, Chloé, Lara, Félix, Jade, Pat
```

---

## Évolutions futures (V2)

| Amélioration | Description |
|---|---|
| Balance H/F | Équilibrer la répartition homme/femme dans chaque groupe |
| Compatibilité d'allure | Grouper les coureurs par `pace_label` similaire |
| Éviter les ex | Bloquer deux personnes bloquées dans le même groupe |
| Score de compatibilité IA | Utiliser les réponses onboarding pour scorer la compatibilité |
