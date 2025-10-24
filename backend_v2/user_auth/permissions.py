from rest_framework import permissions

from user_auth.utils.choices import UserRoles


class IsDirector(permissions.BasePermission):
    """Is user an authorized director"""
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.roles.filter(name=UserRoles.DIRECTOR).exists()

class IsDirectorAndOwner(IsDirector):
    def has_object_permission(self, request, view, obj):
        return obj.owner == request.user

class IsManager(permissions.BasePermission):
    """Is user an authorized manager"""
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.roles.filter(name=UserRoles.MANAGER).exists()


class IsClient(permissions.BasePermission):
    """Is user an authorized client"""
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.roles.filter(name=UserRoles.CLIENT).exists()