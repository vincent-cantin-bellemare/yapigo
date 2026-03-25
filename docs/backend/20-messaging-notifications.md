# 20 — Messagerie & Notifications

## Vue d'ensemble

Le système de communication de RunDate comporte deux couches :

1. **Messagerie** — conversations de groupe et privées, avec archivage individuel
2. **Notifications** — alertes push (FCM) + in-app, déclenchées par des events Django

---

## Types de conversations

| Type | Déclencheur | Nom affiché |
|---|---|---|
| `group` | Confirmation d'un `RunGroup` | "Run [quartier] #N" (ex: "Run Laurier #3") |
| `private` | Crush mutuel (`UserLike` x2) | Prénom de l'autre personne |
| `private` | Acceptation d'un `ContactRequest` | Prénom de l'autre personne |

### Conversations de groupe

- Créées **automatiquement** par le signal `post_save` sur `RunGroup(status=confirmed)`
- Un `ConversationMember` est créé pour chaque membre du groupe
- Le premier message est un **icebreaker système** : "Bienvenue dans votre groupe! Présentez-vous après le run 🏃"
- La conversation reste active même après la fin de l'événement (`is_active=True`)
- Liée à `run_group` ET à `event` (dénormalisé) pour faciliter les filtres Flutter

### Conversations privées — Crush mutuel

Déclenchement : `UserLike.post_save` détecte le like mutuel.

```
UserLike(from_user=A, to_user=B) créé
→ signal vérifie si UserLike(from_user=B, to_user=A) existe
→ si oui :
   1. Crée Conversation(type='private', is_active=True)
   2. Crée ConversationMember pour A et B
   3. Insère Message(is_system=True) — "Vous vous êtes mutuellement likés! La conversation est ouverte 💘"
   4. Crée AppNotification(type=crushMatch) pour A et pour B
   5. Envoie FCM push aux deux
```

### Conversations privées — ContactRequest

Flux en 3 étapes :

```
Étape 1 — A envoie une demande à B (doivent avoir un RunGroup commun)
  mutation messagingContactRequestSend(toUserId: B, runGroupId: X, introMessage: "...")
  → ContactRequest(from=A, to=B, status=pending)
  → AppNotification(type=contactRequest) pour B
  → FCM push à B

Étape 2 — B voit la demande dans l'app (onglet "Demandes")
  query messagingContactRequestList(direction: RECEIVED, status: PENDING)

Étape 3 — B accepte ou refuse
  mutation messagingContactRequestAccept(requestId: R)
  → ContactRequest.status = accepted
  → Crée Conversation(type='private')
  → Message système : "Vous avez accepté de vous connecter! Bonne conversation 🤝"
  → AppNotification pour A (tu es notifié que B a accepté)

  mutation messagingContactRequestDecline(requestId: R)
  → ContactRequest.status = declined
  → Pas de notification (silence)
```

**Contraintes** :
- Une seule demande par paire par `RunGroup`
- Impossible si une conversation privée existe déjà entre les deux
- Impossible si les deux n'ont pas partagé le même `RunGroup`

---

## Archivage des conversations

L'archivage est **individuel** (côté `ConversationMember`). Un membre peut archiver une conversation sans affecter les autres.

```
messagingConversationArchive(conversationId: X)
→ ConversationMember(user=current, conversation=X).is_archived = True

messagingConversationList(archived: false) → n'inclut pas X
messagingConversationList(archived: true)  → inclut X seulement
```

- Une conversation archivée n'est **jamais supprimée** — elle reste accessible
- Si un nouveau message arrive dans une conversation archivée → la désarchiver automatiquement (`is_archived = False`)

---

## Modèles impliqués

```
Conversation (type, group_name, run_group, event, is_active)
  ↕ ConversationMember (user, is_archived, last_read_at, joined_at)
  ↕ Message (sender, content, is_icebreaker, is_system, timestamp)

ContactRequest (from_user, to_user, run_group, status, intro_message, conversation)
```

---

## Calcul des messages non lus

Pas de table `MessageRead` séparée. On compare :

```python
# Dans ConversationMember.unread_count (property)
unread = Message.objects.filter(
    conversation=self.conversation,
    timestamp__gt=self.last_read_at or datetime.min,
    is_system=False,
).exclude(sender=self.user).count()
```

Mis à jour lors de `messagingMessageMarkConversationRead` :
```python
ConversationMember.objects.filter(
    conversation_id=conversation_id, user=current_user
).update(last_read_at=now())
```

Total non-lus (badge global) : somme des `unread_count` sur toutes les memberships non archivées.

---

## Queries GraphQL

```graphql
# Liste filtrée (actives ou archivées, par type, par événement)
messagingConversationList(
  type: ConversationType = ALL
  archived: Boolean = false
  eventId: ID
  limit: Int = 30
  offset: Int = 0
): ConversationPage

# Détail + messages paginés
messagingConversationDetail(id: ID!, limit: Int = 50, offset: Int = 0): Conversation

# Total non-lus (pour le badge de l'onglet)
messagingUnreadTotal: Int

# Demandes de contact
messagingContactRequestList(
  direction: ContactRequestDirection = RECEIVED
  status: ContactRequestStatus = PENDING
): [ContactRequest]
```

## Mutations GraphQL

```graphql
messagingMessageSend(conversationId: ID!, content: String!): Message
messagingMessageMarkConversationRead(conversationId: ID!): Boolean
messagingConversationArchive(conversationId: ID!): Boolean
messagingConversationUnarchive(conversationId: ID!): Boolean
messagingContactRequestSend(toUserId: ID!, runGroupId: ID!, introMessage: String): ContactRequestPayload
messagingContactRequestAccept(requestId: ID!): ContactRequestPayload
messagingContactRequestDecline(requestId: ID!): Boolean
```

---

## Notifications

### Types et déclencheurs

| Type | Déclencheur | FCM push | Action Flutter |
|---|---|---|---|
| `matchFound` | RunGroup créé (sous-groupes formés) | ✅ | Ouvrir l'événement |
| `runConfirmed` | RunDateEvent.is_confirmed → True | ✅ | Ouvrir l'événement |
| `runCancelled` | RunDateEvent annulé par admin | ✅ | Ouvrir la liste |
| `thresholdReached` | Seuil min atteint (events_event_check_threshold) | ✅ | Ouvrir l'événement |
| `eventCancelledNoQuorum` | Deadline dépassée sans seuil | ✅ | Ouvrir la liste |
| `deadlineReminder` | 2h avant la deadline (management command) | ✅ | Ouvrir les inscriptions |
| `runToday` | Matin du jour de l'événement (management command) | ✅ | Ouvrir l'événement |
| `rateReminder` | 2h après la fin du run (management command) | ✅ | Ouvrir le formulaire de note |
| `spotFreed` | Annulation d'une inscription (place libérée) | ✅ | Ouvrir l'événement |
| `crushMatch` | UserLike mutuel détecté | ✅ | Ouvrir la conversation privée |
| `contactRequest` | ContactRequest créé | ✅ | Ouvrir les demandes |
| `friendInvited` | Buddy code utilisé | ✅ | Ouvrir le profil ami |

### Modèle `AppNotification`

```python
class AppNotification(BaseModel):
    user = ForeignKey(User, related_name='notifications')
    type = CharField(choices=[...12 types...])
    title = CharField
    body = TextField
    is_read = BooleanField(default=False)
    from_user = ForeignKey(User, null=True)   # pour crushMatch, contactRequest
    event = ForeignKey(RunDateEvent, null=True)  # pour les notifs liées à un run
    run_group = ForeignKey(RunGroup, null=True)  # pour matchFound
    contact_request = ForeignKey(ContactRequest, null=True)  # pour contactRequest
```

**Signal `post_save`** : à chaque `AppNotification` créée → envoi FCM automatique si `user.fcm_token` non null.

### Management commands — workers notifications

| Command | Fréquence | Action |
|---|---|---|
| `notifications_notification_send_deadline_reminder` | toutes les 15 min | Cherche les événements dont la deadline est dans < 2h et envoie `deadlineReminder` |
| `notifications_notification_send_run_today` | toutes les heures | Cherche les run du jour à 8h et envoie `runToday` |
| `notifications_notification_send_rate_reminder` | toutes les heures | Cherche les run terminés il y a 2h sans note et envoie `rateReminder` |

### Queries GraphQL

```graphql
notificationsNotificationList(
  unreadOnly: Boolean
  type: NotificationType   # filtrer par type
  limit: Int = 30
  offset: Int = 0
): NotificationPage

notificationsNotificationUnreadCount: Int
```

### Mutations GraphQL

```graphql
notificationsNotificationMarkRead(id: ID!): Boolean
notificationsNotificationMarkAllRead: Boolean
```

---

## Sécurité et N+1

### Sécurité
- Un utilisateur ne peut lire/écrire que dans les conversations dont il est `ConversationMember`
- Vérifié à chaque opération messaging par le résolveur, pas seulement au niveau middleware

### N+1 prevention
```python
# selector : messagingConversationList
Conversation.objects
  .filter(memberships__user=current_user, memberships__is_archived=False)
  .select_related("run_group", "event", "event__neighborhood")
  .prefetch_related(
      Prefetch(
          "memberships",
          queryset=ConversationMember.objects.select_related("user"),
      ),
      Prefetch(
          "messages",
          queryset=Message.objects.order_by("-timestamp")[:1],
          to_attr="last_message_list",
      ),
  )
  .annotate(
      last_message_time=Max("messages__timestamp")
  )
  .order_by("-last_message_time")
```

---

## Création automatique des conversations de groupe

Déclenchée par signal Django sur `RunGroup` :

```python
# events/signals.py
@receiver(post_save, sender=RunGroup)
def create_group_conversation(sender, instance, created, **kwargs):
    if instance.status == "confirmed":
        if hasattr(instance, "conversation"):
            return  # already exists

        event = instance.event
        neighborhood = event.neighborhood.name if event.neighborhood else "RunDate"
        group_number = RunGroup.objects.filter(event=event).count()
        group_name = f"Run {neighborhood} #{group_number}"

        conversation = Conversation.objects.create(
            conversation_type="group",
            group_name=group_name,
            run_group=instance,
            event=event,
        )
        for user in instance.members.all():
            ConversationMember.objects.create(conversation=conversation, user=user)

        Message.objects.create(
            conversation=conversation,
            sender=None,
            content="Bienvenue dans votre groupe! Présentez-vous après le run 🏃",
            is_icebreaker=True,
            is_system=True,
        )
```
