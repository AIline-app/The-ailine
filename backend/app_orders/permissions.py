from rest_framework import permissions


class IsOwnerOrAdmin(permissions.BasePermission):
    """Редактирование профиля только его владельцем"""
    def has_object_permission(self, request, view, obj):
        return obj.user == request.user


class IsOwnerOnly(permissions.BasePermission):
    """Доступ к заказам есть только у пользователя, который его создал."""
    def has_object_permission(self, request, view, obj):
        return obj.customer == request.user
