# 05 — Authentification

## Architecture : deux niveaux distincts

```
Niveau 1 — Application    Authorization: Basic <base64(username:password)>
Niveau 2 — Utilisateur    Token: <UserAccessToken 64 chars>
```

Pas de JWT. Pas de `Authorization: Bearer`. Deux en-têtes séparés.

---

## Niveau 1 — Authentification de l'application

Avant d'identifier un utilisateur, chaque requête GraphQL doit prouver qu'elle vient d'un client autorisé (app mobile RunDate, futur site web, etc.).

**En-tête** : `Authorization: Basic <base64(username:password)>`

**Modèle** : `ApplicationAccess` — contient les identifiants de chaque application cliente.

**Décorateur** : `@require_authorization` — valide les credentials Basic Auth contre `ApplicationAccess`, injecte `application_access` dans le résolveur.

```python
@require_authorization
def mutate(self, info, application_access, ...):
    # application_access est injecté automatiquement
```

---

## Niveau 2 — Authentification de l'utilisateur

Une fois l'application identifiée, les requêtes nécessitant un utilisateur connecté envoient un second en-tête.

**En-tête** : `Token: <64 caractères opaques>`

**Modèles** : `UserAccess` → `UserAccessToken`

**Décorateur** : `@require_user_access_token` — valide le token, vérifie l'expiration, vérifie `access_status`, enregistre `mark_used` avec l'IP, injecte `user_access`.

```python
@require_user_access_token
def mutate(self, info, application_access, user_access, ...):
    user = user_access.user
```

---

## Tableau des en-têtes HTTP

| En-tête | Valeur | Obligatoire | Rôle |
|---|---|---|---|
| `Authorization` | `Basic <base64(user:pass)>` | Oui — toutes les requêtes | Identifier l'application cliente |
| `Token` | 64 caractères opaques | Selon la mutation/query | Identifier l'utilisateur connecté |
| `language` | `fr` ou `en` | Recommandé | Langue des messages retournés |

---

## CORS — en-têtes autorisés

```python
CORS_ALLOW_HEADERS = [
    "content-type",
    "authorization",
    "token",
    "language",
    "x-csrftoken",
    "x-language",
]
```

---

## Ordre des décorateurs sur les résolveurs

```python
@log_graphql_request
@require_authorization
@require_user_access_token
@extract_language
def mutate(self, info, application_access, user_access, language, ...):
    ...
```

Les mutations publiques (ex: demande d'OTP, vérification OTP) n'ont que `@require_authorization` — pas de `Token` requis.

```python
# Mutation de login — pas de @require_user_access_token
@log_graphql_request
@require_authorization
@extract_language
def mutate(self, info, application_access, language, phone, code):
    ...
```

---

## Flow complet

### Étape 1 — Demander un code OTP

```
Headers:
  Authorization: Basic <base64(rundate-mobile:secret)>
  language: fr

Mutation: accountsUserAccessRequestOtp(phone: "+15145550010")
→ { ok: true }
→ SMS envoyé via Twilio
```

### Étape 2 — Vérifier le code → obtenir le token

```
Headers:
  Authorization: Basic <base64(rundate-mobile:secret)>
  language: fr

Mutation: accountsUserAccessVerifyOtp(phone: "+15145550010", code: "123456")
→ { ok: true, token: "abc123...64chars", isNewUser: false }
```

### Étape 3 — Toutes les requêtes authentifiées

```
Headers:
  Authorization: Basic <base64(rundate-mobile:secret)>
  Token: abc123...64chars
  language: fr

Query: accountsUserMe
→ { firstName: "Sophie", badge: "habitue", ... }
```

---

## Modèles

### `ApplicationAccess`

```python
class ApplicationAccess(BaseModel):
    """Represents an authorized client application."""
    username = models.CharField(max_length=100, unique=True)
    password = models.CharField(max_length=255)        # hashed
    name = models.CharField(max_length=200)            # ex: "RunDate Mobile"
    is_active = models.BooleanField(default=True)
    description = models.TextField(null=True, blank=True)

    class Meta:
        verbose_name = 'application access'
        verbose_name_plural = 'application accesses'

    @property
    def authorization_header(self):
        """Returns the ready-to-use Basic Auth header value."""
        import base64
        credentials = f"{self.username}:{self.raw_password}"
        return f"Basic {base64.b64encode(credentials.encode()).decode()}"
```

### `UserAccess`

Représente l'accès d'un utilisateur (statut, lié à une application spécifique).

```python
class UserAccess(BaseModel):
    user = models.ForeignKey(
        'User', on_delete=models.CASCADE, related_name='user_accesses'
    )
    application_access = models.ForeignKey(
        ApplicationAccess, on_delete=models.CASCADE, related_name='user_accesses'
    )
    access_status = models.CharField(
        max_length=50,
        choices=[('active', 'Active'), ('suspended', 'Suspended'), ('banned', 'Banned')],
        default='active'
    )

    class Meta:
        verbose_name = 'user access'
        verbose_name_plural = 'user accesses'
        unique_together = ('user', 'application_access')
```

### `UserAccessToken`

Token opaque 64 caractères. Remplace le `AuthToken` initial.

```python
class UserAccessToken(BaseModel):
    user_access = models.ForeignKey(
        UserAccess, on_delete=models.CASCADE, related_name='tokens'
    )
    token = models.CharField(max_length=64, unique=True, default=generate_token)
    expires_at = models.DateTimeField(null=True, blank=True)  # null = pas d'expiration
    last_used_at = models.DateTimeField(null=True, blank=True)
    last_used_ip = models.GenericIPAddressField(null=True, blank=True)

    class Meta:
        verbose_name = 'user access token'
        verbose_name_plural = 'user access tokens'

    def mark_used(self, ip=None):
        self.last_used_at = now()
        self.last_used_ip = ip
        self.save(update_fields=['last_used_at', 'last_used_ip'])

    @property
    def is_expired(self):
        if self.expires_at is None:
            return False
        return now() > self.expires_at

    @property
    def is_valid(self):
        return (
            not self.is_expired
            and self.user_access.access_status == 'active'
            and not self.user_access.user.is_deleted
        )
```

### `OtpVerification` (inchangé)

```python
class OtpVerification(BaseModel):
    phone = models.CharField(max_length=20)
    code = models.CharField(max_length=6)
    expires_at = models.DateTimeField()
    is_used = models.BooleanField(default=False)
```

### `OtpRateLimit` (inchangé)

Max 5 tentatives OTP par heure par numéro — validé dans le service, pas en middleware.

---

## Décorateurs

Implémentés dans `accounts/decorators.py` :

### `@require_authorization`

```python
def require_authorization(func):
    """Validates Basic Auth against ApplicationAccess. Injects application_access."""
    @wraps(func)
    def wrapper(self, info, *args, **kwargs):
        auth_header = info.context.META.get('HTTP_AUTHORIZATION', '')
        application_access = services.validate_basic_auth(auth_header)
        if not application_access:
            return ErrorPayload(status=False, errors={"permission": "Unauthorized application"})
        return func(self, info, *args, application_access=application_access, **kwargs)
    return wrapper
```

### `@require_user_access_token`

```python
def require_user_access_token(func):
    """Validates Token header against UserAccessToken. Injects user_access."""
    @wraps(func)
    def wrapper(self, info, *args, **kwargs):
        token_value = info.context.META.get('HTTP_TOKEN', '')
        ip = info.context.META.get('HTTP_CF_CONNECTING_IP') or info.context.META.get('REMOTE_ADDR')
        user_access = services.validate_user_token(token_value, ip)
        if not user_access:
            return ErrorPayload(status=False, errors={"token": "Invalid or expired token"})
        return func(self, info, *args, user_access=user_access, **kwargs)
    return wrapper
```

### `@extract_language`

```python
def extract_language(func):
    """Extracts language header (fr/en). Injects language."""
    @wraps(func)
    def wrapper(self, info, *args, **kwargs):
        language = info.context.META.get('HTTP_LANGUAGE', 'fr')
        if language not in ('fr', 'en'):
            language = 'fr'
        return func(self, info, *args, language=language, **kwargs)
    return wrapper
```

### `@log_graphql_request`

```python
def log_graphql_request(func):
    """Logs the GraphQL operation to ApplicationAccessLog."""
    @wraps(func)
    def wrapper(self, info, *args, **kwargs):
        # Logging happens after execution (non-blocking)
        result = func(self, info, *args, **kwargs)
        services.log_graphql_operation(info, result)
        return result
    return wrapper
```

---

## Rate limiting

`RateLimitMiddleware` dans `monitoring/middleware.py` :
- Limite par IP sur l'endpoint `/graphql/`
- Retourne une réponse `429 JSON` si dépassement
- Seuils configurables dans les settings (`RATE_LIMIT_REQUESTS`, `RATE_LIMIT_WINDOW_SECONDS`)
- Compteur stocké en base (pas de Redis) dans un modèle `RateLimit`

---

## Mutations GraphQL

```graphql
# Public (seulement @require_authorization)
accountsUserAccessRequestOtp(phone: String!): RequestOtpPayload
accountsUserAccessVerifyOtp(phone: String!, code: String!): UserAccessTokenPayload

# Protégées (@require_authorization + @require_user_access_token)
accountsUserUpdateProfile(...): User
accountsUserUploadPhoto(photo: Upload!): User
accountsUserUpdateFcmToken(token: String!): Boolean
```

`UserAccessTokenPayload` (voir [06-api-graphql.md](./06-api-graphql.md) — norme `status` + `errors` en `JSONObject`) :
```graphql
type UserAccessTokenPayload {
  status: Boolean!
  token: String
  isNewUser: Boolean
  errors: JSONObject!
}
```
