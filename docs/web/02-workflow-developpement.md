# RunDate — Workflow de développement du site web

Stratégie de développement en 3 phases : on construit le design complet d'abord, puis on branche les fonctionnalités backend.

---

## Principe

On développe le site **interface en premier**, sans aucune intégration backend. Tous les formulaires ont une soumission simulée (`console.log`) jusqu'à ce que le design soit validé. Ensuite, on branche les services (emails, Google Sheets, reCAPTCHA).

```
Phase 1 (Setup)  →  Phase 2 (Interface)  →  Phase 3 (Backend)
   ~1 jour              ~3-5 jours              ~1-2 jours
```

---

## Phase 1 — Setup & Infrastructure

Mettre en place le projet et les outils de base.

### 1.1 Initialiser Next.js

```bash
cd apps/web
npx create-next-app@latest . --typescript --tailwind --eslint --app --src-dir
```

- Next.js 15 avec App Router
- TypeScript strict
- Tailwind CSS v4
- ESLint configuré
- Dossier `src/`

### 1.2 Configurer le thème Tailwind

- Couleurs yapigo dans `tailwind.config.ts` :

```typescript
const config = {
  theme: {
    extend: {
      colors: {
        // Brand gradient (logo colors)
        teal: { DEFAULT: '#00D4AA', light: '#5EEAD4', dark: '#00838F' },
        cyan: { DEFAULT: '#00BCD4', light: '#67E8F9', dark: '#0097A7' },
        ocean: { DEFAULT: '#0097A7', light: '#22D3EE', dark: '#00838F' },
        navy: { DEFAULT: '#1B2A4A', light: '#1B4A6A', dark: '#0B1120' },
        // Neutrals
        cream: '#FBF7F2',
        'dark-scaffold': '#1A1A2E',
        'dark-surface': '#242438',
        'slate-grey': '#64748B',
        // Semantic
        error: { DEFAULT: '#EF4444', light: '#F87171' },
        warning: { DEFAULT: '#F59E0B', light: '#FBBF24' },
        success: { DEFAULT: '#10B981', light: '#34D399' },
      },
      backgroundImage: {
        'gradient-brand': 'linear-gradient(135deg, #00D4AA, #00BCD4, #0097A7, #1B2A4A)',
      },
    },
  },
};
```

- Polices Nunito et DM Sans via `next/font/google`
- Variables CSS globales pour light/dark themes

### 1.3 Configurer next-intl (bilingue)

- Installer `next-intl`
- Middleware pour la détection de locale
- Routing par locale (`/fr/...`, `/en/...`)
- Fichiers de traduction `fr.json` et `en.json`
- Locale par défaut : `fr`

### 1.4 Assets

- Copier le logo depuis `apps/mobile/assets/images/logo_rundate.jpeg` vers `public/images/`
- Créer les placeholders pour les screenshots
- Favicon

**Critère de validation Phase 1** : `npm run dev` démarre sans erreur, la page affiche « RunDate » avec les bonnes couleurs et polices, le routing `/fr` et `/en` fonctionne.

---

## Phase 2 — Interface (UI seulement)

Construire toutes les pages et composants. Les formulaires ont une soumission simulée.

### 2.1 Layout commun

- **Navbar** : logo, liens de navigation, language switcher FR/EN, bouton CTA « Préinscris-toi », menu hamburger mobile
- **Footer** : liens vers toutes les pages, réseaux sociaux, pages légales, contact@rundate.app
- **Bandeau countdown** : sticky en haut, countdown animé vers le lancement, compteur de préinscriptions (valeur statique en attendant la Phase 3)

### 2.2 Page d'accueil (`/`)

La page la plus complexe. Sections dans l'ordre :

1. Hero (tagline animée, CTA)
2. Le problème (stats animées au scroll)
3. Tes options actuelles (comparaison Tinder/Hinge/club vs RunDate)
4. Pourquoi la course (4 arguments)
5. Comment ça marche (4 étapes visuelles)
6. Sécurité et confiance (5 points)
7. Fonctionnalités (grille icônes)
8. Carte de Montréal (quartiers interactifs)
9. Screenshots (carousel placeholders)
10. Vidéo (placeholder)
11. App Store (badges « Bientôt »)
12. Témoignages « avant RunDate » (frustrations)
13. Témoignages « après RunDate » (promesse)
14. Rejoins l'équipe (recrutement ambassadeurs)
15. Conçu à Montréal
16. CTA final (formulaire inline préinscription)

### 2.3 Page fonctionnalités (`/features`)

- Blocs alternés (image gauche/droite) pour chaque fonctionnalité
- Screenshots placeholders avec device frame
- Explication détaillée de chaque feature

### 2.4 Page roadmap (`/roadmap`)

- Timeline verticale avec les phases de développement
- Phase actuelle en surbrillance
- Barre de progression
- Date estimée de release

### 2.5 Page préinscription (`/register`) — UI seulement

- Formulaire complet (prénom, email, téléphone, ville, source)
- Validation côté client
- Soumission → `console.log` des données + message de succès simulé
- Page de confirmation (« Merci! Tu es le Xe coureur! » avec boutons partage)

### 2.6 Page Lièvre (`/lievre`) — UI seulement

- Section explicative du rôle
- Formulaire complet (prénom, email, téléphone, expérience, pace, dispo, motivation)
- Soumission → `console.log` + message de succès simulé

### 2.7 Page contact (`/contact`) — UI seulement

- Formulaire (nom, email, sujet dropdown, message)
- Sujets : Question générale, Partenariat, Presse, Je veux m'impliquer, Bug/problème, Autre
- Soumission → `console.log` + message de succès simulé

### 2.8 Page Trouve ton pace (`/pace-quiz`)

- Quiz interactif en 3 étapes avec animations
- Résultat : esprit animal avec image et description
- Boutons de partage réseaux sociaux
- CTA vers la préinscription

### 2.9 Page à propos (`/about`)

- Section « Montréal d'abord »
- Bio développeur avec photo placeholder
- LinkedIn placeholder
- Vision et motivation

### 2.10 Page sondage étude de marché (`/survey`)

- Wizard multi-étapes (5 étapes, 16 questions, barre de progression)
- Étape 1 : Profil (célibataire, âge, genre)
- Étape 2 : Course (fréquence, pace, solo/groupe)
- Étape 3 : Rencontres (apps utilisées, frustrations, préférences)
- Étape 4 : RunDate (intérêt, features importantes, freins, pricing)
- Étape 5 : Localisation + commentaire libre + CTA préinscription
- UI : une question par écran, animations entre étapes, ton casual québécois
- Soumission → `console.log` des réponses en attendant la Phase 3

### 2.11 Pages légales

- **FAQ** (`/faq`) : accordéon avec 11+ questions, bilingue
- **Confidentialité** (`/privacy`) : 9 sections, bilingue
- **CGU** (`/terms`) : 10 sections, bilingue

Contenu repris du Flutter et traduit en anglais.

### 2.12 SEO

- Metadata Next.js par page et par locale (title, description, OG tags)
- JSON-LD : Organization, WebApplication, FAQPage
- Balises `hreflang`
- Sitemap et robots.txt via next-sitemap
- Images optimisées

### 2.13 Configuration Vercel

- `vercel.json` à la racine du monorepo
- `.env.example` avec toutes les variables requises
- Documentation de déploiement

**Critère de validation Phase 2** : toutes les pages sont navigables en FR et EN, le design est cohérent avec le thème de l'app Flutter, les formulaires affichent les données dans la console, le site est responsive (mobile, tablette, desktop).

---

## Phase 3 — Backend / Intégrations

Brancher les services externes sur les formulaires déjà fonctionnels côté UI.

### 3.1 Cookie consent & Google Analytics

1. Créer le composant `CookieConsentBanner` (bannière bilingue, bas de page)
2. Choix : Accepter / Refuser / Personnaliser (analytiques vs nécessaires)
3. Persistance du choix dans un cookie `cookie-consent` (durée 1 an)
4. Charger Google Analytics 4 (`gtag.js`) **uniquement** si consentement accepté
5. Bouton « Gérer les cookies » dans le footer pour modifier son choix
6. Conforme à la Loi 25 du Québec et au RGPD

**Pré-requis** : ID Google Analytics 4 (G-XXXXXXXXXX) — à fournir par le développeur.

### 3.2 reCAPTCHA v3

1. Installer `react-google-recaptcha-v3`
2. Créer le `RecaptchaProvider` côté client
3. Créer l'API route `/api/recaptcha` pour la vérification server-side
4. Intégrer aux 3 formulaires (register, lièvre, contact)
5. Tester avec les clés de test Google

**Pré-requis** : clés reCAPTCHA v3 (site key + secret key) — à fournir par le développeur.

### 3.3 Envoi de courriels

1. Installer `nodemailer`
2. Créer l'utilitaire `src/lib/email.ts` (Gmail SMTP)
3. Créer les API routes :
   - `/api/contact` → email avec sujet `[RunDate Contact] {sujet}`
   - `/api/lievre` → email avec sujet `[RunDate] Candidature Lièvre : {prénom}`
   - `/api/register` → email de confirmation à l'utilisateur + notification admin
4. Remplacer les `console.log` des formulaires par des appels aux API routes
5. Tester l'envoi

**Pré-requis** : identifiant d'application Google (Gmail app password) — à fournir par le développeur.

### 3.4 Google Sheets (préinscriptions)

1. Installer `googleapis`
2. Créer un Google Sheet avec les colonnes : Date, Prénom, Email, Téléphone, Ville, Source
3. Configurer un service account Google Cloud avec accès au Sheet
4. Créer l'utilitaire `src/lib/sheets.ts`
5. Modifier l'API route `/api/register` pour ajouter une ligne au Sheet
6. Implémenter le compteur en temps réel (`PreRegistrationCounter`) qui lit le nombre de lignes du Sheet
7. Tester

**Pré-requis** : Google Cloud service account + ID du spreadsheet — à configurer par le développeur.

### 3.5 Sondage → Google Sheets

1. Créer un onglet « Sondage » dans le Google Sheet (colonnes : date, Q1-Q16, préinscrit oui/non)
2. Créer l'API route `/api/survey` pour sauvegarder les réponses
3. Si préinscription (Q16 = oui) → écrire aussi dans l'onglet « Préinscriptions » avec Source = « sondage »
4. Remplacer le `console.log` du wizard par l'appel API
5. Tester le flux complet

**Critère de validation Phase 3** : les formulaires envoient de vrais emails, les préinscriptions s'ajoutent au Google Sheet, le sondage enregistre les réponses, le compteur affiche le vrai nombre, le reCAPTCHA bloque les soumissions suspectes.

---

## Récapitulatif des dépendances npm

```json
{
  "dependencies": {
    "next": "^15",
    "react": "^19",
    "react-dom": "^19",
    "next-intl": "^4",
    "framer-motion": "^11",
    "react-google-recaptcha-v3": "^1",
    "nodemailer": "^6",
    "googleapis": "^140",
    "next-sitemap": "^4"
  },
  "devDependencies": {
    "typescript": "^5",
    "@types/react": "^19",
    "@types/nodemailer": "^6",
    "tailwindcss": "^4",
    "eslint": "^9"
  }
}
```

---

## Checklist de déploiement

- [ ] Toutes les pages fonctionnent en FR et EN
- [ ] Formulaires fonctionnels (emails envoyés, Sheet alimenté)
- [ ] reCAPTCHA actif sur les 3 formulaires
- [ ] SEO vérifié (Lighthouse, meta tags, sitemap)
- [ ] Performance vérifiée (Core Web Vitals, Lighthouse > 90)
- [ ] Responsive vérifié (mobile, tablette, desktop)
- [ ] `vercel.json` configuré pour le monorepo
- [ ] Variables d'environnement dans Vercel
- [ ] Domaine `www.rundate.app` configuré
- [ ] SSL actif (automatique avec Vercel)
- [ ] Pages légales accessibles (URLs pour App Store / Google Play)
