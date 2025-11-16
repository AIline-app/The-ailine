from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.decorators import action
from rest_framework.viewsets import GenericViewSet

from accounts.models import User
from api.accounts.serializers import UserSerializer


class UserViewSet(GenericViewSet):
    serializer_class = UserSerializer
    permission_classes = (IsAuthenticated,)

    def get_queryset(self):
        return User.objects.filter(id=self.request.user.id)

    @action(detail=False, methods=["get"], url_path="me")
    def me(self, request):
        """Return the currently authenticated user (including id)."""
        serializer = self.get_serializer(request.user)
        return Response(serializer.data)
