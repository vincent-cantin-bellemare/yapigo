# 15 — Synchronisation de base de données

## Vue d'ensemble

Trois outils distincts selon le besoin :

| Outil | Fichier | Usage |
|---|---|---|
| `backup.sh` | `scripts/backup.sh` | Créer / restaurer / lister les backups (côté serveur) |
| `sync_db.py` | `scripts/sync_db.py` | Copier une DB distante → dev local |
| `Makefile` | `Makefile` | Interface unifiée pour appeler les deux scripts |

**Flux toujours unidirectionnel** : on tire les données d'un environnement vers le dev local. Il n'existe pas de script pour pousser la DB locale vers un serveur distant.

---

## Partie 1 — `backup.sh` : backups côté serveur

Ce script tourne dans le container `django` ou `postgres` sur chaque serveur. Il gère le cycle de vie complet des backups PostgreSQL.

### Commandes

```bash
# Créer un backup
backup.sh backup
# → pg_dump | gzip → rundate_backup_YYYYMMDD_HHMMSS.sql.gz
# → Upload optionnel vers Google Drive via rclone
# → Conserve les N derniers (BACKUP_RETENTION_COUNT)

# Lister les backups disponibles (local + Google Drive)
backup.sh list

# Restaurer un backup précis
backup.sh restore rundate_backup_20260323_030000.sql.gz

# Restaurer le plus récent
backup.sh restore latest

# Voir le statut du système de backup
backup.sh status
```

### Variables d'environnement

```env
BACKUP_DIR=/volumes/app/backups
BACKUP_RETENTION_COUNT=7
BACKUP_MIN_DISK_GB=5
DATABASE_URL=postgresql://rundate:password@postgres:5432/rundate
RCLONE_GDRIVE_CLIENT_ID=...         # optionnel — Google Drive OAuth
RCLONE_GDRIVE_CLIENT_SECRET=...
RCLONE_GDRIVE_REFRESH_TOKEN=...
```

### Mécanisme

```bash
# Backup
pg_dump -h $HOST -U $USER -d $DB | gzip > rundate_backup_YYYYMMDD_HHMMSS.sql.gz

# Restauration
# 1. DROP DATABASE IF EXISTS rundate;
# 2. CREATE DATABASE rundate;
# 3. gunzip < backup.sql.gz | psql -d rundate
```

### Emplacements des backups locaux sur les serveurs

```
/volumes/app/backups/           ← production
/volumes/app/backups/           ← staging  (volume monté différemment par env)
```

---

## Partie 2 — `sync_db.py` : importer une DB distante en local

Script Python utilisé par le développeur sur sa machine locale pour récupérer la base de données d'un serveur distant et la restaurer dans son Docker de développement.

**Prérequis** : être connecté au VPN Tailscale pour que les noms SSH soient joignables.

### Serveurs SSH configurés

```python
# scripts/sync_db.py
ENVIRONMENTS = {
    "production": {
        "ssh_host": "rundate-production",
        "backup_dir": "/volumes/app/backups",
        "container": "rundate-postgres-1",
    },
    "staging": {
        "ssh_host": "rundate-staging",
        "backup_dir": "/volumes/app/backups",
        "container": "rundate-postgres-1",
    },
}
```

### Étapes exécutées automatiquement

```
1. SSH → serveur distant
   └── trouve le *.sql.gz le plus récent (ou --file spécifié)

2. SCP → téléchargement local
   └── copie dans /volumes/app/backups/ (local)

3. Décompression
   └── gunzip du fichier .sql.gz

4. Docker
   └── vérifie que le container postgres est démarré (le lance si nécessaire)

5. PostgreSQL
   └── DROP + CREATE de la base de données cible

6. Restauration
   └── psql < backup.sql dans le container postgres

7. Instructions
   └── affiche les nouvelles valeurs à mettre dans .env.dev
```

### Mise à jour manuelle après sync

Le nom de la DB change pour correspondre au fichier de backup. Mettre à jour `.env.dev` :

```env
# Avant
POSTGRES_DB=rundate
DATABASE_URL=postgresql://rundate:password@postgres:5432/rundate

# Après sync du backup rundate_backup_20260323_030000
POSTGRES_DB=rundate_backup_20260323_030000
DATABASE_URL=postgresql://rundate:password@postgres:5432/rundate_backup_20260323_030000
```

> Pas de `CELERY_RESULT_BACKEND` — RunDate n'utilise pas Celery.

---

## Partie 3 — Makefile : interface unifiée

### Backups côté serveur

```makefile
# Créer un backup
make backup-dev
make backup-staging
make backup-production

# Lister les backups
make backup-list-staging
make backup-list-production

# Restaurer (sur la machine qui tourne l'environnement)
make backup-restore-staging FILE=latest
make backup-restore-production FILE=rundate_backup_20260323_030000.sql.gz
```

### Sync vers le dev local

```makefile
# Le plus récent (avec confirmation interactive)
make sync-db SOURCE=production
make sync-db SOURCE=staging

# Raccourcis
make sync-staging-db
make sync-production-db

# Fichier précis, sans confirmation
make sync-db SOURCE=production FILE=rundate_backup_20260323_030000.sql.gz YES=1
```

---

## Flux complet typique

```
Serveur Staging (rundate-staging via Tailscale)
  │
  ├── make backup-staging
  │   └── backup.sh backup
  │       └── pg_dump | gzip → rundate_backup_20260323_030000.sql.gz
  │           └── rclone → Google Drive (optionnel)
  │
  ↓ SSH / SCP (via Tailscale VPN)
  │
Dev Local
  │
  ├── make sync-db SOURCE=staging
  │   └── scripts/sync_db.py --source staging
  │       ├── SSH → liste les backups sur rundate-staging
  │       ├── SCP → télécharge le .sql.gz en local
  │       ├── gunzip → .sql
  │       ├── docker compose exec postgres → DROP/CREATE database
  │       ├── psql < backup.sql → restauration
  │       └── affiche les variables à mettre à jour dans .env.dev
  │
  └── Mise à jour manuelle de .env.dev
      (POSTGRES_DB, DATABASE_URL)
```

---

## Ce que ce système ne fait PAS

- **Pas de push** de la DB locale vers un serveur
- **Pas de connexion DB directe** entre machines — tout passe par SSH/SCP
- Les commandes `graphql_*` du devtools (ex: `graphql_events_event_list --env staging`) ne se connectent pas à la DB distante — elles font des appels HTTP vers l'API GraphQL du serveur distant

---

## Makefile — extrait complet

```makefile
# === Database Sync ===

sync-db:
    python scripts/sync_db.py --source $(SOURCE) $(if $(FILE),--file $(FILE),) $(if $(YES),--yes,)

sync-staging-db:
    python scripts/sync_db.py --source staging

sync-production-db:
    python scripts/sync_db.py --source production

# === Backups ===

backup-dev:
    docker compose -f docker-compose.dev.yml exec django bash scripts/backup.sh backup

backup-staging:
    docker compose -f docker-compose.staging.yml exec django bash scripts/backup.sh backup

backup-production:
    docker compose -f docker-compose.production.yml exec django bash scripts/backup.sh backup

backup-list-staging:
    docker compose -f docker-compose.staging.yml exec django bash scripts/backup.sh list

backup-list-production:
    docker compose -f docker-compose.production.yml exec django bash scripts/backup.sh list

backup-restore-staging:
    docker compose -f docker-compose.staging.yml exec django bash scripts/backup.sh restore $(FILE)

backup-restore-production:
    docker compose -f docker-compose.production.yml exec django bash scripts/backup.sh restore $(FILE)
```

---

## Scripts à créer

```
backend/scripts/
  backup.sh       ← backup/restore/list/status PostgreSQL
  sync_db.py      ← sync d'un environnement distant vers dev local
  smoke_test.sh   ← smoke test GraphQL post-déploiement (voir 08-graphql-cli.md)
  crontab.example ← crontab à installer sur le host Proxmox
```
