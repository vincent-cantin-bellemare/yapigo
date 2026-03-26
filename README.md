# Run Date

Dating app for runners — meet people by going running together. Based in Montreal / Quebec. Domain: rundate.app

## Monorepo Structure

```
rundate/
  apps/
    mobile/       Flutter (Dart) — iOS/Android mobile app
    web/          Next.js (TypeScript) — Web app (coming soon)
  backend/        Django (Python) — REST API (coming soon)
  scripts/        Utility scripts (icon generation, etc.)
  assets/
    logos/         Logo files and candidates
```

## Tech Stack

- **Mobile**: Flutter 3.41.5 / Dart 3.11.3
- **Web**: Next.js + TypeScript + Tailwind CSS (planned)
- **Backend**: Django + Django REST Framework (planned)
- **Matching**: AI-powered matching (planned)

## Getting Started

### Mobile App

```bash
cd apps/mobile
flutter pub get
flutter run
```

**Prerequisites**: Flutter SDK 3.41+, Xcode (iOS), CocoaPods

### Icon Generation

```bash
cd scripts
pip install fal-client Pillow
python generate_rundate_logo_fal.py
```

## Target Audience

- Runners in Quebec who want to meet new people through running
- Tone: casual "tu" (tutoiement), natural Québécois French, fun and encouraging
