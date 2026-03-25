# 16 — Settings et URLs multi-environnements

## Deux axes distincts

Ne pas confondre ces deux variables :

| Variable | Valeurs | Rôle |
|---|---|---|
| `ENVIRONMENT` | `dev`, `staging`, `production`, `test` | L'environnement de déploiement |
| `ENV` | `None`, `"admin"`, `"graphql"` | Le rôle du processus Django (quel service il expose) |

---

## Partie 1 — `ENV` : le rôle du processus

Défini dans `config/settings/env_settings.py` :

```python
# config/settings/env_settings.py
ENV_ADMIN = "admin"
ENV_GRAPHQL = "graphql"
ENV = None  # default = dev complet (admin + graphql dans un seul processus)
```

Trois fichiers de settings spécialisés, chacun d'une seule ligne utile :

```python
# config/settings_admin.py
from .settings.base import *
ENV = ENV_ADMIN       # → admin à / + GraphQL avec graphiql

# config/settings_graphql.py
from .settings.base import *
ENV = ENV_GRAPHQL     # → /graphql/ uniquement, sans graphiql, sans introspection
```

---

## Partie 2 — `urls.py` : routage conditionnel selon `ENV`

```python
# config/urls.py
from django.conf import settings

ENV = getattr(settings, 'ENV', None)
ENV_ADMIN = getattr(settings, 'ENV_ADMIN', 'admin')
ENV_GRAPHQL = getattr(settings, 'ENV_GRAPHQL', 'graphql')

# ─── Toujours présent ────────────────────────────────────────────────
urlpatterns = [
    path('health/', health_check),
    path('media/', serve_media),
    path('static/', serve_static),
]

# ─── ENV = None (dev local) ou ENV = "admin" (service admin) ─────────
if ENV is None or ENV == ENV_ADMIN:
    urlpatterns += [
        path('', admin.site.urls),              # admin à la racine
        path('graphql/', GraphQLView.as_view(
            graphiql=True,
            validation_rules=[MaxQueryDepthRule(12)],
        )),
    ]

# ─── ENV = "graphql" (service API public) ────────────────────────────
elif ENV == ENV_GRAPHQL:
    urlpatterns += [
        path('graphql/', GraphQLView.as_view(
            graphiql=False,
            validation_rules=[
                MaxQueryDepthRule(7),
                DisableIntrospectionRule(),   # introspection désactivée en prod
            ],
        )),
    ]
```

### Résumé par mode

| Mode | URL admin | URL GraphQL | graphiql | Introspection |
|---|---|---|---|---|
| `ENV=None` (dev) | `/` | `/graphql/` | ✅ | ✅ |
| `ENV="admin"` | `/` | `/graphql/` | ✅ | ✅ |
| `ENV="graphql"` | ✗ | `/graphql/` | ✗ | ✗ |

---

## Partie 3 — `ENVIRONMENT` : sécurité conditionnelle

`config/settings/security_settings.py` :

```python
# config/settings/security_settings.py
from django.core.exceptions import ImproperlyConfigured

ENVIRONMENT = os.environ.get('ENVIRONMENT')

ALLOWED_ENVIRONMENTS = ('dev', 'staging', 'production', 'test')
if ENVIRONMENT not in ALLOWED_ENVIRONMENTS:
    raise ImproperlyConfigured(
        f"ENVIRONMENT must be one of {ALLOWED_ENVIRONMENTS}, got: {ENVIRONMENT!r}"
    )

_IS_SECURE = ENVIRONMENT in ('production', 'staging')

SECURE_SSL_REDIRECT = _IS_SECURE
SECURE_HSTS_SECONDS = 31536000 if _IS_SECURE else 0
SECURE_HSTS_INCLUDE_SUBDOMAINS = _IS_SECURE
SESSION_COOKIE_SECURE = _IS_SECURE
CSRF_COOKIE_SECURE = _IS_SECURE
```

`config/settings/base.py` — CSP uniquement sur les processus qui servent du HTML :

```python
# CSP inutile sur le processus GraphQL (que du JSON)
if ENV != ENV_GRAPHQL:
    MIDDLEWARE.insert(1, "csp.middleware.CSPMiddleware")
```

---

## Partie 4 — Docker Compose production : un container par rôle

Le même code Django tourne dans plusieurs containers avec un `DJANGO_SETTINGS_MODULE` différent.

```yaml
# docker-compose.production.yml

services:
  app-admin:
    build: .
    command: gunicorn config.wsgi:application --workers 4 --threads 2 --bind 0.0.0.0:8000
    env_file: .env.production
    environment:
      DJANGO_SETTINGS_MODULE: config.settings_admin
    # Accessible via admin.rundate.app → Cloudflare Zero Trust → ce container

  app-graphql:
    build: .
    command: gunicorn config.wsgi:application --workers 6 --threads 4 --bind 0.0.0.0:8000
    env_file: .env.production
    environment:
      DJANGO_SETTINGS_MODULE: config.settings_graphql
    # Accessible via api.rundate.app → Cloudflare WAF → ce container

  app-idle:
    build: .
    command: sleep infinity   # container de secours pour les management commands
    env_file: .env.production
    environment:
      DJANGO_SETTINGS_MODULE: config.settings_graphql

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

  workers:
    build: .
    command: bash docker/start_workers.sh
    env_file: .env.production
    environment:
      DJANGO_SETTINGS_MODULE: config.settings_graphql
```

### Ressources par container

| Container | Workers | Threads | Slots concurrents | Rôle |
|---|---|---|---|---|
| `app-admin` | 4 | 2 | 8 | Admin + GraphQL avec graphiql |
| `app-graphql` | 6 | 4 | 24 | API GraphQL publique |
| `app-idle` | — | — | — | Management commands à la demande |
| `workers` | — | — | — | Management commands en boucle |

### Nginx routing par domaine

```nginx
# docker/nginx/production.conf

# API GraphQL publique
server {
    listen 443 ssl;
    server_name api.rundate.app;
    location /graphql/ { proxy_pass http://app-graphql:8000; }
    location /health/  { proxy_pass http://app-graphql:8000; }
    location /media/   { alias /app/media/; }
}

# Admin (protégé par Cloudflare Zero Trust en amont)
server {
    listen 443 ssl;
    server_name admin.rundate.app;
    location / { proxy_pass http://app-admin:8000; }
}
```

---

## Partie 5 — Structure des fichiers settings

```
config/
  settings/
    __init__.py
    base.py            # settings communs à tous les ENV
    env_settings.py    # constantes ENV_ADMIN, ENV_GRAPHQL, ENV = None
    security_settings.py   # HTTPS, HSTS, cookies selon ENVIRONMENT
    database_settings.py   # DATABASE_URL parsing
    cors_settings.py       # CORS_ALLOW_HEADERS, CORS_ALLOWED_ORIGINS
    graphql_settings.py    # GRAPHENE config, depth limits
  settings_admin.py    # from .settings.base import * + ENV = ENV_ADMIN
  settings_graphql.py  # from .settings.base import * + ENV = ENV_GRAPHQL
```

### `config/settings/base.py`

```python
# config/settings/base.py
from .env_settings import *
from .security_settings import *
from .database_settings import *
from .cors_settings import *
from .graphql_settings import *

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    ...
    'graphene_django',
    'corsheaders',
    'imagekit',
    'apps.accounts',
    'apps.events',
    'apps.messaging',
    'apps.notifications',
    'apps.community',
    'apps.geography',
    'apps.devtools',
    'apps.monitoring',
]
```

---

## Résumé visuel du flux en production

```
.env.production
  ENVIRONMENT=production     → sécurité HTTPS, HSTS, cookies sécurisés
  DATABASE_URL=...

docker-compose.production.yml
  ├── app-admin
  │     DJANGO_SETTINGS_MODULE=config.settings_admin
  │     → ENV = "admin"
  │     → / (admin) + /graphql/ (avec graphiql)
  │     → 4 workers × 2 threads
  │     → admin.rundate.app (Cloudflare Zero Trust)
  │
  ├── app-graphql
  │     DJANGO_SETTINGS_MODULE=config.settings_graphql
  │     → ENV = "graphql"
  │     → /graphql/ uniquement (sans graphiql, sans introspection)
  │     → 6 workers × 4 threads
  │     → api.rundate.app (Cloudflare WAF)
  │
  ├── app-idle
  │     → sleep infinity
  │     → utilisé pour make shell-production, migrations d'urgence
  │
  └── workers
        → management commands en boucle infinie
        → même settings que app-graphql
```

---

## Makefile — lancer un management command en production

```makefile
# Via app-idle (container toujours disponible)
shell-production:
    docker compose -f docker-compose.production.yml exec app-idle python manage.py shell

migrate-production:
    docker compose -f docker-compose.production.yml exec app-idle python manage.py migrate

seed-production:
    docker compose -f docker-compose.production.yml exec app-idle python manage.py seed_prod_base
```
