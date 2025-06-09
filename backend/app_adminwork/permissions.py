from rest_framework import permissions


class IsManager(permissions.BasePermission):
    """Редактирование статуса заказа админом."""
    def has_permission(self, request, view):
        return request.user.role == 'manager'

    def has_object_permission(self, request, view, obj):
        return request.user.role == 'manager'
