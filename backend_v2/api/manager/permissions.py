from rest_framework.permissions import IsAuthenticated


class IsCarWashManager(IsAuthenticated):
    """Check if the user is an authenticated manager at the requested car wash"""
    def has_permission(self, request, view):
        return (super().has_permission(request, view)
                and hasattr(view, 'car_wash')
                and view.car_wash.managers.contains(request.user))

    def has_object_permission(self, request, view, obj):
        return (hasattr(view, 'car_wash')
                and view.car_wash.managers.contains(request.user))
