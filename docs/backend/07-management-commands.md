# 07 — Management commands (workers)

## Concept

Les tâches récurrentes tournent dans le container `workers` (même image que `django`) via des management commands Django en **boucle infinie**. Pas de Celery, pas de Redis.

## Convention de nommage

```
<app>_<model>_<action>   (snake_case)
```

Le fichier `.py` = le nom de la commande = `python manage.py <app>_<model>_<action>`.

## Structure obligatoire

```python
import time
import logging
from django.core.management.base import BaseCommand

logger = logging.getLogger(__name__)

class Command(BaseCommand):
    help = 'Description de la commande'

    def handle(self, *args, **options):
        logger.info("command_started", extra={"command": "events_event_check_threshold"})
        while True:
            try:
                self._run()
            except Exception as e:
                logger.error("command_error", extra={"error": str(e)})
            time.sleep(300)  # 5 minutes

    def _run(self):
        # logique métier ici
        pass
```

Règles :
- Boucle infinie avec `time.sleep(N)` — jamais de crash du process
- `try/except` à l'intérieur de la boucle (pas autour)
- Logging structuré avec `extra={}` — jamais `print()`
- Logique métier dans `services.py` — la commande appelle seulement `services.xxx()`

---

## Liste des commandes

### App `events`

#### `events_event_check_threshold`
- **Fréquence** : toutes les 5 minutes
- **Rôle** : trouve les `RunDateEvent` où `total_registered >= min_threshold` et `is_confirmed=False`, les confirme et crée les notifications `thresholdReached`
- **Fichier** : `apps/events/management/commands/events_event_check_threshold.py`

#### `events_event_cancel_no_quorum`
- **Fréquence** : toutes les 10 minutes
- **Rôle** : trouve les events dont la `deadline` est passée, `is_confirmed=False` → annule et crée les notifications `eventCancelledNoQuorum`
- **Fichier** : `apps/events/management/commands/events_event_cancel_no_quorum.py`

#### `events_registration_promote_waitlist`
- **Fréquence** : toutes les 5 minutes
- **Rôle** : si une place se libère dans un event confirmé, promeut le premier de la liste d'attente → crée notification `spotFreed`
- **Fichier** : `apps/events/management/commands/events_registration_promote_waitlist.py`

### App `notifications`

#### `notifications_notification_send_deadline_reminder`
- **Fréquence** : toutes les 30 minutes
- **Rôle** : envoie des rappels aux inscrits 24h et 6h avant la deadline d'un event
- **Fichier** : `apps/notifications/management/commands/notifications_notification_send_deadline_reminder.py`

#### `notifications_notification_send_today_reminder`
- **Fréquence** : toutes les 30 minutes
- **Rôle** : le matin du run (entre 7h et 8h), envoie `runToday` aux participants confirmés
- **Fichier** : `apps/notifications/management/commands/notifications_notification_send_today_reminder.py`

#### `notifications_notification_send_rating_reminder`
- **Fréquence** : toutes les heures
- **Rôle** : J+1 après un run passé, envoie `rateReminder` aux participants qui n'ont pas encore noté
- **Fichier** : `apps/notifications/management/commands/notifications_notification_send_rating_reminder.py`

### App `monitoring`

#### `monitoring_httprequestlog_purge`
- **Fréquence** : toutes les 24 heures
- **Rôle** : supprime les `HttpRequestLog` plus vieux que `HTTP_LOG_RETENTION_DAYS` (défaut : 30 jours). Suppression en batch pour éviter les locks prolongés.
- **Fichier** : `apps/monitoring/management/commands/monitoring_httprequestlog_purge.py`

### App `accounts`

#### `accounts_authtoken_cleanup`
- **Fréquence** : toutes les 24 heures
- **Rôle** : supprime les `AuthToken` dont `last_used_at` est plus vieux que `TOKEN_EXPIRY_DAYS`
- **Fichier** : `apps/accounts/management/commands/accounts_authtoken_cleanup.py`

#### `accounts_userlike_check_mutual`
- **Fréquence** : toutes les 5 minutes
- **Rôle** : filet de sécurité — vérifie les likes mutuels non encore notifiés (si le signal a raté)
- **Fichier** : `apps/accounts/management/commands/accounts_userlike_check_mutual.py`

---

## Container `workers`

Dans `docker-compose.*.yml`, le service `workers` lance toutes les commandes en parallèle via `supervisord` ou un script de démarrage :

```bash
# docker/start_workers.sh
python manage.py events_event_check_threshold &
python manage.py events_event_cancel_no_quorum &
python manage.py events_registration_promote_waitlist &
python manage.py notifications_notification_send_deadline_reminder &
python manage.py notifications_notification_send_today_reminder &
python manage.py notifications_notification_send_rating_reminder &
python manage.py accounts_authtoken_cleanup &
python manage.py accounts_userlike_check_mutual &
python manage.py monitoring_httprequestlog_purge &
wait
```

---

## Makefile

```bash
make workers-dev       # voir les logs du container workers
make restart-workers   # redémarrer le container workers
```
