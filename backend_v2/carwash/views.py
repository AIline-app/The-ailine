from django.db import transaction
from rest_framework import generics, status, viewsets
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response

from carwash.models import Car
from carwash.models.carwash import CarWash
from carwash.serializers import CarWashWriteSerializer, CarSerializer
from user_auth.permissions import IsDirector


class CarWashViewSet(viewsets.ModelViewSet):
    queryset = CarWash.objects.prefetch_related('settings', 'documents').all()
    serializer_class = CarWashWriteSerializer

    def get_permissions(self):
        if self.action == 'list':
            permission_classes = [IsAuthenticated]
        else:
            permission_classes = [IsDirector]
        return [permission() for permission in permission_classes]

    @transaction.atomic
    def create(self, request, *args, **kwargs):
        request.data['owner'] = request.user.id
        return super().create(request, *args, **kwargs)

class CarViewSet(viewsets.ModelViewSet):
    serializer_class = CarSerializer
    permission_classes = [IsAuthenticated]
    lookup_field='number'

    def get_queryset(self):
        return Car.objects.filter(owner=self.request.user)

    def perform_create(self, serializer):
        serializer.save(owner=self.request.user)
