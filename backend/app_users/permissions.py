from rest_framework import permissions


class IsOwnerOrReadOnly(permissions.BasePermission):
    """Редактирование профиля только его владельцем"""
    def has_object_permission(self, request, view, obj):
        if request.method in permissions.SAFE_METHODS:
            return True
        return obj.user == request.user


class OwnerOnly(permissions.BasePermission):
    """Получение информации только владельцем."""
    def has_object_permission(self, request, view, obj):
        return obj.user == request.user
