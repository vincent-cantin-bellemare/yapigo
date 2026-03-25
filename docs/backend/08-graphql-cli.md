# 08 — GraphQL CLI (devtools)

## Concept

L'app `devtools` contient des management commands qui exécutent des opérations GraphQL réelles depuis le terminal. Elles permettent de :

- Tester chaque query/mutation sans client externe (Postman, Flutter)
- Vérifier le flow auth de bout en bout
- Intégrer dans un smoke test post-déploiement
- Déboguer rapidement en staging ou production

## Convention de nommage

```
graphql_<app>_<model>_<action>   (snake_case)
```

Le préfixe `graphql_` distingue ces commandes des commandes workers.

## Client partagé

Toutes les commandes utilisent `devtools/utils/graphql_client.py` :

```python
from django.test import Client
import json

def run_query(query: str, variables: dict = None, token: str = None) -> dict:
    """Execute a GraphQL operation against the local endpoint."""
    client = Client()
    headers = {}
    if token:
        headers['HTTP_AUTHORIZATION'] = f'Bearer {token}'
    response = client.post(
        '/graphql/',
        data=json.dumps({'query': query, 'variables': variables or {}}),
        content_type='application/json',
        **headers
    )
    return response.json()
```

Appel via `django.test.Client` : pas de port ouvert requis, fonctionne directement dans le container.

## Arguments communs

Toutes les commandes acceptent :

| Argument | Description |
|---|---|
| `--token` | Token Bearer pour les opérations authentifiées |
| `--raw` | Affiche le JSON brut sans formatage |
| `--verbose` | Affiche la query GraphQL envoyée |

## Liste des commandes

### `accounts`

```bash
# Demander un code OTP
python manage.py graphql_accounts_user_request_otp --phone "+15145550010"
# → { ok: true }

# Vérifier le code OTP → retourne le token
python manage.py graphql_accounts_user_verify_otp --phone "+15145550010" --code "123456"
# → token: abc123... (affiché dans le terminal, à copier)

# Profil de l'utilisateur connecté
python manage.py graphql_accounts_user_me --token "abc123..."
# → Sophie Tremblay | badge: Habitué | XP: 420 | buddy: LAPINO-QUEEN

# Mise à jour du profil
python manage.py graphql_accounts_user_update_profile --token "abc123..." --bio "Nouvelle bio"

# Lier un ami via buddy code
python manage.py graphql_accounts_buddy_code_link --token "abc123..." --code "ORIGNAL-TURBO"
```

### `events`

```bash
# Liste des événements
python manage.py graphql_events_event_list --token "abc123..." --city "Montréal" --limit 5
# → tableau formaté : ID | Date | Quartier | Allure | Inscrits

# Détail d'un événement
python manage.py graphql_events_event_detail --token "abc123..." --event-id "uuid-here"

# S'inscrire à un événement
python manage.py graphql_events_event_register --token "abc123..." --event-id "uuid-here"
# → { ok: true, status: "confirmed" }

# Annuler une inscription
python manage.py graphql_events_event_cancel_registration --token "abc123..." --event-id "uuid-here"

# Noter un événement
python manage.py graphql_events_event_rate --token "abc123..." --event-id "uuid-here" --rating 4.5

# Points de rencontre
python manage.py graphql_events_meeting_point_list
```

### `messaging`

```bash
# Liste des conversations
python manage.py graphql_messaging_conversation_list --token "abc123..."

# Envoyer un message
python manage.py graphql_messaging_message_send --token "abc123..." \
    --conversation-id "uuid-here" --content "Salut le groupe!"

# Marquer comme lu
python manage.py graphql_messaging_message_mark_conversation_read \
    --token "abc123..." --conversation-id "uuid-here"
```

### `notifications`

```bash
# Liste des notifications
python manage.py graphql_notifications_notification_list --token "abc123..." --unread-only

# Marquer toutes comme lues
python manage.py graphql_notifications_notification_mark_all_read --token "abc123..."
```

### `devtools`

```bash
# Exporter le schéma GraphQL
python manage.py graphql_devtools_schema_export
# → génère shared/schema/schema.graphql
```

---

## Smoke test post-déploiement

`scripts/smoke_test.sh` enchaîne les commandes clés :

```bash
#!/bin/bash
set -e
echo "=== Smoke test RunDate ==="

python manage.py graphql_accounts_user_request_otp --phone "$TEST_PHONE"
read -p "Code OTP reçu par SMS : " OTP_CODE

TOKEN=$(python manage.py graphql_accounts_user_verify_otp \
    --phone "$TEST_PHONE" --code "$OTP_CODE" --extract-token)

python manage.py graphql_accounts_user_me --token "$TOKEN"
python manage.py graphql_events_event_list --token "$TOKEN" --city "Montréal" --limit 3
python manage.py graphql_notifications_notification_list --token "$TOKEN"

echo "=== Smoke test OK ==="
```

## Makefile

```bash
make smoke-test-dev      # lance smoke_test.sh dans le container dev
make smoke-test-staging  # lance smoke_test.sh dans le container staging
```

## Emplacement dans le dépôt

```
apps/devtools/
  management/
    commands/
      graphql_accounts_user_request_otp.py
      graphql_accounts_user_verify_otp.py
      graphql_accounts_user_me.py
      graphql_accounts_user_update_profile.py
      graphql_accounts_buddy_code_link.py
      graphql_events_event_list.py
      graphql_events_event_detail.py
      graphql_events_event_register.py
      graphql_events_event_cancel_registration.py
      graphql_events_event_rate.py
      graphql_events_meeting_point_list.py
      graphql_messaging_conversation_list.py
      graphql_messaging_message_send.py
      graphql_messaging_message_mark_conversation_read.py
      graphql_notifications_notification_list.py
      graphql_notifications_notification_mark_all_read.py
      graphql_devtools_schema_export.py
  utils/
    graphql_client.py
  apps.py
```
