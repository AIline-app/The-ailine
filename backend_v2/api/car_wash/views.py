from django.db import transaction
from django.db.models import Q
from rest_framework import viewsets, filters
from rest_framework.permissions import AllowAny, IsAuthenticated

from car_wash.models import Car
from car_wash.models.box import Box
from car_wash.models.car_wash import CarWash
from api.car_wash.serializers import CarWashWriteSerializer, CarSerializer, BoxSerializer
from api.accounts.permissions import IsDirectorAndOwner


class CarWashViewSet(viewsets.ModelViewSet):
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

class BoxViewSet(viewsets.ModelViewSet):
    serializer_class = BoxSerializer
    filter_backends = [filters.OrderingFilter]
    ordering_fields = ['name']
    permission_classes = [IsDirectorAndOwner]
    lookup_url_kwarg='box_id'

    def get_queryset(self):
        carwash_id = self.kwargs.get('carwash_id')
        queryset = Box.objects.select_related('car_wash').filter(car_wash__owner=self.request.user)

        if carwash_id:
            queryset = queryset.filter(car_wash=carwash_id)

        return queryset


class CarViewSet(viewsets.ModelViewSet):
    serializer_class = CarSerializer
    permission_classes = [IsAuthenticated]
    lookup_field='number'

    def get_queryset(self):
        return Car.objects.filter(owner=self.request.user)

    def perform_create(self, serializer):
        serializer.save(owner=self.request.user)
