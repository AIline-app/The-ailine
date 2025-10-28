from django.db.models import Q
from rest_framework import viewsets, filters
from rest_framework.permissions import AllowAny, IsAuthenticated, SAFE_METHODS

from car_wash.models import Car
from car_wash.models.box import Box
from car_wash.models.car_wash import CarWash
from api.car_wash.serializers import CarWashWriteSerializer, CarSerializer, BoxSerializer, CarWashReadSerializer
from api.car_wash.permissions import IsDirector


class CarWashViewSet(viewsets.ModelViewSet):
    serializer_class = CarWashWriteSerializer
    filter_backends = [filters.OrderingFilter]
    ordering_fields = ['name']

    def get_permissions(self):
        if self.request.method in SAFE_METHODS:
            permission_classes = [AllowAny]
        else:
            permission_classes = [IsDirector]
        return [permission() for permission in permission_classes]

    def get_queryset(self):
        queryset = CarWash.objects.prefetch_related('settings')
        if self.request.method in SAFE_METHODS:
            if self.request.user.is_authenticated:
                return queryset.filter(
                    Q(is_active=True) | Q(owner=self.request.user)
                )
            else:
                return queryset.filter(is_active=True)
        else:
            return queryset.prefetch_related('documents').filter(owner=self.request.user)

    def get_serializer_class(self):
        return {
            "create": CarWashWriteSerializer,
            "update": CarWashWriteSerializer,
            "list": CarWashReadSerializer,
            "retrieve": CarWashReadSerializer,
            "view": None,
            "view_all": None,
        }.get(self.action, self.serializer_class)

    def perform_create(self, serializer):
        serializer.save(owner=self.request.user)

    def perform_update(self, serializer):
        serializer.save(owner=self.request.user)


class BoxViewSet(viewsets.ModelViewSet):
    serializer_class = BoxSerializer
    filter_backends = [filters.OrderingFilter]
    ordering_fields = ['name']
    permission_classes = [IsDirector]
    lookup_url_kwarg='box_id'

    def get_queryset(self):
        car_wash_id = self.kwargs.get('car_wash_id')
        queryset = Box.objects.select_related('car_wash').filter(car_wash__owner=self.request.user)

        if car_wash_id:
            queryset = queryset.filter(car_wash=car_wash_id)

        return queryset


class CarViewSet(viewsets.ModelViewSet):
    serializer_class = CarSerializer
    permission_classes = [IsAuthenticated]
    lookup_field='number'

    def get_queryset(self):
        return Car.objects.filter(owner=self.request.user)

    def perform_create(self, serializer):
        serializer.save(owner=self.request.user)
