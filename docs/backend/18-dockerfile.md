# 18 — Dockerfile

Fichier : `backend/Dockerfile`

---

## Image de base

```dockerfile
FROM python:3.11-slim
```

Image officielle Python 3.11 en version **slim** — Debian minimal, taille réduite.

---

## Variables d'environnement Python

```dockerfile
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
```

| Variable | Effet |
|---|---|
| `PYTHONDONTWRITEBYTECODE=1` | Empêche la création des fichiers `.pyc` — inutiles dans un container |
| `PYTHONUNBUFFERED=1` | Force les logs à s'afficher immédiatement dans la console Docker, sans tampon |

---

## Bloc 1 — Git + Docker CLI

```dockerfile
RUN apt-get update && apt-get install -y \
    git \
    apt-transport-https ca-certificates curl gnupg lsb-release \
    && curl -fsSL https://download.docker.com/linux/debian/gpg \
        | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && apt-get install -y docker-ce-cli \
    && rm -rf /var/lib/apt/lists/*
```

- **`git`** — requis pour que le Dev Container fonctionne avec VS Code / Cursor. Sans `git` dans le container, GitLens et le terminal intégré ne peuvent pas faire `git commit`, `git log`, etc.
- **`docker-ce-cli`** — client Docker uniquement (pas le daemon). Combiné au socket Docker monté en volume dans `docker-compose.dev.yml`, permet d'exécuter `docker compose exec` depuis l'intérieur du container. Utilisé par `sync_db.py` pour restaurer la DB.
- **`rm -rf /var/lib/apt/lists/*`** — supprime le cache APT pour réduire la taille de la couche Docker.

---

## Bloc 2 — Client PostgreSQL

```dockerfile
RUN apt-get install --auto-remove -y postgresql-client libpq-dev
```

- **`postgresql-client`** — fournit `psql`, `pg_dump`, `pg_isready`. Utilisé par `backup.sh` et `sync_db.py`.
- **`libpq-dev`** — bibliothèque C de PostgreSQL, nécessaire pour que `psycopg` se compile correctement.

---

## Bloc 3 — rclone

```dockerfile
RUN apt-get install --auto-remove -y unzip && \
    curl https://rclone.org/install.sh | bash
```

Installe `rclone` — utilisé par `backup.sh` pour envoyer les backups PostgreSQL vers Google Drive.

---

## Dépendances Python

```dockerfile
COPY requirements/ /app/requirements/
RUN pip install --no-cache-dir -r /app/requirements/base.txt

COPY ./code /app/code
```

`requirements/` est copié **avant** le code source — optimisation du cache Docker : si le code change mais pas les dépendances, Docker réutilise la couche `pip install` déjà construite.

---

## Ports exposés

```dockerfile
EXPOSE 8000 8001
```

| Port | Usage |
|---|---|
| `8000` | Service admin (`ENV="admin"`, `settings_admin`) |
| `8001` | Service GraphQL (`ENV="graphql"`, `settings_graphql`) |

---

## Alias bash (Dev Container)

Injectés dans `~/.bashrc` — permettent de taper des commandes courtes dans le terminal Dev Container :

| Alias | Commande complète |
|---|---|
| `runserver` | `cd /app/code && python3 manage.py runserver 0.0.0.0:8000` |
| `runserver_graphql` | `cd /app/code && DJANGO_SETTINGS_MODULE=config.settings_graphql python3 manage.py runserver 0.0.0.0:8001` |
| `migrate` | `cd /app/code && python3 manage.py migrate` |
| `makemigrations` | `cd /app/code && python3 manage.py makemigrations` |
| `shell` | `cd /app/code && python3 manage.py shell` |
| `dbshell` | `cd /app/code && python3 manage.py dbshell` |
| `test` | `cd /app/code && python3 manage.py test` |
| `collectstatic` | `cd /app/code && python3 manage.py collectstatic --noinput` |
| `showmigrations` | `cd /app/code && python3 manage.py showmigrations` |
| `createsuperuser` | `cd /app/code && python3 manage.py createsuperuser` |
| `flush` | `cd /app/code && python3 manage.py flush` |
| `flake` | `cd /app/code && flake8` |
| `seed` | `cd /app/code && python3 manage.py seed_all` |

Chaque alias inclut `cd /app/code &&` — `manage.py` est toujours trouvé peu importe le répertoire courant.

---

## Lien avec le Dev Container

```json
{
    "dockerComposeFile": ["../docker-compose.dev.yml"],
    "service": "django",
    "workspaceFolder": "/app/code",
    "postCreateCommand": "cd /app/code && make migrate-dev && make seed-dev",
    "forwardPorts": [8000, 8001, 5432]
}
```

VS Code / Cursor utilise ce fichier pour :
- Démarrer `docker-compose.dev.yml` et se connecter au service `django`
- Ouvrir le workspace dans `/app/code` à l'intérieur du container
- Installer automatiquement les extensions : Python, Pylance, Black, GitLens, Django, Thunder Client
- Rediriger les ports vers la machine locale

**C'est pourquoi `git` doit être dans le Dockerfile** : GitLens et le terminal intégré du Dev Container ont besoin de `git` dans le même container que le code.

---

## Différence dev vs production

En production, le même `Dockerfile` est utilisé mais Gunicorn est lancé directement — pas de `runserver` :

```yaml
# docker-compose.production.yml
app-graphql:
  build: .
  command: gunicorn config.wsgi:application --workers 6 --threads 4 --bind 0.0.0.0:8000
  environment:
    DJANGO_SETTINGS_MODULE: config.settings_graphql
```

Les alias bash ne sont jamais utilisés en production — ils sont uniquement pratiques dans le terminal Dev Container.
