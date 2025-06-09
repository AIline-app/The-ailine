from django.contrib import admin

from app_users.models import User
from django.contrib.auth.admin import UserAdmin


@admin.register(User)
class UserAdmin(UserAdmin):
    change_user_password_template = None
    fieldsets = (
        (
            None,
            {'fields': ('phone', 'is_phone_verified', 'password')},
        ),
        (
            'Личная информация',
            {'fields': ('username', 'type_auto', 'number_auto', 'role')},
        ),
    )
    add_fieldsets = (
        (
            None,
            {
                'classes': ('wide',),
                'fields': (
                    'phone',
                    'is_phone_verified',
                    'username',
                    'password1',
                    'password2',
                ),
            },
        ),
    )

    list_display = ['id', 'username', 'phone', 'type_auto']
    list_filter = [
        'is_superuser',
        'is_phone_verified',
        'type_auto',
        'role',
        'soft_delete']
    search_fields = ['username', 'phone']
    ordering = ['pk']
