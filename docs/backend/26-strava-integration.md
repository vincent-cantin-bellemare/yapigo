# 26 — Intégration Strava

Connexion OAuth 2.0 avec Strava pour afficher les statistiques de course des membres sur leur profil RunDate.

**Objectif** : permettre aux membres de connecter volontairement leur compte Strava afin d'afficher des stats (km/an, sorties, allure) sur leur profil. Aucune revente de données — usage strictement interne et affiché à l'utilisateur lui-même et aux autres membres.

---

## Modèle de données

Voir `04-modeles-django.md` — section `StravaConnection`.

App Django : `accounts`.
Migration : `accounts/migrations/000X_add_strava_connection.py`

---

## OAuth 2.0 Flow

Strava utilise le standard OAuth 2.0 (Authorization Code Flow).

```
Flutter              Django backend           Strava API
  │                       │                       │
  │── GET /auth/strava/ ──▶│                       │
  │                       │── redirect ──────────▶│
  │                       │            (authorize) │
  │◀── 302 strava.com ────│                       │
  │                       │                       │
  │    [user approves]    │                       │
  │                       │◀── callback?code=X ───│
  │                       │── token exchange ────▶│
  │                       │◀── access+refresh ────│
  │                       │── save StravaConn. ───│
  │◀── 200 { connected } ─│                       │
```

### Endpoints Django

| Méthode | URL | Description |
|---|---|---|
| `GET` | `/auth/strava/` | Génère l'URL d'autorisation Strava et redirige |
| `GET` | `/auth/strava/callback/` | Reçoit le code OAuth, échange contre token, sauvegarde |
| `DELETE` | `/auth/strava/disconnect/` | Supprime le `StravaConnection` de l'utilisateur |

### Paramètres Strava

```python
STRAVA_CLIENT_ID     = env("STRAVA_CLIENT_ID")
STRAVA_CLIENT_SECRET = env("STRAVA_CLIENT_SECRET")
STRAVA_REDIRECT_URI  = "https://api.rundate.app/auth/strava/callback/"

STRAVA_AUTH_URL    = "https://www.strava.com/oauth/authorize"
STRAVA_TOKEN_URL   = "https://www.strava.com/oauth/token"
STRAVA_SCOPES      = "activity:read,profile:read_all"
```

### Renouvellement du token

Les access tokens Strava expirent après **6 heures**. Le renouvellement est automatique :

```python
def get_valid_token(strava_conn: StravaConnection) -> str:
    if now() >= strava_conn.token_expires_at - timedelta(minutes=5):
        resp = requests.post(STRAVA_TOKEN_URL, data={
            "client_id": settings.STRAVA_CLIENT_ID,
            "client_secret": settings.STRAVA_CLIENT_SECRET,
            "grant_type": "refresh_token",
            "refresh_token": strava_conn.refresh_token,
        })
        data = resp.json()
        strava_conn.access_token = data["access_token"]
        strava_conn.refresh_token = data["refresh_token"]
        strava_conn.token_expires_at = datetime.fromtimestamp(
            data["expires_at"], tz=timezone.utc
        )
        strava_conn.save(update_fields=[
            "access_token", "refresh_token", "token_expires_at"
        ])
    return strava_conn.access_token
```

---

## Endpoints Strava utilisés

| Endpoint | Données récupérées |
|---|---|
| `GET /athlete` | `ytd_run_totals` (km, count), `all_run_totals` |
| `GET /athletes/{id}/stats` | `ytd_run_totals`, `recent_run_totals` (mois glissant) |
| `GET /athlete/activities?per_page=90` | Calcul allure moyenne sur 90 derniers jours |

### Calcul `avg_pace_seconds`

```python
def compute_avg_pace(activities: list[dict]) -> int | None:
    runs = [a for a in activities if a["type"] == "Run" and a["distance"] > 0]
    if not runs:
        return None
    total_seconds = sum(a["moving_time"] for a in runs)
    total_meters = sum(a["distance"] for a in runs)
    return int((total_seconds / total_meters) * 1000)  # sec/km
```

---

## Synchronisation Celery

Une tâche périodique resynchronise les stats de tous les comptes connectés, une fois par jour.

```python
# accounts/tasks.py
@shared_task(name="strava_sync_all_users")
def strava_sync_all_users():
    for conn in StravaConnection.objects.select_related("user").all():
        try:
            strava_sync_user.delay(conn.user_id)
        except Exception as e:
            logger.warning("strava_sync_skip", extra={"user": conn.user_id, "error": str(e)})

@shared_task(name="strava_sync_user")
def strava_sync_user(user_id: int):
    conn = StravaConnection.objects.get(user_id=user_id)
    token = get_valid_token(conn)
    headers = {"Authorization": f"Bearer {token}"}

    stats = requests.get(
        f"https://www.strava.com/api/v3/athletes/{conn.strava_athlete_id}/stats",
        headers=headers,
    ).json()
    activities = requests.get(
        "https://www.strava.com/api/v3/athlete/activities",
        headers=headers,
        params={"per_page": 90},
    ).json()

    conn.ytd_km = stats["ytd_run_totals"]["distance"] / 1000
    conn.ytd_runs = stats["ytd_run_totals"]["count"]
    conn.month_km = stats["recent_run_totals"]["distance"] / 1000
    conn.avg_pace_seconds = compute_avg_pace(activities)
    conn.last_synced_at = now()
    conn.save()
```

**Celery Beat schedule** (settings) :

```python
CELERY_BEAT_SCHEDULE = {
    "strava-daily-sync": {
        "task": "strava_sync_all_users",
        "schedule": crontab(hour=4, minute=0),  # 4h AM chaque nuit
    },
}
```

---

## GraphQL

### Type `StravaStats`

```graphql
type StravaStats {
  ytdKm:           Float
  ytdRuns:         Int
  monthKm:         Float
  avgPaceSeconds:  Int
  avgPaceFormatted: String   # "M:SS /km" — calculé côté backend
  lastSyncedAt:    DateTime
}
```

### Champ sur `User`

```graphql
type User {
  # ... champs existants ...
  stravaConnected: Boolean!
  stravaStats:     StravaStats  # null si non connecté
}
```

### Query example

```graphql
query {
  accountsUserDetail(id: "u1") {
    firstName
    stravaConnected
    stravaStats {
      ytdKm
      ytdRuns
      monthKm
      avgPaceFormatted
    }
  }
}
```

---

## Politique de données (LPRPDE / Loi 25)

| Règle | Implémentation |
|---|---|
| Consentement explicite | L'utilisateur lance lui-même le flux OAuth depuis son profil |
| Finalité limitée | Stats affichées uniquement sur RunDate — aucune revente, aucun partage tiers |
| Droit à l'effacement | `StravaConnection` supprimé en cascade à la suppression du compte (`on_delete=CASCADE`) |
| Déconnexion à la demande | `DELETE /auth/strava/disconnect/` disponible à tout moment depuis le profil |
| Minimisation des données | Seules les stats agrégées sont stockées — pas de tracé GPS, pas d'activité détaillée |
| Sécurité des tokens | Tokens chiffrés en DB via `django-encrypted-fields` |

---

## Variables d'environnement requises

```bash
STRAVA_CLIENT_ID=<id de l'app Strava>
STRAVA_CLIENT_SECRET=<secret de l'app Strava>
```

À ajouter dans `.env.staging` et `.env.production`. Voir `09-environnements.md`.

---

## Sécurité tokens Strava côté Flutter

Le flux OAuth se fait entièrement côté backend — **Flutter ne voit jamais les tokens Strava**. Le mobile lance simplement une URL vers `https://api.rundate.app/auth/strava/` via `url_launcher` (en production), puis interroge `stravaStats` via GraphQL une fois la connexion établie.

---

## Limites de taux Strava

| Limite | Valeur |
|---|---|
| Requêtes par 15 min | 100 |
| Requêtes par jour | 1 000 |

Avec la sync quotidienne (1 appel `/stats` + 1 appel `/activities` par user), la limite de 1 000/jour supporte jusqu'à ~500 membres connectés à Strava. Au-delà, échelonner la tâche Celery sur plusieurs heures.
