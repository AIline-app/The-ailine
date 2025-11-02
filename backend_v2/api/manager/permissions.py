from rest_framework.permissions import IsAuthenticated, SAFE_METHODS, BasePermission


class IsManager(IsAuthenticated):
    """Check if the user is an authenticated manager"""
    def has_permission(self, request, view):
        return (super().has_permission(request, view)
                and request.user.is_manager)

    def has_object_permission(self, request, view, obj):
        return view.car_wash.managers.contains(request.user)


class IsCarWashManager(IsManager):
    """Check if the user is an authenticated director and owns the requested car wash"""
    def has_permission(self, request, view):
        return (super().has_permission(request, view)
                and hasattr(view, 'car_wash')
                and request.user.manager_car_washes.contains(view.car_wash))
                # and request.user in view.car_wash.managers)
