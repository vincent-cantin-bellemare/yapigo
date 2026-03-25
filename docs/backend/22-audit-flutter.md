# 22 — Audit Flutter → Couverture backend

Matrice complète de chaque écran Flutter et de ce que le backend doit fournir. À utiliser comme référence avant de commencer chaque feature.

**Légende** : ✅ Documenté | ⚠️ Partiel | ❌ Manquant

---

## `faq_screen` — FAQ

| Feature | Couverture | Note |
|---|---|---|
| 12 questions/réponses hardcodées | ✅ `FaqItem` model + `communityFaqList` | Admin-managed, multilingue |

---

## `community_rules_screen` — Règles de la communauté

| Feature | Couverture | Note |
|---|---|---|
| 8 règles avec icône + titre + corps | ✅ `CommunityRule` model + `communityRuleList` | `icon_name` = nom Material Flutter |

---

## `privacy_screen` / `terms_screen` — Documents légaux

| Feature | Couverture | Note |
|---|---|---|
| Politique de confidentialité | ✅ `LegalDocument(type=privacy)` + `communityLegalDocument` | Versionné, is_current |
| Conditions d'utilisation | ✅ `LegalDocument(type=terms)` + `communityLegalDocument` | Versionné, is_current |
| Acceptation horodatée | ✅ `UserLegalAcceptance` + `accountsUserAcceptLegal` | `document_version` lie les deux |

---

## `splash_screen` / `onboarding_screen`

| Feature | Couverture | Note |
|---|---|---|
| Événements publics (avant connexion) | ✅ `eventsEventList` | Accessible sans Token |
| A/B tests contenu | ❌ | Hors scope V1 |

---

## `signup_wizard_screen` — Inscription

| Feature | Couverture | Note |
|---|---|---|
| Envoi OTP | ✅ `accountsUserAccessRequestOtp` | |
| Renvoi OTP | ✅ `accountsUserAccessResendOtp` | |
| Validation OTP | ✅ `accountsUserAccessVerifyOtp` | |
| Création compte (démographie, ville) | ✅ `accountsUserUpdateProfile` | |
| Upload photo profil | ✅ `accountsUserUploadPhoto` | |
| Réponses quiz (20 questions) | ✅ `accountsUserSaveOnboardingAnswers` | Avant `accountsUserBioGenerate` |
| Quiz bio + génération Claude | ✅ `accountsUserBioGenerate` + `accountsUserBioSelect` | Voir doc 19 ; flux ordre dans `06-api-graphql.md` |
| Upload selfie vérification | ✅ `accountsUserUploadVerificationSelfie` | |
| Acceptation CGU/Privacy | ✅ `accountsUserAcceptLegal` | |
| Mode démo (`demoMode`) | ⚠️ Champ `is_demo` absent du modèle | Ajouter si nécessaire |

---

## `profile_screen` — Profil

| Feature | Couverture | Note |
|---|---|---|
| Lecture profil complet | ✅ `accountsUserMe` | |
| Stats (connexions, runs, km, note) | ✅ `User.stats` (`UserStats` GraphQL) + annotations ORM | Voir `06-api-graphql.md` |
| Buddy code affiché | ✅ Champ `buddy_code` | |
| Switches notifications (×8) | ✅ `UserNotificationPreferences` + `accountsUserUpdateNotificationPreferences` | |
| Visibilité profil / opt-in vedette | ✅ `accountsUserUpdatePrivacySettings` | |
| Email optionnel | ✅ Champ `email` sur User | |
| Suspendre compte | ✅ `accountsUserSuspend` | |
| Supprimer compte | ✅ `accountsUserDeleteAccount` | |
| Déconnexion | ✅ Invalider `UserAccessToken` (mutation `accountsUserAccessLogout` à ajouter) | |
| Témoignages (HomeScreen) | ✅ `Testimonial` model + query `communityTestimonialList` à ajouter | |

---

## `edit_profile_screen` — Édition profil

| Feature | Couverture | Note |
|---|---|---|
| Upload/supprimer/réordonner galerie (max 6) | ✅ `accountsUserPhotoAdd/Delete/Reorder` | |
| Photo principale | ✅ `accountsUserUploadPhoto` | |
| Ville, quartier, genre, orientation, bio | ✅ `accountsUserUpdateProfile` | Bio éditable ici ou via quiz + IA (doc 19) |
| Intentions / objectifs | ✅ `accountsUserUpdateProfile(runningGoals)` → `User.running_goals` | Champ canonique côté app |
| Légendes photos galerie | ⚠️ Champ `caption` absent de `UserPhoto` | Ajouter |

---

## `bio_quiz_screen` — Quiz bio

| Feature | Couverture | Note |
|---|---|---|
| Sauvegarder les 20 réponses | ✅ `accountsUserSaveOnboardingAnswers` | |
| Générer bio via Claude | ✅ `accountsUserBioGenerate` | |
| Sélectionner une bio | ✅ `accountsUserBioSelect` | |

---

## `verify_account_screen` — Vérification identité

| Feature | Couverture | Note |
|---|---|---|
| Lister créneaux disponibles | ⚠️ `VerificationSlot` model existe, query manquante | Ajouter `accountsVerificationSlotList` |
| Réserver un créneau | ⚠️ Mutation `accountsVerificationSlotBook` manquante | |
| Upload selfie | ✅ `accountsUserUploadVerificationSelfie` | |
| Mise à jour `is_verified` (par admin) | ✅ Via Django Admin | |

---

## `run_history_screen` — Historique des runs

| Feature | Couverture | Note |
|---|---|---|
| Runs passés de l'utilisateur | ✅ `eventsRegistrationList(upcoming: false)` | |
| Membres du groupe par run | ✅ `communityEventMemberList(eventId)` | |
| Like / contact post-run | ✅ `accountsUserLike` + `messagingContactRequestSend` | |
| Photos de l'événement | ✅ `communityEventPhotoList(eventId)` | |
| Ajouter une photo | ✅ `communityEventPhotoUpload` | |
| Note soumise | ✅ `EventRating` + `eventsEventSubmitRating` | |

---

## `invite_friend_screen` — Inviter un ami

| Feature | Couverture | Note |
|---|---|---|
| Buddy code unique par user | ✅ `User.buddy_code` (généré à l'inscription) | |
| Tracker les inscriptions via buddy code | ⚠️ `EventRegistration.buddy_user` tracke le parrainage | Attribution à enrichir si besoin |

---

## `contact_form_screen` — Formulaire de contact

| Feature | Couverture | Note |
|---|---|---|
| Soumission ticket | ✅ `accountsSupportTicketCreate` + `SupportTicket` model | |
| Anti-spam / rate limit | ✅ `RateLimit` model dans monitoring | |

---

## `events_list_screen` — Liste des événements

| Feature | Couverture | Note |
|---|---|---|
| Liste filtrée (date, quartier, allure) | ✅ `eventsEventList(filters, orderBy)` | |
| Onglets Prochains / Inscrits / Passés | ✅ `filters.status` + `eventsRegistrationList` | |
| Désinscription avec raison | ✅ `eventsEventCancelRegistration(reason)` | |
| Position liste d'attente | ✅ `EventRegistration.waitlist_position` | |
| Météo par événement | ❌ Intégration météo externe (ex: Open-Meteo API) non documentée | V2 |
| Partage / deep link | ❌ Génération d'URL canonique (ex: `rundate.app/events/:id`) | À documenter |

---

## `event_detail_screen` — Détail événement

| Feature | Couverture | Note |
|---|---|---|
| Données complètes événement | ✅ `eventsEventDetail` | |
| Jauge inscriptions / seuil / répartition H/F | ✅ Properties sur `RunDateEvent` | |
| Point de rencontre (masqué si non inscrit) | ✅ Logique dans résolveur selon statut inscription | |
| Mon groupe (`RunGroup`) | ✅ Via `EventRegistration` → `RunGroup` | |
| Photos événement | ✅ `communityEventPhotoList` | |
| Conversation groupe | ✅ `messagingConversationList(eventId)` | |
| S'inscrire via `ApplyWizard` | ✅ `eventsEventRegister` | |
| Ajouter au calendrier (.ics) | ❌ Génération fichier `.ics` non documentée | Simple à générer |

---

## `apply_wizard_screen` — Inscription à un run

| Feature | Couverture | Note |
|---|---|---|
| Pace, distance préférés | ✅ `eventsEventRegister(paceLabel, distanceLabel)` | |
| Équipement / compagnon | ✅ `equipment`, `companionType` sur `EventRegistration` | |
| Buddy code | ✅ `eventsEventRegister(buddyCode)` | |
| Invitations post-inscription | ⚠️ `accountsUserSearch` + `messagingContactRequestSend` existants | Flux d'invitation à définir |

---

## `waiting_screen` — Écran d'attente

| Feature | Couverture | Note |
|---|---|---|
| Progression seuil en temps réel | ⚠️ Polling via `eventsEventDetail.totalRegistered` | WebSocket V2 |
| Questions d'attente (communauté) | ✅ `communityWaitingQuestionList` | |
| Réponses aux questions d'attente | ⚠️ Non stockées (utilisées côté UI seulement) | Envisager si besoin matching |
| Notification "groupe formé" | ✅ `AppNotification(type=matchFound)` + FCM | |

---

## `match_reveal_screen` — Révélation du groupe

| Feature | Couverture | Note |
|---|---|---|
| Membres du RunGroup | ✅ `RunGroup.members` | |
| Lièvre et buddy dans le groupe | ✅ `RunGroup.lievre`, `EventRegistration.buddy_user` | |
| Point de départ + lien maps | ✅ `MeetingPoint.maps_url` | |
| Items "à apporter" (équipement des membres) | ✅ `EventRegistration.equipment` | |
| Ouverture conversation groupe | ✅ `messagingConversationList(eventId)` | |

---

## `conversations_screen` / `chat_screen` — Messagerie

| Feature | Couverture | Note |
|---|---|---|
| Liste conversations | ✅ `messagingConversationList` | |
| Messages paginés | ✅ `messagingConversationDetail` | |
| Envoyer un message | ✅ `messagingMessageSend` | |
| Mute notifications | ✅ `messagingConversationMute/Unmute` | |
| Archiver conversation | ✅ `messagingConversationArchive/Unarchive` | |
| Quitter groupe | ✅ `messagingConversationLeave` | |
| Signaler un message | ✅ `communityContentReport(content_type=MESSAGE)` | |
| Messages temps réel | ⚠️ Polling V1, WebSocket V2 | |

---

## `notifications_screen` — Notifications

| Feature | Couverture | Note |
|---|---|---|
| Liste notifications | ✅ `notificationsNotificationList` | |
| Marquer lu / tous lus | ✅ `notificationsNotificationMarkRead/AllRead` | |
| Archiver une notification (swipe) | ⚠️ Champ `is_archived` absent de `AppNotification` | Ajouter |
| Accepter demande de contact inline | ✅ `messagingContactRequestAccept` | |
| Confirmer une place libérée inline | ✅ `eventsEventRegister` | |

---

## `members_screen` — Membres

| Feature | Couverture | Note |
|---|---|---|
| Recherche avec filtres (ville, genre, pace) | ✅ `accountsUserSearch(filters)` | `gender` à ajouter dans `UserFilters` |
| Recherche par nom (texte libre) | ⚠️ `UserFilters.name` absent | Ajouter champ `name` (icontains sur `first_name`) |
| Tri (récent, runs, km) | ✅ `UserOrderBy` | |
| Profil détaillé → `UserProfileSheet` | ✅ `accountsUserDetail` | |

---

## `rate_event_screen` — Notation

| Feature | Couverture | Note |
|---|---|---|
| Note globale + dimensions | ✅ `eventsEventSubmitRating` | |
| Commentaire public/privé | ✅ `EventRating.is_comment_public` | |
| Notes par participant | ⚠️ Non documenté (rating individuel par membre du groupe) | Peut être `EventRating` par membre |
| "J'aimerais te connaître" | ✅ `messagingContactRequestSend` + `LikeMessageSheet` | |
| "Recourir avec ce groupe" | ✅ `EventRating.wants_rerun_with_group` | |
| Signaler un participant | ✅ `communityContentReport(content_type=USER_PROFILE)` | |

---

## `community_feed_screen` — Feed communauté

| Feature | Couverture | Note |
|---|---|---|
| Feed photos global paginé | ✅ `communityFeedList` | |
| Like photo | ✅ `communityPhotoLike/Unlike` + `PhotoLike` model | |
| Commentaires | ❌ Reporté à V2 (marqué "bientôt" dans Flutter) | |
| Upload photo | ✅ `communityEventPhotoUpload` | |
| Signaler une photo | ✅ `communityContentReport(content_type=EVENT_PHOTO)` | |

---

## `home_screen` — Accueil

| Feature | Couverture | Note |
|---|---|---|
| Statut inscription / matching | ✅ `eventsRegistrationList` | |
| Stats communauté "cette semaine" | ⚠️ Query `communityStatsWeekly` à créer | Chiffres simples (COUNT) |
| "King/Queen du moment" (top coureurs) | ⚠️ `accountsUserSearch(orderBy: XP_DESC, limit: 2)` | Suffisant |
| Nouveaux membres | ✅ `accountsUserSearch(orderBy: CREATED_AT_DESC)` | |
| Membres actifs | ✅ `accountsUserSearch` + filtre `last_seen_at` | |
| Profils compatibles | ⚠️ Même allure que l'utilisateur connecté | Simple filter |
| Témoignages | ⚠️ Query `communityTestimonialList` à ajouter | Admin-managed |
| Run passé à noter (badge) | ✅ `eventsRegistrationList(upcoming:false)` + check `EventRating` | |

---

## Queries manquantes à ajouter

Ces queries ont été identifiées pendant l'audit mais ne sont pas encore dans `06-api-graphql.md` :

```graphql
# Stats communauté agrégées pour HomeScreen
communityStatsWeekly: CommunityStats

type CommunityStats {
  upcomingRunsCount: Int!
  activeNeighborhoodsCount: Int!
  registeredThisWeekCount: Int!
}

# Témoignages publiés
communityTestimonialList: [Testimonial!]!

# Fermer sa session (invalider le token)
accountsUserAccessLogout: Boolean

# Créneaux de vérification disponibles
accountsVerificationSlotList: [VerificationSlot!]!

# Réserver un créneau de vérification
accountsVerificationSlotBook(slotId: ID!): Boolean
```

---

## Fonctionnalités V2 (hors scope V1)

| Feature | Écran | Raison du report |
|---|---|---|
| Météo par événement | EventsList, EventDetail | Intégration API externe |
| Messages temps réel (WebSocket) | Chat | Django Channels requis |
| Commentaires photos | CommunityFeed | UI non finalisée dans Flutter |
| Deep links / URL canoniques | EventDetail, partage | Dépend du site web Next.js |
| Ajout au calendrier (.ics) | EventDetail | Simple mais non prioritaire |
| Notation individuelle par membre | RateEvent | Complexité UI/UX à revoir |
| A/B tests contenu onboarding | Onboarding | Hors scope |
