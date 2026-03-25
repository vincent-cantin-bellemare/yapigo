# Plan de développement RunDate

Stratégie de développement pour l'ensemble du projet : backend Django + app Flutter.

---

## Principe — Slices verticaux

Plutôt que de construire tout le backend puis tout le frontend, on développe **feature par feature** en couvrant backend + Flutter ensemble à chaque étape. Chaque slice est testable de bout en bout avant de passer à la suivante.

Une seule exception : **la Phase 0 est un prérequis absolu** — le squelette backend doit tenir avant de brancher quoi que ce soit côté Flutter.

```
Phase 0  →  Flutter Prep  →  Slice 1  →  Slice 2  →  ...  →  Slice 10
(backend)   (infra mobile)   (auth)      (events)              (avancé)
```

---

## Phase 0 — Fondations backend

> Durée estimée : ~2 semaines. À faire intégralement avant de toucher Flutter.

Ce sont les éléments qui ne peuvent pas être faits "un peu à la fois" — tout doit tenir ensemble avant de brancher un seul écran.

### Infrastructure

- Docker Compose multi-container + Makefile + DevContainer
- Settings multi-environnements (`dev` / `staging` / `production`) — voir [16-settings-multi-env.md](./backend/16-settings-multi-env.md)
- Fichiers `.env` par environnement, volumes dans `/volumes/app/`
- Nginx + Gunicorn configurés — voir [09-environnements.md](./backend/09-environnements.md)
- Dockerfile finalisé — voir [18-dockerfile.md](./backend/18-dockerfile.md)

**Vérification** : `make start-dev` démarre sans erreur.

### Modèles Django

- Les 46 modèles dans leurs 9 apps, tous avec `BaseModel`, `verbose_name`, `related_name`
- Toutes les migrations générées et appliquées
- Voir [04-modeles-django.md](./backend/04-modeles-django.md) pour le catalogue complet

**Vérification** : `make migrate-dev` → zéro erreur.

### Authentification

- `ApplicationAccess` + middleware Basic Auth
- `UserAccessToken` + token opaque 64 chars
- `OtpVerification` + `OtpRateLimit`
- Décorateurs `@require_authorization`, `@require_user_access_token`
- Voir [05-authentification.md](./backend/05-authentification.md)

**Vérification** : `make gql-auth-request-otp` répond avec `status: true`.

### Système i18n

- `TranslationService` + fichiers JSON `fr.json` / `en.json`
- Décorateur `@extract_language`
- Voir [17-i18n.md](./backend/17-i18n.md)

### GraphQL

- Schema Graphene monté (`config/schema.py`)
- Scalar `JSONObject`, depth limiting, introspection désactivée en prod
- Norme `status` / `errors` appliquée partout — voir [06-api-graphql.md](./backend/06-api-graphql.md)
- GraphiQL accessible en dev et staging

### Admin minimal

- Juste assez pour créer des données de test manuellement
- `User`, `RunDateEvent`, `MeetingPoint` enregistrés

### Seeds de base

- Fixtures : villes, quartiers, points de rencontre, questions d'attente
- 1 compte admin, 1 user de test, 1 événement de test
- Voir [10-seeds.md](./backend/10-seeds.md)

**Livrable final Phase 0** : GraphiQL ouvert → `accountsUserAccessRequestOtp` répond → token retourné.

---

## Flutter Prep — Couche réseau

> À faire une fois la Phase 0 terminée, avant le Slice 1.

L'UI Flutter existe déjà (30 écrans, ~29 000 lignes de Dart). Le travail consiste à **remplacer les mocks par une vraie couche réseau** sans casser l'UI.

### Dépendances à ajouter

```yaml
# pubspec.yaml
graphql_flutter: ...        # client GraphQL
flutter_riverpod: ...       # state management
flutter_secure_storage: ... # stockage sécurisé du token
firebase_messaging: ...     # FCM push notifications
image_picker: ...           # upload photos
```

### Architecture à mettre en place

```
lib/
  services/
    graphql_service.dart    # client GraphQL configuré (headers Authorization + Token + language)
    auth_service.dart       # gestion token : save / load / clear
  repositories/
    auth_repository.dart    # méthodes stub → brancher sur GraphQL
    events_repository.dart
    members_repository.dart
    messaging_repository.dart
    notifications_repository.dart
  providers/
    auth_provider.dart      # Riverpod StateNotifier
    events_provider.dart
    ...
```

### Gestion d'erreurs

- Pattern `status` / `errors` reçu du backend → exception typée côté Flutter
- Erreurs réseau (timeout, 500) → snackbar générique
- Erreurs métier (`errors.event_full`) → message traduit affiché dans l'UI

**Livrable Flutter Prep** : app compile, `GraphQLService` configuré, premier `accountsUserAccessRequestOtp` envoyé depuis le code Flutter → réponse reçue dans les logs.

---

## Slice 1 — Auth + Onboarding

> Screens : `splash_screen`, `onboarding_screen`, `signup_wizard_screen`

### Backend

| Mutation / Query | Description |
|---|---|
| `accountsUserAccessRequestOtp` | Demande d'OTP par SMS (Twilio) |
| `accountsUserAccessResendOtp` | Renvoi OTP |
| `accountsUserAccessVerifyOtp` | Validation OTP → retourne token |
| `accountsUserUpdateProfile` | Création du profil (prénom, ville, genre...) |
| `accountsUserUploadPhoto` | Photo de profil |
| `accountsUserSaveOnboardingAnswers` | 20 réponses au quiz |
| `accountsUserBioGenerate` | Génération bio via Claude — voir [19-bio-generation.md](./backend/19-bio-generation.md) |
| `accountsUserBioSelect` | Sélection d'une bio proposée |
| `accountsUserUploadVerificationSelfie` | Upload selfie identité |
| `accountsUserAcceptLegal` | Acceptation CGU / Politique de confidentialité |
| `communityLegalDocument` | Récupérer le contenu légal à afficher |

### Flutter

- `splash_screen` : vérifier token stocké → rediriger vers home ou onboarding
- `signup_wizard_screen` : OTP → profil → photo → quiz → bio → selfie → CGU

### Test

```bash
make gql-auth-request-otp phone="+15141234567"
make gql-auth-verify-otp phone="+15141234567" code="123456"
make gql-accounts-update-profile firstName="Alex" city="montreal"
```

---

## Slice 2 — Événements (liste + home)

> Screens : `events_list_screen`, `home_screen`

### Backend

| Mutation / Query | Description |
|---|---|
| `eventsEventList` | Liste filtrée (ville, quartier, allure, distance, date, statut) avec pagination |
| `communityTestimonialList` | Témoignages pour la section home |
| `geographyCityList` | Villes disponibles |
| `geographyNeighborhoodList` | Quartiers par ville |

### Flutter

- `events_list_screen` : infinite scroll (offset/limit 20), onglets Prochains / Inscrits / Passés, polling toutes les 30s
- `home_screen` : sections dashboard, témoignages, prochain run inscrit

### Test

```bash
make gql-events-list city="montreal" pace="canard_du_parc"
make gql-events-list status="upcoming" limit=20 offset=0
```

---

## Slice 3 — Détail événement + Inscription

> Screens : `event_detail_screen`, `apply_wizard_screen`, `waiting_screen`, `match_reveal_screen`

### Backend

| Mutation / Query | Description |
|---|---|
| `eventsEventDetail` | Données complètes (jauge, point de rencontre masqué si non inscrit) |
| `eventsEquipmentTypeList` | Catalogue équipement (admin-managed) |
| `eventsCompanionTypeList` | Catalogue compagnons (admin-managed) |
| `eventsEventRegister` | Inscription avec allure, distance, équipement, buddy code |
| `eventsEventCancelRegistration` | Désinscription avec raison |
| `eventsEventInviteSend` | Invitation d'un autre membre |
| `eventsEventRegistrationPublicList` | Liste publique des inscrits (si soi-même inscrit) |
| `eventsEventRegisterAddPreferredPartner` | Ajouter un partenaire préféré |
| `communityWaitingQuestionList` | Questions d'attente pour `waiting_screen` |

### Flutter

- `event_detail_screen` : affichage complet, jauge, mon groupe, photos, conversation groupe
- `apply_wizard_screen` : wizard inscription (allure → distance → équipement → compagnon → buddy)
- `waiting_screen` : polling `eventsEventDetail.totalRegistered` toutes les 10s jusqu'à groupe formé
- `match_reveal_screen` : membres du groupe, Lièvre, point de départ

### Test

```bash
make gql-events-detail eventId="abc123"
make gql-events-register eventId="abc123" paceLabel="canard_du_parc" buddyCode="CHAT-RAPIDE"
```

---

## Slice 4 — Profil membre

> Screens : `profile_screen`, `edit_profile_screen`, `bio_quiz_screen`, `run_history_screen`

### Backend

| Mutation / Query | Description |
|---|---|
| `accountsUserMe` | Profil complet de l'utilisateur connecté |
| `accountsUserUpdateProfile` | Mise à jour bio, objectifs, ville, genre... |
| `accountsUserPhotoAdd` | Ajout photo à la galerie |
| `accountsUserPhotoDelete` | Suppression photo galerie |
| `accountsUserPhotoReorder` | Réordonner la galerie |
| `accountsUserStats` | Stats agrégées : connexions, runs, km, note — via annotations ORM |
| `accountsUserUpdateNotificationPreferences` | 8 switches notifications |
| `accountsUserUpdatePrivacySettings` | Visibilité profil + opt-in vedette |
| `accountsUserUpdateLanguage` | Sauvegarder la langue préférée (`fr` / `en`) |
| `accountsUserSuspend` | Suspendre le compte |
| `accountsUserDeleteAccount` | Supprimer (soft delete) |
| `accountsUserAccessLogout` | Invalider le token → déconnexion |
| `eventsRegistrationList` | Historique des runs (passés) |

### Flutter

- `profile_screen` : stats, galerie, buddy code, switches, visibilité, suspend/delete/logout
- `edit_profile_screen` : édition bio, objectifs, photo principale, galerie
- `bio_quiz_screen` : relancer le quiz → `accountsUserBioGenerate` → sélection
- `run_history_screen` : liste des runs passés, membres du groupe, photos, like post-run

### Test

```bash
make gql-accounts-me
make gql-accounts-update-profile bio="Coureur social du dimanche"
make gql-accounts-user-stats
```

---

## Slice 5 — Membres + Connexions

> Screens : `members_screen`, `user_profile_sheet`, `activity_screen`

### Backend

| Mutation / Query | Description |
|---|---|
| `accountsUserList` | Listing membres avec filtres et pagination (offset/limit) |
| `accountsUserDetail` | Profil public d'un membre |
| `accountsUserByBuddyCode` | Retrouver un membre par son buddy code |
| `accountsUserLike` | Like (crush) → crush mutuel déclenche une connexion |
| `messagingContactRequestSend` | Demande de contact |
| `accountsUserBlock` | Bloquer un membre |
| `communityContentReportCreate` | Signaler un membre / contenu |

### Flutter

- `members_screen` : infinite scroll (20/page), filtres par ville/allure/statut vérifié
- `user_profile_sheet` : bottom sheet profil public, like, contact, block, signaler
- `activity_screen` : likes reçus, connexions récentes, demandes de contact

### Test

```bash
make gql-accounts-user-list city="montreal" verified=true limit=20
make gql-accounts-user-like userId="xyz"
```

---

## Slice 6 — Messagerie

> Screens : `conversations_screen`, `chat_screen`

### Backend

| Mutation / Query | Description |
|---|---|
| `messagingConversationList` | Liste des conversations (groupe + privées) |
| `messagingMessageList` | Messages d'une conversation (pagination) |
| `messagingMessageSend` | Envoyer un message |
| `messagingMessageMarkRead` | Marquer comme lu |
| `messagingConversationArchive` | Archiver une conversation groupe |
| `messagingTypingHeartbeat` | Heartbeat "est en train d'écrire" (TTL 5s) |
| `messagingConversationTypingUsers` | Qui est en train d'écrire |
| `messagingUnreadTotal` | Total messages non lus (badge tab) |

Stratégie temps réel : FCM data push + polling 3s sur `chat_screen` — voir [25-messagerie-temps-reel.md](./backend/25-messagerie-temps-reel.md).

### Flutter

- `conversations_screen` : liste conversations, badge non lus, polling 15s
- `chat_screen` : messages, envoi, typing indicator, polling 3s, FCM pour messages instantanés

### Test

```bash
make gql-messaging-conversation-list
make gql-messaging-message-send conversationId="abc" body="Salut !"
```

---

## Slice 7 — Notifications + FCM

> Screen : `notifications_screen`, badges tab bar

### Backend

| Mutation / Query | Description |
|---|---|
| `accountsNotificationList` | Liste des notifications (paginée) |
| `accountsNotificationMarkRead` | Marquer une notification comme lue |
| `accountsNotificationMarkAllRead` | Tout marquer comme lu |
| `accountsNotificationArchive` | Archiver une notification individuellement |
| `accountsNotificationUnreadCount` | Compte non lus (badge onglet) |

Stratégie : FCM pour livraison immédiate + polling 60s pour badge — voir [25-messagerie-temps-reel.md](./backend/25-messagerie-temps-reel.md).

### Flutter

- `notifications_screen` : liste, archivage, badge cleared au clic sur l'onglet (comportement Messenger)
- Tab bar : badge rouge sur "Notifications" et "Messages" depuis les `unreadCount`

### Test

```bash
make gql-notifications-list
make gql-notifications-unread-count
```

---

## Slice 8 — Photos + Vérification identité

> Screens : `verify_account_screen`, galerie dans `profile_screen`, photos dans `run_history_screen`

### Backend

| Mutation / Query | Description |
|---|---|
| `accountsVerificationSlotList` | Créneaux de vérification disponibles |
| `accountsVerificationSlotBook` | Réserver un créneau |
| `accountsUserUploadVerificationSelfie` | Upload selfie |
| `accountsUserVerificationStatus` | Statut de la demande en cours |
| `accountsUserVerificationCancel` | Annuler une demande pending |
| `communityEventPhotoUpload` | Upload photo d'un événement |
| `communityEventPhotoList` | Photos d'un événement |

Traitement images : `django-imagekit` + Pillow, thumbnails auto — voir [21-photos-membres.md](./backend/21-photos-membres.md).

### Flutter

- `verify_account_screen` : créneaux disponibles → réserver → upload selfie → statut (polling ou FCM)
- Galerie : `image_picker` → `accountsUserPhotoAdd` → réaffichage

### Test

```bash
make gql-accounts-verification-slot-list
make gql-accounts-upload-verification-selfie photoPath="./test.jpg"
```

---

## Slice 9 — Contenu statique

> Screens : `faq_screen`, `community_rules_screen`, `terms_screen`, `privacy_screen`, `contact_form_screen`

### Backend

| Mutation / Query | Description |
|---|---|
| `communityFaqList` | FAQ (retourne `question_fr`, `question_en`, `answer_fr`, `answer_en`) |
| `communityRuleList` | Règles de la communauté avec icône |
| `communityLegalDocument` | Document légal par type (`terms`, `privacy`) |
| `accountsUserAcceptLegal` | Enregistrer l'acceptation horodatée |
| `accountsSupportTicketCreate` | Formulaire de contact |

Tout le contenu retourne **fr + en** en même temps — Flutter choisit selon `appLocale` sans refetch — voir [17-i18n.md](./backend/17-i18n.md).

### Flutter

- Screens simples : query GraphQL → affichage selon `appLocale.value`
- `contact_form_screen` : mutation + confirmation

### Test

```bash
make gql-community-faq-list
make gql-community-legal-document type="terms"
```

---

## Slice 10 — Features avancées

> Screens : `rate_event_screen`, `invite_friend_screen`, `recap_screen`, `report_screen`

### Backend

| Feature | Éléments |
|---|---|
| Algorithme de groupes | `GroupMatchingService` — voir [23-group-matching.md](./backend/23-group-matching.md) |
| Météo événements | `EventWeather` + worker `events_weather_sync` (Open-Meteo) |
| Rating événement | `eventsEventSubmitRating`, `EventRating` |
| Invitation à un événement | `eventsEventInviteSend`, `eventsEventInviteRespond` |
| Actions admin bulk | 52 actions — voir [24-admin-actions.md](./backend/24-admin-actions.md) |
| Sauvegardes | `pg_dump` + rclone → Google Drive — voir [11-sauvegardes.md](./backend/11-sauvegardes.md) |
| Synchronisation DB | `sync_db.py` — voir [15-sync-db.md](./backend/15-sync-db.md) |

### Flutter

- `rate_event_screen` : noter le run post-événement (étoiles + commentaire)
- `invite_friend_screen` : partager buddy code via `share_plus`
- `recap_screen`, `report_screen` : résumé de run, signaler un membre

---

## Stratégie de test par slice

| Ce qu'on teste | Outil |
|---|---|
| API GraphQL (mutations, queries, auth) | Commandes `make gql-*` — voir [08-graphql-cli.md](./backend/08-graphql-cli.md) |
| Logique métier Django (models, services) | `pytest` + fixtures Django |
| UI Flutter (navigation, formulaires) | Deploy iPhone via `xcrun devicectl` |
| Visuel rapide Flutter web | `flutter run -d chrome` (screenshots uniquement — pas d'automation DOM avec CanvasKit) |

### Boucle de feedback par slice

```
1. Backend : coder les mutations/queries de la slice
2. CLI : valider avec make gql-* que l'API répond correctement
3. Flutter : brancher le repository et connecter l'écran
4. Deploy : xcrun devicectl → tester sur iPhone
5. ✅ Slice terminée → passer à la suivante
```

---

## Références documentation

| Document | Lien |
|---|---|
| Tous les modèles Django | [04-modeles-django.md](./backend/04-modeles-django.md) |
| Auth OTP + token | [05-authentification.md](./backend/05-authentification.md) |
| API GraphQL (norme + opérations) | [06-api-graphql.md](./backend/06-api-graphql.md) |
| Commandes CLI de test | [08-graphql-cli.md](./backend/08-graphql-cli.md) |
| Environnements + Docker | [09-environnements.md](./backend/09-environnements.md) |
| i18n (suffixes `_fr`/`_en` + JSON) | [17-i18n.md](./backend/17-i18n.md) |
| Génération bio IA (Claude) | [19-bio-generation.md](./backend/19-bio-generation.md) |
| Messagerie + Notifications | [20-messaging-notifications.md](./backend/20-messaging-notifications.md) |
| Photos, connexions, blocage | [21-photos-membres.md](./backend/21-photos-membres.md) |
| Audit Flutter → backend | [22-audit-flutter.md](./backend/22-audit-flutter.md) |
| Algorithme de groupes | [23-group-matching.md](./backend/23-group-matching.md) |
| Actions Django Admin | [24-admin-actions.md](./backend/24-admin-actions.md) |
| Messagerie temps réel + polling | [25-messagerie-temps-reel.md](./backend/25-messagerie-temps-reel.md) |
