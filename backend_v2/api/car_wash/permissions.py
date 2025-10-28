from rest_framework.permissions import IsAuthenticated

from car_wash.models.box import Box


class IsDirector(IsAuthenticated):
    """Is user an authorized director"""
    def has_permission(self, request, view):
        return (super().has_permission(request, view)
                and request.user.is_director)

    def has_object_permission(self, request, view, obj):
        if isinstance(obj, Box):
            obj = obj.car_wash
        return (super().has_object_permission(request, view, obj)
                and obj.owner == request.user)


class IsManager(IsAuthenticated):
    """Is user an authorized manager"""
    def has_permission(self, request, view):
        return (super().has_permission(request, view)
                and request.user.is_manager)


class IsClient(IsAuthenticated):
    """Is user an authorized client"""
    def has_permission(self, request, view):
        return (super().has_permission(request, view)
                and request.user.is_client)
