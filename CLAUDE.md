# Run Date — Instructions Claude Code

## Langue

- Toujours répondre à l'utilisateur en **français**
- Tout le code en **anglais** — commentaires, docstrings, noms de variables/fonctions/classes

## Commits

Ne jamais committer sans permission explicite.

```
✅ Déclenche un commit : "commit", "fais un commit", "pousse ça"
❌ NE déclenche PAS : "prends des actifs", "sauvegarde", "backup", "c'est bon"
```

## Git — stratégie de branches

```
dev       ← travail quotidien
staging   ← merge depuis dev
main      ← PR depuis staging uniquement — jamais de force push
```

## Projet

Application de dating en courant — rencontre des gens en allant courir ensemble. Basée à Montréal / Québec. Domain: rundate.app

- **Stack mobile** : Flutter (`apps/mobile/`)
- **Stack backend** : Django + Graphene-Django + PostgreSQL (`backend/`)
- **Stack web** : Next.js (`apps/web/`, planifié)
- **Documentation** : `docs/backend/` (18 documents)

## Règles générales

- Ne jamais modifier le mobile et le backend dans la même opération sans demande explicite
- Toujours lire la documentation dans `docs/backend/` avant de modifier le backend
- Les données sont actuellement mockées côté Flutter — ne pas casser les mocks existants
