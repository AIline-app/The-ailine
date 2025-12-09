from django.contrib import admin
from django.contrib.auth import get_user_model
from django.contrib.auth.admin import UserAdmin
from django.contrib.auth.models import Group
from django.contrib.sites.models import Site
from django.utils.translation import gettext_lazy as _
from allauth.account.models import EmailAddress

User = get_user_model()


@admin.register(User)
class UserAdmin(UserAdmin):

    fieldsets = (
        (
            None,
            {
                "fields": (
                    "password",
                ),
            }
        ),
        (
            _("Personal info"),
            {
                "fields": (
                    "username",
                    "phone_number",
                )
            }
        ),
        (
            _("Permissions"),
            {
                "fields": (
                    "is_staff",
                    "is_superuser",
                    "is_verified",
                    "is_active",
                ),
            },
        ),
        (
            _("Dates"),
            {
                "fields": (
                    "created_at",
                    "last_login",
                )
            }
        ),
    )

    list_display = (
        'id',
        'username',
        'phone_number',
        'is_active',
        'is_verified',
        'is_staff',
        'is_superuser',
        'created_at',
    )
    list_filter = ('is_active', 'is_verified', 'is_staff', 'is_superuser', 'created_at')
    search_fields = ('phone_number', 'username', 'id')
    ordering = ('-created_at',)
    readonly_fields = ('id', 'created_at', 'last_login')


unregister = (EmailAddress, Group, Site)

# Unregister EmailAddress from allauth if available
for model in unregister:
    try:
        admin.site.unregister(model)
    except Exception:
        print(f'{model} is not a registered model')
