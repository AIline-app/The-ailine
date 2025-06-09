from rest_framework import permissions


class IsMyServiceOrReadOnly(permissions.BasePermission):
    """Редактирование услуги только её владельцем"""
    def has_object_permission(self, request, view, obj):
        if request.method in permissions.SAFE_METHODS:
            return True
        return obj.wash.user == request.user


class TrueForAll(permissions.BasePermission):
    """Доступ для всех."""
    def has_permission(self, request, view):
        return True

    def has_object_permission(self, request, view, obj):
        return True
