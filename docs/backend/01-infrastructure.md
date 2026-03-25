# 01 — Infrastructure

## Machine hôte

| Composant | Détail |
|---|---|
| Modèle | NUC 2024 i7 |
| RAM | 64 Go |
| Stockage | SSD |
| Hyperviseur | Proxmox VE (bare metal) |

## VM Ubuntu

- **OS** : Ubuntu 24.04 LTS
- **Logiciels installés sur le host** :
  - Docker Engine + Docker Compose (dernière version stable)
  - `make`
  - `rclone` (sauvegardes Google Drive)
  - Claude Code CLI

## Volumes persistants

Tous les volumes Docker sont montés depuis `/volumes/app/` sur la VM :

```
/volumes/app/
  media/      ← photos profil, galerie, photos d'événements
  postgres/   ← données PostgreSQL
  backups/    ← pg_dump compressés avant envoi Google Drive
```

## Cloudflare

- DNS + proxy activé sur tous les sous-domaines
- WAF (Web Application Firewall) actif
- **Cloudflare Zero Trust (Access)** sur `admin.rundate.app` et `admin.staging.rundate.app` :
  - Login obligatoire via email/OTP Cloudflare avant d'atteindre le container Django
  - Aucun accès admin possible sans authentification Cloudflare
- Cloudflare Tunnel (optionnel) pour exposer le backend sans ouvrir de ports

## Domaines

| Domaine | Rôle | Protection |
|---|---|---|
| `api.rundate.app` | API GraphQL production | Cloudflare WAF |
| `api.staging.rundate.app` | API GraphQL staging | Cloudflare WAF |
| `api.dev.rundate.app` | API GraphQL dev | accès local / tunnel |
| `admin.rundate.app` | Django admin production — accessible à `/` | Cloudflare Zero Trust |
| `admin.staging.rundate.app` | Django admin staging — accessible à `/` | Cloudflare Zero Trust |
| `www.rundate.app` | Futur site Next.js | — |

## Nginx

Un container Nginx par environnement. Il sert :
- Les requêtes vers Gunicorn (Django)
- Les fichiers statiques (`/static/`)
- Les médias uploadés (`/media/`)

```
Cloudflare → Nginx (container) → Gunicorn (container Django)
                              → /volumes/app/media/ (fichiers statiques)
```

## Crontab sur le host Proxmox

Le fichier `scripts/crontab.example` dans le dépôt documente les tâches cron à installer sur la VM :

```cron
# Sauvegarde quotidienne à 3h du matin
0 3 * * * /opt/rundate/scripts/backup.sh >> /var/log/rundate-backup.log 2>&1
```

Copier sur la VM avec : `crontab -e` puis coller le contenu de `scripts/crontab.example`.
