# 09 — Environnements & Docker

## Deux axes à ne pas confondre

| Variable | Valeurs | Rôle |
|---|---|---|
| `ENVIRONMENT` | `dev`, `staging`, `production`, `test` | L'environnement de déploiement |
| `ENV` | `None`, `"admin"`, `"graphql"` | Le rôle du processus Django |

Voir [16-settings-multi-env.md](./16-settings-multi-env.md) pour le détail complet.

## Trois environnements de déploiement

| Environnement | Fichier Compose | Fichier .env | URL API | URL Admin |
|---|---|---|---|---|
| Dev | `docker-compose.dev.yml` | `.env.dev` | `localhost:8000/graphql/` | `localhost:8000/` |
| Staging | `docker-compose.staging.yml` | `.env.staging` | `api.staging.rundate.app` | `admin.staging.rundate.app` |
| Production | `docker-compose.production.yml` | `.env.production` | `api.rundate.app` | `admin.rundate.app` |

## Containers par environnement

### Dev — un seul container Django (`ENV=None`)

```yaml
services:
  django:     # ENV=None → admin + GraphQL + graphiql dans un seul processus
  postgres:
  nginx:
  workers:
```

### Staging / Production — un container par rôle

```yaml
services:
  app-admin:    # DJANGO_SETTINGS_MODULE=config.settings_admin   (ENV="admin")
  app-graphql:  # DJANGO_SETTINGS_MODULE=config.settings_graphql (ENV="graphql")
  app-idle:     # sleep infinity — pour make shell / migrate
  postgres:
  nginx:
  workers:      # management commands en boucle
```

## Fichiers `.env`

Les fichiers `.env.*` réels sont dans `.gitignore`. Seul `.env.example` est committé.

### `.env.example`

```env
# Django
DJANGO_SETTINGS_MODULE=config.settings.production
SECRET_KEY=your-secret-key-here
DEBUG=False
ALLOWED_HOSTS=api.rundate.app

# Database
DATABASE_URL=postgres://rundate:password@postgres:5432/rundate

# Twilio
TWILIO_ACCOUNT_SID=
TWILIO_AUTH_TOKEN=
TWILIO_VERIFY_SERVICE_SID=

# Firebase
FIREBASE_CREDENTIALS_PATH=/app/secrets/firebase.json

# Media
MEDIA_ROOT=/volumes/app/media
MEDIA_URL=https://api.rundate.app/media/

# Auth — ApplicationAccess (Basic Auth)
# Add application credentials via Django admin, not via .env

# UserAccessToken expiry
TOKEN_EXPIRY_DAYS=90

# Rate limiting
RATE_LIMIT_REQUESTS=100
RATE_LIMIT_WINDOW_SECONDS=60

# GraphQL
MAX_QUERY_DEPTH=7
GRAPHIQL_ENABLED=False

# Anthropic — Claude AI (bio generation)
ANTHROPIC_API_KEY=
ANTHROPIC_MODEL=claude-sonnet-4-6
```

### Différences par environnement

| Variable | Dev | Staging | Production |
|---|---|---|---|
| `DEBUG` | `True` | `False` | `False` |
| `GRAPHIQL_ENABLED` | `True` | `True` | `False` |
| `ALLOWED_HOSTS` | `*` | `api.staging.rundate.app` | `api.rundate.app` |
| `DJANGO_SETTINGS_MODULE` | `config.settings.dev` | `config.settings.staging` | `config.settings.production` |

## Containers Docker

| Service | Image | Rôle |
|---|---|---|
| `django` | build local | Gunicorn + app Django |
| `postgres` | `postgres:latest` | Base de données |
| `nginx` | `nginx:alpine` | Reverse proxy, static files, médias |
| `workers` | build local (même image) | Management commands en boucle infinie |

## Volumes

Tous les volumes persistants sont montés depuis `/volumes/app/` sur la VM Ubuntu :

```
/volumes/app/
  media/      ← photos profil, galerie, photos d'événements
  postgres/   ← données PostgreSQL (bind mount)
  backups/    ← pg_dump compressés avant envoi Google Drive
```

Extrait `docker-compose.production.yml` :

```yaml
volumes:
  postgres_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /volumes/app/postgres

services:
  django:
    build: .
    env_file: .env.production
    volumes:
      - /volumes/app/media:/app/media
    depends_on:
      - postgres

  postgres:
    image: postgres:latest
    env_file: .env.production
    volumes:
      - postgres_data:/var/lib/postgresql/data

  nginx:
    image: nginx:alpine
    volumes:
      - ./docker/nginx/production.conf:/etc/nginx/conf.d/default.conf
      - /volumes/app/media:/app/media:ro
    ports:
      - "443:443"
    depends_on:
      - django

  workers:
    build: .
    env_file: .env.production
    command: bash docker/start_workers.sh
    depends_on:
      - postgres
```

## Dev — spécificités

```yaml
# docker-compose.dev.yml (extrait)
services:
  django:
    command: python manage.py runserver 0.0.0.0:8000
    volumes:
      - .:/app           # live reload du code
    ports:
      - "8000:8000"
    environment:
      DJANGO_SETTINGS_MODULE: config.settings.dev
```

- Code source monté en volume → live reload
- Port 8000 exposé directement (pas de Cloudflare)
- GraphiQL activé sur `http://localhost:8000/graphql/`

## DevContainer

Fichier : `backend/.devcontainer/devcontainer.json`

```json
{
    "name": "RunDate Dev Container",
    "dockerComposeFile": ["../docker-compose.dev.yml"],
    "service": "django",
    "workspaceFolder": "/app/code",
    "customizations": {
        "vscode": {
            "settings": {
                "python.defaultInterpreterPath": "/usr/local/bin/python",
                "python.linting.pylintEnabled": true,
                "python.linting.enabled": true,
                "python.formatting.provider": "black",
                "editor.formatOnSave": true,
                "[python]": {
                    "editor.defaultFormatter": "ms-python.black-formatter"
                }
            },
            "extensions": [
                "ms-python.python",
                "ms-python.vscode-pylance",
                "ms-python.black-formatter",
                "visualstudioexptteam.vscodeintellicode",
                "eamodio.gitlens",
                "shardulm94.trailing-spaces",
                "batisteo.vscode-django",
                "rangav.vscode-thunder-client"
            ]
        }
    },
    "forwardPorts": [8000, 5432],
    "postCreateCommand": "cd /app/code && make migrate-dev && make seed-dev",
    "features": {}
}
```

| Champ | Valeur | Notes |
|---|---|---|
| `service` | `django` | Nom du service dans `docker-compose.dev.yml` |
| `workspaceFolder` | `/app/code` | Code Django monté ici dans le container |
| `forwardPorts` | `8000`, `5432` | Django + PostgreSQL |
| `postCreateCommand` | `make migrate-dev && make seed-dev` | Migrations + données de départ automatiques |

Extensions installées :

| Extension | Rôle |
|---|---|
| `ms-python.python` | Support Python de base |
| `ms-python.vscode-pylance` | IntelliSense avancé |
| `ms-python.black-formatter` | Formatage Black + format on save |
| `visualstudioexptteam.vscodeintellicode` | Suggestions IA |
| `eamodio.gitlens` | Git avancé |
| `shardulm94.trailing-spaces` | Détecte les espaces trailing |
| `batisteo.vscode-django` | Snippets et syntaxe Django |
| `rangav.vscode-thunder-client` | Test des requêtes GraphQL depuis VS Code |

Ajouter `black` dans `requirements/dev.txt` :

```
-r base.txt
django-debug-toolbar
factory-boy
black
```

## Makefile complet

```makefile
# Dev
start-dev:
    docker compose -f docker-compose.dev.yml up

stop-dev:
    docker compose -f docker-compose.dev.yml down

migrate-dev:
    docker compose -f docker-compose.dev.yml exec django python manage.py migrate

seed-dev:
    docker compose -f docker-compose.dev.yml exec django python manage.py seed_all

shell-dev:
    docker compose -f docker-compose.dev.yml exec django python manage.py shell

workers-dev:
    docker compose -f docker-compose.dev.yml logs -f workers

# Staging
start-staging:
    docker compose -f docker-compose.staging.yml up -d

stop-staging:
    docker compose -f docker-compose.staging.yml down

migrate-staging:
    docker compose -f docker-compose.staging.yml exec django python manage.py migrate

seed-staging:
    docker compose -f docker-compose.staging.yml exec django python manage.py seed_prod_base

smoke-test-staging:
    docker compose -f docker-compose.staging.yml exec django bash scripts/smoke_test.sh

# Production
start-production:
    docker compose -f docker-compose.production.yml up -d

stop-production:
    docker compose -f docker-compose.production.yml down

migrate-production:
    docker compose -f docker-compose.production.yml exec django python manage.py migrate

backup-production:
    ./scripts/backup.sh

logs-production:
    docker compose -f docker-compose.production.yml logs -f django

smoke-test-production:
    docker compose -f docker-compose.production.yml exec django bash scripts/smoke_test.sh

# Schema
export-schema:
    docker compose -f docker-compose.dev.yml exec django python manage.py graphql_devtools_schema_export
```
