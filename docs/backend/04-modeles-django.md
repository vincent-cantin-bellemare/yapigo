# 04 — Modèles Django

Tous les modèles héritent de `BaseModel` :

```python
class BaseModel(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    class Meta:
        abstract = True
```

---

## App `geography`

### `City`
| Champ | Type | Notes |
|---|---|---|
| `name` | CharField | ex: "Montréal" |
| `region` | CharField | ex: "Montréal" |
| `lat` | FloatField | |
| `lng` | FloatField | |

### `Neighborhood`
| Champ | Type | Notes |
|---|---|---|
| `name` | CharField | ex: "Le Plateau-Mont-Royal" |
| `city` | ForeignKey(City) | |

---

## App `accounts`

### `User`
Correspondance Flutter : `apps/mobile/lib/models/user.dart`

| Champ | Type | Notes |
|---|---|---|
| `phone` | CharField(unique) | Identifiant principal, format E.164 |
| `first_name` | CharField | |
| `last_name` | CharField | |
| `gender` | CharField | |
| `sexual_orientation` | CharField(null) | |
| `birth_year` | IntegerField | `age` calculé en property |
| `city` | ForeignKey(City) | |
| `neighborhood` | ForeignKey(Neighborhood, null) | |
| `photo` | ProcessedImageField(null) | Redimensionné 800×800 au upload |
| `photo_thumbnail` | ImageSpecField | Crop 200×200, généré à la demande |
| `bio` | TextField(null) | |
| `is_verified` | BooleanField(default=False) | Vérification identité — passé à True par le service lors de l'approbation |
| `verified_at` | DateTimeField(null) | Timestamp de la vérification approuvée |
| `xp` | IntegerField(default=0) | |
| `badge` | property | Calculé depuis `xp` (BadgeLevel enum) |
| `is_suspended` | BooleanField | ≠ soft delete |
| `is_deleted` | BooleanField | Soft delete |
| `deleted_at` | DateTimeField(null) | Soft delete |
| `is_lievre` | BooleanField | Peut être pace leader |
| `buddy_code` | CharField(unique) | Format ANIMAL-MOT généré à l'inscription |
| `pace_label` | CharField(choices) | tortueSociale → roadRunner |
| `distance_label` | CharField(choices) | cafeCreme → ultraSocial |
| `running_goals` | ArrayField(CharField) | |
| `fcm_token` | CharField(null) | Token Firebase push notifications |
| `email` | CharField(null, unique) | Optionnel, non utilisé pour l'auth |
| `profile_visibility` | CharField(choices, default='public') | `public` / `connections_only` |
| `wants_featured_profile` | BooleanField(default=False) | Opt-in visibilité réseaux RunDate |
| `last_seen_at` | DateTimeField(null) | Mis à jour à chaque requête authentifiée |
| `language` | CharField(choices, default='fr') | `fr` / `en` — préférence langue persistée via `accountsUserUpdateLanguage` |

**Profil configurable par le membre** (mutations GraphQL — voir `06-api-graphql.md`) :

- **Objectifs de course** : `running_goals` — liste de tags / intentions ; mise à jour via `accountsUserUpdateProfile(runningGoals: [...])` depuis l’écran profil (ou flux équivalent Flutter).
- **Bio** :
  - **Via quiz** : `accountsUserSaveOnboardingAnswers` enregistre les réponses ; `accountsUserBioGenerate` puis `accountsUserBioSelect` fixent `User.bio` à partir des propositions Claude — voir [19-bio-generation.md](./19-bio-generation.md).
  - **Édition libre** : `accountsUserUpdateProfile(bio: "...")` pour modifier la bio sans repasser par la génération IA.

`UserOnboardingAnswer` alimente la bio IA et enrichit le profil ; **`running_goals` reste le champ canonique** pour les objectifs affichés et filtrés dans l’app.

**BadgeLevel** (calculé depuis xp) : `curieux` (0) → `social` (100) → `habitue` (300) → `populaire` (600) → `legende` (1000)

**Properties calculées** :
- `age` — depuis `birth_year`
- `badge` — depuis `xp`
- `connections_count` — crush mutuels actifs (UserLike mutuels, voir ci-dessous)
- `total_runs` — RunGroup(status=completed) dont l'utilisateur est membre
- `total_km` — somme des `approx_distance_km` des runs complétés
- `average_rating` — moyenne des notes reçues

> **Connexions** : pas de `ManyToManyField`. Une "connexion" = crush mutuel uniquement (`UserLike` x2). `connections_count` est une property calculée — pas de table dédiée.

> **GraphQL `UserStats`** : `connections_count`, `total_runs`, `total_km` et `average_rating` sont exposés via le type `UserStats` dans le schéma GraphQL. Les sélecteurs les calculent via **annotations ORM** (`Count`, `Sum`, `Avg`) en une seule requête SQL — jamais via les properties Python (N+1 non-safe). Voir `06-api-graphql.md` section "UserStats".

---

### `StravaConnection`

App `accounts`. Stocke les tokens OAuth Strava et les dernières statistiques synchronisées pour un utilisateur.
Relation `OneToOneField` → `User` (un seul compte Strava par membre).
Voir `26-strava-integration.md` pour le flux complet.

| Champ | Type | Notes |
|---|---|---|
| `user` | OneToOneField(User, on_delete=CASCADE, related_name='strava') | |
| `strava_athlete_id` | BigIntegerField(unique) | ID athlète Strava |
| `access_token` | CharField(512) | Token courant — chiffré en DB (django-encrypted-fields) |
| `refresh_token` | CharField(512) | Token de renouvellement — chiffré en DB |
| `token_expires_at` | DateTimeField | Expiry du access_token (renouvelé automatiquement) |
| `ytd_km` | FloatField(null) | Km courus depuis le 1er janvier |
| `ytd_runs` | IntegerField(null) | Nombre de sorties depuis le 1er janvier |
| `month_km` | FloatField(null) | Km courus le mois courant |
| `avg_pace_seconds` | IntegerField(null) | Allure moyenne (sec/km) sur les 90 derniers jours |
| `last_synced_at` | DateTimeField(null) | Dernière sync Celery réussie |
| `connected_at` | DateTimeField(auto_now_add) | Date de connexion initiale |

**Properties** :
- `avg_pace_formatted` — formatte `avg_pace_seconds` en `"M:SS /km"`

**GraphQL** :
- `stravaStats: StravaStats` exposé sur le type `User` — `null` si non connecté.
- Type SDL : `type StravaStats { ytdKm: Float, ytdRuns: Int, monthKm: Float, avgPaceSeconds: Int, lastSyncedAt: DateTime }`

**Règles** :
- Supprimé en cascade à la suppression du compte (`on_delete=CASCADE`)
- Sync quotidienne via Celery Beat (task `strava_sync_all_users`)
- Déconnexion : `DELETE /auth/strava/disconnect/` supprime l'enregistrement complet

---

### `ApplicationAccess`

Représente un client autorisé (app mobile, futur site web…).

| Champ | Type | Notes |
|---|---|---|
| `username` | CharField(unique) | Identifiant Basic Auth |
| `password` | CharField | Hashé |
| `name` | CharField | ex: "RunDate Mobile" |
| `is_active` | BooleanField | |
| `description` | TextField(null) | |

Property `authorization_header` → génère la valeur `Basic <base64>` prête à l'emploi.

### `UserAccess`

Lie un `User` à une `ApplicationAccess` avec un statut d'accès.

| Champ | Type | Notes |
|---|---|---|
| `user` | ForeignKey(User, related_name='user_accesses') | |
| `application_access` | ForeignKey(ApplicationAccess, related_name='user_accesses') | |
| `access_status` | CharField(choices) | active / suspended / banned |

Unique together : `(user, application_access)`.

### `UserAccessToken`

Remplace `AuthToken`. Token opaque 64 caractères.

| Champ | Type | Notes |
|---|---|---|
| `user_access` | ForeignKey(UserAccess, related_name='tokens') | |
| `token` | CharField(64, unique) | `secrets.token_urlsafe(48)` |
| `expires_at` | DateTimeField(null) | null = pas d'expiration |
| `last_used_at` | DateTimeField(null) | |
| `last_used_ip` | GenericIPAddressField(null) | |

Méthode `mark_used(ip)` — appelée par `@require_user_access_token`.
Property `is_valid` — vérifie expiration + `access_status` + `is_deleted`.

### `UserPhoto`

Photos de la galerie de profil. Séparées de la photo principale (`User.photo`).

| Champ | Type | Notes |
|---|---|---|
| `user` | ForeignKey(User, related_name='gallery') | |
| `photo` | ProcessedImageField | `upload_to='users/gallery/'`, redimensionné 800×800 |
| `photo_thumbnail` | ImageSpecField | Crop 200×200, généré à la demande |
| `order` | IntegerField(default=0) | Ordre d'affichage dans le profil |

- **Maximum 6 photos** par utilisateur (enforced dans le service, pas la DB)
- Publication immédiate — pas de modération
- La photo principale (`User.photo`) est distincte et ne compte pas dans les 6

### `UserBlock`

| Champ | Type | Notes |
|---|---|---|
| `blocked_by` | ForeignKey(User, related_name='blocks_made') | Utilisateur qui bloque |
| `blocked_user` | ForeignKey(User, related_name='blocks_received') | Utilisateur bloqué |

Unique together : `(blocked_by, blocked_user)`.

**Effets du blocage** :
- La conversation privée existante entre les deux reste visible **mais les deux ne peuvent plus écrire** (vérifié dans `messagingMessageSend`)
- L'utilisateur bloqué n'apparaît plus dans `accountsUserSearch` pour le bloqueur
- L'utilisateur bloqué ne peut plus envoyer de `ContactRequest` au bloqueur
- Déblocage possible à tout moment via `accountsUserUnblock`

### `ContentReport`

Signalement de contenu inapproprié par les membres.

| Champ | Type | Notes |
|---|---|---|
| `reporter` | ForeignKey(User, related_name='reports_made') | |
| `content_type` | CharField(choices) | `user_photo` / `event_photo` / `message` / `user_profile` |
| `user_photo` | ForeignKey(UserPhoto, null, related_name='reports') | |
| `event_photo` | ForeignKey(EventPhoto, null, related_name='reports') | |
| `message` | ForeignKey(Message, null, related_name='reports') | |
| `reported_user` | ForeignKey(User, null, related_name='reports_against') | Pour `user_profile` |
| `reason` | CharField(choices) | `inappropriate` / `harassment` / `spam` / `fake_profile` / `other` |
| `notes` | TextField(null) | Commentaire libre du reporter |
| `is_resolved` | BooleanField(default=False) | Traité par un admin |
| `resolved_by` | ForeignKey(User, null) | Admin qui a traité |
| `resolved_at` | DateTimeField(null) | |

Visible dans le Django Admin sous `MonitoringContentReportAdmin` (lecture + actions de résolution).

### `UserNotificationPreferences`

Préférences de notifications push et in-app par utilisateur. Correspond aux 8 switches dans `ProfileScreen`.

| Champ | Type | Notes |
|---|---|---|
| `user` | OneToOneField(User, related_name='notification_preferences') | |
| `push_run_confirmed` | BooleanField(default=True) | Run confirmé (seuil atteint) |
| `push_run_today` | BooleanField(default=True) | Rappel le matin du run |
| `push_deadline_reminder` | BooleanField(default=True) | Deadline bientôt |
| `push_spot_freed` | BooleanField(default=True) | Place libérée en liste d'attente |
| `push_crush_match` | BooleanField(default=True) | Crush mutuel |
| `push_contact_request` | BooleanField(default=True) | Demande de contact |
| `push_message` | BooleanField(default=True) | Nouveau message |
| `push_rate_reminder` | BooleanField(default=True) | Rappel de notation |

Créé automatiquement par signal `post_save` sur `User` (defaults à tout activé).

### `UserLegalAcceptance`

Horodatage des acceptations légales (CGU, politique de confidentialité).

| Champ | Type | Notes |
|---|---|---|
| `user` | ForeignKey(User, related_name='legal_acceptances') | |
| `document_type` | CharField(choices) | `terms` / `privacy` |
| `document_version` | CharField | ex: `2026-03-01` |
| `accepted_at` | DateTimeField(auto_now_add) | |
| `ip` | GenericIPAddressField(null) | IP au moment de l'acceptation |

Un enregistrement par acceptation (historique complet). Consulté par l'admin en cas de litige.

### `SupportTicket`

Tickets créés via le formulaire de contact (`ContactFormScreen`).

| Champ | Type | Notes |
|---|---|---|
| `user` | ForeignKey(User, null, related_name='support_tickets') | null si non authentifié |
| `subject` | CharField(choices) | `city` / `meeting_point` / `organizer` / `lievre` / `bug` / `other` |
| `name` | CharField | Pré-rempli depuis profil |
| `phone` | CharField | Pré-rempli depuis profil |
| `email` | CharField(null) | Optionnel |
| `message` | TextField | |
| `status` | CharField(choices, default='open') | `open` / `in_progress` / `resolved` / `closed` |
| `resolved_by` | ForeignKey(User, null) | Admin |
| `resolved_at` | DateTimeField(null) | |

### `Testimonial`

Témoignages affichés sur `HomeScreen`, gérés par l'admin.

| Champ | Type | Notes |
|---|---|---|
| `user` | ForeignKey(User, null) | Auteur (null = anonyme) |
| `display_name_fr` | CharField | ex: "Sophie, 34 ans, Plateau" |
| `display_name_en` | CharField(blank=True) | |
| `content_fr` | TextField | Texte du témoignage en français |
| `content_en` | TextField(blank=True) | |
| `is_published` | BooleanField(default=False) | Visible dans l'app |
| `order` | IntegerField(default=0) | Ordre d'affichage |

### `UserOnboardingAnswer`

Stocke les réponses aux 20 questions de l'onboarding. Utilisées pour la génération de bio IA et comme données de profil enrichies.

| Champ | Type | Notes |
|---|---|---|
| `user` | ForeignKey(User, related_name='onboarding_answers') | |
| `question_id` | CharField(10) | ex: `q1`, `q2` … `q20` |
| `question_text_fr` | CharField | Copie de la question en français au moment de la réponse |
| `question_text_en` | CharField(blank=True) | Copie de la question en anglais |
| `answer` | CharField | Réponse choisie (valeur brute — non traduite) |
| `category` | CharField(null) | ex: `Allure`, `Motivation`, `Flirt` |

Unique together : `(user, question_id)` — une réponse par question par utilisateur.

**Questions disponibles (20 au total)** :

| ID | Catégorie | Question |
|---|---|---|
| q1 | Allure | À quel rythme tu cours? |
| q2 | Motivation | Tu cours pour...? |
| q3 | Musique | Chanson pour ton dernier km? |
| q4 | Flirt | Ton move quand t'es essoufflé(e) devant quelqu'un de cute? |
| q5 | Humeur | Comment tu te sens avant un run avec des inconnus? |
| q6 | Personnalité | Tu es plutôt... |
| q7 | Local | Ton spot préféré pour courir à Montréal? |
| q8 | Horaire | Run du matin ou après le travail? |
| q9 | Après-run | Après le run, tu... |
| q10 | Jasette | Tu parles de quoi quand tu cours à côté de quelqu'un? |
| q11 | Météo | Pluie légère sur le parcours, tu... |
| q12 | Intentions | Objectif sur un RunDate? |
| q13 | Valeurs | C'est quoi ton red flag en groupe? |
| q14 | Local | Tu connais bien les sentiers du coin? |
| q15 | Vibe | Chien en laisse sur le parcours, tu... |
| q16 | Ponctualité | Tu arrives au point de départ... |
| q17 | Saison | Hiver à Montréal, tu cours dehors? |
| q18 | Suite | Si quelqu'un te propose un café après, tu... |
| q19 | Ambiance | Playlist ou nature? |
| q20 | Attentes | Premier RunDate, tu espères surtout... |

### `OtpVerification`
| Champ | Type | Notes |
|---|---|---|
| `phone` | CharField | |
| `code` | CharField(6) | |
| `expires_at` | DateTimeField | Durée : 10 minutes |
| `is_used` | BooleanField | |

### `OtpRateLimit`
| Champ | Type | Notes |
|---|---|---|
| `phone` | CharField | |
| `attempt_count` | IntegerField | |
| `window_start` | DateTimeField | Fenêtre de 1 heure |

**Règle** : max 5 tentatives OTP par heure par numéro.

### `UserLike` (système Crush)
| Champ | Type | Notes |
|---|---|---|
| `from_user` | ForeignKey(User) | |
| `to_user` | ForeignKey(User) | |
| `run_group` | ForeignKey(RunGroup) | Contexte : après quel run |
| `created_at` | DateTimeField | |

Signal `post_save` : si like mutuel détecté → crée `AppNotification(type=crushMatch)` pour les deux.

---

## App `events`

### `MeetingPoint`
Correspondance Flutter : `meeting_point.dart`

| Champ | Type | Notes |
|---|---|---|
| `name` | CharField | |
| `type` | CharField(choices) | park / cafe / landmark |
| `address` | CharField | |
| `neighborhood` | ForeignKey(Neighborhood) | |
| `description` | TextField(null) | |
| `photo` | ProcessedImageField(null) | |
| `maps_url` | URLField(null) | |

### `RunDateEvent`
Correspondance Flutter : `run_date_event.dart`

> **Création : admin Django uniquement.** Aucune mutation GraphQL de création — les événements sont créés et gérés via `admin.rundate.app`.
>
> **Matching : premier arrivé, premier servi.** Pas d'algorithme de matching pour l'instant. `EventRegistration.status = confirmed` dans l'ordre des inscriptions jusqu'à `max_capacity`, puis `waitlisted`.

| Champ | Type | Notes |
|---|---|---|
| `category` | CharField(max_length=30, choices=EVENT_CATEGORY_CHOICES, default='running') | `running`, `picnic`, `mixed_training`. One per event. |
| `neighborhood` | ForeignKey(Neighborhood) | |
| `city` | ForeignKey(City) | |
| `date` | DateTimeField | |
| `deadline` | DateTimeField | Fin des inscriptions |
| `pace_label` | CharField(choices) | |
| `distance_label` | CharField(choices) | |
| `approx_distance_km` | FloatField | |
| `trail_percent` | IntegerField | 0-100 |
| `apero_spot` | ForeignKey(AperoSpot, null, related_name='events') | Café apéro (voir `AperoSpot`) |
| `min_threshold` | IntegerField(default=6) | Minimum pour confirmer |
| `max_capacity` | IntegerField(default=30) | |
| `target_group_size` | IntegerField(default=6) | Taille des sous-groupes |
| `is_confirmed` | BooleanField | True si seuil atteint |
| `meeting_point` | ForeignKey(MeetingPoint) | |
| `lievre` | ForeignKey(User, null) | Pace leader optionnel |
| `activities` | ArrayField(CharField) | Tags d'activité |
| `is_deleted` | BooleanField | Soft delete |
| `deleted_at` | DateTimeField(null) | |

**`EVENT_CATEGORY_CHOICES`** :

| Value | Label (FR) | Flutter enum |
|---|---|---|
| `running` | Course à pied | `EventCategory.courseAPied` |
| `picnic` | Picnic rencontre | `EventCategory.picnicRencontre` |
| `mixed_training` | Entraînement mixte | `EventCategory.entrainementMixte` |

Each event has exactly one category (no multi-select).

**Properties calculées** : `total_registered`, `men_count`, `women_count`, `spots_remaining`, `is_past`, `is_deadline_passed`

### `EventRegistration`

| Champ | Type | Notes |
|---|---|---|
| `user` | ForeignKey(User, related_name='registrations') | |
| `event` | ForeignKey(RunDateEvent, related_name='registrations') | |
| `status` | CharField(choices) | `confirmed` / `waitlisted` / `cancelled` |
| `waitlist_position` | IntegerField(null) | Position en liste d'attente |
| `registered_at` | DateTimeField(auto_now_add) | |
| `cancelled_at` | DateTimeField(null) | |
| `cancellation_reason` | CharField(null) | Raison de désinscription (texte libre) |
| `pace_label` | CharField(choices, null) | Allure choisie à l'inscription (peut différer du profil) |
| `distance_label` | CharField(choices, null) | Distance préférée pour ce run |
| `equipment_items` | ManyToManyField(EquipmentType, blank=True) | Matériel apporté (remplace `equipment` ArrayField) |
| `companions` | ManyToManyField(CompanionType, blank=True) | Accompagnants (remplace `companion_type` CharField) |
| `companion_note` | TextField(null) | Précision libre ex: "Labrador, très gentil, en laisse" |
| `buddy_user` | ForeignKey(User, null, related_name='buddy_registrations') | Ami invité via buddy code — lien mutuel automatique |
| `preferred_partners` | ManyToManyField(User, blank=True, related_name='preferred_by') | Partenaires préférés choisis depuis la liste des inscrits |
| `lievre_invitation` | ForeignKey(LievreInvitation, null, related_name='registration') | Lié si le membre est Lièvre confirmé pour ce run |
| `is_priority_lievre` | BooleanField(default=False) | True = saute la liste d'attente, assigné leader en priorité |

Unique together : `(user, event)`.

> **Priorité Lièvre** : si `lievre_invitation` est non null et `status='accepted'`, le service force `status='confirmed'` et `is_priority_lievre=True` indépendamment de `max_capacity`.

> **Buddy code** : si un buddy code est fourni à l'inscription, on cherche l'utilisateur correspondant et on lie les deux via `buddy_user`. Si le buddy est déjà inscrit, le service établit automatiquement le lien mutuel (`B.registration.buddy_user = A`). Paires mutuelles garanties dans le même `RunGroup`.

> **Partenaires préférés** : soft preference — le matching tente de regrouper les préférences mutuelles (A préfère B ET B préfère A). Préférences unilatérales ignorées. Priorité dans le matching : Lièvres > Buddy pairs > Préférences mutuelles > Solo.

### `LievreInvitation`

Invitation envoyée par un admin à un utilisateur éligible (`is_lievre=True`) pour mener un groupe lors d'un run spécifique.

| Champ | Type | Notes |
|---|---|---|
| `event` | ForeignKey(RunDateEvent, related_name='lievre_invitations') | |
| `user` | ForeignKey(User, related_name='lievre_invitations') | Doit avoir `is_lievre=True` |
| `invited_by` | ForeignKey(User, null, related_name='lievre_invitations_sent') | Admin qui envoie l'invitation |
| `status` | CharField(choices, default='pending') | `pending` / `accepted` / `declined` |
| `admin_message` | TextField(null) | Message personnalisé de l'admin au Lièvre |
| `responded_at` | DateTimeField(null) | Moment de la réponse |
| `target_pace_label` | CharField(choices, null) | Allure du groupe qu'on lui demande de mener |

Unique together : `(event, user)` — une invitation par Lièvre par événement.

**Flux complet :**

```
1. Admin crée LievreInvitation via Django Admin
   → AppNotification(type='lievre_invitation') envoyée au Lièvre
   → FCM push

2. Lièvre voit l'invitation dans ses notifications / onglet profil
   → mutation eventsLievreInvitationRespond(invitationId, accept=True)
   → LievreInvitation.status = 'accepted' / 'declined'
   → Si accepté : AppNotification(type='lievre_invitation_accepted') à l'admin

3. Le Lièvre s'inscrit à l'événement via eventsEventRegister
   → Système détecte LievreInvitation(event, user, status='accepted')
   → EventRegistration.lievre_invitation = cette invitation
   → Statut forcé à 'confirmed' (pas de waitlist pour les Lièvres)
   → EventRegistration.pace_label = invitation.target_pace_label

4. Lors du matching (GroupMatchingService)
   → Lièvres confirmés distribués en premier (un par groupe)
   → Voir doc 23
```

**Admin** : `LievreInvitationAdmin` — création rapide depuis le détail d'un événement, filtre par statut, action "Relancer les invitations en attente".

### `EventRating`

Note multi-dimensionnelle soumise après un run. Plus riche que `EventRegistration.rating` (float simple).

| Champ | Type | Notes |
|---|---|---|
| `user` | ForeignKey(User, related_name='ratings_given') | |
| `event` | ForeignKey(RunDateEvent, related_name='ratings') | |
| `run_group` | ForeignKey(RunGroup, null, related_name='ratings') | Groupe spécifique |
| `overall_rating` | FloatField | Note globale 1-5 |
| `trail_rating` | FloatField(null) | Parcours |
| `group_rating` | FloatField(null) | Ambiance du groupe |
| `apero_rating` | FloatField(null) | Apéro smoothie |
| `comment` | TextField(null) | Commentaire général |
| `is_comment_public` | BooleanField(default=True) | Si False, visible admin seulement |
| `wants_rerun_with_group` | BooleanField(null) | "Je veux recourir avec ce groupe" |

Unique together : `(user, event)`. Déclenche la mise à jour de `User.average_rating` via signal.

### `RunGroup`
(= `RunMatch` dans Flutter)

| Champ | Type | Notes |
|---|---|---|
| `event` | ForeignKey(RunDateEvent) | |
| `members` | ManyToManyField(User) | |
| `lievre` | ForeignKey(User, null) | |
| `status` | CharField(choices) | confirmed / completed / cancelled |

### `AperoSpot`

Café ou lieu apéro après le run. Réutilisable sur plusieurs événements. Géré via Django Admin.

| Champ | Type | Notes |
|---|---|---|
| `name` | CharField | ex: "Café Névé" |
| `address` | CharField | |
| `neighborhood` | ForeignKey(Neighborhood) | |
| `lat` | FloatField | Coordonnées GPS |
| `lng` | FloatField | |
| `maps_url` | URLField(null) | Lien Google Maps / Apple Maps |
| `website_url` | URLField(null) | |
| `phone` | CharField(null) | |
| `notes` | TextField(null) | ex: "terrasse disponible été" |
| `photo` | ProcessedImageField(null) | |

### `EventWeather`

Météo prévisionnelle liée à un événement. Alimenté par `events_weather_sync` (toutes les 3h).

| Champ | Type | Notes |
|---|---|---|
| `event` | OneToOneField(RunDateEvent, related_name='weather') | |
| `temp_celsius` | FloatField(null) | |
| `feels_like` | FloatField(null) | |
| `condition` | CharField(null) | `clear` / `cloudy` / `rain` / `snow` / `thunderstorm` |
| `condition_icon` | CharField(null) | Code icône ex: `"01d"` — mappé côté Flutter |
| `wind_kmh` | FloatField(null) | |
| `precip_mm` | FloatField(null) | Précipitations prévues |
| `fetched_at` | DateTimeField(null) | |
| `source` | CharField(default='open-meteo') | |

API : **Open-Meteo** — gratuit, sans clé API. Endpoint : `https://api.open-meteo.com/v1/forecast?latitude={lat}&longitude={lng}&hourly=temperature_2m,precipitation,weathercode,windspeed_10m`

### `EquipmentType`

Catalogue du matériel que les membres peuvent apporter. Géré via Django Admin, exposé via GraphQL.

| Champ | Type | Notes |
|---|---|---|
| `name_fr` | CharField | ex: "Gourde" |
| `name_en` | CharField(blank=True) | ex: "Water bottle" |
| `icon_name` | CharField | Nom d'icône Material Flutter ex: `water_drop` |
| `category` | CharField(choices) | `hydration` / `sun` / `safety` / `trail` / `other` |
| `order` | IntegerField(default=0) | |
| `is_active` | BooleanField(default=True) | |

Exemples : Gourde, Bouteille d'eau, Lunettes de soleil, Casquette, Bâtons de marche, Gilet réfléchissant, Lampe frontale, Crème solaire.

### `CompanionType`

Catalogue des accompagnants que les membres peuvent amener. Géré via Django Admin, exposé via GraphQL.

| Champ | Type | Notes |
|---|---|---|
| `name_fr` | CharField | ex: "Chien" |
| `name_en` | CharField(blank=True) | ex: "Dog" |
| `icon_name` | CharField | Nom d'icône Material Flutter ex: `pets` |
| `requires_note` | BooleanField(default=False) | Si True, Flutter affiche un champ texte pour préciser |
| `order` | IntegerField(default=0) | |
| `is_active` | BooleanField(default=True) | |

Exemples : Chien (`requires_note=True`), Poussette, Fauteuil roulant, Enfant.

### `EventInvitation`

Invitation envoyée par un membre inscrit à un autre utilisateur pour rejoindre l'événement.

| Champ | Type | Notes |
|---|---|---|
| `event` | ForeignKey(RunDateEvent, related_name='invitations') | |
| `from_user` | ForeignKey(User, related_name='event_invitations_sent') | Doit être inscrit à l'event |
| `to_user` | ForeignKey(User, related_name='event_invitations_received') | |
| `message` | TextField(null) | Message facultatif de l'invitant |
| `status` | CharField(choices, default='pending') | `pending` / `accepted` / `declined` / `expired` |
| `responded_at` | DateTimeField(null) | |

Unique together : `(event, from_user, to_user)`.

**Flux :**
```
A (inscrit) invite B avec message optionnel
→ EventInvitation(status=pending)
→ AppNotification(type='event_invitation', from_user=A, event=event, event_invitation=inv)
→ FCM push notification à B

B accepte → eventsEventInviteRespond(accept=True)
  → EventRegistration créée pour B (confirmed si place dispo, sinon waitlisted)
  → AppNotification(type='event_invitation_accepted') pour A

B décline → EventInvitation(status=declined), aucune notification à A
```

### `EventRegistrationLog`

Audit trail append-only de chaque changement de statut d'inscription. Jamais modifié après création.

| Champ | Type | Notes |
|---|---|---|
| `registration` | ForeignKey(EventRegistration, related_name='logs') | |
| `user` | ForeignKey(User) | Dénormalisé |
| `event` | ForeignKey(RunDateEvent) | Dénormalisé |
| `action` | CharField(choices) | `registered` / `waitlisted` / `promoted` / `cancelled` / `kicked` |
| `previous_status` | CharField(null) | |
| `new_status` | CharField | |
| `reason` | TextField(null) | Raison si annulation / kick |
| `triggered_by` | CharField(choices) | `user` / `admin` / `system` / `auto_promotion` |

Créé automatiquement par le service d'inscription à chaque changement de statut.

---

## App `messaging`

### `Conversation`

Deux types de conversations coexistent dans le même modèle, distingués par `conversation_type`.

| Champ | Type | Notes |
|---|---|---|
| `conversation_type` | CharField(choices) | `group` / `private` |
| `group_name` | CharField | ex: "Run Laurier #3" — calculé côté serveur à la création |
| `run_group` | ForeignKey(RunGroup, null) | `group` uniquement — null pour les privées |
| `event` | ForeignKey(RunDateEvent, null) | Dénormalisé depuis RunGroup pour faciliter les filtres |
| `is_active` | BooleanField(default=True) | False si groupe annulé ou conversation fermée |

**Types** :
- `group` — créée automatiquement à la confirmation d'un `RunGroup`. Nom = "Run [quartier] #N"
- `private` — créée lors d'un crush mutuel (`UserLike`) **ou** après acceptation d'un `ContactRequest`

### `ConversationMember`

Modèle intermédiaire entre `Conversation` et `User`. Remplace le `ManyToManyField` simple — permet de gérer l'archivage par utilisateur.

| Champ | Type | Notes |
|---|---|---|
| `conversation` | ForeignKey(Conversation, related_name='memberships') | |
| `user` | ForeignKey(User, related_name='conversation_memberships') | |
| `joined_at` | DateTimeField(auto_now_add) | |
| `last_read_at` | DateTimeField(null) | Dernier message lu — pour calcul des non-lus |
| `is_archived` | BooleanField(default=False) | Archive côté utilisateur (les autres membres ne voient pas) |
| `archived_at` | DateTimeField(null) | |
| `is_muted` | BooleanField(default=False) | Notifications push désactivées pour cette conversation |

Unique together : `(conversation, user)`.

> **Archivage** : une conversation archivée disparaît de la liste principale mais reste accessible via `archived=true`. L'archivage est individuel — si un membre archive, les autres ne sont pas affectés.

### `Message`

| Champ | Type | Notes |
|---|---|---|
| `conversation` | ForeignKey(Conversation, related_name='messages') | |
| `sender` | ForeignKey(User, null) | null pour les messages système (`is_system=True`) |
| `content` | TextField | |
| `timestamp` | DateTimeField(auto_now_add) | |
| `is_icebreaker` | BooleanField(default=False) | Message de départ généré automatiquement |
| `is_system` | BooleanField(default=False) | Notifications système dans le chat (ex: "Crush mutuel!") |
| `is_hidden` | BooleanField(default=False) | Masqué par admin suite à un signalement |

> Les non-lus sont calculés en comparant `Message.timestamp` et `ConversationMember.last_read_at` — plus de table `MessageRead` séparée.

### `ContactRequest`

Demande de contact privé entre deux membres ayant partagé un `RunGroup`.

| Champ | Type | Notes |
|---|---|---|
| `from_user` | ForeignKey(User, related_name='sent_contact_requests') | |
| `to_user` | ForeignKey(User, related_name='received_contact_requests') | |
| `run_group` | ForeignKey(RunGroup, null) | Contexte du run commun |
| `status` | CharField(choices) | `pending` / `accepted` / `declined` |
| `intro_message` | CharField(500, null) | Message d'intro optionnel |
| `conversation` | ForeignKey(Conversation, null, related_name='contact_request') | Créée à l'acceptation |

Unique together : `(from_user, to_user, run_group)` — une seule demande par paire par run.

**Signal `post_save`** sur `status = accepted` :
1. Crée une `Conversation(type='private')`
2. Crée deux `ConversationMember` (from + to)
3. Insère un `Message(is_system=True)` — "Vous avez accepté de vous connecter après le run!"
4. Crée une `AppNotification(type=contactRequest)` pour `to_user`

### `TypingStatus`

Indicateur "en train d'écrire" pour la messagerie. TTL court — auto-expire après 5 secondes sans heartbeat.

| Champ | Type | Notes |
|---|---|---|
| `user` | ForeignKey(User, related_name='typing_statuses') | |
| `conversation` | ForeignKey(Conversation, related_name='typing_statuses') | |
| `expires_at` | DateTimeField | `now() + 5 secondes` — mis à jour à chaque heartbeat |

Unique together : `(user, conversation)` — upsert via `update_or_create`. Le management command `messaging_typing_status_purge` supprime les enregistrements expirés toutes les 60s.

---

## App `notifications`

### `AppNotification`
Correspondance Flutter : `app_notification.dart`

| Champ | Type | Notes |
|---|---|---|
| `user` | ForeignKey(User) | Destinataire |
| `type` | CharField(choices) | Voir types ci-dessous |
| `title_fr` | CharField | Titre en français |
| `title_en` | CharField(blank=True) | Titre en anglais |
| `body_fr` | TextField | Corps en français |
| `body_en` | TextField(blank=True) | Corps en anglais |
| `is_read` | BooleanField(default=False) | |
| `is_archived` | BooleanField(default=False) | Masquée de la liste principale, pas supprimée |
| `archived_at` | DateTimeField(null) | |
| `from_user` | ForeignKey(User, null, related_name='notifications_sent') | Pour crushMatch, contactRequest, event_invitation |
| `event` | ForeignKey(RunDateEvent, null, related_name='notifications') | Pour les notifs liées à un run |
| `run_group` | ForeignKey(RunGroup, null, related_name='notifications') | Pour matchFound |
| `contact_request` | ForeignKey(ContactRequest, null, related_name='notifications') | Pour contactRequest |
| `event_invitation` | ForeignKey(EventInvitation, null, related_name='notifications') | Pour event_invitation |

Les deux langues sont générées à la création via `TranslationService`. Flutter affiche `title_fr` ou `title_en` selon `User.language`.

**Types** : `matchFound`, `runConfirmed`, `runCancelled`, `deadlineReminder`, `runToday`, `rateReminder`, `friendInvited`, `contactRequest`, `thresholdReached`, `eventCancelledNoQuorum`, `spotFreed`, `crushMatch`, `lievre_invitation`, `lievre_invitation_accepted`, `event_invitation`, `event_invitation_accepted`, `verification_approved`, `verification_rejected`

Signal `post_save` : envoi FCM automatique à la création d'une notification.

---

## App `community`

### `EventPhoto`

Photos partagées par les membres après un run. Visibles publiquement par tous les utilisateurs de l'app.

| Champ | Type | Notes |
|---|---|---|
| `event` | ForeignKey(RunDateEvent, related_name='photos') | |
| `user` | ForeignKey(User, related_name='event_photos') | Membre qui a uploadé |
| `photo` | ProcessedImageField | `upload_to='events/photos/'`, redimensionné 1200×1200 max |
| `photo_thumbnail` | ImageSpecField | Crop 400×400, généré à la demande |
| `description` | TextField(null) | Légende optionnelle |
| `order` | IntegerField(default=0) | Ordre dans la galerie de l'événement |

- **Visibilité** : publique, sans restriction, visible à tout moment (avant/pendant/après)
- **Publication** : immédiate — pas de modération
- **Limite** : max 10 photos par utilisateur par événement (enforced dans le service)
- Signalement possible via `ContentReport(content_type='event_photo')`

### `FaqItem`

Questions fréquentes affichées dans `FaqScreen`. Gérées via Django Admin, servies en GraphQL. L'API retourne les deux langues — Flutter choisit selon `User.language`.

| Champ | Type | Notes |
|---|---|---|
| `question_fr` | TextField | |
| `question_en` | TextField(blank=True) | |
| `answer_fr` | TextField | Peut contenir du texte formaté avec `\n•` |
| `answer_en` | TextField(blank=True) | |
| `order` | IntegerField(default=0) | Ordre d'affichage |
| `is_published` | BooleanField(default=False) | Contrôle la visibilité dans l'app |

### `CommunityRule`

Règles de la communauté affichées dans `CommunityRulesScreen`. Structure spécifique avec icône.

| Champ | Type | Notes |
|---|---|---|
| `icon_name` | CharField | Nom d'icône Material Flutter ex: `schedule_outlined` |
| `title_fr` | CharField | Titre court en français |
| `title_en` | CharField(blank=True) | |
| `body_fr` | TextField | Description détaillée en français |
| `body_en` | TextField(blank=True) | |
| `order` | IntegerField(default=0) | |
| `is_published` | BooleanField(default=True) | |

### `LegalDocument`

Documents légaux versionnés (CGU, politique de confidentialité). Historique complet — `is_current` identifie la version active. Référencé par `UserLegalAcceptance.document_version`. Un seul record par version, les deux langues sur le même enregistrement.

| Champ | Type | Notes |
|---|---|---|
| `document_type` | CharField(choices) | `terms` / `privacy` |
| `version` | CharField | ex: `2026-03-01` — doit correspondre à `UserLegalAcceptance.document_version` |
| `title_fr` | CharField | ex: `"Conditions d'utilisation"` |
| `title_en` | CharField(blank=True) | ex: `"Terms of Use"` |
| `effective_date` | DateField | Date d'entrée en vigueur |
| `content_fr` | TextField | Contenu complet en français |
| `content_en` | TextField(blank=True) | Contenu complet en anglais |
| `is_current` | BooleanField(default=False) | Un seul document `is_current=True` par `document_type` |
| `published_at` | DateTimeField(null) | Null = brouillon |

Unique together (soft) : un seul `is_current=True` par `(document_type)` — enforced dans le service lors de la publication.

### `PhotoLike`

Like sur une photo de la galerie communauté.

| Champ | Type | Notes |
|---|---|---|
| `user` | ForeignKey(User, related_name='photo_likes') | |
| `event_photo` | ForeignKey(EventPhoto, related_name='likes') | |

Unique together : `(user, event_photo)`. `EventPhoto.likes_count` = `likes.count()` (annotable en queryset).

### `WaitingQuestion`
| Champ | Type | Notes |
|---|---|---|
| `question_fr` | TextField | |
| `question_en` | TextField(blank=True) | |
| `options_fr` | ArrayField(CharField) | Options de réponse en français |
| `options_en` | ArrayField(CharField, blank=True) | Options de réponse en anglais |
| `category` | CharField(null) | ex: "Allure", "Motivation" |
| `xp_reward` | IntegerField(default=5) | |

### `UserVerification`

Demande de vérification d'identité soumise par un membre. Chaque tentative crée un enregistrement distinct — historique complet conservé.

| Champ | Type | Notes |
|---|---|---|
| `user` | ForeignKey(User, related_name='verifications') | |
| `selfie_photo` | ProcessedImageField | `upload_to='verifications/selfies/'`, redimensionné 1200×1200 max |
| `status` | CharField(choices, default='pending') | `pending` / `approved` / `rejected` / `cancelled` |
| `submitted_at` | DateTimeField(auto_now_add) | Date de soumission du selfie |
| `reviewed_at` | DateTimeField(null) | Date de la décision admin |
| `reviewed_by` | ForeignKey(User, null, related_name='verifications_reviewed') | Admin ayant pris la décision |
| `rejection_reason` | CharField(choices, null) | `photo_unclear` / `face_not_visible` / `profile_mismatch` / `other` |
| `rejection_note` | TextField(null) | Note interne admin (non affichée à l'utilisateur) |
| `slot` | ForeignKey(VerificationSlot, null, related_name='verification') | Créneau réservé (si applicable) |

**Flux :**
```
1. Membre upload selfie → mutation accountsUserUploadVerificationSelfie(photo)
   → UserVerification(status=pending, selfie_photo=...)
   → AppNotification admin (ou alerte Dashboard)

2. Admin examine dans Django Admin
   → Approuve → UserVerification(status=approved, reviewed_by=admin, reviewed_at=now())
                 → User.is_verified=True, User.verified_at=now()
                 → AppNotification(type='verification_approved') au membre
   → Rejette  → UserVerification(status=rejected, rejection_reason=..., rejection_note=...)
                 → AppNotification(type='verification_rejected') au membre
                 → Membre peut soumettre une nouvelle tentative

3. Membre peut annuler une demande en attente → status=cancelled
```

Un seul `UserVerification(status=pending)` actif par utilisateur — enforced dans le service.

### `VerificationSlot`

Créneaux de vérification disponibles, gérés via Django Admin.

| Champ | Type | Notes |
|---|---|---|
| `date` | DateField | |
| `time_slot` | CharField | ex: "10h00-10h15" |
| `is_available` | BooleanField(default=True) | False quand réservé |
| `booked_by` | ForeignKey(User, null, related_name='verification_slots') | Utilisateur ayant réservé |
| `booked_at` | DateTimeField(null) | |

---

## App `monitoring`

### `HttpRequestLog`

Journal de toutes les requêtes HTTP reçues par le backend. Alimenté par un middleware Django.

**Ce modèle n'hérite PAS de `BaseModel`** — pas d'`updated_at`, pas d'UUID primary key. Il utilise un `AutoField` classique pour des raisons de performance (insertions à très haute fréquence).

| Champ | Type | Notes |
|---|---|---|
| `id` | AutoField (PK) | Int auto-incrémenté — plus rapide que UUID pour l'insert |
| `timestamp` | DateTimeField(auto_now_add, db_index) | Moment de la requête |
| `method` | CharField(10) | GET, POST, OPTIONS… |
| `path` | CharField(255) | URL path ex: `/graphql/` |
| `status_code` | IntegerField(null) | Code de réponse HTTP |
| `response_time_ms` | IntegerField(null) | Durée de traitement en ms |
| `ip` | GenericIPAddressField(null) | IP du client (derrière Cloudflare : `CF-Connecting-IP`) |
| `user_agent` | TextField(null) | En-tête `User-Agent` complet |
| `browser_name` | CharField(100, null) | Parsé depuis user_agent ex: `Chrome` |
| `browser_version` | CharField(50, null) | ex: `122.0` |
| `os_name` | CharField(100, null) | ex: `iOS`, `Android`, `macOS` |
| `device_type` | CharField(50, null) | `mobile`, `tablet`, `desktop` |
| `user` | ForeignKey(User, null) | Utilisateur authentifié si token valide |
| `graphql_operation` | CharField(200, null) | Nom de l'opération GraphQL si applicable |
| `referer` | URLField(null) | En-tête `Referer` |
| `country_code` | CharField(2, null) | Depuis l'en-tête Cloudflare `CF-IPCountry` |

```python
class HttpRequestLog(models.Model):
    """Logs every HTTP request for monitoring and debugging. Not soft-deletable."""

    id = models.AutoField(primary_key=True)
    timestamp = models.DateTimeField(auto_now_add=True, db_index=True)
    method = models.CharField(max_length=10)
    path = models.CharField(max_length=255)
    status_code = models.IntegerField(null=True)
    response_time_ms = models.IntegerField(null=True)
    ip = models.GenericIPAddressField(null=True)
    user_agent = models.TextField(null=True, blank=True)
    browser_name = models.CharField(max_length=100, null=True, blank=True)
    browser_version = models.CharField(max_length=50, null=True, blank=True)
    os_name = models.CharField(max_length=100, null=True, blank=True)
    device_type = models.CharField(max_length=50, null=True, blank=True)
    user = models.ForeignKey(
        'accounts.User', null=True, blank=True,
        on_delete=models.SET_NULL, related_name='http_logs'
    )
    graphql_operation = models.CharField(max_length=200, null=True, blank=True)
    referer = models.URLField(null=True, blank=True)
    country_code = models.CharField(max_length=2, null=True, blank=True)

    class Meta:
        verbose_name = 'http request log'
        verbose_name_plural = 'http request logs'
        indexes = [
            models.Index(fields=['timestamp']),
            models.Index(fields=['user', 'timestamp']),
            models.Index(fields=['ip', 'timestamp']),
        ]
```

### Middleware `HttpRequestLogMiddleware`

Enregistre chaque requête en base après l'envoi de la réponse (via `process_response`). Le parsing du `user_agent` est fait avec la lib `user-agents`.

```python
# monitoring/middleware.py
import time
import user_agents
from .models import HttpRequestLog

class HttpRequestLogMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        start = time.monotonic()
        response = self.get_response(request)
        elapsed_ms = int((time.monotonic() - start) * 1000)

        self._log(request, response, elapsed_ms)
        return response

    def _log(self, request, response, elapsed_ms):
        ua_string = request.META.get('HTTP_USER_AGENT', '')
        ua = user_agents.parse(ua_string)

        # Cloudflare headers
        ip = request.META.get('HTTP_CF_CONNECTING_IP') or request.META.get('REMOTE_ADDR')
        country = request.META.get('HTTP_CF_IPCOUNTRY')

        graphql_op = None
        if request.path == '/graphql/' and hasattr(request, 'graphql_operation'):
            graphql_op = request.graphql_operation

        HttpRequestLog.objects.create(
            method=request.method,
            path=request.path[:255],
            status_code=response.status_code,
            response_time_ms=elapsed_ms,
            ip=ip,
            user_agent=ua_string[:2000] if ua_string else None,
            browser_name=ua.browser.family,
            browser_version=ua.browser.version_string,
            os_name=ua.os.family,
            device_type='mobile' if ua.is_mobile else ('tablet' if ua.is_tablet else 'desktop'),
            user=getattr(request, 'user', None) if hasattr(request, 'user') and request.user.is_authenticated else None,
            graphql_operation=graphql_op,
            referer=request.META.get('HTTP_REFERER', '')[:500] or None,
            country_code=country,
        )
```

Ajout à `requirements/base.txt` : `user-agents`

### Purge des anciennes données

Management command `monitoring_httprequestlog_purge` (suit la convention de nommage) :

- **Fréquence** : toutes les 24 heures dans le container `workers`
- **Rétention** : configurable via `HTTP_LOG_RETENTION_DAYS` dans les settings (défaut : **30 jours**)
- **Mécanisme** : suppression en batch pour éviter les locks DB prolongés

```python
# apps/monitoring/management/commands/monitoring_httprequestlog_purge.py
import time
from django.core.management.base import BaseCommand
from django.utils.timezone import now
from datetime import timedelta
from django.conf import settings
from apps.monitoring.models import HttpRequestLog

class Command(BaseCommand):
    help = 'Purge HTTP request logs older than HTTP_LOG_RETENTION_DAYS'

    def handle(self, *args, **options):
        while True:
            try:
                self._purge()
            except Exception as e:
                logger.error("purge_error", extra={"error": str(e)})
            time.sleep(86400)  # 24 hours

    def _purge(self):
        retention_days = getattr(settings, 'HTTP_LOG_RETENTION_DAYS', 30)
        cutoff = now() - timedelta(days=retention_days)
        deleted, _ = HttpRequestLog.objects.filter(timestamp__lt=cutoff).delete()
        logger.info("logs_purged", extra={"count": deleted, "cutoff": str(cutoff)})
```

### `ApplicationAccessLog`

Log chaque appel GraphQL par application. Alimenté par le décorateur `@log_graphql_request`.

| Champ | Type | Notes |
|---|---|---|
| `id` | AutoField (PK) | Int auto-incrémenté |
| `timestamp` | DateTimeField(auto_now_add, db_index) | |
| `application_access` | ForeignKey(ApplicationAccess, related_name='logs') | |
| `user_access_token` | ForeignKey(UserAccessToken, null, related_name='logs') | null si requête publique |
| `graphql_operation` | CharField(200, null) | Nom de la mutation/query |
| `graphql_variables` | JSONField(null) | Variables (données sensibles filtrées) |
| `graphql_headers` | JSONField(null) | Headers filtrés (sans Authorization ni Token) |
| `http_request_log` | ForeignKey(HttpRequestLog, null, related_name='graphql_logs') | Lien au log HTTP global |

### `RateLimit`

Compteur pour le rate limiting par IP — pas de Redis.

| Champ | Type | Notes |
|---|---|---|
| `ip` | GenericIPAddressField(unique) | |
| `request_count` | IntegerField(default=1) | |
| `window_start` | DateTimeField | Début de la fenêtre courante |

### Admin Django

`MonitoringHttpRequestLogAdmin` — lecture seule, filtres par date/IP/user/opération GraphQL.
`MonitoringApplicationAccessLogAdmin` — lecture seule, filtres par application/opération.
