# 06 — API GraphQL

## Point d'entrée

```
POST /graphql/
Content-Type: application/json
Authorization: Basic <base64(username:password)>   ← toutes les requêtes (app)
Token: <64 chars>                                  ← requêtes authentifiées (user)
language: fr                                       ← recommandé
```

GraphiQL activé en dev et staging, désactivé en production.

Voir [05-authentification.md](./05-authentification.md) pour le flow complet.

---

## Convention de nommage

Format : **`<app><Model><Action>`** en camelCase strict.

| Partie | Valeurs possibles |
|---|---|
| `app` | `accounts`, `events`, `messaging`, `notifications`, `community`, `geography` |
| `Model` | PascalCase du modèle principal |
| `Action` (query) | `List`, `Detail`, `Me`, `Count`, `UnreadCount`, `Search`, `ByBuddyCode`, `SpotsCount` |
| `Action` (mutation) | Verbe : `Register`, `Cancel`, `Send`, `MarkRead`, `RequestOtp`, `VerifyOtp`, `Update`, `Upload`, `Like`, `Select`, `Generate`, `Save` |

```graphql
# ✅ Correct
accountsUserMe
eventsEventList
messagingMessageSend
notificationsNotificationMarkAllRead

# ❌ Interdit
getUser
listEvents
send_message
markRead
```

---

## Norme GraphQL — Statuts et erreurs (mutations)

### Structure de retour d’une mutation

Toutes les mutations qui retournent un **Payload** suivent le **même patron** à trois champs. Les trois sont **toujours présents ensemble**.

| Champ (GraphQL) | Type | Rôle |
|---|---|---|
| `status` | `Boolean!` | `true` = succès, `false` = échec |
| `errors` | `JSONObject!` | Dictionnaire des erreurs ; **`{}` vide si succès** — jamais `null` |
| `<ressource>` | `Field` nullable | Objet créé / mis à jour / utile à la réponse ; **`null` si échec** |

Schéma SDL :

```graphql
scalar JSONObject   # Objet JSON : {} si succès ; { "clef": "message traduit" } si échec

type ExampleMutationPayload {
  status: Boolean!
  errors: JSONObject!
  registration: EventRegistration   # nom du 3e champ = ressource concernée
}
```

### Implémentation Graphene (Python)

```python
import graphene

class ExampleMutationPayload(graphene.ObjectType):
    status = graphene.Boolean(required=True, description="True if operation was successful")
    errors = graphene.JSONString(required=True, description="Error dict if failed; empty {} if success")
    registration = graphene.Field(EventRegistrationType, description="Created/updated object if successful")
```

`graphene.JSONString` sérialise un `dict` Python en JSON ; côté client, parser comme objet JSON (même sémantique que `JSONObject` en SDL).

### Succès

```python
return ExampleMutation(
    status=True,
    errors={},                    # toujours un dict vide — jamais None
    registration=registration,
)
```

### Échec

```python
return ExampleMutation(
    status=False,
    errors={"email": translate("errors", "email_is_required", language)},
    registration=None,
)
```

La **clé** du dictionnaire `errors` identifie le champ ou la catégorie d’erreur (souvent le nom du paramètre GraphQL ou une clé standard ci-dessous).

### Clés d’erreur standardisées

| Clé | Quand l’utiliser |
|---|---|
| `email` | Validation email |
| `password` | Validation mot de passe |
| `token` | Problème de token (invalide, expiré) |
| `permission` | Accès refusé |
| `authentication` | Échec d’authentification |
| `access_status` | Compte désactivé / suspendu |
| `language` | Langue invalide |
| `database` | Erreur à la sauvegarde en base |
| `rate_limit` | Limite de débit atteinte |
| `general` | Erreur inattendue (filet `except Exception`) |
| *(nom de paramètre)* | Objet introuvable ou validation sur ce champ (ex. `event_id`, `user_id`) |

### Messages traduits

Tous les messages dans `errors` passent par `translate()` — **jamais de chaîne en dur** :

```python
from apps.i18n.utils import translate

errors = {"permission": translate("errors", "access_denied", language)}
errors = {"email": translate("errors", "email_is_required", language)}
errors = {"rate_limit": translate("errors", "otp_rate_limit_exceeded", language, minutes=remaining)}
```

`language` vient du décorateur `@extract_language` (header `language`).

### Hiérarchie try/except dans `mutate`

```python
def mutate(root, info, application_access, user_access, language, ...):
    try:
        if not has_permission:
            return MyMutation(status=False, errors={"permission": translate(...)}, my_object=None)
        try:
            obj = MyModel.objects.get(id=my_id)
        except MyModel.DoesNotExist:
            return MyMutation(status=False, errors={"my_id": translate(...)}, my_object=None)
        if business_rule_fails:
            return MyMutation(status=False, errors={"field": translate(...)}, my_object=None)
        try:
            obj.save()
            return MyMutation(status=True, errors={}, my_object=obj)
        except Exception:
            return MyMutation(
                status=False,
                errors={"database": translate("errors", "database_error", language)},
                my_object=None,
            )
    except Exception as e:
        return MyMutation(status=False, errors={"general": str(e)}, my_object=None)
```

### HTTP 200 et erreurs métier

En cas d’échec métier (`status=False`), la réponse HTTP reste **200** ; le client lit **`status`** et **`errors`**, pas le code HTTP.

### Nommage RunDate (pas `portal_*`)

Les mutations suivent **`<app><Model><Action>`** (camelCase), pas le préfixe `portal_` d’autres projets. Chaque app peut exposer un type Graphene regroupant ses champs `Field` sur le schéma racine.

### Mutations retournant seulement `Boolean`

Certaines mutations documentées retournent encore `Boolean` ; **cible** : les faire évoluer vers un Payload minimal `{ status, errors }` pour homogénéité.

---

## Pagination — Infinite scroll

Convention **offset/limit** sur toutes les queries retournant des listes. Toutes les listes supportent le **infinite scroll** côté Flutter.

```graphql
type EventPage             { items: [RunDateEvent!]!       total: Int!  hasMore: Boolean! }
type UserPage              { items: [User!]!                total: Int!  hasMore: Boolean! }
type NotificationPage      { items: [AppNotification!]!    total: Int!  hasMore: Boolean! }
type RegistrationPublicPage{ items: [RegistrationPublicItem!]! total: Int! hasMore: Boolean! }
type EventInvitationPage   { items: [EventInvitation!]!    total: Int!  hasMore: Boolean! }
```

**Pattern Flutter — infinite scroll :**
```
1re page  → offset=0,  limit=20  → hasMore=true  → Flutter charge la page
2e page   → offset=20, limit=20  → hasMore=true  → déclenché à ~80% du scroll
3e page   → offset=40, limit=20  → hasMore=false → stop
```

**Règles obligatoires :**
- Tri stable obligatoire : toujours un tri secondaire `id_asc` pour éviter doublons/trous entre pages
- `hasMore` est la seule condition de déclenchement (pas `items.length == limit`)
- `total` affiché dans l'en-tête de liste (ex: "142 membres")

**Page size recommandée par listing :**

| Listing | `limit` défaut | Raison |
|---|---|---|
| `accountsUserSearch` (membres) | 20 | Cartes profil avec photos |
| `eventsEventList` | 20 | Cartes événements détaillées |
| `eventsEventRegistrationPublicList` | 30 | Lignes légères |
| `messagingConversationList` | 30 | Lignes légères |
| `accountsNotificationList` | 30 | Lignes légères |
| `communityFeedList` (photos) | 24 | Grille 3 colonnes (multiple de 3) |

---

## Types de sortie — Stats et profils

### `UserStats` — statistiques agrégées d'un membre

Calculées dynamiquement via annotations ORM (pas de cache). Incluses sur tout objet `User` retourné par GraphQL.

```graphql
type UserStats {
  connectionsCount: Int!   # crush mutuels actifs (UserLike bidirectionnel)
  totalRuns:        Int!   # RunGroup(status=completed) dont l'user est membre
  totalKm:          Float! # somme approx_distance_km des runs complétés
  averageRating:    Float  # null si aucune note reçue encore
}
```

Le champ `stats: UserStats!` est disponible sur tout type `User` dans le schéma :

```graphql
# Profil d'un membre — accès complet aux stats
query {
  accountsUserById(userId: "...") {
    id
    firstName
    photoThumbnail
    paceLabel
    badge
    isVerified
    stats {
      connectionsCount
      totalRuns
      totalKm
      averageRating
    }
  }
}

# Liste membres — stats incluses dans chaque item
query {
  accountsUserSearch(limit: 20, offset: 0) {
    total
    hasMore
    items {
      id
      firstName
      stats { totalRuns totalKm averageRating }
    }
  }
}
```

**Calcul backend — annotations ORM (N+1 safe) :**

Les sélecteurs `get_user_by_id` et `get_user_list` annotent le queryset en une seule requête SQL :

```python
from django.db.models import Count, Avg, Sum, Q, F

qs = User.objects.annotate(
    connections_count=Count(
        'likes_given',
        filter=Q(likes_given__to_user__likes_given__to_user=F('id')),
        distinct=True,
    ),
    total_runs=Count(
        'run_groups',
        filter=Q(run_groups__status='completed'),
        distinct=True,
    ),
    total_km=Sum(
        'run_groups__event__approx_distance_km',
        filter=Q(run_groups__status='completed'),
    ),
    average_rating=Avg('ratings_received__overall_rating'),
)
```

Pas de cache. Acceptable pour le volume RunDate. À réévaluer si montée en charge.

---

## Types d'entrée — Filtres et tri

### Filtres événements

```graphql
input EventFilters {
  cityId: ID                   # filtrer par ville
  neighborhoodId: ID           # filtrer par quartier
  category: EventCategory      # catégorie : RUNNING, PICNIC, MIXED_TRAINING
  paceLabel: PaceLabel         # allure : TORTUE_SOCIALE → ROAD_RUNNER
  distanceLabel: DistanceLabel # distance : CAFE_CREME → ULTRA_SOCIAL
  status: EventStatus          # upcoming / confirmed / past / all (défaut: upcoming)
  dateFrom: DateTime           # événements à partir de cette date
  dateTo: DateTime             # événements jusqu'à cette date
  hasSpots: Boolean            # true = seulement les événements avec places disponibles
  isConfirmed: Boolean         # true = seuil atteint, false = en attente de confirmation
}

enum EventStatus {
  UPCOMING   # événements futurs (deadline non dépassée)
  CONFIRMED  # seuil atteint (is_confirmed = true)
  PAST       # événements passés
  ALL        # tous sans filtre de date
}

enum EventOrderBy {
  DATE_ASC        # par défaut — plus proche en premier
  DATE_DESC       # plus loin en premier
  SPOTS_ASC       # places restantes croissant
  SPOTS_DESC      # places restantes décroissant
  CREATED_AT_DESC # plus récemment créés
}

enum EventCategory {
  RUNNING          # Course à pied
  PICNIC           # Picnic rencontre
  MIXED_TRAINING   # Entraînement mixte
}

enum PaceLabel {
  TORTUE_SOCIALE
  CANARD_DU_PARC
  RENARD_RUSE
  CHEVREUIL_DE_LONGUEUIL
  ROAD_RUNNER
}

enum DistanceLabel {
  CAFE_CREME
  TOUR_DU_QUARTIER
  DEMI_FOLIE
  MARATHON_DE_JASETTE
  ULTRA_SOCIAL
}
```

### Filtres membres

```graphql
input UserFilters {
  buddyCode: String      # recherche exacte par code ANIMAL-MOT
  cityId: ID             # filtrer par ville
  neighborhoodId: ID     # filtrer par quartier
  paceLabel: PaceLabel   # filtrer par allure
  isLievre: Boolean      # seulement les pace leaders
  isVerified: Boolean    # seulement les profils vérifiés
}

enum UserOrderBy {
  CREATED_AT_DESC   # plus récents en premier (défaut)
  FIRST_NAME_ASC    # par prénom A→Z
  XP_DESC           # plus d'expérience en premier
}
```

---

## Protection

- **Depth limiting** : requêtes imbriquées limitées à 7 niveaux
- **Rate limiting OTP** : 5 tentatives/heure/numéro en base (pas de Redis)
- **Tous les resolvers** vérifient `info.context.user.is_authenticated` si l'opération est privée

---

## Queries

### `accounts`

```graphql
# Profil de l'utilisateur connecté
accountsUserMe: User

# Profil public par UUID
accountsUserDetail(id: ID!): User

# Recherche rapide par buddy code (ANIMAL-MOT) — lookup exact
accountsUserByBuddyCode(code: String!): User

# Liste/recherche de membres avec filtres
accountsUserSearch(
  filters: UserFilters
  orderBy: UserOrderBy = CREATED_AT_DESC
  limit: Int = 20
  offset: Int = 0
): UserPage

# Crush mutuels de l'utilisateur connecté (= ses "connexions")
accountsUserConnectionList(
  limit: Int = 30
  offset: Int = 0
): UserPage

# Liste des utilisateurs bloqués par l'utilisateur connecté
accountsUserBlockList: [User!]!

# Galerie de photos de profil d'un utilisateur
accountsUserPhotoGallery(userId: ID!): [UserPhoto!]!

# ─── Vérification d'identité ───

# Statut de ma demande de vérification en cours
accountsUserVerificationStatus: UserVerification

# Créneaux de vérification disponibles
accountsVerificationSlotList(
  dateFrom: Date
  dateTo: Date
): [VerificationSlot!]!
```

**Notes `accountsUserSearch`** :
- Exclut les profils supprimés, suspendus, et les utilisateurs bloqués par le demandeur
- Les champs sensibles (`phone`, `fcm_token`, `last_seen_at`) sont masqués pour les profils tiers
- `buddyCode` dans `UserFilters` : match exact insensible à la casse

### `events`

```graphql
# Liste paginée des événements avec filtres et tri
eventsEventList(
  filters: EventFilters
  orderBy: EventOrderBy = DATE_ASC
  limit: Int = 20
  offset: Int = 0
): EventPage

# Détail d'un événement
eventsEventDetail(id: ID!): RunDateEvent

# Points de rencontre filtrables
eventsMeetingPointList(
  neighborhoodId: ID
  cityId: ID
  type: String       # park / cafe / landmark
  limit: Int = 50
  offset: Int = 0
): [MeetingPoint]

# Inscriptions de l'utilisateur connecté
eventsRegistrationList(
  status: String     # confirmed / waitlisted / cancelled / all (défaut: confirmed)
  upcoming: Boolean  # true = seulement les futurs (défaut: true)
): [EventRegistration]

# Nombre de places restantes pour un événement
eventsEventSpotsCount(eventId: ID!): Int
```

**Notes `eventsEventList`** :
- `status: UPCOMING` (défaut) — exclut les événements passés et annulés
- `hasSpots: true` — filtre sur `max_capacity - total_registered > 0`
- `paceLabel` / `distanceLabel` — les enums correspondent aux choices Django
- Sans filtres, retourne les 20 prochains événements par date croissante

### `messaging`

```graphql
# Liste des conversations — filtrée, triée
messagingConversationList(
  type: ConversationType       # group / private / all (défaut: all)
  archived: Boolean = false    # false = actives, true = archivées
  eventId: ID                  # filtrer par événement associé
  limit: Int = 30
  offset: Int = 0
): ConversationPage

# Détail d'une conversation avec messages paginés (les plus récents en premier)
messagingConversationDetail(
  id: ID!
  limit: Int = 50
  offset: Int = 0
): Conversation

# Nombre total de messages non lus (toutes conversations actives)
messagingUnreadTotal: Int

# Demandes de contact reçues en attente
messagingContactRequestList(
  direction: ContactRequestDirection = RECEIVED  # RECEIVED / SENT
  status: ContactRequestStatus = PENDING         # PENDING / ACCEPTED / DECLINED / ALL
): [ContactRequest]

enum ConversationType { GROUP  PRIVATE  ALL }
enum ContactRequestDirection { RECEIVED  SENT }
enum ContactRequestStatus { PENDING  ACCEPTED  DECLINED  ALL }
```

**Notes `messagingConversationList`** :
- Trie par `last_message.timestamp DESC` par défaut (les plus actives en premier)
- Inclut `unread_count` calculé depuis `last_read_at` de l'utilisateur courant
- N'expose jamais les conversations où l'utilisateur n'est pas membre

### `notifications`

```graphql
notificationsNotificationList(
  unreadOnly: Boolean
  limit: Int = 30
  offset: Int = 0
): NotificationPage
```

### `community` — Queries

```graphql
# Feed global de photos (toutes photos d'événements, ordre anti-chronologique)
communityFeedList(
  limit: Int = 30
  offset: Int = 0
): EventPhotoPage

# FAQ — retourne les deux langues (_fr et _en), Flutter choisit selon User.language
communityFaqList: [FaqItem!]!

# Règles de la communauté — retourne les deux langues, Flutter choisit
communityRuleList: [CommunityRule!]!

# Document légal courant — retourne title_fr/en et content_fr/en
communityLegalDocument(type: LegalDocumentType!): LegalDocument

enum LegalDocumentType { TERMS  PRIVACY }

# Questions pour l'écran d'attente
communityWaitingQuestionList: [WaitingQuestion]

# Membres d'un événement avec filtres optionnels
communityEventMemberList(
  eventId: ID!
  paceLabel: PaceLabel   # filtrer par allure dans le groupe
  limit: Int = 50
  offset: Int = 0
): UserPage

# Photos d'un événement (publiques, triées par order ASC)
communityEventPhotoList(
  eventId: ID!
  limit: Int = 50
  offset: Int = 0
): EventPhotoPage
```

---

## Mutations

### `events` — Lièvre

```graphql
# Voir ses invitations Lièvre (en attente ou passées)
eventsLievreInvitationList(
  status: LievreInvitationStatus = PENDING   # PENDING / ACCEPTED / DECLINED / ALL
): [LievreInvitation!]!

# Répondre à une invitation Lièvre
eventsLievreInvitationRespond(
  invitationId: ID!
  accept: Boolean!
): LievreInvitationPayload

enum LievreInvitationStatus { PENDING  ACCEPTED  DECLINED  ALL }

type LievreInvitationPayload {
  status: Boolean!
  errors: JSONObject!
  invitation: LievreInvitation
}
```

**Notes** :
- Seuls les admins peuvent créer des invitations (via Django Admin uniquement, pas de mutation publique)
- Un Lièvre peut décliner — l'admin est notifié pour inviter quelqu'un d'autre
- Après acceptation, `eventsEventRegister` détecte automatiquement l'invitation et assigne `is_priority_lievre=True`

### `accounts` — Support

```graphql
# Formulaire de contact (ContactFormScreen)
accountsSupportTicketCreate(
  subject: SupportTicketSubject!   # CITY / MEETING_POINT / ORGANIZER / LIEVRE / BUG / OTHER
  message: String!
  email: String
): Boolean

enum SupportTicketSubject { CITY  MEETING_POINT  ORGANIZER  LIEVRE  BUG  OTHER }
```

### `accounts` — Photos de profil

```graphql
# Mettre à jour la photo principale
accountsUserUploadPhoto(photo: Upload!): User

# Ajouter une photo à la galerie (max 6)
accountsUserPhotoAdd(photo: Upload!): UserPhoto

# Supprimer une photo de la galerie
accountsUserPhotoDelete(photoId: ID!): Boolean

# Réordonner les photos de la galerie
accountsUserPhotoReorder(photoIds: [ID!]!): [UserPhoto!]!
```

### `accounts` — Blocage

```graphql
# Bloquer un utilisateur
accountsUserBlock(userId: ID!): Boolean

# Débloquer un utilisateur
accountsUserUnblock(userId: ID!): Boolean
```

### Signalement de contenu

```graphql
# Signaler une photo de profil, photo d'événement, message ou profil
communityContentReport(
  contentType: ContentReportType!   # USER_PHOTO / EVENT_PHOTO / MESSAGE / USER_PROFILE
  contentId: ID!                    # UUID de l'objet signalé
  reason: ContentReportReason!      # INAPPROPRIATE / HARASSMENT / SPAM / FAKE_PROFILE / OTHER
  notes: String                     # commentaire optionnel
): Boolean

enum ContentReportType { USER_PHOTO  EVENT_PHOTO  MESSAGE  USER_PROFILE }
enum ContentReportReason { INAPPROPRIATE  HARASSMENT  SPAM  FAKE_PROFILE  OTHER }
```

### `community` — Photos d'événements

```graphql
# Uploader une photo d'événement (max 10 par user par événement)
communityEventPhotoUpload(
  eventId: ID!
  photo: Upload!
  description: String
): EventPhoto

# Supprimer sa propre photo d'événement
communityEventPhotoDelete(photoId: ID!): Boolean

# Liker une photo
communityPhotoLike(photoId: ID!): Boolean

# Retirer son like
communityPhotoUnlike(photoId: ID!): Boolean
```

### `accounts` — Auth

```graphql
# ─── Public : @require_authorization seulement (pas de Token requis) ───
accountsUserAccessRequestOtp(phone: String!): RequestOtpPayload
accountsUserAccessResendOtp(phone: String!): RequestOtpPayload    # renvoi code
accountsUserAccessVerifyOtp(phone: String!, code: String!): UserAccessTokenPayload

# ─── Protégées : @require_authorization + @require_user_access_token ───

# Sauvegarder les réponses onboarding (jusqu'à 20 questions)
accountsUserSaveOnboardingAnswers(
  answers: [OnboardingAnswerInput!]!
): SaveOnboardingAnswersPayload

# Générer 2-3 propositions de bio via Claude Sonnet 4.6
# Utilise les réponses onboarding + données profil
accountsUserBioGenerate: BioGeneratePayload

# Sélectionner et enregistrer une des propositions générées
accountsUserBioSelect(bio: String!): User

# Mise à jour du profil
accountsUserUpdateProfile(
  firstName: String
  lastName: String
  bio: String
  paceLabel: String
  distanceLabel: String
  runningGoals: [String]
  neighborhood: String
): User

# ─── Flux profil — objectifs et bio ───
# 1. Sauvegarde quiz : accountsUserSaveOnboardingAnswers
# 2. Génération / choix bio : accountsUserBioGenerate → accountsUserBioSelect
# 3. Ajustements profil : accountsUserUpdateProfile (runningGoals, bio, paceLabel, distanceLabel, etc.)
# Voir aussi [19-bio-generation.md](./19-bio-generation.md) et `04-modeles-django.md` (section User).

# Upload de photo de profil
accountsUserUploadPhoto(photo: Upload!): User

# Sauvegarder la préférence de langue
accountsUserUpdateLanguage(language: String!): Boolean   # "fr" | "en"

# Mise à jour du token FCM (Firebase push)
accountsUserUpdateFcmToken(token: String!): Boolean

# Like après un run (système Crush)
accountsUserLike(userId: ID!, runGroupId: ID!): Boolean

# Lier un ami via buddy code
accountsBuddyCodeLink(code: String!): BuddyLinkPayload

# ─── Vérification d'identité ───

# Soumettre un selfie → crée UserVerification(status=pending)
accountsUserUploadVerificationSelfie(photo: Upload!): UserVerificationPayload

# Annuler une demande en attente
accountsUserVerificationCancel: Boolean

# Statut de ma demande en cours
accountsUserVerificationStatus: UserVerification

# Réserver un créneau de vérification (optionnel)
accountsVerificationSlotBook(slotId: ID!): Boolean

type UserVerification {
  id: ID!
  status: String!             # pending / approved / rejected / cancelled
  submittedAt: DateTime!
  reviewedAt: DateTime
  rejectionReason: String     # photo_unclear / face_not_visible / profile_mismatch / other
  slot: VerificationSlot
}

type UserVerificationPayload {
  status: Boolean!
  errors: JSONObject!
  verification: UserVerification
}

# Mettre à jour les préférences de notifications
accountsUserUpdateNotificationPreferences(
  pushRunConfirmed: Boolean
  pushRunToday: Boolean
  pushDeadlineReminder: Boolean
  pushSpotFreed: Boolean
  pushCrushMatch: Boolean
  pushContactRequest: Boolean
  pushMessage: Boolean
  pushRateReminder: Boolean
): UserNotificationPreferences

# Mettre à jour les préférences de profil
accountsUserUpdatePrivacySettings(
  profileVisibility: ProfileVisibility   # PUBLIC / CONNECTIONS_ONLY
  wantsFeaturedProfile: Boolean
): User

# Suspendre son propre compte
accountsUserSuspend: Boolean

# Supprimer son compte (soft delete)
accountsUserDeleteAccount(reason: String): Boolean

# Accepter les CGU / politique de confidentialité
accountsUserAcceptLegal(
  documentType: LegalDocumentType!   # TERMS / PRIVACY
  documentVersion: String!
): Boolean

enum ProfileVisibility { PUBLIC  CONNECTIONS_ONLY }
enum LegalDocumentType { TERMS  PRIVACY }
```

### `events`

```graphql
# Catalogues de matériel et accompagnants (chargés une fois à l'ouverture de l'écran d'inscription)
eventsEquipmentTypeList: [EquipmentType!]!
eventsCompanionTypeList: [CompanionType!]!

type EquipmentType { id: ID! nameFr: String! nameEn: String! iconName: String! category: String! }
type CompanionType { id: ID! nameFr: String! nameEn: String! iconName: String! requiresNote: Boolean! }

# Liste publique des inscrits à un événement — visible aux inscrits seulement
eventsEventRegistrationPublicList(
  eventId: ID!
  limit: Int = 30
  offset: Int = 0
): RegistrationPublicPage

type RegistrationPublicItem {
  userId: ID!
  firstName: String!
  photoThumbnail: String
  paceLabel: String
  distanceLabel: String
  isVerified: Boolean!
  badge: String
  isPreferredByMe: Boolean!    # true si déjà dans mes preferred_partners
}

# S'inscrire à un événement avec préférences
eventsEventRegister(
  eventId: ID!
  paceLabel: PaceLabel
  distanceLabel: DistanceLabel
  equipmentItemIds: [ID!]      # IDs de EquipmentType (remplace equipment ArrayField)
  companionTypeIds: [ID!]      # IDs de CompanionType (remplace companionType CharField)
  companionNote: String        # Précision libre ex: "Labrador, très gentil"
  buddyCode: String            # code ANIMAL-MOT — lien mutuel automatique si buddy déjà inscrit
): EventRegistrationPayload

# Ajouter / retirer un partenaire préféré (soft preference — best effort dans le matching)
eventsEventRegisterAddPreferredPartner(eventId: ID!, userId: ID!): Boolean
eventsEventRegisterRemovePreferredPartner(eventId: ID!, userId: ID!): Boolean

# Invitations à un événement
eventsEventInviteSend(eventId: ID!, toUserId: ID!, message: String): EventInvitationPayload
eventsEventInviteRespond(invitationId: ID!, accept: Boolean!): EventInvitationPayload
eventsEventInviteSentList(eventId: ID!): [EventInvitation!]!
eventsEventInviteReceivedList(limit: Int = 20, offset: Int = 0): EventInvitationPage

type EventInvitationPayload { status: Boolean!  errors: JSONObject!  invitation: EventInvitation }

# Annuler son inscription
eventsEventCancelRegistration(
  eventId: ID!
  reason: String    # raison optionnelle
): Boolean

# Soumettre une note multi-dimensionnelle après un run
eventsEventSubmitRating(
  eventId: ID!
  overallRating: Float!
  trailRating: Float
  groupRating: Float
  aperoRating: Float
  comment: String
  isCommentPublic: Boolean
  wantsRerunWithGroup: Boolean
): EventRatingPayload

type EventRatingPayload {
  status: Boolean!
  errors: JSONObject!
  rating: EventRating
}
```

### `messaging`

```graphql
# Envoyer un message
messagingMessageSend(conversationId: ID!, content: String!): Message

# Marquer tous les messages d'une conversation comme lus (met à jour last_read_at)
messagingMessageMarkConversationRead(conversationId: ID!): Boolean

# Archiver une conversation (individuel — les autres membres ne voient pas)
messagingConversationArchive(conversationId: ID!): Boolean

# Désarchiver une conversation
messagingConversationUnarchive(conversationId: ID!): Boolean

# Couper les notifications push pour une conversation
messagingConversationMute(conversationId: ID!): Boolean

# Réactiver les notifications push
messagingConversationUnmute(conversationId: ID!): Boolean

# Quitter une conversation de groupe (ne peut pas quitter les privées)
messagingConversationLeave(conversationId: ID!): Boolean

# ─── Contact requests ───

# Envoyer une demande de contact privé (doit avoir un run commun)
messagingContactRequestSend(
  toUserId: ID!
  runGroupId: ID!
  introMessage: String   # message optionnel (max 500 chars)
): ContactRequestPayload

# Accepter une demande → crée la conversation privée
messagingContactRequestAccept(requestId: ID!): ContactRequestPayload

# Refuser une demande
messagingContactRequestDecline(requestId: ID!): Boolean
```

**Typing indicator (polling toutes les 2s quand la conversation est ouverte) :**
```graphql
# Heartbeat "je suis en train d'écrire" — appelé toutes les 2s pendant la frappe
messagingTypingHeartbeat(conversationId: ID!): Boolean

# Retourne les users actuellement en train d'écrire dans cette conversation
messagingConversationTypingUsers(conversationId: ID!): [TypingUser!]!

type TypingUser { userId: ID!  firstName: String! }
```

**Règles métier** :
- `messagingContactRequestSend` : échoue si les deux utilisateurs ne partagent pas le même `RunGroup`
- `messagingContactRequestSend` : échoue si une `Conversation(type=private)` existe déjà entre les deux
- Un crush mutuel (`UserLike` x2) ouvre **automatiquement** une conversation privée **sans passer par ContactRequest**
- `messagingConversationArchive` : la conversation reste dans la liste si `archived=true`, n'est jamais supprimée
- `messagingTypingHeartbeat` upsert `TypingStatus(expires_at=now+5s)` — auto-expire sans requête de stop

### `notifications`

```graphql
# Marquer une notification comme lue
notificationsNotificationMarkRead(id: ID!): Boolean

# Marquer toutes les notifications comme lues
notificationsNotificationMarkAllRead: Boolean

# Archiver / désarchiver une notification individuelle
notificationsNotificationArchive(id: ID!): Boolean
notificationsNotificationUnarchive(id: ID!): Boolean

# Compteur de notifications non lues — query légère pour le badge (polled toutes les 30s)
accountsNotificationUnreadCount: Int!

# Total messages non lus toutes conversations confondues — badge onglet Messages (polled toutes les 30s)
messagingUnreadTotal: Int!
```

**Filtre `archived` sur la liste de notifications :**

```graphql
notificationsNotificationList(
  unreadOnly: Boolean
  archived: Boolean = false    # false = actives (défaut), true = archivées
  limit: Int = 30
  offset: Int = 0
): NotificationPage
```

**Comportement badge — clearing au tap :**

| Onglet tapé | Action Flutter | Résultat |
|---|---|---|
| Onglet Notifications | `notificationsNotificationMarkAllRead` | `accountsNotificationUnreadCount` → 0, badge disparaît |
| Onglet Messages | Fetch `messagingUnreadTotal` | Badge mis à jour avec le total actuel |
| Conversation ouverte | `messagingMessageMarkConversationRead(conversationId)` | `messagingUnreadTotal` décrémenté, badge ajusté au poll suivant (3s) |

`messagingUnreadTotal` est calculé côté backend : somme des messages dont `timestamp > ConversationMember.last_read_at` pour toutes les conversations actives non-archivées de l'utilisateur.

---

## Payloads — types référencés dans le schéma

Référence croisée des types **Payload** ; le patron `status` + `errors` + champ ressource est détaillé dans la section **Norme GraphQL — Statuts et erreurs** ci-dessus. Jamais d’exception GraphQL brute pour les erreurs métier — HTTP **200**, le client lit `status` et `errors`.

**Exemple de réponse JSON (succès) :**

```json
{
  "data": {
    "eventsEventRegister": {
      "status": true,
      "errors": {},
      "registration": { "id": "…", "status": "confirmed" }
    }
  }
}
```

**Exemple de réponse JSON (échec) :**

```json
{
  "data": {
    "eventsEventRegister": {
      "status": false,
      "errors": { "event_id": "Cet événement n'existe pas." },
      "registration": null
    }
  }
}
```

```graphql
type EventRegistrationPayload {
  status: Boolean!
  errors: JSONObject!
  registration: EventRegistration
}

type UserAccessTokenPayload {
  status: Boolean!
  token: String        # UserAccessToken.token (64 chars)
  isNewUser: Boolean
  errors: JSONObject!
}

type RequestOtpPayload {
  status: Boolean!
  errors: JSONObject!
}

type ConversationPage {
  items: [Conversation!]!
  total: Int!
  hasMore: Boolean!
}

type EventPhotoPage {
  items: [EventPhoto!]!
  total: Int!
  hasMore: Boolean!
}

type ContactRequestPayload {
  status: Boolean!
  errors: JSONObject!
  contactRequest: ContactRequest
  conversation: Conversation   # rempli après acceptation
}

input OnboardingAnswerInput {
  questionId: String!   # q1 … q20
  questionText: String!
  answer: String!
  category: String
}

type SaveOnboardingAnswersPayload {
  status: Boolean!
  errors: JSONObject!
  savedCount: Int
}

type BioGeneratePayload {
  status: Boolean!
  errors: JSONObject!
  proposals: [String!]!  # 2-3 propositions générées par Claude
}

type BuddyLinkPayload {
  status: Boolean!
  errors: JSONObject!
  buddyUser: User
}
```

## Ordre des décorateurs sur les résolveurs

```python
@log_graphql_request       # toujours en premier
@require_authorization     # toujours présent
@require_user_access_token # seulement si auth requise
@extract_language          # toujours présent
def mutate(self, info, application_access, user_access, language, ...):
    ...
```

---

## Implémentation des filtres côté Django

Les filtres sont implémentés dans des **selectors** dédiés, jamais directement dans les résolveurs.

```python
# apps/events/selectors.py

def get_event_list(filters=None, order_by="date", limit=20, offset=0):
    """
    Returns a filtered, ordered, paginated queryset of RunDateEvent.
    Always excludes soft-deleted events.
    """
    qs = RunDateEvent.active.select_related(
        "city", "neighborhood", "meeting_point", "lievre"
    ).prefetch_related("registrations")

    if filters:
        if filters.get("city_id"):
            qs = qs.filter(city_id=filters["city_id"])
        if filters.get("neighborhood_id"):
            qs = qs.filter(neighborhood_id=filters["neighborhood_id"])
        if filters.get("pace_label"):
            qs = qs.filter(pace_label=filters["pace_label"])
        if filters.get("distance_label"):
            qs = qs.filter(distance_label=filters["distance_label"])
        if filters.get("is_confirmed") is not None:
            qs = qs.filter(is_confirmed=filters["is_confirmed"])
        if filters.get("date_from"):
            qs = qs.filter(date__gte=filters["date_from"])
        if filters.get("date_to"):
            qs = qs.filter(date__lte=filters["date_to"])
        if filters.get("has_spots"):
            # Annoter pour filtrer sur les places restantes
            qs = qs.annotate(
                registered_count=Count("registrations", filter=Q(registrations__status="confirmed"))
            ).filter(registered_count__lt=F("max_capacity"))

        status = filters.get("status", "upcoming")
        if status == "upcoming":
            qs = qs.filter(deadline__gt=now())
        elif status == "past":
            qs = qs.filter(date__lt=now())
        elif status == "confirmed":
            qs = qs.filter(is_confirmed=True, deadline__gt=now())
        # status == "all" → pas de filtre de date

    ORDER_MAP = {
        "DATE_ASC": "date",
        "DATE_DESC": "-date",
        "SPOTS_ASC": "registered_count",
        "SPOTS_DESC": "-registered_count",
        "CREATED_AT_DESC": "-created_at",
    }
    qs = qs.order_by(ORDER_MAP.get(order_by, "date"))

    total = qs.count()
    items = list(qs[offset: offset + limit])
    return items, total
```

```python
# apps/accounts/selectors.py

def get_user_list(filters=None, order_by="CREATED_AT_DESC", limit=20, offset=0):
    """Returns non-deleted, non-suspended users matching the given filters."""
    qs = User.active.select_related("city", "neighborhood")

    if filters:
        if filters.get("buddy_code"):
            qs = qs.filter(buddy_code__iexact=filters["buddy_code"])
        if filters.get("city_id"):
            qs = qs.filter(city_id=filters["city_id"])
        if filters.get("neighborhood_id"):
            qs = qs.filter(neighborhood_id=filters["neighborhood_id"])
        if filters.get("pace_label"):
            qs = qs.filter(pace_label=filters["pace_label"])
        if filters.get("is_lievre") is not None:
            qs = qs.filter(is_lievre=filters["is_lievre"])
        if filters.get("is_verified") is not None:
            qs = qs.filter(is_verified=filters["is_verified"])

    ORDER_MAP = {
        "CREATED_AT_DESC": "-created_at",
        "FIRST_NAME_ASC": "first_name",
        "XP_DESC": "-xp",
    }
    qs = qs.order_by(ORDER_MAP.get(order_by, "-created_at"))

    total = qs.count()
    items = list(qs[offset: offset + limit])
    return items, total
```

**Règles N+1** : tous les selectors utilisent `select_related` / `prefetch_related`. Jamais de requête dans une property appelée depuis un résolveur de liste.

---

## Health check (hors GraphQL)

```
GET /health/
→ { "status": "ok" }
```

Non authentifié, utilisé par Docker `HEALTHCHECK` et monitoring externe.

## URL de l'admin Django

L'admin est monté à la **racine `/`** sur le sous-domaine dédié — pas de chemin `/admin/`.

```python
# config/urls.py
urlpatterns = [
    path('graphql/', GraphQLView.as_view(graphiql=settings.GRAPHIQL_ENABLED)),
    path('health/', health_check),
    path('media/', serve_media),
]

# config/urls_admin.py  ← chargé uniquement sur admin.rundate.app
urlpatterns = [
    path('', admin.site.urls),   # ← racine, pas /admin/
]
```

Nginx route selon le `Host` header :
- `api.rundate.app` → `urls.py` (GraphQL uniquement)
- `admin.rundate.app` → `urls_admin.py` (admin à `/`)

Avantage sécurité : l'URL `/admin/` n'existe pas sur l'API publique. L'admin n'est accessible que sur le sous-domaine dédié, lui-même protégé par Cloudflare Zero Trust.
