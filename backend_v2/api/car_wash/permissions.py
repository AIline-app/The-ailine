from rest_framework.permissions import IsAuthenticated, SAFE_METHODS, BasePermission


class ReadOnly(BasePermission):
    def has_permission(self, request, view):
        return request.method in SAFE_METHODS

    def has_object_permission(self, request, view, obj):
        return request.method in SAFE_METHODS


class IsDirector(IsAuthenticated):
    def has_permission(self, request, view):
        return (super().has_permission(request, view)
                and request.user.is_director)

    def has_object_permission(self, request, view, obj):
        return obj.owner == request.user

class IsCarWashOwner(IsDirector):
    def has_permission(self, request, view):
        return (super().has_permission(request, view)
                and hasattr(view, 'car_wash')
                and request.user == view.car_wash.owner)

    def has_object_permission(self, request, view, obj):
        return super().has_object_permission(request, view, obj.car_wash)


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
