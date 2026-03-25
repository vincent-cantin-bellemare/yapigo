# 10 — Seeds

## Principe

Les seeds permettent de démarrer avec des données cohérentes sans tout réinstaller. Elles sont exécutées via des management commands Django.

## Commandes disponibles

```bash
# Toutes les seeds (dev uniquement)
make seed-dev
→ python manage.py seed_all

# Données de référence seulement (staging + production au premier démarrage)
make seed-prod-base
→ python manage.py seed_prod_base

# Utilisateurs fake (dev + staging)
python manage.py seed_fake_users

# Événements de test
python manage.py seed_events
```

## Ordre d'exécution (`seed_all`)

1. `seed_cities_neighborhoods` — villes et quartiers
2. `seed_meeting_points` — 12 points de rencontre
3. `seed_waiting_questions` — 20 questions + icebreakers
4. `seed_fake_users` — 50 utilisateurs fake
5. `seed_events` — 10 événements sur les 14 prochains jours

## Détail de chaque seed

### `seed_cities_neighborhoods`

Charge les villes et quartiers depuis les fixtures JSON.

Source des données : `apps/mobile/lib/data/quebec_cities.dart` (synchronisé).

```json
// fixtures/seed_cities.json
[
  { "model": "geography.city", "pk": "uuid", "fields": { "name": "Montréal", "region": "Montréal", "lat": 45.5017, "lng": -73.5673 }}
]
```

Quartiers Montréal inclus :
- Ahuntsic-Cartierville, Anjou, Griffintown, Hochelaga-Maisonneuve, Lachine, LaSalle
- Le Plateau-Mont-Royal, Le Sud-Ouest, Mercier, Mile-End, Montréal-Nord, Outremont
- Petite-Patrie, Rosemont, Saint-Henri, Saint-Laurent, Verdun, Villeray, Vieux-Montréal...

### `seed_meeting_points`

Charge les 12 points de rencontre depuis les fixtures JSON.

Source : `apps/mobile/lib/data/mock_meeting_points.dart` (synchronisé).

Inclut : Parc La Fontaine, Parc Laurier, Parc Jarry, Parc Jeanne-Mance, Mont-Royal (Cartier), Café Olimpico, Dispatch Coffee, Pikolo Espresso Bar, Crew Collective, Bassin Peel, Horloge Vieux-Port, Stade olympique.

### `seed_waiting_questions`

Charge les 20 questions de l'écran d'attente + les icebreakers.

Source : `apps/mobile/lib/data/mock_questions.dart` (synchronisé).

Catégories : Allure, Motivation, Musique, Flirt, Humeur, Personnalité, Local, Horaire, Après-run, Jasette, Météo, Intentions, Valeurs, Ponctualité, Saison, Suite, Ambiance, Attentes.

### `seed_fake_users`

Génère 50 utilisateurs fake réalistes pour les tests.

Caractéristiques :
- Prénoms/noms québécois
- Photos via `https://picsum.photos/seed/<nom>/200/200`
- XP et badges variés (curieux → légende)
- Buddy codes uniques format ANIMAL-MOT
- Bios en québécois
- Répartition : ~50% Montréal, ~20% Plateau, ~15% Mile-End, ~15% autres quartiers
- Allures variées (tortue → road runner)

### `seed_events`

Génère 10 événements ancrés sur `now()` comme dans le mock Flutter.

| # | Jours depuis aujourd'hui | Quartier | Allure | Statut |
|---|---|---|---|---|
| 1 | +3 | Plateau | Renard rusé | Confirmé |
| 2 | +5 | Mile-End | Canard | Liste d'attente |
| 3 | +7 | Villeray | Tortue | Proche du seuil |
| 4 | +8 | Hochelaga | Road Runner | Complet |
| 5 | +10 | Rosemont | Renard | Non confirmé |
| 6 | -2 | Vieux-Port | Chevreuil | Passé |
| ... | ... | ... | ... | ... |

## Idempotence

Toutes les seeds sont **idempotentes** : les relancer ne crée pas de doublons.

```python
# Pattern utilisé dans chaque seed
city, created = City.objects.get_or_create(
    name="Montréal",
    defaults={"region": "Montréal", "lat": 45.5017, "lng": -73.5673}
)
```

## Réinitialiser complètement

```bash
# Supprimer et recréer la base (dev seulement)
make reset-dev
→ docker compose down -v && docker compose up -d && make migrate-dev && make seed-dev
```
