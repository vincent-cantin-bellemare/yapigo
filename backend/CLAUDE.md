# RunDate Backend — Instructions Claude Code

## Langue et code

- Toujours répondre en **français**
- Tout le code en **anglais** — commentaires, docstrings, `verbose_name`, `help_text`, noms de variables

## Commits

Ne jamais committer sans "commit" ou "fais un commit" explicite de l'utilisateur.

## Chemins importants (dans le container)

- Code Django : `/app/code/project/`
- Documentation : `/app/docs/` (lire avant de modifier)
- Ne jamais écrire sous `/app/project/` ou `/app/`

---

## Stack

- Django 5.x + Graphene-Django (GraphQL uniquement — pas de REST)
- PostgreSQL, Gunicorn, Nginx
- Auth : deux niveaux — `Authorization: Basic` (app) + `Token:` (user)
- Pas de Celery, pas de Redis, pas de JWT

## Apps Django

```
accounts    geography    events      messaging
notifications   community   devtools    monitoring   i18n
```

---

## Conventions de code

### flake8

```bash
cd /app/code && flake8
```

Config `.flake8` :
```ini
[flake8]
max-line-length = 88
extend-ignore = E203,W503,E501,F401,F841,F821,F403,F405
exclude = .git,__pycache__,.venv,venv,env,.env,migrations,staticfiles,media,volumes
```

### Service Layer obligatoire

Toute logique métier dans `services.py`. Jamais dans les vues, admin, mutations ou management commands.

```python
# ✅ Résolveur GraphQL correct — voir docs/backend/06-api-graphql.md (status + errors dict)
def mutate(self, info, ...):
    result = services.do_something(...)
    return Payload(status=True, errors={}, result=result)

# ❌ Logique dans le résolveur
def mutate(self, info, ...):
    obj = MyModel.objects.filter(...).update(...)
```

### Modèles

- Un modèle par fichier dans `models/`
- `models/__init__.py` importe tout et définit `__all__`
- `related_name` obligatoire sur chaque `ForeignKey` et `ManyToManyField`
- `verbose_name` et `verbose_name_plural` obligatoires dans `Meta`
- `null=True, blank=True` pour les champs optionnels
- Tous les modèles héritent de `BaseModel` (UUID pk, `created_at`, `updated_at`)
- Pas de nouveaux index sans permission explicite

### Ordre des membres dans les classes Python

```
Constantes → Champs → class Meta → __str__/dunder
→ @classmethod → @staticmethod → @property
→ méthodes publiques → méthodes privées (_method)
```

### Tests

Mettre à jour les tests existants après modification. Ne pas créer de nouveaux fichiers de test sauf si demandé.

---

## Nommage GraphQL

Format **`<app><Model><Action>`** en camelCase :

```graphql
# ✅ Correct
accountsUserMe          eventsEventList
messagingMessageSend    notificationsNotificationMarkAllRead

# ❌ Interdit
getUser   listEvents   send_message
```

## Nommage management commands

Format **`<app>_<model>_<action>`** en snake_case :

```
events_event_check_threshold
notifications_notification_send_deadline_reminder
monitoring_httprequestlog_purge
```

## Nommage commandes GraphQL CLI (devtools)

Format **`graphql_<app>_<model>_<action>`** :

```
graphql_accounts_user_me
graphql_events_event_list
graphql_events_event_register
```

---

## Authentification — deux niveaux

```
Authorization: Basic <base64(username:password)>   # toutes les requêtes (app)
Token: <64 chars>                                  # requêtes authentifiées (user)
language: fr                                       # langue
```

Ordre des décorateurs :
```python
@log_graphql_request
@require_authorization
@require_user_access_token  # si auth requise
@extract_language
def mutate(self, info, application_access, user_access, language, ...):
```

---

## Traductions i18n

Jamais de string hardcodée pour l'utilisateur :

```python
# ✅ Correct
from apps.i18n.utils import translate
translate("errors", "otp_invalid", language)

# ❌ Interdit
return "Code invalide"
```

---

## Settings — deux axes

```
ENVIRONMENT = dev | staging | production   → sécurité HTTPS, HSTS
ENV         = None | "admin" | "graphql"  → URLs exposées par le processus
```

Fichiers : `config/settings_admin.py` et `config/settings_graphql.py`

## Admin Django

- URL à **`/`** sur `admin.rundate.app` — jamais `/admin/`
- `@admin.register` uniquement dans `admin/__init__.py`
- Jamais de HTML inline — toujours `AdminHTMLUtils`
- `get_*_link` obligatoire pour les FK dans `list_display`
- Toute logique d'action dans un **service** — jamais de `queryset.update()` direct dans une action
- Actions destructives : utiliser `BulkActionWithConfirmMixin` + `requires_confirmation = True`
- Emojis dans `description` pour distinguer visuellement : ✅ Non-destructif | ⚠️ Réversible | ❌/🚫 Irréversible
- Voir [24-admin-actions.md](../docs/backend/24-admin-actions.md) pour le catalogue complet

---

## Soft delete

```python
# ✅ Correct sur User et RunDateEvent
RunDateEvent.active.all()   # manager ActiveManager

# ❌ Interdit
RunDateEvent.objects.all()
```

## Erreurs GraphQL

Toujours retourner un Payload avec **`status`** + **`errors`** (dictionnaire JSON, `{}` si succès) + champ ressource — jamais d'exception brute pour les erreurs métier. Voir [06-api-graphql.md](../docs/backend/06-api-graphql.md) section *Norme — Statuts et erreurs*.

```python
# ✅ Correct
return EventsEventRegisterPayload(
    status=False,
    errors={"event": translate("errors", "event_full", language)},
    registration=None,
)

# ❌ Interdit
raise GraphQLError("Event is full")
```

---

## Génération de bio IA (Claude Sonnet 4.6)

Toute la logique dans `accounts/services/bio_generation.py` — jamais dans les mutations directement.

```python
# ✅ Correct
from apps.accounts.services.bio_generation import BioGenerationService

def mutate(self, info, application_access, user_access, language):
    try:
        proposals = BioGenerationService().generate(user_access.user)
        return AccountsUserBioGeneratePayload(status=True, errors={}, proposals=proposals)
    except anthropic.APIError as e:
        logger.error("bio_generation_error", extra={"error": str(e)})
        return AccountsUserBioGeneratePayload(
            status=False,
            errors={"general": translate("errors", "bio_generation_failed", language)},
            proposals=[],
        )
```

Règles :
- Jamais d'exception brute — toujours retourner un Payload `status=False` + `errors` (dict)
- Minimum 5 réponses onboarding en base pour déclencher la génération
- Le modèle est configurable via `settings.ANTHROPIC_MODEL` (ne pas hardcoder)
- Les clés API dans `1Password`, jamais dans le code

Voir [19-bio-generation.md](../docs/backend/19-bio-generation.md) pour le détail complet.

## Migrations

```bash
# ✅ Toujours nommer
python manage.py makemigrations --name create_user_model

# ❌ Jamais laisser le nom auto
# → 0001_auto_20260323_1200.py
```

---

## Documentation

Toutes les décisions d'architecture sont dans `docs/backend/` :

| # | Document |
|---|---|
| 01 | Infrastructure (VM, Proxmox, Cloudflare) |
| 02 | Stack technique |
| 03 | Structure du projet |
| 04 | Modèles Django |
| 05 | Authentification |
| 06 | API GraphQL |
| 07 | Management commands (workers) |
| 08 | GraphQL CLI (devtools) |
| 09 | Environnements & Docker |
| 10 | Seeds |
| 11 | Sauvegardes |
| 12 | Conventions de code |
| 13 | Schéma GraphQL & Flutter |
| 14 | Standards admin Django |
| 15 | Synchronisation DB |
| 16 | Settings multi-environnements |
| 17 | Système i18n |
| 18 | Dockerfile |
