# Run Date — Migration Inventory (Flutter → Next.js)

## Stack cible

- **Next.js 15** (App Router) dans `apps/web/`
- **shadcn/ui** + **Tailwind CSS v4**
- **Nunito** (titres) + **DM Sans** (corps) via `next/font/google`
- **Zustand** pour l'état global (theme, locale, demo mode)
- Données mockées portées telles quelles en TypeScript

---

## Design System — Couleurs

| Token | Hex | Usage |
|-------|-----|-------|
| `teal` | `#00D4AA` | Accent primaire (gradient start) |
| `cyan` | `#00BCD4` | Accent secondaire |
| `ocean` | `#0097A7` | Primary (boutons, nav active) |
| `deep-teal` | `#00838F` | Accent dense |
| `navy-blue` | `#1B4A6A` | Titres secondaires |
| `navy` | `#1B2A4A` | Texte principal (light mode) |
| `cream` | `#FBF7F2` | Fond scaffold (light) |
| `slate-grey` | `#64748B` | Texte secondaire |
| `border` | `#CBD5E1` | Bordures |
| `error` | `#EF4444` | Erreur |
| `warning` | `#F59E0B` | Avertissement |
| `success` | `#10B981` | Succès |
| `dark-scaffold` | `#1A1A2E` | Fond scaffold (dark) |
| `dark-surface` | `#242438` | Surfaces (dark) |
| `dark-border` | `#1E3A5F` | Bordures (dark) |

## Design System — Typographie

| Style | Police | Taille | Weight |
|-------|--------|--------|--------|
| headlineLarge | Nunito | 28px | 800 |
| headlineMedium | Nunito | 24px | 700 |
| headlineSmall | Nunito | 20px | 700 |
| titleLarge | Nunito | 18px | 700 |
| titleMedium | Nunito | 16px | 600 |
| bodyLarge | DM Sans | 16px | 400 |
| bodyMedium | DM Sans | 14px | 400 |
| bodySmall | DM Sans | 14px | 400 (secondary color) |
| labelLarge | DM Sans | 14px | 600 |

**Taille minimale : 14px** (audience 30-50 ans)

---

## Pages Core — Inventaire détaillé

### 1. Onboarding (`lib/screens/onboarding/onboarding_screen.dart`)
- **Route Next.js** : `/onboarding`
- **Layout** : PageView 3 pages (quartier, groupe, apéro) + SmoothPageIndicator
- **Composants** : AppLogo, images carrousel, boutons Découvrir/Créer compte/Passer
- **Données** : aucune (images assets)
- **Navigation** : → SignupWizard, GuestEvents
- **Notes** : toggle demoMode

### 2. Guest Events (`lib/screens/onboarding/guest_events_screen.dart`)
- **Route Next.js** : `/events/preview`
- **Layout** : liste simplifiée d'événements (cartes quartier, date, ravito)
- **Composants** : AppLogo, cartes événements simplifiées, bandeau CTA
- **Données** : `mockEvents`
- **Navigation** : → SignupWizard

### 3. Signup Wizard (`lib/screens/auth/signup_wizard_screen.dart`)
- **Route Next.js** : `/signup` (multi-step)
- **Layout** : PageView multi-étapes (~16 étapes) non scrollable
- **Étapes** : téléphone → OTP → nom → genre → orientation → âge → province → ville → quartier → objectifs → photo → bio → selfie → visibilité → langue → conditions → bienvenue + confettis
- **Données** : `quebecCities`
- **Navigation** : → Terms, Privacy, CommunityRules, BioQuiz

### 4. Home Screen (`lib/screens/home/home_screen.dart`)
- **Route Next.js** : `/` (dans layout principal)
- **Layout** : CustomScrollView avec RefreshIndicator + skeleton loader
- **Sections** :
  - Hero banner (gradient teal→navy, avatar, "Salut {prénom}!")
  - Status card (inscription en cours / approuvé / etc.)
  - Stats communauté
  - Coureurs du mois
  - Nouveaux membres
  - Profils compatibles
  - Membres actifs
  - Témoignages (carrousel PageView + SmoothPageIndicator)
  - Vidéo promo
  - Événements populaires (liste horizontale)
  - Organisateurs
  - Photos communauté
  - CTAs (proposer parcours, devenir organisateur)
  - Toggle thème
- **Données** : `mockEventPhotos`, `mockEvents`, `mockUsers`, `currentUser`
- **Navigation** : → EventsList, EventDetail, RateEvent, ContactForm, OrganizersList, CommunityFeed
- **Widgets** : UserAvatar, PhotoGalleryViewer, ShimmerBlock

### 5. Events List (`lib/screens/events/events_list_screen.dart`)
- **Route Next.js** : `/events`
- **Layout** : TabBar (Prochains/Inscrits/Passés) + filtres + bascule liste/carte
- **Composants** :
  - Filtres (jour, quartier, tri) via bottom sheets
  - EventCard (quartier, date, météo, intensité, organisateur)
  - PastEventCard
  - Vue carte stylisée (CustomPaint, pas vrai SDK map)
- **Données** : `mockEvents`, `mockWeatherByEventId`, `mockUsers`
- **Navigation** : → EventDetail, ContactForm
- **Widgets** : UserAvatar, WeatherBadge, PaceLabelIcon

### 6. Event Detail (`lib/screens/events/event_detail_screen.dart`)
- **Route Next.js** : `/events/[id]`
- **Layout** : écran riche scrollable
- **Sections** :
  - Bannière quartier + infos prix/récurrence
  - Compte à rebours
  - Météo (WeatherBadge)
  - Jauge inscriptions (capacité min/max)
  - Intensité & distance
  - Organisateurs (avatars cliquables → profil)
  - Point de départ (MeetingPointCard, masqué si pas inscrit)
  - Trajet
  - Ravito smoothie
  - Partage (WhatsApp, SMS, etc.)
  - Répartition H/F/autres
  - Groupe (compagnons)
  - "Comment ça marche"
  - CTA sticky bas (inscription, paiement, chat, calendrier)
- **Données** : `mockEventPhotos`, `mockMeetingPoints`, `mockUsers`, `mockWeatherByEventId`, `mockConversations`, `currentUser`
- **Navigation** : → ApplyWizard, PaymentCheckout, ChatScreen, ContactForm, InviteFriend, UserProfileSheet
- **Widgets** : UserAvatar, WeatherBadge, MeetingPointCard, PhotoGalleryViewer, AddPhotoSheet, PaceLabelIcon, DistanceLabelIcon, CancellationPolicySheet, TipOrganizerSheet

### 7. Members (`lib/screens/members/members_screen.dart`)
- **Route Next.js** : `/members`
- **Layout** : recherche + filtres + SliverList
- **Composants** :
  - Barre de recherche
  - Filtres bottom sheet (genre, quartier/ville, sport)
  - Tri (récents, activités)
  - Section horizontale "sports en commun"
  - Liste de membres (rangées avec avatar, nom, badge, ville)
- **Données** : `mockUsers`, `currentUser`
- **Navigation** : → UserProfileSheet
- **Widgets** : UserAvatar

### 8. Activity (`lib/screens/activity/activity_screen.dart`)
- **Route Next.js** : `/activity`
- **Layout** : 3 sous-onglets (Messages, Notifications, Connexions)
- **Sous-écrans** :
  - ConversationsScreen (embedded)
  - NotificationsScreen (embedded)
  - ConnectionRequestsScreen (embedded)

### 9. Conversations (`lib/screens/messages/conversations_screen.dart`)
- **Route Next.js** : `/activity/messages`
- **Layout** : liste de conversations avec aperçu, avatar groupe, indicateur non lu
- **Données** : `mockConversations`
- **Navigation** : → ChatScreen

### 10. Chat (`lib/screens/messages/chat_screen.dart`)
- **Route Next.js** : `/activity/messages/[id]`
- **Layout** : fil de bulles + barre de saisie + menu
- **Fonctionnalités** : bulles colorées par expéditeur, icebreakers, menu (membres, mute, quitter, signaler)
- **Données** : `mockIcebreakers`, `mockUsers`
- **Navigation** : → UserProfileSheet

### 11. Notifications (`lib/screens/notifications/notifications_screen.dart`)
- **Route Next.js** : `/activity/notifications`
- **Layout** : liste de cartes Dismissible (swipe archive)
- **Composants** : icônes par NotificationType, actions inline (contactRequest, spotFreed)
- **Données** : `mockNotifications`, `mockEvents`
- **Navigation** : → EventDetail (pour matchFound)
- **Widgets** : UserAvatar

### 12. Profile (`lib/screens/profile/profile_screen.dart`)
- **Route Next.js** : `/profile`
- **Layout** : header profil + sections regroupées
- **Sections** :
  - Photo, nom, badge, galerie miniatures
  - Complétion profil (barre)
  - Bio & objectifs
  - Menu : compte, facturation, Strava, aide, langue, thème, démo
  - Version app
- **Données** : `currentUser`, PackageInfo
- **Navigation** : → UserProfileSheet, EditProfile, VerifyAccount, InviteFriend, Billing, Connections, HelpLegal
- **Widgets** : UserPhotoViewer

### 13. Edit Profile (`lib/screens/profile/edit_profile_screen.dart`)
- **Route Next.js** : `/profile/edit`
- **Layout** : formulaire long scrollable
- **Sections** :
  - Grille photos (3 colonnes)
  - Champs : prénom, genre, orientation, ville (Autocomplete), quartiers Montréal
  - Intentions (FilterChip)
  - Bio + lien BioQuiz
  - Date naissance, email
  - Visibilité, opt-in réseaux
  - Switches notifications
  - Zone danger (suspendre/supprimer)
- **Données** : `currentUser`, `quebecCities`
- **Navigation** : → BioQuiz, UserPhotoViewer

### 14. User Profile Sheet (`lib/screens/profile/user_profile_sheet.dart`)
- **Type** : Bottom sheet modal (pas une page)
- **Équivalent Next.js** : Sheet/Drawer shadcn/ui, ou route modale `/profile/[id]`
- **Layout** : TabController (3 ou 4 onglets selon contexte)
- **Onglets** : aperçu, stats, photos, actions (like)
- **Données** : `mockEvents`, `mockMeetingPoints`
- **Navigation** : → EventDetail, UserPhotoViewer, launchUrl Strava
- **Widgets** : UserAvatar, UserPhotoViewer, LikeMessageSheet, PaceLabelIcon

### 15. Community Feed (`lib/screens/community/community_feed_screen.dart`)
- **Route Next.js** : `/community`
- **Layout** : fil photos triées par date + FAB ajout photo
- **Composants** : cartes photo (auteur, image 4/3, likes/commentaires mock)
- **Données** : `mockEventPhotos`, `mockEvents`, `mockMeetingPoints`
- **Navigation** : → AddPhotoSheet, PhotoGalleryViewer
- **Widgets** : AddPhotoSheet, PhotoGalleryViewer

### 16. Payment Checkout (`lib/screens/payment/payment_checkout_screen.dart`)
- **Route Next.js** : `/events/[id]/checkout`
- **Layout** : résumé commande + case politique + bouton payer
- **Composants** : mock Stripe payment sheet
- **Données** : KaiEvent (paramètre), CancellationPolicy
- **Navigation** : → PaymentConfirmation
- **Widgets** : CancellationPolicySheet

### 17. Payment Confirmation (`lib/screens/payment/payment_confirmation_screen.dart`)
- **Route Next.js** : `/events/[id]/confirmation`
- **Layout** : succès + confettis + détails paiement + rappel politique
- **Données** : KaiEvent
- **Navigation** : → ApplyWizard

---

## Modèles à porter en TypeScript

| Fichier Flutter | Classes | Champs clés |
|----------------|---------|-------------|
| `kai_event.dart` | `KaiEvent`, enums `EventCategory`, `EventStatus`, `RegistrationStatus`, `IntensityLevel`, `DistanceLabel`, `PaymentStatus`, `RecurrenceType` | id, category, neighborhood, city, date, deadline, intensity, distance, price, capacity, organizerIds, etc. |
| `user.dart` | `User`, `UserActivity`, `BadgeLevel` | id, firstName, lastName, phone, gender, age, city, neighborhood, photoUrl, bio, badge, xp, activities, stats, gallery, etc. |
| `message.dart` | `Message`, `Conversation` | id, senderId, content, timestamp, participants |
| `app_notification.dart` | `AppNotification`, `NotificationType` | id, type, title, body, timestamp, isRead, relatedUserId |
| `event_photo.dart` | `EventPhoto` | id, eventId, userId, url, caption, timestamp |
| `meeting_point.dart` | `MeetingPoint`, `MeetingPointType` | id, name, type, lat, lng, address |
| `weather_forecast.dart` | `WeatherForecast`, `WeatherCondition` | condition, temp, humidity, wind, tips |
| `run_match.dart` | `ActivityMatch`, `MatchStatus` | users, status, event |
| `cancellation_policy.dart` | `CancellationPolicy` | deadlines, refund rates, text |
| `profile_visibility.dart` | `ProfileVisibility` | enum values |
| `verification_slot.dart` | `VerificationSlot`, `VerificationStatus` | date, time, status |
| `waiting_question.dart` | `WaitingQuestion` | question, options |

## Mock Data à porter

| Fichier | Export principal |
|---------|----------------|
| `mock_events.dart` | `mockEvents` (List<KaiEvent>) |
| `mock_users.dart` | `currentUser`, `mockUsers` (List<User>) |
| `mock_messages.dart` | `mockConversations` (List<Conversation>) |
| `mock_notifications.dart` | `mockNotifications` (List<AppNotification>) |
| `mock_event_photos.dart` | `mockEventPhotos` (List<EventPhoto>) |
| `mock_weather.dart` | `mockWeatherByEventId` (Map<String, WeatherForecast>) |
| `mock_meeting_points.dart` | `mockMeetingPoints` (List<MeetingPoint>) |
| `mock_questions.dart` | `mockIcebreakers`, `waitingQuestions` |
| `mock_billing.dart` | `MockInvoice`, cartes factices |
| `mock_bring_items.dart` | `mockBringItems`, `bringItemEmojis` |
| `quebec_cities.dart` | `searchCities`, `montrealNeighborhoods`, `QuebecCity` |

---

## Widgets partagés → Composants React

| Widget Flutter | Fichier | Composant React cible |
|---------------|---------|----------------------|
| `AppLogo` | `app_logo.dart` | `<AppLogo />` (SVG/Image) |
| `UserAvatar` | `user_avatar.dart` | shadcn `<Avatar />` wrapper |
| `WeatherBadge` | `weather_badge.dart` | `<WeatherBadge />` (Badge) |
| `MeetingPointCard` | `meeting_point_card.dart` | `<MeetingPointCard />` (Card) |
| `PhotoGalleryViewer` | `photo_gallery_viewer.dart` | `<PhotoGallery />` (Dialog lightbox) |
| `AddPhotoSheet` | `add_photo_sheet.dart` | `<AddPhotoDialog />` (Sheet) |
| `CancellationPolicySheet` | `cancellation_policy_sheet.dart` | `<CancellationPolicySheet />` (Sheet) |
| `TipOrganizerSheet` | `tip_organizer_sheet.dart` | `<TipOrganizerSheet />` (Sheet) |
| `LikeMessageSheet` | `like_message_sheet.dart` | `<LikeMessageSheet />` (Sheet) |
| `FrostedContainer` | `frosted_container.dart` | CSS `backdrop-filter: blur()` |
| `PaceLabelIcon` | `pace_label_icon.dart` | `<PaceIcon />` |
| `DistanceLabelIcon` | `distance_label_icon.dart` | `<DistanceIcon />` |
| `UserPhotoViewer` | `user_photo_viewer.dart` | `<UserPhotoViewer />` (Dialog) |
| `ShimmerBlock` | `skeletons/shimmer_block.dart` | shadcn `<Skeleton />` |
| `WebShell` | `web_shell.dart` | Plus nécessaire (layout responsive natif) |

---

## Structure de routes Next.js proposée

```
app/
├── (auth)/
│   ├── onboarding/page.tsx
│   ├── signup/page.tsx
│   └── events-preview/page.tsx
├── (main)/
│   ├── layout.tsx                  ← MainShell (nav 5 onglets)
│   ├── page.tsx                    ← Home
│   ├── events/
│   │   ├── page.tsx                ← EventsList
│   │   └── [id]/
│   │       ├── page.tsx            ← EventDetail
│   │       ├── checkout/page.tsx
│   │       └── confirmation/page.tsx
│   ├── members/
│   │   └── page.tsx                ← Members
│   ├── activity/
│   │   ├── page.tsx                ← Activity (tabs)
│   │   └── messages/
│   │       └── [id]/page.tsx       ← Chat
│   ├── community/
│   │   └── page.tsx                ← CommunityFeed
│   └── profile/
│       ├── page.tsx                ← Profile
│       └── edit/page.tsx           ← EditProfile
└── layout.tsx                      ← Root layout (ThemeProvider, fonts)
```

---

## Hors scope initial

- Pages légales (CGU, privacy, FAQ, community rules) — texte statique
- Bio quiz, invite friend, billing, verify account, run history
- Waiting room / match reveal
- Rate event, apply wizard
- Organizers list
- Intégration API backend
