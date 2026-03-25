# 24 — Actions Django Admin

Catalogue complet des actions disponibles dans les listes admin, organisées par app et modèle.

---

## Conventions générales

### Structure obligatoire

```python
# admin_actions/user_admin_actions.py

from django.contrib import admin
from django.utils.timezone import now

@admin.action(description="🚫 Bloquer les utilisateurs sélectionnés")
def block_users(modeladmin, request, queryset):
    """Suspend selected users (is_suspended = True)."""
    from apps.accounts.services.user_moderation import UserModerationService
    count = 0
    for user in queryset:
        UserModerationService().suspend(user, by=request.user)
        count += 1
    modeladmin.message_user(request, f"{count} utilisateur(s) bloqué(s).", messages.SUCCESS)
```

Règles :
- Toute logique métier passe par un **service** — jamais de `queryset.update()` direct dans l'action
- Toujours `modeladmin.message_user(...)` avec le nombre d'objets affectés
- Les emojis dans `description` aident à distinguer visuellement les actions destructives (🚫 ❌ ✅ 🔄)
- Les actions **destructives** (suppression, blocage) demandent une page de confirmation intermédiaire

### Confirmation pour actions destructives

```python
@admin.action(description="❌ Supprimer (soft delete) les utilisateurs sélectionnés")
def soft_delete_users(modeladmin, request, queryset):
    if request.POST.get("confirm"):
        # Action confirmée
        count = queryset.filter(is_deleted=False).count()
        for user in queryset:
            UserModerationService().soft_delete(user)
        modeladmin.message_user(request, f"{count} utilisateur(s) supprimé(s).", messages.SUCCESS)
        return None

    # Afficher la page de confirmation
    return render(request, "admin/confirm_action.html", {
        "title": "Confirmer la suppression",
        "queryset": queryset,
        "action": "soft_delete_users",
        "warning": "Cette action est réversible mais irréversible si l'utilisateur se reconnecte.",
    })
```

---

## App `accounts`

### Modèle `User`

| Action | Description | Destructif |
|---|---|---|
| `block_users` | 🚫 Suspendre — `is_suspended=True` | ⚠️ Oui |
| `unblock_users` | ✅ Débloquer — `is_suspended=False` | Non |
| `soft_delete_users` | ❌ Supprimer (soft) — `is_deleted=True` + `deleted_at=now()` | ⚠️ Oui |
| `restore_users` | 🔄 Restaurer — `is_deleted=False` + `deleted_at=None` | Non |
| `mark_verified` | ✅ Marquer comme vérifié — `is_verified=True` | Non |
| `mark_unverified` | ⚠️ Retirer la vérification — `is_verified=False` | ⚠️ Oui |
| `set_lievre` | 🐇 Accorder le rôle Lièvre — `is_lievre=True` | Non |
| `remove_lievre` | Retirer le rôle Lièvre — `is_lievre=False` | ⚠️ Oui |
| `reset_xp` | ⚠️ Remettre XP à zéro — `xp=0` | ⚠️ Oui |
| `send_push_notification` | 📲 Envoyer une notif FCM manuelle (prompt texte) | Non |
| `export_csv` | 📄 Exporter en CSV (id, prénom, ville, badge, xp, date inscription) | Non |
| `anonymize_accounts` | 🔒 Anonymiser (RGPD) — remplace nom/phone/bio par données anonymes | ⚠️ Irréversible |

```python
# Fichier : admin_actions/user_admin_actions.py
# Actions exportées : block_users, unblock_users, soft_delete_users,
#                     restore_users, mark_verified, mark_unverified,
#                     set_lievre, remove_lievre, reset_xp,
#                     send_push_notification, export_csv, anonymize_accounts
```

### Modèle `LievreInvitation`

| Action | Description | Destructif |
|---|---|---|
| `resend_lievre_invitations` | 🔁 Renvoyer la notification aux invitations en attente | Non |
| `cancel_lievre_invitations` | ❌ Annuler les invitations sélectionnées | ⚠️ Oui |
| `mark_invitations_accepted` | ✅ Forcer le statut `accepted` (contourne le flux normal) | Non |

### Modèle `SupportTicket`

| Action | Description | Destructif |
|---|---|---|
| `mark_tickets_in_progress` | 🔄 Marquer En cours | Non |
| `mark_tickets_resolved` | ✅ Marquer Résolu | Non |
| `mark_tickets_closed` | Marquer Fermé | Non |
| `assign_to_me` | 📌 M'assigner les tickets sélectionnés | Non |

### Modèle `ContentReport`

| Action | Description | Destructif |
|---|---|---|
| `mark_reports_resolved` | ✅ Marquer comme traité | Non |
| `dismiss_reports` | Classer sans suite | Non |
| `suspend_reported_user` | 🚫 Suspendre l'utilisateur signalé | ⚠️ Oui |
| `delete_reported_content` | ❌ Supprimer le contenu signalé + résoudre | ⚠️ Oui |

---

## App `events`

### Modèle `RunDateEvent`

| Action | Description | Destructif |
|---|---|---|
| `confirm_events` | ✅ Forcer la confirmation (bypass seuil) — `is_confirmed=True` + notifs | Non |
| `cancel_no_quorum_events` | ❌ Annuler les runs sans quorum — `is_deleted=True` + notifs annulation | ⚠️ Oui |
| `soft_delete_events` | ❌ Supprimer (soft) — `is_deleted=True` | ⚠️ Oui |
| `restore_events` | 🔄 Restaurer — `is_deleted=False` | Non |
| `create_run_groups` | 🏃 Créer les groupes (`GroupMatchingService.run`) | Non |
| `send_deadline_reminder` | 📲 Envoyer manuellement le rappel deadline | Non |
| `send_run_today_notification` | 📲 Envoyer manuellement "c'est aujourd'hui" | Non |
| `send_rate_reminder` | ⭐ Envoyer manuellement le rappel de notation | Non |
| `export_registrations_csv` | 📄 Exporter les inscriptions de l'événement en CSV | Non |

```python
# Fichier : admin_actions/run_date_event_admin_actions.py
```

### Modèle `EventRegistration`

| Action | Description | Destructif |
|---|---|---|
| `confirm_registrations` | ✅ Forcer `status='confirmed'` (depuis waitlist ou cancelled) | Non |
| `move_to_waitlist` | Déplacer en liste d'attente — `status='waitlisted'` | Non |
| `cancel_registrations` | ❌ Annuler les inscriptions — `status='cancelled'` | ⚠️ Oui |
| `promote_from_waitlist` | ⬆️ Promouvoir les waitlisted (dans l'ordre de position) | Non |
| `mark_as_lievre_priority` | 🐇 Marquer `is_priority_lievre=True` | Non |

### Modèle `RunGroup`

| Action | Description | Destructif |
|---|---|---|
| `mark_groups_completed` | ✅ Marquer comme terminés — `status='completed'` | Non |
| `cancel_groups` | ❌ Annuler les groupes — `status='cancelled'` + notifs | ⚠️ Oui |
| `reassign_lievre` | 🐇 Réassigner le Lièvre (sélecteur utilisateur) | Non |

---

## App `messaging`

### Modèle `Conversation`

| Action | Description | Destructif |
|---|---|---|
| `deactivate_conversations` | 🚫 Désactiver — `is_active=False` (plus d'envoi possible) | ⚠️ Oui |
| `reactivate_conversations` | ✅ Réactiver — `is_active=True` | Non |

### Modèle `Message`

| Action | Description | Destructif |
|---|---|---|
| `hide_messages` | 🚫 Masquer les messages — `is_hidden=True` (champ à ajouter) | ⚠️ Oui |
| `delete_flagged_messages` | ❌ Supprimer les messages signalés + résoudre les reports | ⚠️ Irréversible |

---

## App `notifications`

### Modèle `AppNotification`

| Action | Description | Destructif |
|---|---|---|
| `resend_fcm_push` | 📲 Renvoyer le push FCM pour les notifs sélectionnées | Non |
| `mark_notifications_read` | Marquer comme lues | Non |

---

## App `community`

### Modèle `EventPhoto` / `UserPhoto`

| Action | Description | Destructif |
|---|---|---|
| `delete_photos` | ❌ Supprimer les photos + fichiers physiques | ⚠️ Irréversible |
| `mark_photos_flagged` | 🚩 Marquer comme signalées (pour revue) | Non |

### Modèle `FaqItem` / `CommunityRule` / `Testimonial`

| Action | Description | Destructif |
|---|---|---|
| `publish_items` | ✅ Publier — `is_published=True` | Non |
| `unpublish_items` | Dépublier — `is_published=False` | Non |

### Modèle `LegalDocument`

| Action | Description | Destructif |
|---|---|---|
| `publish_as_current` | ✅ Publier comme version courante — `is_current=True` + `published_at=now()` + dépublie l'ancienne version | Non |
| `unpublish_document` | Dépublier — `is_current=False` | ⚠️ Oui |

> `publish_as_current` doit s'assurer qu'il n'y a qu'un seul document `is_current=True` par `(document_type, language)` — invalide automatiquement l'ancienne version.

---

## App `monitoring`

### Modèle `HttpRequestLog`

| Action | Description | Destructif |
|---|---|---|
| `purge_selected_logs` | ❌ Supprimer les logs sélectionnés | ⚠️ Irréversible |
| `export_logs_csv` | 📄 Exporter en CSV | Non |

---

## Mixin `BulkActionWithConfirmMixin`

Pour les actions destructives, utiliser ce mixin réutilisable au lieu de répéter le pattern de confirmation :

```python
# common/admin_mixins.py

class BulkActionWithConfirmMixin:
    """
    Mixin for ModelAdmin classes that need confirmation pages for destructive actions.
    Usage: set action_confirm_template on the action function.
    """

    def response_action(self, request, queryset):
        """Override to inject confirmation page support."""
        action = self.admin_site.get_action(request.POST["action"])
        if hasattr(action[0], "requires_confirmation") and not request.POST.get("confirm"):
            selected_ids = request.POST.getlist(admin.helpers.ACTION_CHECKBOX_NAME)
            return render(request, "admin/confirm_bulk_action.html", {
                "title": getattr(action[0], "confirm_title", "Confirmer l'action"),
                "warning": getattr(action[0], "confirm_warning", ""),
                "queryset": queryset,
                "action_name": request.POST["action"],
                "selected_ids": selected_ids,
                "opts": self.model._meta,
            })
        return super().response_action(request, queryset)
```

```python
# Utilisation sur une action
@admin.action(description="❌ Soft delete users")
def soft_delete_users(modeladmin, request, queryset):
    ...

soft_delete_users.requires_confirmation = True
soft_delete_users.confirm_title = "Confirmer la suppression"
soft_delete_users.confirm_warning = "Les utilisateurs seront marqués comme supprimés. Réversible via 'Restaurer'."
```

---

## Template de confirmation (`templates/admin/confirm_bulk_action.html`)

```html
{% extends "admin/base_site.html" %}
{% block content %}
<h1>{{ title }}</h1>
<p class="errornote">{{ warning }}</p>
<p>Tu es sur le point d'appliquer cette action sur <strong>{{ queryset.count }}</strong> objet(s).</p>
<form method="post">
  {% csrf_token %}
  {% for id in selected_ids %}
    <input type="hidden" name="_selected_action" value="{{ id }}">
  {% endfor %}
  <input type="hidden" name="action" value="{{ action_name }}">
  <input type="hidden" name="confirm" value="1">
  <input type="submit" value="Confirmer" class="button default">
  <a href="{{ request.META.HTTP_REFERER }}">Annuler</a>
</form>
{% endblock %}
```

---

## Résumé des fichiers d'actions

```
apps/
  accounts/
    admin_actions/
      __init__.py
      user_admin_actions.py          # 12 actions
      lievre_invitation_admin_actions.py  # 3 actions
      support_ticket_admin_actions.py     # 4 actions
      content_report_admin_actions.py     # 4 actions

  events/
    admin_actions/
      __init__.py
      run_date_event_admin_actions.py     # 9 actions
      event_registration_admin_actions.py # 5 actions
      run_group_admin_actions.py          # 3 actions

  messaging/
    admin_actions/
      __init__.py
      conversation_admin_actions.py      # 2 actions
      message_admin_actions.py           # 2 actions

  notifications/
    admin_actions/
      __init__.py
      app_notification_admin_actions.py  # 2 actions

  community/
    admin_actions/
      __init__.py
      photo_admin_actions.py             # 2 actions
      content_admin_actions.py           # 2 actions (publish/unpublish — partagé)
      legal_document_admin_actions.py    # 2 actions

  monitoring/
    admin_actions/
      __init__.py
      http_request_log_admin_actions.py  # 2 actions
```
