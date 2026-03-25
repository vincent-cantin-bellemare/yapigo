# 11 — Sauvegardes

> Pour le système complet de synchronisation DB entre environnements (backup + sync_db.py + Makefile), voir [15-sync-db.md](./15-sync-db.md).

## Principe

- Sauvegarde de la **base de données uniquement** (pas des médias)
- `pg_dump` → compression gzip → envoi sur **Google Drive** via `rclone`
- Exécuté par un **cron sur le host Proxmox** (pas dans Docker)
- Script versionné dans `scripts/backup.sh`
- Crontab versionné dans `scripts/crontab.example`

## Script `scripts/backup.sh`

```bash
#!/bin/bash
set -e

TIMESTAMP=$(date +%Y%m%d_%H%M)
BACKUP_FILE="/volumes/app/backups/rundate_${TIMESTAMP}.sql.gz"
GDRIVE_DEST="gdrive:rundate-backups/"

echo "[$(date)] Starting backup..."

# Dump la base depuis le container postgres
docker exec rundate-postgres-1 pg_dump -U rundate rundate | gzip > "$BACKUP_FILE"

echo "[$(date)] Dump created: $BACKUP_FILE"

# Envoi sur Google Drive
rclone copy "$BACKUP_FILE" "$GDRIVE_DEST"

echo "[$(date)] Uploaded to Google Drive"

# Supprimer localement après upload
rm "$BACKUP_FILE"

# Garder seulement les 30 dernières sauvegardes sur Google Drive
rclone delete --min-age 30d "$GDRIVE_DEST"

echo "[$(date)] Backup complete"
```

## Crontab `scripts/crontab.example`

```cron
# RunDate — Backup quotidien à 3h du matin
0 3 * * * /opt/rundate/scripts/backup.sh >> /var/log/rundate-backup.log 2>&1

# Optionnel : backup hebdomadaire supplémentaire le dimanche à 2h
0 2 * * 0 /opt/rundate/scripts/backup.sh >> /var/log/rundate-backup.log 2>&1
```

### Installation sur le host Proxmox

```bash
crontab -e
# → coller le contenu de scripts/crontab.example
```

## Sauvegarde manuelle

```bash
make backup-production
# → exécute scripts/backup.sh
```

## Configuration rclone

`rclone` doit être configuré sur le host Proxmox pour accéder à Google Drive :

```bash
rclone config
# → choisir Google Drive
# → suivre le flow OAuth
# → nommer le remote "gdrive"
```

Les credentials rclone sont stockés dans `~/.config/rclone/rclone.conf` sur le host. **Ne pas commiter.**

## Restauration

```bash
# Télécharger depuis Google Drive
rclone copy "gdrive:rundate-backups/rundate_20260323_030000.sql.gz" /tmp/

# Décompresser et restaurer
gunzip -c /tmp/rundate_20260323_030000.sql.gz | \
    docker exec -i rundate-postgres-1 psql -U rundate rundate
```

## Rétention

| Destination | Durée |
|---|---|
| `/volumes/app/backups/` | Supprimé après upload |
| Google Drive | 30 derniers jours |
