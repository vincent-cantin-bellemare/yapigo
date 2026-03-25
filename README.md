# yapigo

Multi-sport social app for active people in Quebec. Sign up for outdoor activities together, meet at the point de chute, and gather for Apéro Smoothie after.

## Monorepo Structure

```
yapigo/
  apps/
    mobile/       Flutter (Dart) — iOS/Android mobile app
    web/          Next.js (TypeScript) — Web app (coming soon)
  backend/        Django (Python) — REST API (coming soon)
  scripts/        Utility scripts (icon generation, etc.)
  assets/
    originals/    Original design files (logos, videos)
```

## Tech Stack

- **Mobile**: Flutter 3.41.5 / Dart 3.11.3
- **Web**: Next.js + TypeScript + Tailwind CSS (planned)
- **Backend**: Django + Django REST Framework (planned)
- **Matching**: AI-powered group matching (planned)

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
python generate_icons.py
```

## Target Audience

- Active people in Quebec who enjoy outdoor sports and group activities
- Tone: casual "tu" (tutoiement), natural Québécois French, fun and encouraging
