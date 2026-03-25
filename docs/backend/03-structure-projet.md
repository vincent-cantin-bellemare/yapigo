# 03 — Structure du projet

## Arborescence complète

```
backend/
  apps/
    accounts/           # Auth, User, AuthToken, OtpVerification, UserLike
    events/             # RunDateEvent, MeetingPoint, EventRegistration, RunGroup
    messaging/          # Conversation, Message, MessageRead
    notifications/      # AppNotification, FCM dispatch
    community/          # EventPhoto, WaitingQuestion, VerificationSlot
    geography/          # City, Neighborhood (données de référence)
    devtools/           # Commandes GraphQL CLI pour tester l'API
    monitoring/         # HttpRequestLog — journalisation de toutes les requêtes HTTP
    i18n/               # Système de traductions JSON custom (fr/en)
  config/
    settings/
      __init__.py
      base.py                # settings communs (INSTALLED_APPS, MIDDLEWARE…)
      env_settings.py        # constantes ENV_ADMIN, ENV_GRAPHQL, ENV = None
      security_settings.py   # HTTPS/HSTS/cookies selon ENVIRONMENT
      database_settings.py   # DATABASE_URL parsing
      cors_settings.py       # CORS_ALLOW_HEADERS par environnement
      graphql_settings.py    # GRAPHENE, depth limits, introspection
    settings_admin.py        # from base import * + ENV = ENV_ADMIN
    settings_graphql.py      # from base import * + ENV = ENV_GRAPHQL
    urls.py                  # routage conditionnel selon settings.ENV
                             # admin monté à / sur admin.rundate.app
    schema.py                # Root Graphene schema (assemble toutes les apps)
    asgi.py
    wsgi.py
  scripts/
    backup.sh           # pg_dump + rclone → Google Drive (côté serveur)
    sync_db.py          # copie une DB distante → dev local (via SSH/SCP + Tailscale)
    smoke_test.sh       # Smoke test GraphQL post-déploiement
    crontab.example     # Crontab à installer sur le host Proxmox
  fixtures/             # Données de référence (JSON Django fixtures)
    seed_cities.json
    seed_neighborhoods.json
    seed_meeting_points.json
    seed_waiting_questions.json
  seeds/                # Scripts de seeding custom (management commands)
    seed_fake_users.py
    seed_events.py
  .devcontainer/
    devcontainer.json
  docker/
    nginx/
      dev.conf
      staging.conf
      production.conf
    Dockerfile
    Dockerfile.workers
  .env.example          # Template committé, sans secrets
  .env.dev              # Non committé (dans .gitignore)
  .env.staging          # Non committé
  .env.production       # Non committé
  docker-compose.dev.yml
  docker-compose.staging.yml
  docker-compose.production.yml
  Makefile
  manage.py
  requirements/
    base.txt
    dev.txt
    production.txt
```

## Structure interne de chaque app

Toutes les apps suivent le même layout. Exemple avec `events` :

```
events/
  models/
    __init__.py             # re-exporte RunDateEvent, MeetingPoint, etc.
    run_date_event.py
    meeting_point.py
    event_registration.py
    run_group.py
  schema/
    __init__.py
    types.py                # Graphene ObjectType pour chaque modèle
    queries.py              # Query class (eventsEventList, eventsEventDetail…)
    mutations.py            # Mutations (eventsEventRegister, eventsEventRate…)
  admin/
    __init__.py
    run_date_event_admin.py
    meeting_point_admin.py
    event_registration_admin.py
  management/
    commands/
      events_event_check_threshold.py
      events_event_cancel_no_quorum.py
      events_registration_promote_waitlist.py
  tests/
    test_schema_queries.py
    test_schema_mutations.py
    test_services.py
    test_selectors.py
    fixtures/
      event_factory.py
      registration_factory.py
  signals.py
  selectors.py              # Lecture DB : list_events(), get_event()…
  services.py               # Écriture : register_user(), cancel_registration()…
  apps.py
```

## Schéma partagé avec Flutter

```
rundate/                    ← racine du monorepo
  shared/
    schema/
      schema.graphql        # Committé, généré par make export-schema
  apps/
    mobile/
  backend/
  docs/
```

## Root schema GraphQL

`config/schema.py` assemble les schemas de toutes les apps :

```python
import graphene
from apps.accounts.schema.queries import AccountsQuery
from apps.accounts.schema.mutations import AccountsMutation
from apps.events.schema.queries import EventsQuery
from apps.events.schema.mutations import EventsMutation
from apps.messaging.schema.queries import MessagingQuery
from apps.messaging.schema.mutations import MessagingMutation
from apps.notifications.schema.queries import NotificationsQuery
from apps.notifications.schema.mutations import NotificationsMutation

class Query(AccountsQuery, EventsQuery, MessagingQuery, NotificationsQuery, graphene.ObjectType):
    pass

class Mutation(AccountsMutation, EventsMutation, MessagingMutation, NotificationsMutation, graphene.ObjectType):
    pass

schema = graphene.Schema(query=Query, mutation=Mutation)
```
