# 13 — Schéma GraphQL & intégration Flutter

## Principe

GraphQL est auto-documenté. Le backend génère un fichier `schema.graphql` complet qui sert de **contrat entre le backend et le frontend**. Ce fichier est committé dans le monorepo et mis à jour à chaque changement d'API.

## Export du schéma

### Commande

```bash
make export-schema
# → python manage.py graphql_devtools_schema_export
# → génère shared/schema/schema.graphql
```

### Emplacement dans le monorepo

```
rundate/                      ← racine du monorepo
  shared/
    schema/
      schema.graphql          ← committé, contrat API
  apps/
    mobile/                   ← Flutter
  backend/                    ← Django
  docs/
```

### Quand mettre à jour

À chaque fois qu'un modèle GraphQL change (nouveau champ, nouvelle query, nouvelle mutation) :

```bash
# 1. Modifier le code backend
# 2. Exporter le schéma
make export-schema

# 3. Commiter les deux ensemble
git add backend/ shared/schema/schema.graphql
git commit -m "add eventsEventRate mutation"
```

---

## Intégration Flutter

### Option A — `graphql_flutter` (recommandé pour démarrer)

Pas de génération de code. Les queries sont écrites manuellement en s'appuyant sur `schema.graphql` comme documentation.

```yaml
# apps/mobile/pubspec.yaml
dependencies:
  graphql_flutter: ^5.x
```

```dart
// Exemple d'utilisation
final eventsQuery = gql(r'''
  query eventsEventList($city: String!, $limit: Int) {
    eventsEventList(city: $city, limit: $limit) {
      items {
        id
        neighborhood { name }
        date
        paceLabel
        distanceLabel
        totalRegistered
        isConfirmed
      }
      total
      hasMore
    }
  }
''');
```

### Option B — `ferry` (recommandé quand l'API se stabilise)

Génération automatique de classes Dart typées depuis `schema.graphql`.

```yaml
# apps/mobile/pubspec.yaml
dependencies:
  ferry: ^0.x
  gql_http_link: ^0.x

dev_dependencies:
  ferry_generator: ^0.x
  build_runner: ^2.x
```

Workflow :
1. Écrire les queries dans des fichiers `.graphql`
2. `dart run build_runner build` → génère les classes Dart
3. Si le schéma change et que les queries ne sont plus valides → **le build échoue** → désynchronisation impossible

### Comparaison

| | `graphql_flutter` | `ferry` |
|---|---|---|
| Setup | Rapide | Long (codegen) |
| Type safety | Manuel | Automatique |
| Erreur si API change | Aucune au build | Build fail |
| Recommandé | Phase initiale | Moyen terme |

---

## Client GraphQL Flutter

### Configuration de base

```dart
// lib/data/graphql_client.dart
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final _storage = FlutterSecureStorage();

Future<GraphQLClient> buildGraphQLClient() async {
  final token = await _storage.read(key: 'auth_token');

  final authLink = AuthLink(
    getToken: () async => token != null ? 'Bearer $token' : null,
  );

  final httpLink = HttpLink('https://api.rundate.app/graphql/');
  final link = authLink.concat(httpLink);

  return GraphQLClient(
    link: link,
    cache: GraphQLCache(),
  );
}
```

### Stockage du token

Le token est stocké dans `flutter_secure_storage` (Keychain iOS / Keystore Android), pas en mémoire simple.

---

## Introspection

GraphQL supporte l'introspection native : il est possible d'interroger le schéma directement via l'API.

```graphql
# Query d'introspection (dev/staging uniquement)
{
  __schema {
    types { name }
    queryType { fields { name } }
    mutationType { fields { name } }
  }
}
```

L'introspection est **désactivée en production** dans `settings/production.py` :

```python
GRAPHENE = {
    'SCHEMA': 'config.schema.schema',
    'MIDDLEWARE': [...],
    'INTROSPECTION': False,  # disabled in production
}
```
