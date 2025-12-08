from django.contrib import admin
from django.contrib.auth import get_user_model
from django.contrib.auth.models import Group
from django.contrib.sites.models import Site
from allauth.account.models import EmailAddress

User = get_user_model()


@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = (
        'phone_number', 'username', 'is_active', 'is_verified', 'is_staff', 'is_superuser', 'created_at', 'id'
    )
    list_filter = ('is_active', 'is_verified', 'is_staff', 'is_superuser', 'created_at')
    search_fields = ('phone_number', 'username', 'id')
    ordering = ('-created_at',)
    readonly_fields = ('id', 'created_at', 'last_login', 'password')


unregister = (EmailAddress, Group, Site)

# Unregister EmailAddress from allauth if available
for model in unregister:
    try:
        admin.site.unregister(model)
    except Exception:
        print(f'{model} is not a registered model')
