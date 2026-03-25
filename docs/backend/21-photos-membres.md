# 21 — Photos, Connexions, Blocage & Signalements

## Vue d'ensemble

Ce document couvre quatre systèmes liés aux membres :

1. **Photos de profil** — photo principale + galerie de 6
2. **Photos d'événements** — partagées par les membres, publiques
3. **Connexions** — crush mutuels uniquement
4. **Blocage & Signalements** — sécurité et modération

---

## Photos de profil

### Structure

```
User.photo           ← photo principale (ProcessedImageField, 800×800)
User.photo_thumbnail ← crop 200×200 de la principale (ImageSpecField)
UserPhoto (galerie)  ← jusqu'à 6 photos additionnelles
```

La photo principale et la galerie sont deux systèmes distincts. La galerie n'affecte pas `User.photo`.

### Modèle `UserPhoto`

```python
class UserPhoto(BaseModel):
    user = ForeignKey(User, related_name='gallery', on_delete=CASCADE)
    photo = ProcessedImageField(
        upload_to='users/gallery/',
        processors=[ResizeToFit(800, 800)],
        format='JPEG',
        options={'quality': 85},
    )
    photo_thumbnail = ImageSpecField(
        source='photo',
        processors=[ResizeToFill(200, 200)],
        format='JPEG',
        options={'quality': 80},
    )
    order = IntegerField(default=0)

    class Meta:
        ordering = ['order']
        verbose_name = 'user photo'
        verbose_name_plural = 'user photos'
```

### Règles métier

| Règle | Détail |
|---|---|
| Maximum | 6 photos dans la galerie (enforced dans `UserPhotoService.add`) |
| Format sortie | JPEG uniquement |
| Taille max entrée | 10 Mo (validé dans la mutation) |
| Redimensionnement | 800×800 max, qualité 85% |
| Thumbnail | 200×200 crop, qualité 80% |
| Suppression | Soft : le fichier physique est supprimé du volume `media/` |
| Publication | Immédiate — pas de modération |
| Signalement | Via `ContentReport(content_type='user_photo')` |

### Service `UserPhotoService`

```python
# apps/accounts/services/user_photo.py

class UserPhotoService:

    MAX_GALLERY_PHOTOS = 6

    def add(self, user, photo_file) -> UserPhoto:
        count = UserPhoto.objects.filter(user=user).count()
        if count >= self.MAX_GALLERY_PHOTOS:
            raise ValidationError("max_gallery_reached")
        order = count  # append at the end
        return UserPhoto.objects.create(user=user, photo=photo_file, order=order)

    def delete(self, user, photo_id) -> None:
        photo = UserPhoto.objects.get(id=photo_id, user=user)
        photo.photo.delete(save=False)  # delete physical file
        photo.delete()
        self._reorder(user)

    def reorder(self, user, photo_ids: list) -> list[UserPhoto]:
        photos = {str(p.id): p for p in UserPhoto.objects.filter(user=user)}
        for i, pid in enumerate(photo_ids):
            if pid in photos:
                photos[pid].order = i
                photos[pid].save(update_fields=['order'])
        return list(UserPhoto.objects.filter(user=user).order_by('order'))

    def _reorder(self, user) -> None:
        for i, photo in enumerate(UserPhoto.objects.filter(user=user).order_by('order')):
            photo.order = i
            photo.save(update_fields=['order'])
```

### Mutations GraphQL

```graphql
accountsUserUploadPhoto(photo: Upload!): User        # photo principale
accountsUserPhotoAdd(photo: Upload!): UserPhoto      # galerie
accountsUserPhotoDelete(photoId: ID!): Boolean
accountsUserPhotoReorder(photoIds: [ID!]!): [UserPhoto!]!
```

---

## Photos d'événements

### Modèle `EventPhoto`

```python
class EventPhoto(BaseModel):
    event = ForeignKey(RunDateEvent, related_name='photos', on_delete=CASCADE)
    user = ForeignKey(User, related_name='event_photos', on_delete=CASCADE)
    photo = ProcessedImageField(
        upload_to='events/photos/',
        processors=[ResizeToFit(1200, 1200)],
        format='JPEG',
        options={'quality': 88},
    )
    photo_thumbnail = ImageSpecField(
        source='photo',
        processors=[ResizeToFill(400, 400)],
        format='JPEG',
        options={'quality': 82},
    )
    description = TextField(null=True, blank=True)
    order = IntegerField(default=0)
```

### Règles métier

| Règle | Détail |
|---|---|
| Visibilité | Publique — visible par tous les utilisateurs, à tout moment |
| Maximum | 10 photos par utilisateur par événement |
| Redimensionnement | 1200×1200 max |
| Suppression | Seul l'uploader peut supprimer sa propre photo |
| Admin | Peut supprimer n'importe quelle photo via Django Admin |
| Signalement | Via `ContentReport(content_type='event_photo')` |

### Mutations GraphQL

```graphql
communityEventPhotoUpload(eventId: ID!, photo: Upload!, description: String): EventPhoto
communityEventPhotoDelete(photoId: ID!): Boolean
```

### Query GraphQL

```graphql
communityEventPhotoList(eventId: ID!, limit: Int = 50, offset: Int = 0): EventPhotoPage
```

---

## Connexions (crush mutuels)

### Définition

Une "connexion" dans RunDate = deux utilisateurs se sont mutuellement liké via `UserLike` après un run commun. Il n'y a pas de table dédiée — c'est une property calculée.

```python
# apps/accounts/models/user.py

@property
def connections_count(self) -> int:
    """Number of mutual crushes (= connections in Flutter)."""
    liked_by_me = UserLike.objects.filter(from_user=self).values_list('to_user_id', flat=True)
    return UserLike.objects.filter(from_user_id__in=liked_by_me, to_user=self).count()
```

### Query GraphQL

```graphql
# Crush mutuels de l'utilisateur connecté
accountsUserConnectionList(limit: Int = 30, offset: Int = 0): UserPage
```

Implémentation dans le selector :
```python
def get_connections(user, limit=30, offset=0):
    liked_by_me = UserLike.objects.filter(from_user=user).values_list('to_user_id', flat=True)
    mutual_ids = UserLike.objects.filter(
        from_user_id__in=liked_by_me, to_user=user
    ).values_list('from_user_id', flat=True)
    qs = User.active.filter(id__in=mutual_ids).select_related('city', 'neighborhood')
    total = qs.count()
    return list(qs[offset:offset + limit]), total
```

---

## Blocage d'utilisateurs

### Modèle `UserBlock`

```python
class UserBlock(BaseModel):
    blocked_by = ForeignKey(User, related_name='blocks_made', on_delete=CASCADE)
    blocked_user = ForeignKey(User, related_name='blocks_received', on_delete=CASCADE)

    class Meta:
        unique_together = ('blocked_by', 'blocked_user')
        verbose_name = 'user block'
        verbose_name_plural = 'user blocks'
```

### Effets du blocage

| Zone | Comportement |
|---|---|
| Conversation privée existante | Reste visible pour les deux, mais **écriture désactivée** |
| `messagingMessageSend` | Retourne `status=False`, `errors={"user_blocked": "<message traduit>"}` dans les deux sens |
| `accountsUserSearch` | L'utilisateur bloqué n'apparaît pas dans les résultats du bloqueur |
| `messagingContactRequestSend` | Impossible si un blocage existe dans un sens ou l'autre |
| `accountsUserDetail` | Le profil est accessible (pas masqué) mais le bouton Contact est désactivé |

### Service `UserBlockService`

```python
# apps/accounts/services/user_block.py

class UserBlockService:

    def block(self, blocked_by, blocked_user) -> None:
        UserBlock.objects.get_or_create(blocked_by=blocked_by, blocked_user=blocked_user)

    def unblock(self, blocked_by, blocked_user) -> None:
        UserBlock.objects.filter(blocked_by=blocked_by, blocked_user=blocked_user).delete()

    def is_blocked(self, user_a, user_b) -> bool:
        """Returns True if any block exists between the two users (in either direction)."""
        return UserBlock.objects.filter(
            models.Q(blocked_by=user_a, blocked_user=user_b) |
            models.Q(blocked_by=user_b, blocked_user=user_a)
        ).exists()
```

### Mutations GraphQL

```graphql
accountsUserBlock(userId: ID!): Boolean
accountsUserUnblock(userId: ID!): Boolean
```

---

## Signalements (`ContentReport`)

### Modèle

```python
class ContentReport(BaseModel):
    reporter = ForeignKey(User, related_name='reports_made', on_delete=CASCADE)
    content_type = CharField(max_length=20, choices=[
        ('user_photo', 'User Photo'),
        ('event_photo', 'Event Photo'),
        ('message', 'Message'),
        ('user_profile', 'User Profile'),
    ])
    user_photo = ForeignKey(UserPhoto, null=True, blank=True, related_name='reports', on_delete=SET_NULL)
    event_photo = ForeignKey(EventPhoto, null=True, blank=True, related_name='reports', on_delete=SET_NULL)
    message = ForeignKey(Message, null=True, blank=True, related_name='reports', on_delete=SET_NULL)
    reported_user = ForeignKey(User, null=True, blank=True, related_name='reports_against', on_delete=SET_NULL)
    reason = CharField(max_length=20, choices=[
        ('inappropriate', 'Inappropriate'),
        ('harassment', 'Harassment'),
        ('spam', 'Spam'),
        ('fake_profile', 'Fake Profile'),
        ('other', 'Other'),
    ])
    notes = TextField(null=True, blank=True)
    is_resolved = BooleanField(default=False)
    resolved_by = ForeignKey(User, null=True, blank=True, on_delete=SET_NULL)
    resolved_at = DateTimeField(null=True, blank=True)
```

### Mutation GraphQL

```graphql
communityContentReport(
  contentType: ContentReportType!
  contentId: ID!
  reason: ContentReportReason!
  notes: String
): Boolean
```

### Django Admin

`ContentReportAdmin` — accès lecture + actions :
- `mark_resolved` — action batch
- Filtres : `is_resolved`, `content_type`, `reason`
- `list_display` : `reporter`, `content_type`, `reason`, `is_resolved`, `created_at`
- Lien vers le contenu signalé avec `get_content_link`

---

## Stockage physique des fichiers

Tous les médias sont dans `/volumes/app/media/` (bind mount sur la VM) :

```
/volumes/app/media/
  users/
    photos/        ← User.photo (photos principales)
    gallery/       ← UserPhoto (galerie)
  events/
    photos/        ← EventPhoto (photos d'événements)
    thumbnails/    ← générés par django-imagekit à la demande
```

Servis par Nginx avec mise en cache longue durée (`Cache-Control: max-age=31536000`).
