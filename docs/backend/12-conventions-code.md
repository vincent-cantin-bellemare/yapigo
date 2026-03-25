# 12 — Conventions de code

Ces conventions sont encodées comme règles Cursor dans `.cursor/rules/` et s'appliquent automatiquement lors du développement.

| Règle Cursor | Scope | Contenu |
|---|---|---|
| `project-rules.mdc` | toujours actif | Langue, commits, git workflow |
| `backend-django-models.mdc` | `backend/**/*.py` | Modèles, Meta, related_name, ordering |
| `backend-code-quality.mdc` | `backend/**/*.py` | flake8, service layer, tests |
| `backend-app-structure.mdc` | `backend/**/*.py` | Structure des apps |
| `backend-graphql-naming.mdc` | `backend/**/*.py` | Nommage queries/mutations |
| `backend-management-commands.mdc` | `backend/**/management/commands/*.py` | Nommage workers |
| `backend-graphql-commands.mdc` | `backend/apps/devtools/**/*.py` | Nommage CLI GraphQL |
| `backend-services-selectors.mdc` | `backend/**/*.py` | Pattern selectors/services |
| `backend-graphql-errors.mdc` | `backend/**/*.py` | Payloads d'erreur |
| `backend-soft-delete.mdc` | `backend/**/*.py` | SoftDeleteMixin |
| `backend-base-model.mdc` | `backend/**/*.py` | BaseModel UUID |
| `backend-migrations.mdc` | `backend/**/migrations/*.py` | Nommage, indexes |
| `backend-admin.mdc` | `backend/**/*.py` | Mixins, AdminHTMLUtils, get_*_link, URL `/` |
| `backend-signals-naming.mdc` | `backend/**/*.py` | Nommage signals |
| `backend-tests-naming.mdc` | `backend/**/tests/*.py` | Nommage, factory_boy |
| `backend-graphql-auth.mdc` | `backend/**/*.py` | Auth deux niveaux, décorateurs, headers |
| `backend-settings-architecture.mdc` | `backend/config/**/*.py` | ENV vs ENVIRONMENT, URLs conditionnelles, multi-container |

---

## Règles générales (toujours actives)

### Langue
- Réponses à l'utilisateur : **français**
- Tout le code : **anglais** — commentaires, docstrings, `verbose_name`, `help_text`, noms de variables/fonctions/classes

### Commits
Ne jamais committer sans permission explicite de l'utilisateur.

```
✅ Déclenche un commit : "commit", "fais un commit", "pousse ça"
❌ Ne déclenche PAS : "prends des actifs", "sauvegarde", "backup", "c'est bon"
```

### Git — stratégie de branches

```
dev       ← travail quotidien
staging   ← merge depuis dev
main      ← PR depuis staging uniquement
```

```bash
# Déployer sur staging
git fetch origin && git checkout staging && git merge origin/dev --no-edit \
  && git push origin staging && git checkout dev
```

Jamais de `git push --force` sur `main`.

---

## flake8 — validation obligatoire

Après chaque génération ou modification de code Python :

```bash
cd /app/code && flake8
```

Configuration `.flake8` à la racine du backend :
```ini
[flake8]
max-line-length = 88
extend-ignore = E203,W503,E501,F401,F841,F821,F403,F405
exclude =
    .git,
    __pycache__,
    .venv,
    venv,
    env,
    .env,
    migrations,
    staticfiles,
    media,
    volumes,
    project/graphql_documentation/docs/*_doc.py
```

Corriger toutes les erreurs avant de considérer la tâche terminée.

---

---

## L bis : Règles spécifiques aux modèles Django

### `related_name` obligatoire

Chaque `ForeignKey` et `ManyToManyField` doit avoir un `related_name`. Sans exception.

```python
# ✅ Correct
city = models.ForeignKey(City, on_delete=models.PROTECT, related_name='users')
members = models.ManyToManyField(User, related_name='run_groups')

# ❌ Interdit
city = models.ForeignKey(City, on_delete=models.PROTECT)
```

### `verbose_name` et `verbose_name_plural` obligatoires

Chaque modèle doit avoir les deux dans son `Meta`. Pluraliser tous les noms.

```python
class Meta:
    verbose_name = 'run date event'
    verbose_name_plural = 'run date events'
```

### Champs optionnels

```python
# null=True, blank=True par défaut pour les champs optionnels
bio = models.TextField(null=True, blank=True)
```

### Pas de nouveaux indexes sans permission

Ne pas ajouter d'index `db_index=True` ou `Meta.indexes` sans que l'utilisateur le demande explicitement. Conserver les indexes existants.

### Ordre des membres dans une classe Python

```python
class MyModel(BaseModel):
    # 1. Constantes / choices
    # 2. Champs
    # 3. class Meta
    # 4. __str__ et méthodes dunder
    # 5. @classmethod
    # 6. @staticmethod
    # 7. @property
    # 8. Méthodes publiques
    # 9. Méthodes privées (_method)
```

---

## A–D : Structure des fichiers

### Un modèle = un fichier

```
models/
  __init__.py         ← re-exporte tous les modèles
  user.py
  auth_token.py
  otp_verification.py
```

### Schéma GraphQL découpé par app

```
schema/
  __init__.py
  types.py            ← ObjectType Graphene
  queries.py          ← classe Query
  mutations.py        ← classes Mutation
```

### Resolvers = délégation uniquement

Les resolvers ne contiennent jamais de logique métier ni de requêtes DB directes. Ils appellent uniquement `selectors` ou `services`.

### Layout fixe de chaque app

```
<app>/
  models/       admin/      schema/
  management/commands/      tests/fixtures/
  signals.py    selectors.py    services.py    apps.py
```

---

## E : Nommage GraphQL

Format `<app><Model><Action>` camelCase. Voir [06-api-graphql.md](./06-api-graphql.md).

---

## F : Nommage management commands

Format `<app>_<model>_<action>` snake_case. Voir [07-management-commands.md](./07-management-commands.md).

---

## G : Nommage des signals

```python
# ✅ Correct — dans <app>/signals.py
events_event_confirmed = Signal()
accounts_userlike_mutual_detected = Signal()

# ❌ Interdit
event_confirmed = Signal()
on_like = Signal()
```

Les receivers sont connectés uniquement dans `AppConfig.ready()`.

---

## H, T, U : Tests

Nommage des fichiers de test :

```
test_<module>_<scenario>.py

# Exemples
test_events_event_register_success.py
test_accounts_otp_rate_limit_exceeded.py
```

Structure de classe :

```python
class TestEventsEventRegister:
    def test_success(self): ...
    def test_event_full(self): ...
    def test_unauthenticated(self): ...
```

**Factories** (`factory_boy`) — jamais de fixtures JSON Django dans les tests :

```python
# tests/fixtures/event_factory.py
import factory
from apps.events.models import RunDateEvent

class RunDateEventFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = RunDateEvent
    neighborhood = factory.SubFactory(NeighborhoodFactory)
    pace_label = 'renardRuse'
```

---

## I : Selectors et Services

```python
# selectors.py — lecture uniquement, préfixe get_ / list_ / count_
def list_events(city=None, limit=20, offset=0):
    qs = RunDateEvent.active.select_related('city', 'neighborhood', 'meeting_point', 'lievre')
    if city:
        qs = qs.filter(city__name=city)
    return qs[offset:offset + limit]

# services.py — écriture uniquement, préfixe create_ / update_ / cancel_ / send_
def register_user_to_event(user, event_id):
    event = RunDateEvent.active.get(id=event_id)
    if event.is_full:
        raise EventFullError("Event is at maximum capacity")
    # ...
```

---

## J : Erreurs GraphQL

Toutes les mutations retournent un Payload (`status`, `errors` en dict JSON, champ ressource). Jamais d'exception brute pour les erreurs métier. Détail : [06-api-graphql.md](./06-api-graphql.md).

```python
# from apps.i18n.utils import translate
# ✅ Correct — patron Payload : status + errors (JSON dict) + ressource (voir 06-api-graphql.md)
class EventsEventRegisterMutation(graphene.Mutation):
    class Arguments:
        event_id = graphene.ID(required=True)

    status = graphene.Boolean()
    errors = graphene.JSONString()  # {} si succès ; {"event": "…"} si échec
    registration = graphene.Field(EventRegistrationType)

    def mutate(root, info, event_id, language):
        try:
            reg = services.register_user_to_event(info.context.user, event_id)
            return EventsEventRegisterMutation(status=True, errors={}, registration=reg)
        except EventFullError:
            return EventsEventRegisterMutation(
                status=False,
                errors={"event": translate("errors", "event_full", language)},
                registration=None,
            )

# ❌ Interdit
def mutate(root, info, event_id):
    raise GraphQLError("Event is full")
```

---

## K : Soft delete

```python
class SoftDeleteMixin(models.Model):
    is_deleted = models.BooleanField(default=False)
    deleted_at = models.DateTimeField(null=True)

    class Meta:
        abstract = True

    def soft_delete(self):
        self.is_deleted = True
        self.deleted_at = now()
        self.save(update_fields=['is_deleted', 'deleted_at'])

class ActiveManager(models.Manager):
    def get_queryset(self):
        return super().get_queryset().filter(is_deleted=False)
```

Modèles concernés : `User`, `RunDateEvent`.

```python
# ✅ Correct — utiliser le manager actif
RunDateEvent.active.all()

# ❌ Interdit sur les modèles soft-delete
RunDateEvent.objects.all()
```

`is_suspended` (User) ≠ soft delete — ce sont deux états distincts.

---

## L : BaseModel

```python
class BaseModel(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        abstract = True
```

Tous les modèles héritent de `BaseModel`. Jamais d'`AutoField`.

---

## M, N : Migrations et indexes

```bash
# ✅ Correct — toujours nommer les migrations
python manage.py makemigrations --name create_user_model
python manage.py makemigrations --name add_is_deleted_to_event

# ❌ Interdit — noms auto
# → 0001_auto_20260323_1200.py
```

Tout champ utilisé dans un filtre GraphQL doit avoir `db_index=True` :

```python
city = models.ForeignKey(City, db_index=True)
date = models.DateTimeField(db_index=True)
```

---

## O, P : Admin Django

Un fichier par modèle dans `admin/`. Chaque `ModelAdmin` doit définir au minimum :

```python
@admin.register(RunDateEvent)
class RunDateEventAdmin(admin.ModelAdmin):
    list_display = ['id', 'city', 'neighborhood', 'date', 'is_confirmed', 'is_deleted']
    list_filter = ['city', 'is_confirmed', 'pace_label', 'is_deleted']
    search_fields = ['neighborhood__name', 'city__name']
    readonly_fields = ['id', 'created_at', 'updated_at']
```

---

## Q, R, S : Qualité de code

### Langue
Tous les commentaires et docstrings en **anglais**.

### Logging structuré

```python
import logging
logger = logging.getLogger(__name__)

# ✅ Correct
logger.info("event_confirmed", extra={"event_id": str(event.id)})
logger.error("otp_send_failed", extra={"phone": phone, "error": str(e)})

# ❌ Interdit
print("Event confirmed:", event.id)
```

### Ordre des imports (isort)

```python
# 1. stdlib
import time
import logging

# 2. django
from django.db import models
from django.utils.timezone import now

# 3. third-party
import graphene
from twilio.rest import Client

# 4. local
from apps.events.models import RunDateEvent
from apps.events.services import register_user_to_event
```

---

## N+1 queries — règle obligatoire

Tout resolver accédant à des relations doit utiliser `select_related` ou `prefetch_related` :

```python
# ✅ Correct
def resolve_events_event_list(root, info, city=None, limit=20, offset=0):
    return selectors.list_events(city=city, limit=limit, offset=offset)

# Dans selectors.py :
def list_events(city=None, limit=20, offset=0):
    return RunDateEvent.active.select_related(
        'city', 'neighborhood', 'meeting_point', 'lievre'
    ).prefetch_related('registrations__user')[offset:offset + limit]

# ❌ Interdit dans un resolver
def resolve_events_event_list(root, info):
    return RunDateEvent.objects.all()  # N+1 garanti
```
