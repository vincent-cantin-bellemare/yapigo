# 02 — Stack technique

## Vue d'ensemble

| Composant | Choix | Raison |
|---|---|---|
| Framework | Django 5.x | Mature, admin inclus, ORM puissant |
| API | Graphene-Django | GraphQL natif, pas de REST |
| Base de données | PostgreSQL (dernière version) | JSONB, ArrayField, robustesse |
| Serveur WSGI | Gunicorn (4 workers) | Standard production Django |
| Reverse proxy | Nginx (container) | Static files, médias, SSL termination |
| SMS OTP | Twilio Verify | Fiable, API simple |
| Push notifications | Firebase Admin SDK | FCM uniquement |
| Thumbnails | django-imagekit + Pillow | Pré-génération au upload, pas de Redis |
| CORS | django-cors-headers | Headers CORS par environnement |
| Config | python-decouple | Chargement `.env` par environnement |
| Depth limiting | graphql-core | Protection requêtes GraphQL imbriquées |
| Génération de bio IA | Anthropic SDK (`anthropic`) | Claude Sonnet 4.6 — génération de bio depuis les réponses onboarding |

**Pas de :** Redis, Celery, Django REST Framework.

## Requirements

### `requirements/base.txt`

```
django>=5.1
graphene-django>=3.2
psycopg[binary]
gunicorn
twilio
firebase-admin
Pillow
django-imagekit
django-cors-headers
python-decouple
graphql-core
user-agents            # parsing User-Agent pour HttpRequestLog
anthropic              # Claude Sonnet 4.6 — génération de bio
```

### `requirements/dev.txt`

```
-r base.txt
django-debug-toolbar
factory-boy
black
```

### `requirements/production.txt`

```
-r base.txt
sentry-sdk
```

## Traitement des images — django-imagekit

Choix retenu pour les thumbnails. Alternative `sorl-thumbnail` exclue car conçue pour Redis.

Comportement sur le modèle `User` :

```python
from imagekit.models import ImageSpecField, ProcessedImageField
from imagekit.processors import ResizeToFill, ResizeToFit

class User(AbstractBaseUser):
    photo = ProcessedImageField(
        upload_to='users/photos/',
        processors=[ResizeToFit(800, 800)],
        format='JPEG',
        options={'quality': 85},
        null=True
    )
    photo_thumbnail = ImageSpecField(
        source='photo',
        processors=[ResizeToFill(200, 200)],
        format='JPEG',
        options={'quality': 80}
    )
```

- `photo` : redimensionné à 800×800 max au moment de l'upload
- `photo_thumbnail` : crop 200×200, généré à la première demande
- Taille max acceptée en entrée : 10 Mo
- Format de sortie : toujours JPEG

## Tâches asynchrones sans Celery

Les opérations récurrentes tournent dans le container `workers` via des management commands Django en **boucle infinie** avec `time.sleep(N)`. Voir [07-management-commands.md](./07-management-commands.md).

Pour les opérations ponctuelles déclenchées par un événement (ex: envoyer une notification FCM au save d'un objet), on utilise les **Django signals**.

## Firebase

Utilisé uniquement pour l'envoi de notifications push (FCM). Le SDK `firebase-admin` est initialisé au démarrage de l'app avec le fichier de credentials `firebase.json` (non commité, stocké dans 1Password).
