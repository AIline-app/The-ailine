from rest_framework.permissions import IsAuthenticated


class IsOrderOwner(IsAuthenticated):
    """Is user an authorized client and owns the object"""
    def has_object_permission(self, request, view, obj):
        return obj.user == request.user
