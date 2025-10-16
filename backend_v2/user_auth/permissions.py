from rest_framework import permissions

from user_auth.utils.choices import UserRoles


class IsDirector(permissions.BasePermission):
    """Редактирование услуги только её владельцем"""
    def has_permission(self, request, view):
        return request.user.roles.filter(name=UserRoles.DIRECTOR).exists()