# 14 — Standards Django Admin

## Structure des fichiers

```
<app>/
  admin/
    __init__.py               ← seul fichier qui touche @admin.register + définit __all__
    my_model_admin.py         ← définit la classe ModelAdmin (sans @admin.register)
    my_model_filters.py       ← SimpleListFilter si trop nombreux pour le fichier admin
  admin_actions/
    __init__.py
    my_model_admin_actions.py ← actions admin séparées du fichier admin
```

**Règle clé** : chaque `*_admin.py` définit la classe uniquement. Le `__init__.py` fait les `@admin.register` et définit `__all__`.

```python
# admin/__init__.py
from .run_date_event_admin import RunDateEventAdmin
from .user_admin import UserAdmin

__all__ = ['RunDateEventAdmin', 'UserAdmin']

from django.contrib import admin
from apps.events.models import RunDateEvent
from apps.accounts.models import User

admin.site.register(RunDateEvent, RunDateEventAdmin)
admin.site.register(User, UserAdmin)
```

```python
# admin/run_date_event_admin.py
from django.contrib import admin
from project.common.admin_mixins import BaseAdminMixin, SelectRelatedAdminMixin

class RunDateEventAdmin(BaseAdminMixin, SelectRelatedAdminMixin, admin.ModelAdmin):
    # Pas de @admin.register ici
    ...
```

---

## Mixins de base (`common/admin_mixins.py`)

Ordre d'héritage obligatoire :

```python
class MyModelAdmin(BaseAdminMixin, ReadOnlyAdminMixin, admin.ModelAdmin):
    ...
```

| Mixin | Rôle |
|---|---|
| `BaseAdminMixin` | CSS commun (`common/css/admin.css`), `list_per_page = 50`, `show_full_result_count = False` |
| `ReadOnlyAdminMixin` | Désactive `has_add_permission`, `has_change_permission`, `has_delete_permission` — pour données en lecture seule |
| `TimestampAdminMixin` | Fieldset "Timestamps" collapsible réutilisable (`created_at`, `updated_at`) |
| `SelectRelatedAdminMixin` | Surcharge `get_queryset()` avec `select_related_fields` et `prefetch_related_fields` |

---

## `AdminHTMLUtils` (`common/admin_utils.py`)

Classe centrale qui génère tout le HTML admin. Toujours utiliser ses méthodes statiques — jamais de HTML inline dans les `ModelAdmin`.

| Méthode | Usage |
|---|---|
| `create_admin_changelist_link(app_label, model_name, filter_params, text)` | Lien vers une liste filtrée — le plus utilisé |
| `create_admin_change_link(app_label, model_name, object_id, text)` | Lien vers le formulaire d'édition d'un objet |
| `create_single_object_link(obj, text)` | Raccourci — extrait `app_label` et `model_name` depuis l'objet |
| `create_related_objects_link(obj, related_field_name, ...)` | Lien relation inverse avec compteur |
| `create_count_badge(count)` | Badge coloré : vert < 10, orange < 50, bleu sinon |
| `get_status_icon(status_field)` | Icône ✓/✗ selon booléen ou SUCCESS/ERROR |
| `create_html_iframe(content)` | Aperçu HTML sécurisé dans iframe sandboxé |
| `create_text_preview(content)` | Aperçu texte dans boîte stylisée |
| `format_currency(value)` | Formatage monétaire avec séparateur de milliers |
| `calc_percentage(numerator, denominator)` | % avec couleur (vert si 95–105%, rouge sinon) |

---

## Pattern `get_*_link` — lier les modèles entre eux

Norme centrale : toujours utiliser des liens HTML cliquables pour les FK et relations inverses dans `list_display` et `readonly_fields`.

### Pattern manuel (cas complexes)

```python
from project.common.admin_utils import AdminHTMLUtils
from django.contrib import admin

@admin.display(description="Meeting Point", ordering="meeting_point")
def get_meeting_point_link(self, instance):
    if not instance.meeting_point:
        return ""
    return AdminHTMLUtils.create_admin_changelist_link(
        app_label=instance.meeting_point._meta.app_label,
        model_name=instance.meeting_point._meta.model_name,
        filter_params={"id__exact": instance.meeting_point.pk},
        text=str(instance.meeting_point),
    )
```

Le lien pointe vers `/admin/?id__exact=<pk>` et s'ouvre dans un nouvel onglet avec la classe CSS `.admin-link`.

### Factory `make_direct_link` (FK directe → objet unique)

Pour éviter la répétition sur les FK simples :

```python
from project.common.admin_utils import make_direct_link

# Génère automatiquement la méthode get_lievre_link
get_lievre_link = make_direct_link(
    fk_field="lievre",
    model_name="user",
    text_field="first_name",
    description="Lièvre",
    order_field="lievre__first_name",
    app_label="accounts",
)
```

Supporte les chemins imbriqués : `fk_field="run_group.event"` pour remonter deux niveaux.

### Factory `make_related_link` (relation inverse → compteur)

Pour les relations inverses, le lien affiche le nombre d'objets liés :

```python
from project.common.admin_utils import make_related_link

# Génère get_registrations_link → affiche [12] cliquable
get_registrations_link = make_related_link(
    related_field_name="registrations",
    model_name="eventregistration",
    description="Registrations",
    order_field="cache_registrations_count",
    app_label="events",
)
```

### Plusieurs liens (M2M ou liste)

```python
from django.utils.safestring import mark_safe

@admin.display(description="Members")
@mark_safe
def get_members_links(self, obj):
    links = []
    for member in obj.members.all():
        links.append(
            AdminHTMLUtils.create_admin_changelist_link(
                app_label="accounts",
                model_name="user",
                filter_params={"id__exact": member.id},
                text=str(member),
            )
        )
    return "<br>".join(links)
```

---

## Configuration standard d'un `ModelAdmin`

```python
class RunDateEventAdmin(BaseAdminMixin, SelectRelatedAdminMixin, admin.ModelAdmin):

    # Colonnes — toujours inclure des get_*_link pour les FK
    list_display = (
        "id", "city", "neighborhood", "date",
        "is_confirmed", "get_meeting_point_link", "get_lievre_link",
    )

    # Recherche — préfixe "=" pour recherche exacte sur ID
    search_fields = ("=id", "neighborhood__name", "city__name")

    # Filtres latéraux
    list_filter = ("is_confirmed", "pace_label", "city", "is_deleted")

    # Champs non-modifiables dans le formulaire — toujours id + timestamps
    readonly_fields = (
        "id", "created_at", "updated_at",
        "get_meeting_point_link", "get_lievre_link",
    )

    # Sections dans le formulaire de détail
    fieldsets = (
        ("Event", {"fields": ("city", "neighborhood", "date", "deadline")}),
        ("Configuration", {"fields": ("pace_label", "distance_label", "min_threshold", "max_capacity")}),
        ("Status", {"fields": ("is_confirmed", "is_deleted")}),
        ("Relations", {"fields": ("get_meeting_point_link", "get_lievre_link")}),
        ("Timestamps", {"classes": ("collapse",), "fields": ("created_at", "updated_at")}),
    )

    # Optimisation N+1 (via SelectRelatedAdminMixin)
    select_related_fields = ("city", "neighborhood", "meeting_point", "lievre")
    prefetch_related_fields = ("registrations",)

    # FK avec sélecteur popup — évite les dropdowns lourds
    raw_id_fields = ("meeting_point", "lievre")
```

---

## `SimpleListFilter` — deux patterns

### Avec compteurs dynamiques (pattern élaboré)

```python
class RegistrationStatusFilter(admin.SimpleListFilter):
    title = "Registration Status"
    parameter_name = "registration_status"

    def lookups(self, request, model_admin):
        qs = model_admin.get_queryset(request)
        total = qs.count()
        choices = []
        for value, label in [("confirmed", "Confirmed"), ("waitlisted", "Waitlisted")]:
            count = qs.filter(registrations__status=value).distinct().count()
            pct = (count / total * 100) if total else 0
            choices.append((value, f"{label} — {count}/{total} ({pct:.1f}%)"))
        return choices

    def queryset(self, request, queryset):
        if self.value():
            return queryset.filter(registrations__status=self.value()).distinct()
        return queryset
```

### Filtre "invisible" (paramètre URL sans dropdown)

Utile pour les filtres appliqués via les liens `get_*_link` :

```python
class EventFilter(admin.SimpleListFilter):
    title = "Event"
    parameter_name = "event__id__exact"

    def lookups(self, request, model_admin):
        return ()  # Pas d'options visibles dans la sidebar

    def queryset(self, request, queryset):
        if self.value():
            return queryset.filter(event__id=self.value())
        return queryset

    def has_output(self):
        return False  # N'affiche pas dans la barre latérale
```

---

## Actions admin (`admin_actions/`)

> **Catalogue complet** : voir [24-admin-actions.md](./24-admin-actions.md) pour la liste exhaustive de toutes les actions par modèle avec leur niveau de dangerosité.

Les actions complexes sont dans des fichiers séparés, importées dans le `ModelAdmin` :

```python
# admin_actions/run_date_event_admin_actions.py
from django.contrib import admin

@admin.action(description="Confirm selected events (force threshold)")
def force_confirm_events(modeladmin, request, queryset):
    from apps.events.services import confirm_event
    for event in queryset:
        confirm_event(event)
```

```python
# admin/run_date_event_admin.py
from ..admin_actions import force_confirm_events, cancel_no_quorum_events

class RunDateEventAdmin(BaseAdminMixin, admin.ModelAdmin):
    actions = [force_confirm_events, cancel_no_quorum_events]
```

---

## Règles supplémentaires

- `list_per_page = 50` — hérité de `BaseAdminMixin`, ne pas surcharger sauf raison explicite
- `show_full_result_count = False` — hérité de `BaseAdminMixin`, performance sur grandes tables
- Toujours `raw_id_fields` pour les FK vers des modèles avec beaucoup de données (`User`, `RunDateEvent`)
- `readonly_fields` doit toujours inclure `id`, `created_at`, `updated_at`
- Jamais de HTML inline dans un `ModelAdmin` — toujours passer par `AdminHTMLUtils`
- Les méthodes `get_*_link` doivent avoir `@admin.display(description=..., ordering=...)` et `@mark_safe` si elles retournent du HTML
