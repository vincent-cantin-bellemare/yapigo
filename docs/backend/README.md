# Backend RunDate — Documentation

Django + Graphene-Django + PostgreSQL, hébergé sur VM Proxmox avec Docker Compose.

> **Plan de développement** (backend + Flutter, slice par slice) → [docs/plan-developpement.md](../plan-developpement.md)

## Table des matières

| # | Document | Contenu |
|---|---|---|
| 01 | [Infrastructure](./01-infrastructure.md) | VM Proxmox, Ubuntu, Cloudflare, domaines |
| 02 | [Stack technique](./02-stack-technique.md) | Django, GraphQL, libs Python, requirements |
| 03 | [Structure du projet](./03-structure-projet.md) | Dossiers, apps Django, layout complet |
| 04 | [Modèles Django](./04-modeles-django.md) | Tous les modèles avec champs et relations |
| 05 | [Authentification](./05-authentification.md) | OTP Twilio, token maison, flow complet |
| 06 | [API GraphQL](./06-api-graphql.md) | Convention de nommage, **norme statuts/erreurs** (`status`, `errors` JSON), queries, mutations |
| 07 | [Management commands (workers)](./07-management-commands.md) | Boucles infinies, convention nommage |
| 08 | [GraphQL CLI (devtools)](./08-graphql-cli.md) | Commandes de test de l'API depuis le terminal |
| 09 | [Environnements & Docker](./09-environnements.md) | dev / staging / production, .env, volumes |
| 10 | [Seeds](./10-seeds.md) | Données de démarrage et données fake |
| 11 | [Sauvegardes](./11-sauvegardes.md) | pg_dump, rclone, Google Drive, crontab |
| 12 | [Conventions de code](./12-conventions-code.md) | Toutes les règles Cursor backend |
| 13 | [Schéma GraphQL & Flutter](./13-schema-flutter.md) | Export du schéma, intégration Flutter |
| 14 | [Standards admin Django](./14-admin-standards.md) | Mixins, AdminHTMLUtils, get_*_link, filtres, actions |
| 15 | [Synchronisation DB](./15-sync-db.md) | backup.sh, sync_db.py, Makefile, Tailscale |
| 16 | [Settings multi-environnements](./16-settings-multi-env.md) | ENV vs ENVIRONMENT, settings par rôle, Docker multi-container |
| 17 | [Système i18n](./17-i18n.md) | Traductions JSON custom, TranslationService, translate/t/tc |
| 18 | [Dockerfile](./18-dockerfile.md) | Image, dépendances système, alias bash, Dev Container |
| 19 | [Génération de bio IA](./19-bio-generation.md) | Claude Sonnet 4.6, BioGenerationService, mutations GraphQL |
| 20 | [Messagerie & Notifications](./20-messaging-notifications.md) | Conversations groupe/privées, archivage, ContactRequest, FCM, workers |
| 21 | [Photos, Connexions & Blocage](./21-photos-membres.md) | Galerie profil, photos événements, crush mutuels, blocage, signalements |
| 22 | [Audit Flutter → Backend](./22-audit-flutter.md) | Matrice complète screens Flutter → couverture API, features V2 (inclut FAQ, règles, légal) |
| 23 | [Algorithme de groupes](./23-group-matching.md) | GroupMatchingService, buddy pairs, action admin, commande CLI |
| 24 | [Actions Django Admin](./24-admin-actions.md) | Catalogue complet par modèle, confirmation, mixin réutilisable |
| 25 | [Messagerie & Polling temps réel](./25-messagerie-temps-reel.md) | FCM data push, typing indicator, stratégies de polling par écran |

## Résumé de la stack

- **Framework** : Django 5.x
- **API** : Graphene-Django (GraphQL uniquement, pas de REST)
- **Base de données** : PostgreSQL (dernière version)
- **Serveur** : Gunicorn + Nginx
- **Auth** : Token opaque maison (`UserAccessToken`), OTP via Twilio
- **Push notifications** : Firebase Cloud Messaging (FCM)
- **Médias** : Auto-hébergés sur VM, servis par Nginx
- **Thumbnails** : django-imagekit + Pillow
- **Génération de bio** : Claude Sonnet 4.6 (Anthropic) — basée sur les 20 questions onboarding
- **Environnements** : dev / staging / production via Docker Compose
- **Infra** : NUC i7 / Proxmox VM Ubuntu 24.04

## Domaines

| Domaine | Environnement | Description |
|---|---|---|
| `api.rundate.app` | Production | API GraphQL |
| `api.staging.rundate.app` | Staging | API GraphQL staging |
| `api.dev.rundate.app` | Dev | API GraphQL dev |
| `admin.rundate.app` | Production | Django admin à `/` (Cloudflare Zero Trust) |
| `admin.staging.rundate.app` | Staging | Django admin à `/` (Cloudflare Zero Trust) |
| `www.rundate.app` | — | Réservé au futur site Next.js |

## Commandes rapides

```bash
make start-dev          # démarrer l'environnement de développement
make start-production   # démarrer en production (detached)
make migrate-dev        # appliquer les migrations
make seed-dev           # charger toutes les données de départ
make export-schema      # exporter schema.graphql vers shared/schema/
make backup-production  # sauvegarde manuelle de la base de données
make smoke-test-staging # smoke test GraphQL complet
```
