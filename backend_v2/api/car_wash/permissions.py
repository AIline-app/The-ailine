from rest_framework.permissions import IsAuthenticated

from car_wash.models import Box
from services.models import Services


class IsDirector(IsAuthenticated):
    """Is user an authorized director"""
    def has_permission(self, request, view):
        return (super().has_permission(request, view)
                and request.user.is_director)

    def has_object_permission(self, request, view, obj):
        match obj:
            case Box():
                obj = obj.car_wash
            case Services():
                obj = obj.car_wash
            case _:
                pass
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
