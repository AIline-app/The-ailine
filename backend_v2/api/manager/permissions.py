from rest_framework.permissions import IsAuthenticated, SAFE_METHODS, BasePermission


class IsManager(IsAuthenticated):
    """Is user an authorized manager"""
    def has_permission(self, request, view):
        return (super().has_permission(request, view)
                and request.user.is_manager)
