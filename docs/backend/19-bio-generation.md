# 19 — Génération de bio IA (Claude Sonnet 4.6)

## Vue d'ensemble

Le backend utilise l'API Anthropic pour générer des bios de profil personnalisées. Le modèle est alimenté par les réponses aux 20 questions de l'onboarding Flutter. L'utilisateur reçoit 2-3 propositions et en choisit une.

**Déclenchement** :
1. Automatiquement proposé à la fin de l'onboarding (après les 20 questions)
2. À tout moment depuis l'écran de profil ("Régénérer ma bio")

---

## Modèle utilisé

```python
ANTHROPIC_MODEL = env("ANTHROPIC_MODEL", default="claude-sonnet-4-6")
```

Configurable via `.env` pour faciliter les mises à jour de modèle sans redéploiement.

---

## Structure du service

```
apps/accounts/
  services/
    bio_generation.py   ← BioGenerationService
  mutations/
    user_bio_generate.py
    user_bio_select.py
    user_save_onboarding_answers.py
```

---

## `BioGenerationService`

```python
# apps/accounts/services/bio_generation.py
import anthropic
from django.conf import settings

class BioGenerationService:

    def generate(self, user) -> list[str]:
        """
        Generates 2-3 bio proposals from user profile + onboarding answers.
        Returns a list of bio strings.
        """
        context = self._build_context(user)
        prompt = self._build_prompt(context)
        return self._call_claude(prompt)

    def _build_context(self, user) -> dict:
        answers = {
            a.category: a.answer
            for a in user.onboarding_answers.all()
        }
        return {
            "first_name": user.first_name,
            "neighborhood": user.neighborhood.name if user.neighborhood else None,
            "pace_label": user.pace_label,
            "distance_label": user.distance_label,
            "answers": answers,
        }

    def _build_prompt(self, context: dict) -> str:
        answers_text = "\n".join(
            f"- {category}: {answer}"
            for category, answer in context["answers"].items()
        )
        return f"""Tu écris des bios de profil pour une application de course sociale appelée RunDate.
Les bios sont en français québécois décontracté (tutoiement). Elles sont courtes (2-4 phrases),
authentiques, un peu drôles, et reflètent la personnalité de la personne.

Voici les informations sur {context['first_name']} :
- Quartier : {context['neighborhood'] or 'non spécifié'}
- Allure de course : {context['pace_label']}
- Distance préférée : {context['distance_label']}

Réponses aux questions d'onboarding :
{answers_text}

Génère exactement 3 propositions de bio différentes. Chaque bio doit avoir une tonalité légèrement
différente (ex: une plus humoristique, une plus sincère, une plus axée sur la course).

Réponds UNIQUEMENT avec les 3 bios séparées par "---", sans numérotation ni explication."""

    def _call_claude(self, prompt: str) -> list[str]:
        client = anthropic.Anthropic(api_key=settings.ANTHROPIC_API_KEY)
        message = client.messages.create(
            model=settings.ANTHROPIC_MODEL,
            max_tokens=600,
            messages=[{"role": "user", "content": prompt}],
        )
        raw = message.content[0].text
        proposals = [p.strip() for p in raw.split("---") if p.strip()]
        return proposals[:3]
```

---

## Flux complet

```
Flutter (onboarding)
  ↓
accountsUserSaveOnboardingAnswers(answers: [...20 réponses...])
  → UserOnboardingAnswer × 20 créés/mis à jour en base

Flutter (fin onboarding ou profil)
  ↓
accountsUserBioGenerate
  → BioGenerationService.generate(user)
  → Appel Claude API
  → Retourne BioGeneratePayload { proposals: ["bio1", "bio2", "bio3"] }

Flutter (l'utilisateur choisit)
  ↓
accountsUserBioSelect(bio: "bio choisie")
  → User.bio = bio choisie
```

---

## Mutations GraphQL

### `accountsUserSaveOnboardingAnswers`

Sauvegarde les réponses aux 20 questions. Peut être appelée plusieurs fois (upsert sur `question_id`).

```graphql
mutation SaveOnboarding($answers: [OnboardingAnswerInput!]!) {
  accountsUserSaveOnboardingAnswers(answers: $answers) {
    ok
    errors
    savedCount
  }
}
```

### `accountsUserBioGenerate`

Génère 2-3 propositions. Requiert au moins 5 réponses onboarding en base, sinon retourne une erreur.

```graphql
mutation GenerateBio {
  accountsUserBioGenerate {
    ok
    errors
    proposals
  }
}
```

**Erreurs possibles** :
- `"not_enough_answers"` — moins de 5 réponses onboarding sauvegardées
- `"anthropic_error"` — erreur API Anthropic (timeout, quota, etc.)

### `accountsUserBioSelect`

Enregistre la bio choisie sur le profil utilisateur.

```graphql
mutation SelectBio($bio: String!) {
  accountsUserBioSelect(bio: $bio) {
    id
    bio
  }
}
```

---

## Variables d'environnement

| Variable | Défaut | Description |
|---|---|---|
| `ANTHROPIC_API_KEY` | — | Clé API Anthropic (stocker dans 1Password) |
| `ANTHROPIC_MODEL` | `claude-sonnet-4-6` | Modèle à utiliser |

---

## Gestion des erreurs

Le service ne lève jamais d'exception vers le résolveur GraphQL. Il retourne toujours un payload structuré :

```python
# ✅ Correct — voir 06-api-graphql.md (norme status + errors dict)
try:
    proposals = BioGenerationService().generate(user)
    return AccountsUserBioGeneratePayload(status=True, errors={}, proposals=proposals)
except anthropic.APIError as e:
    logger.error("bio_generation_error", extra={"error": str(e), "user_id": str(user.id)})
    return AccountsUserBioGeneratePayload(
        status=False,
        errors={"general": translate("errors", "bio_generation_failed", language)},
        proposals=[],
    )
```

---

## Intégration Flutter

Package Flutter utilisé : `graphql_flutter`

Flux côté Flutter :
1. L'utilisateur répond aux 20 questions — envoi batch via `accountsUserSaveOnboardingAnswers`
2. Appel `accountsUserBioGenerate` — affichage des 3 propositions (cards swipeables)
3. L'utilisateur tape sur une proposition — appel `accountsUserBioSelect`
4. Redirection vers le profil complété

---

## Commande GraphQL CLI (devtools)

```bash
# Générer une bio pour l'utilisateur courant (après avoir sauvegardé les réponses)
python manage.py graphql_accounts_user_bio_generate --token <token>

# Sauvegarder des réponses de test
python manage.py graphql_accounts_user_save_onboarding_answers --token <token>
```
