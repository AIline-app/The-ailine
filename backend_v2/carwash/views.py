from django.db import transaction
from django.db.models import Q
from rest_framework import viewsets, filters
from rest_framework.permissions import AllowAny, IsAuthenticated

from carwash.models import Car
from carwash.models.carwash import CarWash
from carwash.serializers import CarWashWriteSerializer, CarSerializer
from accounts.permissions import IsDirectorAndOwner


class CarWashViewSet(viewsets.ModelViewSet):
    queryset = CarWash.objects.all()
    serializer_class = CarWashWriteSerializer
    filter_backends = [filters.OrderingFilter]
    ordering_fields = ['name']

    def get_permissions(self):
        if self.action in ('list', 'retrieve'):
            permission_classes = [AllowAny]
        else:
            permission_classes = [IsDirectorAndOwner]
        return [permission() for permission in permission_classes]

    def get_queryset(self):
        if self.action in ('list', 'retrieve'):
            if self.request.user.is_authenticated:
                return CarWash.objects.prefetch_related('settings').filter(
                    Q(is_active=True) | Q(owner=self.request.user)
                )
            else:
                return CarWash.objects.prefetch_related('settings').filter(is_active=True)
        else:
            return CarWash.objects.prefetch_related('settings', 'documents').filter(owner=self.request.user)

    @transaction.atomic
    def create(self, request, *args, **kwargs):
        request.data['owner'] = request.user.id
        return super().create(request, *args, **kwargs)

    @transaction.atomic
    def update(self, request, *args, **kwargs):
        request.data['owner'] = request.user.id
        return super().update(request, *args, **kwargs)


class CarViewSet(viewsets.ModelViewSet):
    serializer_class = CarSerializer
    permission_classes = [IsAuthenticated]
    lookup_field='number'

    def get_queryset(self):
        return Car.objects.filter(owner=self.request.user)

    def perform_create(self, serializer):
        serializer.save(owner=self.request.user)
