from django.db import transaction
from rest_framework import generics, status, viewsets
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response

from carwash.models.carwash import CarWash
from carwash.serializers import CarWashSerializer
from user_auth.permissions import IsDirector


class CarWashViewSet(viewsets.ModelViewSet):
    """
    A simple ViewSet for viewing and editing car wash objects.
    """
    queryset = CarWash.objects.prefetch_related('settings', 'documents').all()
    serializer_class = CarWashSerializer

    def get_permissions(self):
        if self.action == 'list':
            permission_classes = [IsAuthenticated]
        else:
            permission_classes = [IsDirector]
        return [permission() for permission in permission_classes]

    def create(self, request, *args, **kwargs):
        request.data['owner'] = request.user.id
        return super().create(request, *args, **kwargs)