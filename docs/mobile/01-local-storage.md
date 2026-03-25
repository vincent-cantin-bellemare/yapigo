# Mobile — Stockage local (Flutter)

Certaines préférences utilisateur sont stockées localement sur l'appareil via `shared_preferences`. Elles ne passent **pas** par le backend — elles sont propres à l'installation de l'app sur le téléphone.

---

## Package

```yaml
# apps/mobile/pubspec.yaml
dependencies:
  shared_preferences: ^2.x.x
```

---

## Préférences stockées localement

| Clé | Type | Description |
|---|---|---|
| `theme_mode` | `String` | `"light"` / `"dark"` / `"system"` (défaut: `"system"`) |
| `onboarding_completed` | `bool` | L'utilisateur a vu l'onboarding |
| `demo_mode` | `bool` | Mode démo activé |
| `last_selected_city` | `String` | Dernière ville sélectionnée dans les filtres |

---

## Dark theme

Le choix de thème est sauvegardé localement avec `shared_preferences`. Il n'est **jamais envoyé au backend**.

```dart
// Lecture
final prefs = await SharedPreferences.getInstance();
final themeMode = prefs.getString('theme_mode') ?? 'system';

// Écriture
await prefs.setString('theme_mode', 'dark');
```

### Intégration dans l'app

```dart
// main.dart ou MaterialApp
ThemeMode _resolveThemeMode(String value) {
  switch (value) {
    case 'light': return ThemeMode.light;
    case 'dark': return ThemeMode.dark;
    default: return ThemeMode.system;
  }
}
```

Le switch dark/light dans `ProfileScreen` (section "Thème") écrit cette valeur et provoque un `setState` ou `notifyListeners` pour reconstruire le `MaterialApp`.

---

## Préférences qui vont côté backend

Ces préférences sont **persistées en base** (pas en local storage) car elles doivent suivre l'utilisateur sur plusieurs appareils ou être utilisées par le serveur :

| Préférence | Backend | GraphQL |
|---|---|---|
| Préférences notifications (8 switches) | `UserNotificationPreferences` | `accountsUserUpdateNotificationPreferences` |
| Visibilité du profil | `User.profile_visibility` | `accountsUserUpdatePrivacySettings` |
| Opt-in profil vedette | `User.wants_featured_profile` | `accountsUserUpdatePrivacySettings` |
| Token FCM push | `User.fcm_token` | `accountsUserUpdateFcmToken` |

---

## Nettoyage à la déconnexion

À la déconnexion, vider uniquement les données sensibles — garder le thème :

```dart
Future<void> logout() async {
  final prefs = await SharedPreferences.getInstance();
  // Keep: theme_mode, last_selected_city
  await prefs.remove('onboarding_completed');
  await prefs.remove('demo_mode');
  // Invalider le token côté backend
  await graphqlClient.mutate(accountsUserAccessLogout);
  // Effacer le token local
  await secureStorage.delete(key: 'access_token');
}
```

---

## Token d'authentification

Le `UserAccessToken` est stocké dans le **secure storage** (pas dans `shared_preferences`) :

```yaml
dependencies:
  flutter_secure_storage: ^9.x.x
```

```dart
const storage = FlutterSecureStorage();

// Sauvegarder
await storage.write(key: 'access_token', value: token);

// Lire
final token = await storage.read(key: 'access_token');

// Supprimer (déconnexion)
await storage.delete(key: 'access_token');
```

`flutter_secure_storage` utilise le Keychain iOS et le Keystore Android — jamais de token en clair.
