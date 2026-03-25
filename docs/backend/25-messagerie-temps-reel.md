# 25 — Messagerie & Polling temps réel

## Architecture retenue : FCM + Short Polling

Approche choisie : **FCM data push + short polling**. Pas de WebSocket, pas de Django Channels, pas de Redis, pas de Daphne. Stack inchangée (Gunicorn / WSGI).

```
Message envoyé
  → backend sauvegarde en DB
  → FCM data push silencieux au(x) destinataire(s)      ← livraison quasi-instantanée (~1s)
  → Flutter reçoit le push → fetche les nouveaux messages via GraphQL
  → Fallback poll toutes les 3-4s si conversation ouverte
```

---

## Messagerie — FCM data push

### Principe

Quand un message est envoyé, le backend envoie un **FCM data push silencieux** (type `data`, pas `notification`) au destinataire. Flutter reçoit ce push en background et fetche immédiatement les nouveaux messages via GraphQL — sans afficher de banner système.

```python
# apps/messaging/services.py
def send_message(sender, conversation, content):
    msg = Message.objects.create(
        conversation=conversation,
        sender=sender,
        content=content,
    )
    for member in conversation.members.exclude(user=sender):
        if member.user.fcm_token:
            send_fcm_data_push(member.user.fcm_token, {
                "type": "new_message",
                "conversation_id": str(conversation.id),
            })
    return msg
```

Le push `data` est silencieux — l'OS ne l'affiche pas. Flutter le reçoit via `FirebaseMessaging.onMessage` (foreground) ou `FirebaseMessaging.onBackgroundMessage` (background) et déclenche un fetch GraphQL.

### Différence push `data` vs push `notification`

| | Push `data` (messages) | Push `notification` (alertes) |
|---|---|---|
| Affiché par l'OS | Non — silencieux | Oui — banner, son, badge |
| Traité par Flutter | Toujours | Seulement si app ouverte |
| Usage RunDate | Nouveaux messages | Notifications push (run confirmé, etc.) |

---

## Typing indicator

### Modèle `TypingStatus`

TTL court — auto-expire après 5 secondes sans heartbeat.

```
| user         | ForeignKey(User)         |
| conversation | ForeignKey(Conversation) |
| expires_at   | DateTimeField            | now() + 5 secondes
```

Unique together : `(user, conversation)` — upsert via `update_or_create`.

### Flux

```
Flutter tape → mutation messagingTypingHeartbeat(conversationId) toutes les 2s
  → backend : TypingStatus.update_or_create(
        user=user, conversation=conv,
        defaults={"expires_at": now() + timedelta(seconds=5)}
    )

Autre participant poll → query messagingConversationTypingUsers(conversationId) toutes les 2s
  → backend : TypingStatus.objects.filter(conversation=conv, expires_at__gt=now())
  → Flutter affiche les "..." de l'autre côté

Clavier fermé > 3s sans heartbeat → expires_at atteint → Flutter arrête d'afficher "..."
```

### Purge automatique

Management command `messaging_typing_status_purge` — tourne toutes les 60s dans le container `workers` :

```python
# apps/messaging/management/commands/messaging_typing_status_purge.py
TypingStatus.objects.filter(expires_at__lt=now()).delete()
```

---

## Stratégie de polling Flutter — Messages

| Situation | Intervalle | Ce qui est polled |
|---|---|---|
| Liste des conversations visible | 5s | `messagingConversationList` (unread counts) |
| Conversation ouverte | 3s | Nouveaux messages + `messagingConversationTypingUsers` |
| App en background | FCM data push uniquement | Déclenché silencieusement par le push |
| Retour en foreground | Immédiatement | Fetch forcé de la conversation active |
| Clavier fermé > 3s | Stop typing heartbeat | `messagingTypingHeartbeat` stoppé côté Flutter |

---

## Badges — Clearing au tap (comportement Messenger)

### Badge Notifications (cloche)

```
Utilisateur tape l'onglet Notifications
  → Flutter appelle immédiatement notificationsNotificationMarkAllRead
  → accountsNotificationUnreadCount retourne 0
  → Badge cloche disparaît instantanément
```

### Badge Messages (bulle)

```
App ouverte → poll toutes les 30s → messagingUnreadTotal → affiche le chiffre sur l'onglet Messages

Utilisateur tape l'onglet Messages
  → Flutter fetche messagingUnreadTotal → badge mis à jour

Utilisateur ouvre une conversation
  → Flutter appelle messagingMessageMarkConversationRead(conversationId)
  → Au poll suivant (3s) → messagingUnreadTotal reflète la nouvelle valeur
  → Badge bulle décrémenté
```

`messagingUnreadTotal` : somme des messages dont `timestamp > ConversationMember.last_read_at` pour toutes les conversations actives non-archivées de l'utilisateur. Calculé en une seule requête annotée.

### Archive individuelle de notification

L'utilisateur peut archiver une notification (swipe ou bouton) sans la supprimer :

```
Swipe sur une notif → notificationsNotificationArchive(id)
  → is_archived=True, archived_at=now()
  → Disparaît de la liste principale (archived=false par défaut)
  → Accessible dans l'écran "Archivées" via notificationsNotificationList(archived=true)
```

---

## Stratégie de polling Flutter — Notifications

Les notifications utilisent un push `notification` standard (affiché par l'OS). Le polling sert uniquement à maintenir le badge à jour.

| Situation | Intervalle | Ce qui est polled |
|---|---|---|
| App ouverte (tout écran) | 30s | `accountsNotificationUnreadCount` + `messagingUnreadTotal` → badges |
| Écran notifications ouvert | 10s | `accountsNotificationList(archived=false)` |
| App en background | FCM push `notification` | Banner affiché par l'OS directement |
| Retour en foreground | Immédiatement | `accountsNotificationList` + reset badge si tout lu |
| Tap sur une notification | Immédiatement | Navigation + fetch détail de la notif |

`accountsNotificationUnreadCount` retourne un simple `Int!` — query ultra-légère pour le badge, sans pagination.

---

## Stratégie de polling Flutter — Événements

Les événements utilisent uniquement du polling. Les FCM push `notification` existants (`runConfirmed`, `runCancelled`, `thresholdReached`) servent de déclencheurs immédiats pour les changements critiques.

| Situation | Intervalle | Ce qui est polled |
|---|---|---|
| Liste des événements visible | 60s | `eventsEventList` — nouveaux events, changements de statut |
| Fiche d'un événement ouverte | 15s | `eventsEventSpotsCount` — compteur de places (léger) |
| Mes inscriptions visible | 30s | `eventsRegistrationList` — statut de mes events |
| FCM push reçu (`runConfirmed`, etc.) | Immédiatement | Refresh de la fiche event concernée |

L'intervalle de 15s sur la fiche event est volontaire : voir le compteur se remplir vers le seuil est une mécanique d'urgence engageante pour l'utilisateur.

```graphql
# Query légère pour le compteur de places — appelée en polling toutes les 15s
query {
  eventsEventSpotsCount(eventId: "...") {
    registered
    threshold
    available
    status
  }
}
```

---

## Récapitulatif des intervalles

| Écran / contexte | Intervalle | Query |
|---|---|---|
| Conversation ouverte | 3s | messages + typing users |
| Liste conversations | 5s | conversation list (unread) |
| Fiche événement | 15s | spots count |
| Mes inscriptions | 30s | registration list |
| Badge notifications + messages | 30s | `accountsNotificationUnreadCount` + `messagingUnreadTotal` |
| Écran notifications | 10s | notification list (archived=false) |
| Liste événements | 60s | event list |
| Tap onglet Notifications | Immédiat | `notificationsNotificationMarkAllRead` → badge cloche → 0 |
| Tap sur conversation | Immédiat | `messagingMessageMarkConversationRead` → badge bulle décrémenté |
| App en background | FCM seulement | — |

---

## Packages Flutter impliqués

| Package | Usage |
|---|---|
| `firebase_messaging` | Réception des FCM push (data + notification) |
| `graphql_flutter` | Queries de polling via `Query` widget ou `client.query` |
| `dart:async` `Timer.periodic` | Polling à intervalle fixe sur les écrans actifs |

Le polling est **stoppé automatiquement** quand l'écran est démonté (`dispose()`) ou quand l'app passe en background.
