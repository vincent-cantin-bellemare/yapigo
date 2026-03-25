# RunDate — Site Web

Documentation complète du site web marketing de RunDate.

Domaine : `www.rundate.app`
Emplacement dans le monorepo : `apps/web/`

---

## Objectif

Le site web sert de vitrine pour l'application RunDate, qui est en cours de développement. Il doit :

- Expliquer le concept, la mission et le fonctionnement de l'app
- Montrer la progression du développement et la date de release approximative
- Afficher des screenshots de l'application avec des explications par écran
- Permettre aux visiteurs de se préinscrire (téléphone et/ou courriel)
- Recruter des Lièvres (pace leaders) bénévoles
- Centraliser les demandes de contact (presse, partenariat, implication, etc.)
- Afficher les liens App Store / Google Play (marqués « Bientôt disponible »)
- Héberger une vidéo promotionnelle (placeholder en attendant)
- Héberger les pages légales requises par Apple et Google (FAQ, Confidentialité, CGU)
- Optimiser le SEO pour bien se positionner

---

## Stack technique

| Technologie | Rôle |
|---|---|
| Next.js 15 (App Router) | Framework React, SSR/SSG |
| TypeScript | Typage |
| Tailwind CSS v4 | Styles |
| next-intl | Bilingue FR/EN |
| Framer Motion | Animations |
| react-google-recaptcha-v3 | Anti-spam formulaires |
| Nodemailer | Envoi d'emails via Gmail SMTP |
| googleapis | Google Sheets API (préinscriptions) |
| next-sitemap | Sitemap / robots.txt |
| Vercel | Déploiement (monorepo, root = `apps/web`) |

**Pas de CMS** — tout le contenu (textes, FAQ, legal, témoignages) est directement dans les fichiers i18n JSON et le code TypeScript.

**Pas d'API backend** — les formulaires envoient des courriels et écrivent dans un Google Sheet via des API routes Next.js serverless.

---

## Thème

Repris de l'app Flutter (`apps/mobile/lib/theme/app_theme.dart`).

### Couleurs

Palette bleue dérivée du gradient du logo yapigo (teal → navy).

#### Couleurs de marque (gradient du logo)

| Nom | Hex | Usage |
|---|---|---|
| Teal | `#00D4AA` | Accent principal, CTAs, liens actifs |
| Cyan | `#00BCD4` | Accent secondaire, hover states, highlights |
| Ocean | `#0097A7` | Couleur primaire, boutons, icônes |
| DeepTeal | `#00838F` | Variante foncée pour contraste, hover |
| NavyBlue | `#1B4A6A` | Headers secondaires, texte foncé |
| Navy | `#1B2A4A` | Ancre foncée, texte principal, headers |

#### Couleurs fonctionnelles

| Nom | Hex | Usage |
|---|---|---|
| Cream | `#FBF7F2` | Fond principal (light theme) |
| DarkScaffold | `#1A1A2E` | Fond principal (dark theme) |
| DarkSurface | `#242438` | Cartes, modals (dark theme) |
| SlateGrey | `#64748B` | Texte secondaire, légendes |
| Border | `#CBD5E1` | Bordures, séparateurs (light) |
| Error | `#EF4444` | Erreurs, alertes |
| Warning | `#F59E0B` | Avertissements |
| Success | `#10B981` | Succès, confirmations |

#### Gradient de marque

```css
--gradient-brand: linear-gradient(135deg, #00D4AA, #00BCD4, #0097A7, #1B2A4A);
```

### Polices

- **Nunito** — titres, boutons, navigation
- **DM Sans** — corps de texte, labels, paragraphes

Chargées via `next/font/google`.

---

## Bilingue

Le site est entièrement bilingue **français / anglais** dès le lancement.

- Routing par locale : `/fr/...` et `/en/...`
- Fichiers de traduction : `src/i18n/messages/fr.json` et `en.json`
- Language switcher dans la navbar
- Locale par défaut : `fr`
- Balises `hreflang` pour le SEO

---

## Pages

Le site comporte **12 pages** organisées sous `src/app/[locale]/`.

### 1. Accueil (`/`)

La page la plus riche en contenu. Elle raconte l'histoire de RunDate et pousse à l'action.

#### Bandeau countdown (sticky, toutes les pages)

- Countdown animé vers la date de lancement (Automne 2026)
- Compteur de préinscriptions en temps réel : « Déjà X coureurs préinscrits — Objectif : 500 »

#### Sections (dans l'ordre de scroll)

**Hero**
- Logo RunDate
- Tagline animée (« Sors du swipe, lace tes souliers »)
- Bouton « Je me préinscris »
- Fond avec gradient teal → navy (gradient de marque)

**Le problème**
- Les apps de rencontre sont de plus en plus délaissées — les gens en ont marre du swipe
- On ne passe pas assez de temps à faire nos activités, on rend l'utile à l'agréable
- Statistiques animées (counter au scroll) :
  - Nombre de célibataires au Québec (~2.4M, source Statistique Canada)
  - Nombre de coureurs au Québec (~1.5M, source Léger/Running Room)
  - RunDate rejoint ces deux mondes

**Tes options actuelles** (comparaison directe, ton direct mais pas agressif)
- **Tinder** : impossible de savoir facilement si la personne est sportive. C'est la plateforme de rencontre la plus rentable au monde — tu veux continuer à les rendre riches?
- **Hinge** : bon concept, mais l'offre et la demande ne sont pas équilibrées. Trop de matchs ou rien du tout, surtout quand t'es un gars.
- **Ton club de course** : tu y vas déjà, mais matcher là-dedans c'est plus compliqué, c'est pas fait pour ça.
- **RunDate** : les coureurs, c'est équilibré — autant d'hommes que de femmes. Une base naturelle pour des rencontres justes.

**Pourquoi la course**
- La course est la meilleure façon de rencontrer : on peut se parler et se voir dans des moments vrais, pas à travers un écran
- Oubliez l'alcool — restez sains durant votre date, pas besoin d'un bar pour connecter
- Vous êtes stressé à l'idée de rencontrer? Quoi de mieux que courir pour évacuer le stress!
- On termine au Ravito (café local partenaire) pour discuter — c'est là que tu brilles après l'effort

**Comment ça marche** (4 étapes visuelles avec icônes animées)
1. Inscris-toi et choisis ton quartier
2. On te matche un groupe de célibataires à ton pace
3. Courez ensemble au point de départ
4. Ravito Smoothie pour jaser et connecter

**Sécurité et confiance** (essentiel, surtout pour les femmes)
- Vérification d'identité (selfie + FaceTime)
- Courses en groupe (jamais seul avec un inconnu)
- Lieux publics uniquement
- Système de signalement
- Données hébergées au Canada

**Fonctionnalités** — grille 6-8 features clés avec icônes
- Matching IA
- Intégration Strava
- Événements de course
- Messagerie de groupe
- Buddy Codes
- Communauté

**Carte de Montréal** (interactive SVG ou Leaflet)
- Quartiers couverts en couleur : Plateau, Mile-End, Villeray, Rosemont, Verdun, Griffintown, Vieux-Port, Hochelaga
- Quartiers « bientôt » en grisé
- Hover pour voir le nom du quartier

**Screenshots** — carousel avec 4-6 placeholders device-framed + légende par écran

**Vidéo** — embed YouTube placeholder (image avec bouton play en attendant la vraie vidéo)

**App Store** — badges iOS/Android « Bientôt disponible »

**Témoignages « avant RunDate »** (frustrations avec les apps actuelles, ton québécois authentique)
- « J'ai matché avec 200 personnes sur Tinder en 6 mois. J'ai eu 3 conversations qui ont mené à rien. Je suis tannée. » — Isabelle, 34 ans, Villeray
- « Sur Hinge, je reçois peut-être 1 like par mois. Mon coloc en reçoit 15 par jour. C'est pas équilibré pantoute. » — Marc-Antoine, 38 ans, Plateau
- « J'allais à mon club de course pour rencontrer du monde, mais c'est tous des couples ou du monde qui veut juste son PR. » — Sophie, 32 ans, Rosemont
- « Mon dernier date Tinder, le gars ressemblait pas à ses photos et il a commandé 4 bières en 1h. J'aurais préféré courir. » — Émilie, 36 ans, Mile-End
- « J'ai supprimé Bumble 3 fois. 3 fois je l'ai réinstallé parce que je savais pas quoi faire d'autre. Y'a tu juste ça comme option? » — Olivier, 41 ans, Verdun
- « Je cours 4 fois par semaine. Je suis célibataire. Comment ça se fait qu'aucune app combine les deux? » — Camille, 29 ans, Griffintown

**Témoignages « après RunDate »** (vision positive, la promesse)
- « On s'est rencontrés au km 3 d'un Run Date. Maintenant on court ensemble tous les matins! » — Sophie, 31 ans
- « Les groupes sont toujours bien formés. J'ai trouvé ma pace (et mon match)! » — Marc-Antoine, 38 ans
- « J'étais sceptique mais l'Ravito Smoothie après, c'est là que la magie opère! » — Émilie, 42 ans
- « Enfin une app de dating qui sort du swipe! On court, on jase, on connecte pour vrai. » — Olivier, 36 ans

**Rejoins l'équipe** (recrutement ambassadeurs/bénévoles)
- « Tu veux faire exploser les inscriptions? On cherche des gens bons en réseaux sociaux pour nous aider à faire connaître RunDate. »
- Aussi : Lièvres, photographes, partenaires cafés/smoothies
- CTA vers la page Contact (sujet « Je veux m'impliquer » pré-sélectionné)

**Conçu à Montréal** (fierté locale)
- « Conçu à Montréal, pour Montréal » — fait par un dev d'ici, pas une multinationale californienne
- CTA vers la page À propos

**CTA final** — formulaire rapide préinscription inline (email seulement) + compteur préinscriptions

---

### 2. Fonctionnalités (`/features`)

Pour chaque fonctionnalité, un bloc avec screenshot placeholder + explication détaillée :

| Fonctionnalité | Description |
|---|---|
| Matching intelligent | Groupes formés par affinités, pace, distance, vibe. Notre « super ordinateur quantique » analyse tout. |
| Événements de course sociale | Calendrier, inscription, seuil minimum de 6 pour confirmer. |
| Intégration Strava | Sync des activités, affichage des stats dans le profil. |
| Buddy Codes | Code unique format ANIMAL-MOT pour courir avec ses amis. |
| Messagerie de groupe | Chat avec ton groupe, icebreakers pour lancer la conversation. |
| Liste des membres | Découvrir d'autres coureurs, filtrer par ville/pace/intérêts. |
| Connexions | Liker, se connecter, retrouver des gens croisés en course. |
| Rôle Lièvre | Meneur d'allure bénévole qui donne le rythme et met l'ambiance. |
| Ravito Smoothie | Point de rencontre post-course dans un café local partenaire. |
| Notation post-course | Évaluer l'événement, le parcours et les membres du groupe. |
| Vérification d'identité | Selfie + appel FaceTime pour la sécurité de tous. |

**Mentions importantes :**
- Gratuit. Peut-être un jour des fonctionnalités avancées payantes.
- Québec d'abord, puis autres provinces. Français, anglais et québécois.

---

### 3. Roadmap / Développement (`/roadmap`)

- Timeline visuelle basée sur les slices du plan de développement (`docs/plan-developpement.md`)
- Phase actuelle mise en évidence (Flutter avec mocks complets)
- Date de release approximative : « Automne 2026 » (à confirmer)
- Barre de progression visuelle
- Indicateurs : 34 écrans développés, 30k+ lignes de code, mocks complets

---

### 4. Trouve ton pace (`/pace-quiz`)

Mini-quiz interactif viral en 3 questions (animations entre chaque étape) :

1. À quel rythme tu cours? (slider ou choix illustré)
2. Quelle distance tu préfères? (choix avec icônes)
3. C'est quoi ta vibe? (social, compétitif, relax...)

**Résultat** : ton « esprit animal » RunDate

| Animal | Pace |
|---|---|
| Tortue sociale | Balade (7:30+/km) |
| Canard du parc | Tranquille (6:30-7:00/km) |
| Renard rusé | Modérée (5:30-6:30/km) |
| Chevreuil de Longueuil | Rapide (5:00-5:30/km) |
| Road Runner | Intense (4:30/km et moins) |

- Image de l'animal, description fun, pace correspondant
- Boutons de partage réseaux sociaux (Facebook, Instagram story, Twitter/X, copier le lien)
- CTA « Préinscris-toi pour courir avec d'autres [animal]! »
- Potentiel viral : les gens partagent leur résultat → découverte organique de RunDate

---

### 5. Préinscription (`/register`)

**Formulaire :**
- Prénom
- Email (requis)
- Téléphone (optionnel)
- Ville
- Comment tu as entendu parler de RunDate?

**Page de confirmation post-inscription :**
- « Merci [prénom]! Tu es le Xe coureur préinscrit! »
- Boutons de partage : « Dis à tes amis de lacer leurs souliers »
- Lien de parrainage (optionnel, via query param)
- CTA vers le quiz « Trouve ton pace » s'ils ne l'ont pas fait

---

### 6. Devenir Lièvre (`/lievre`)

Explication du rôle de Lièvre (meneur d'allure bénévole qui donne le rythme et met l'ambiance).

**Formulaire :**
- Prénom
- Email
- Téléphone
- Expérience de course
- Pace habituelle
- Disponibilités
- Motivation

---

### 7. Contact (`/contact`)

Formulaire unique regroupant toutes les demandes.

**Formulaire :**
- Nom
- Email
- Sujet (dropdown) : Question générale, Partenariat, Presse, Je veux m'impliquer, Bug/problème, Autre
- Message

---

### 8. Sondage étude de marché (`/survey`)

Formulaire multi-étapes servant à la fois de validation produit et d'entonnoir de conversion vers la préinscription. Style wizard (une question par écran, animations, barre de progression), ton casual québécois.

#### Étape 1 — Toi

**Q1. Es-tu célibataire?**
Sous-titre : « Pas de jugement, c'est juste pour mieux te connaître. »
Type : choix unique
- Oui, célibataire
- En couple, mais ouvert(e) aux activités sociales
- C'est compliqué 😅

**Q2. T'as quel âge?**
Sous-titre : « On demande la tranche, pas la date exacte. »
Type : choix unique
- 18-24 ans
- 25-29 ans
- 30-34 ans
- 35-39 ans
- 40-44 ans
- 45-50 ans
- 50 ans et +

**Q3. Tu t'identifies comme...**
Sous-titre : « Pour qu'on comprenne mieux notre communauté. »
Type : choix unique
- Un homme
- Une femme
- Non-binaire / Autre
- Je préfère ne pas répondre

#### Étape 2 — La course

**Q4. Est-ce que tu cours?**
Sous-titre : « Que tu sois marathonien ou que tu cours juste pour l'autobus, on veut savoir. »
Type : choix unique
- Oui, régulièrement (2 fois et + par semaine)
- De temps en temps (quelques fois par mois)
- Rarement, mais j'aimerais m'y remettre
- Non, mais je serais ouvert(e) à essayer
- Non, et ça m'intéresse pas vraiment

**Q5. C'est quoi ton rythme habituel?**
Sous-titre : « Y'a pas de mauvaise réponse. On court tous à notre pace. »
Type : choix unique
Logique conditionnelle : affichée seulement si Q4 ≠ « Non, ça m'intéresse pas »
- 🐢 Balade — On jase plus qu'on court (7:30+/km)
- 🦆 Tranquille — Relax mais ça avance (6:30-7:00/km)
- 🦊 Modéré — Le sweet spot (5:30-6:30/km)
- 🦌 Rapide — Ça déboule (5:00-5:30/km)
- 🏃 Intense — Mode machine (moins de 5:00/km)
- 🤷 Aucune idée / je m'en fous du pace

**Q6. Tu cours en groupe ou en solo?**
Sous-titre : « Les deux sont corrects. »
Type : choix unique
- Toujours solo — mes écouteurs pis moi
- Solo, mais j'aimerais essayer en groupe
- En groupe de temps en temps (club, amis)
- En groupe régulièrement

#### Étape 3 — Les rencontres

**Q7. Tu utilises des apps de rencontre en ce moment?**
Sous-titre : « Tinder, Hinge, Bumble, Grindr... on juge pas. »
Type : choix unique
- Oui, activement
- J'en ai déjà utilisé, mais j'ai lâché
- Non, jamais essayé
- Non, je préfère rencontrer du monde autrement

**Q8. Qu'est-ce qui te gosse le plus avec les apps de rencontre?**
Sous-titre : « Coche tout ce qui s'applique. On comprend. »
Type : choix multiples
- Le swipe sans fin — c'est rendu un réflexe vide
- Les conversations qui mènent nulle part
- Les profils qui matchent pas la réalité
- Le déséquilibre — trop de matchs ou rien pantoute
- Le côté superficiel — jugé juste sur les photos
- La pression de la « première date »
- Pas assez de gens sportifs / actifs
- Honnêtement, ça va bien pour moi

**Q9. Comment tu préfères rencontrer des gens dans la vraie vie?**
Sous-titre : « Si t'avais le choix. »
Type : choix unique
- Lors d'activités (sport, loisirs, bénévolat)
- Par des amis communs
- En ligne (apps, réseaux sociaux)
- Dans des bars / soirées
- Au travail ou aux études
- Événements organisés (speed dating, soirées thématiques)

#### Étape 4 — RunDate

Intro d'étape affichée avant Q10 : « RunDate, c'est une app pour courir en groupe avec des célibataires dans ton quartier à Montréal. Notre algo te matche un groupe à ton rythme. Après la course, tout le monde se retrouve au Ravito Smoothie (un café local) pour jaser. »

**Q10. Ça t'intéresse?**
Sous-titre : « Sois honnête, c'est ça qui nous aide. »
Type : choix unique
- Oui, j'embarque! 🏃
- Ça pourrait m'intéresser, j'aimerais en savoir plus
- Peut-être, mais j'ai des réserves
- Non, c'est pas pour moi

**Q11. Qu'est-ce qui est le plus important pour toi dans une app comme RunDate?**
Sous-titre : « Choisis tes 3 priorités, en ordre. »
Type : top 3 ordonnés (drag & drop ou sélection 1er, 2e, 3e)
- Sécurité (vérification d'identité, courses en groupe, lieux publics)
- Gratuité (pas envie de payer pour rencontrer du monde)
- Qualité du matching (être avec des gens compatibles)
- Variété de quartiers et de lieux
- Flexibilité des paces (pas obligé de courir vite)
- Le côté social après la course (Ravito Smoothie)
- Pouvoir y aller avec un ami (Buddy Code)
- Intégration Strava (voir ses stats)

**Q12. Qu'est-ce qui pourrait te freiner?**
Sous-titre : « On veut savoir pour s'améliorer. Coche tout ce qui s'applique. »
Type : choix multiples
- J'ai peur de pas être assez en forme
- Ça me gêne de courir avec des inconnus
- J'ai pas le temps
- Pas envie de m'embarquer dans une app de plus
- Inquiétude sur la sécurité
- Ça dépend du prix
- Rien me freine, je suis partant(e)! 🔥

**Q13. Combien tu serais prêt(e) à payer par mois?**
Sous-titre : « L'app de base sera gratuite. On parle de fonctionnalités avancées éventuelles. »
Type : choix unique
- Rien — ça doit rester gratuit
- 0 à 5$ / mois
- 5 à 10$ / mois
- 10 à 15$ / mois
- 15$+ / mois si la qualité est là

#### Étape 5 — Pour aller plus loin

**Q14. Tu habites dans quel coin?**
Sous-titre : « Pour savoir où organiser les premiers runs. »
Type : dropdown
- Montréal → (sous-dropdown : Plateau, Mile-End, Villeray, Rosemont, Verdun, Griffintown, Vieux-Port, Hochelaga, Autre)
- Laval
- Longueuil / Rive-Sud
- Québec
- Gatineau
- Sherbrooke
- Autre ville au Québec
- Hors Québec

**Q15. Un commentaire, une suggestion, une idée folle?**
Sous-titre : « Champ libre. Dis-nous ce que tu veux. »
Type : textarea, optionnel

**Q16. Tu veux te préinscrire à RunDate?**
Sous-titre : « Sois parmi les premiers à courir. C'est gratuit et sans engagement. »
Type : CTA avec deux chemins

Si « Oui, inscris-moi! » :
- Prénom (requis)
- Email (requis)
- Téléphone (optionnel)
- → Message : « Merci [prénom]! Tu es le Xe coureur préinscrit! » + boutons partage

Si « Pas pour l'instant » :
- → Message : « Merci d'avoir pris le temps! Tes réponses nous aident énormément. » + bouton partage du sondage

#### Notes UX

- Barre de progression en haut (Étape 1/5, 2/5, etc.)
- Bouton retour pour modifier ses réponses
- Animations entre chaque question (slide gauche/droite, style app mobile)
- Logique conditionnelle : Q5 cachée si Q4 = « Non, ça m'intéresse pas »
- Temps estimé affiché au début : « 2 minutes, promis »
- Ton : tutoiement, québécois naturel, quelques emojis légers

#### Données collectées

- Toutes les réponses → Google Sheet onglet « Sondage »
- Si préinscription (Q16 = oui) → Google Sheet onglet « Préinscriptions » avec colonne Source = « sondage »
- Les données croisées permettent d'analyser : qui se préinscrit, qu'est-ce qui les motive, quel pricing acceptable, quels freins

#### Valeur pour le projet

| Donnée | Utilité |
|---|---|
| Q1, Q4, Q10 | Validation du marché cible |
| Q7, Q8, Q9 | Compréhension de la compétition |
| Q11, Q12 | Priorisation des fonctionnalités |
| Q13 | Stratégie de pricing |
| Q14 | Ciblage géographique |
| Q16 | Conversion en préinscription |

---

### 9. À propos (`/about`)


- **Montréal d'abord** : RunDate est conçu à Montréal, par un développeur d'ici, pour les gens d'ici. Pas une multinationale californienne — un projet local qui comprend ta réalité.
- Photo/avatar du développeur (placeholder)
- Bio de Vincent Cantin Bellemare, programmeur
- Lien LinkedIn (placeholder, à remplir)
- Vision du projet, motivation
- Section « L'équipe » (juste Vincent pour l'instant, extensible)

---

### 10. FAQ (`/faq`)

Accordéon bilingue avec les 11 questions existantes :

1. C'est quoi RunDate?
2. Comment ça marche le matching?
3. C'est quoi un point de départ?
4. C'est quoi l'Ravito Smoothie?
5. Comment marchent les sous-groupes?
6. C'est quoi un Lièvre?
7. C'est quoi un Buddy Code?
8. C'est quoi le système de badges?
9. Est-ce que je peux choisir les membres de mon groupe?
10. C'est quoi les différents paces?
11. Est-ce gratuit?
12. Comment signaler un comportement inapproprié?

Contenu source : `apps/mobile/lib/screens/profile/faq_screen.dart`

Schema JSON-LD `FAQPage` pour le SEO (Google affiche les FAQ directement dans les résultats de recherche).

---

### 11. Politique de confidentialité (`/privacy`)

9 sections reprises du Flutter (`apps/mobile/lib/screens/profile/privacy_screen.dart`) :

1. Collecte des données
2. Utilisation des données
3. Partage des données
4. Vérification d'identité
5. Stockage et sécurité
6. Conservation des données
7. Vos droits
8. Cookies et analytics
9. Contact DPO

URL requise pour App Store Connect et Google Play Console.

---

### 12. Conditions d'utilisation (`/terms`)

10 sections reprises du Flutter (`apps/mobile/lib/screens/profile/terms_screen.dart`) :

1. Acceptation des conditions
2. Description du service
3. Inscription et compte
4. Comportement des utilisateurs
5. Système de notation
6. Annulations et désinscriptions
7. Propriété intellectuelle
8. Limitation de responsabilité
9. Modifications
10. Contact

URL requise pour App Store Connect et Google Play Console.

---

## Composants partagés

### Bandeau countdown
Sticky sur toutes les pages. Countdown animé vers la date de lancement + compteur de préinscriptions en temps réel.

### Navbar
Responsive, logo, liens de navigation, language switcher FR/EN, bouton CTA « Préinscris-toi ».

### Footer
Liens vers toutes les pages, réseaux sociaux (Facebook — placeholder), pages légales (FAQ, Confidentialité, CGU), contact@rundate.app.

---

## Formulaires — gestion technique

Aucune intégration avec l'API backend (pas encore prêt). Tout passe par des API routes Next.js serverless.

```
Utilisateur → Formulaire (client)
  → Token reCAPTCHA v3
  → Next.js API Route (server-side)
    → Vérification reCAPTCHA (Google API)
    → Si valide :
      → Préinscription : Google Sheets API (ajout ligne) + Nodemailer (email confirmation + notif admin)
      → Lièvre : Nodemailer (email avec sujet « Candidature Lièvre »)
      → Contact : Nodemailer (email avec sujet dynamique « [RunDate Contact] {sujet} »)
    → Réponse au client (succès/erreur)
```

### Variables d'environnement requises

| Variable | Usage |
|---|---|
| `GMAIL_USER` | Adresse Gmail pour l'envoi |
| `GMAIL_APP_PASSWORD` | Mot de passe d'application Gmail |
| `GOOGLE_SHEETS_ID` | ID du spreadsheet de préinscriptions |
| `GOOGLE_SERVICE_ACCOUNT_KEY` | Clé JSON du service account Google |
| `RECAPTCHA_SITE_KEY` | Clé publique reCAPTCHA v3 |
| `RECAPTCHA_SECRET_KEY` | Clé secrète reCAPTCHA v3 |
| `CONTACT_EMAIL` | Adresse destinataire (ex: contact@rundate.app) |
| `NEXT_PUBLIC_GA_MEASUREMENT_ID` | ID Google Analytics 4 (ex: G-XXXXXXXXXX) |

### Sujets d'email par formulaire

| Formulaire | Sujet de l'email |
|---|---|
| Préinscription (notif admin) | `[RunDate] Nouvelle préinscription : {prénom}` |
| Préinscription (confirmation) | `Bienvenue chez RunDate, {prénom}!` |
| Lièvre | `[RunDate] Candidature Lièvre : {prénom}` |
| Contact | `[RunDate Contact] {sujet sélectionné}` |

---

## Cookie consent & Google Analytics

- Bannière de consentement aux cookies bilingue FR/EN, conforme à la Loi 25 du Québec et au RGPD
- Google Analytics 4 chargé **uniquement** si l'utilisateur accepte les cookies analytiques
- Choix persisté dans un cookie `cookie-consent` (durée 1 an)
- Bouton pour modifier son choix accessible dans le footer
- Pas de librairie lourde — composant maison léger

---

## SEO

- **next-sitemap** pour générer sitemap.xml et robots.txt
- Metadata Next.js (title, description, OG tags) par page et par locale
- JSON-LD : Organization, WebApplication, FAQPage
- Balises `hreflang` pour FR/EN
- Images optimisées (next/image, WebP)
- Core Web Vitals optimisés (SSG pour pages statiques)
- Meta description : « RunDate — L'app de course sociale pour célibataires à Montréal. Cours en groupe, fais des rencontres, partage un Ravito Smoothie. »

---

## Déploiement

- **Vercel** — monorepo avec `vercel.json` à la racine pointant vers `apps/web`
- Variables d'environnement dans le dashboard Vercel
- Domaine : `www.rundate.app` (ou `rundate.app`)
- Preview deployments sur les branches

---

## Recommandations SEO & croissance

Stratégies recommandées pour amener du trafic organique et faire croître les préinscriptions.

### Priorité haute (à faire au lancement)

**SEO technique (déjà dans le plan)**
- Metadata, JSON-LD (Organization, WebApplication, FAQPage), sitemap, hreflang
- Rich snippets FAQ dans les résultats Google
- Core Web Vitals optimisés (SSG, next/image)

**Google Search Console**
- Soumettre le sitemap dès le premier déploiement sur Vercel
- Surveiller les requêtes, le positionnement et les erreurs d'indexation

**Quiz « Trouve ton pace » comme outil viral**
- Chaque résultat a sa propre URL partageable (`/pace-quiz?result=canard`) avec image OG unique par animal
- Les gens partagent leur résultat sur les réseaux → backlinks naturels et découverte organique
- Capte des requêtes comme « quel type de coureur suis-je », « test pace course »

### Priorité moyenne (post-lancement)

**Pages par quartier**
- Créer des pages statiques par quartier couvert : `/fr/quartiers/plateau`, `/fr/quartiers/mile-end`, etc.
- Contenu : description du quartier pour la course, parcours populaires, cafés partenaires potentiels, « bientôt des événements RunDate ici »
- Rank sur « course [quartier] », « running [quartier] montréal », « où courir à [quartier] »
- 8 quartiers disponibles : Plateau, Mile-End, Villeray, Rosemont, Verdun, Griffintown, Vieux-Port, Hochelaga

**Google My Business**
- Créer une fiche même sans local physique (catégorie « Application mobile » ou « Organisation sportive »)
- Apparaît dans les recherches locales « course montréal », « activités célibataires montréal »
- Gratuit et immédiat

**Backlinks locaux**
- Contacter des blogs running québécois, pages Facebook de clubs de course, médias locaux
- Un seul article dans un média local (Journal de Montréal, Métro, etc.) vaut 50 articles de blog en termes de SEO
- Approcher les influenceurs running/fitness de Montréal pour qu'ils fassent le quiz et partagent leur résultat

### Priorité basse (Phase 2, post-lancement app)

**Blog / articles**
- Articles ciblés sur des requêtes longue traîne :
  - « meilleurs parcours de course à Montréal »
  - « où courir au Plateau Mont-Royal »
  - « comment rencontrer des gens quand on est sportif »
  - « clubs de course montréal célibataires »
  - « activités pour célibataires montréal »
- Attire exactement la cible (coureurs célibataires à Montréal)
- Contenu evergreen (parcours, quartiers, conseils) qui continue de ranker longtemps
- Nécessite de la régularité — à ne pas commencer tant que l'app n'est pas lancée
- ROI lent (3-6 mois pour que Google positionne bien les articles)

### Mots-clés cibles

| Mot-clé | Volume estimé | Compétition |
|---|---|---|
| course célibataire montréal | Faible | Très faible (niche) |
| running dating | Moyen | Faible |
| rencontre sportive québec | Faible | Très faible |
| activités célibataires montréal | Moyen | Moyenne |
| où courir à montréal | Élevé | Moyenne |
| club de course montréal | Moyen | Moyenne |
| app rencontre sportif | Faible | Faible |

### Tableau récapitulatif

| Stratégie | Priorité | Effort | Impact | Quand |
|---|---|---|---|---|
| SEO technique (metadata, JSON-LD, sitemap) | Haute | Faible | Fort | Lancement |
| Quiz viral « Trouve ton pace » | Haute | Moyen | Fort | Lancement |
| Google Search Console | Haute | Faible | Fort | Dès le déploiement |
| Pages par quartier | Moyenne | Moyen | Fort | Post-lancement |
| Google My Business | Moyenne | Faible | Moyen | Post-lancement |
| Backlinks médias locaux | Moyenne | Relationnel | Très fort | Post-lancement |
| Blog / articles | Basse | Élevé | Lent mais durable | Post-lancement app |

---

## Génération d'images

Les images nécessaires au site peuvent être générées via **fal.ai** à l'aide d'un script Python existant dans le projet.

### Images à générer

| Image | Description | Usage |
|---|---|---|
| OG Image | Image Open Graph avec logo RunDate + tagline, 1200x630px | Partage réseaux sociaux (toutes les pages) |
| Hero background | Groupe de coureurs dans un quartier de Montréal, ambiance chaleureuse | Section Hero page d'accueil |
| Screenshots mockups | Device frames (iPhone) avec captures d'écran de l'app | Carousel screenshots, page fonctionnalités |
| Animaux pace | Tortue, Canard, Renard, Chevreuil, Road Runner dans le style RunDate | Quiz « Trouve ton pace », résultats partageables |
| OG par animal | Image OG unique par résultat du quiz (1200x630px avec l'animal + texte) | Partage résultat quiz sur les réseaux |
| Quartiers | Illustrations ou photos des 8 quartiers de Montréal | Carte interactive, futures pages quartiers |
| Icônes features | Icônes illustrées pour chaque fonctionnalité | Grille features, page fonctionnalités |
| Photo placeholder dev | Avatar/illustration du développeur | Page À propos |
| Backgrounds sections | Textures, gradients, illustrations pour les sections de la page d'accueil | Décoration visuelle |

### Outil

Script Python via fal.ai disponible dans `scripts/`. Les images générées seront placées dans `apps/web/public/images/`.

---

## Informations en attente

Ces éléments seront ajoutés en placeholder et remplis plus tard :

- LinkedIn de Vincent Cantin Bellemare
- Identifiants Google (Gmail app password, service account, reCAPTCHA keys)
- URL de la page Facebook RunDate
- Screenshots réels de l'application
- Vidéo promotionnelle (YouTube URL)
- Date de release exacte
