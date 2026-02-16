from rest_framework.permissions import IsAuthenticated, SAFE_METHODS, BasePermission


class ReadOnly(BasePermission):
    """Allow safe methods (e.g., GET, HEAD, OPTIONS)"""
    def has_permission(self, request, view):
        return request.method in SAFE_METHODS

    def has_object_permission(self, request, view, obj):
        return request.method in SAFE_METHODS


class IsDirector(IsAuthenticated):
    """Check if the user is an authenticated director"""
    def has_object_permission(self, request, view, obj):
        return obj.owner == request.user


class IsCarWashOwner(IsDirector):
    """Check if the user is an authenticated director and owns the requested car wash"""
    def has_permission(self, request, view):
        return (super().has_permission(request, view)
                and hasattr(view, 'car_wash')
                and request.user == view.car_wash.owner)

    def has_object_permission(self, request, view, obj):
        if hasattr(obj, 'car_wash'):
            return super().has_object_permission(request, view, obj.car_wash)
        elif hasattr(obj, 'settings'):
            return super().has_object_permission(request, view, obj.settings.car_wash)


class IsManagerSuperior(IsCarWashOwner):
    def has_object_permission(self, request, view, obj):
        return super(IsCarWashOwner, self).has_object_permission(request, view, obj.managed_car_wash)
