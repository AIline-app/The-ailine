from http import HTTPMethod

from django.db.models import Q
from django.shortcuts import get_object_or_404
from rest_framework import viewsets, filters, status
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated, SAFE_METHODS
from rest_framework.response import Response

from api.manager.permissions import IsCarWashManager
from car_wash.models import Car
from car_wash.models.car_wash import CarWash
from api.car_wash.serializers import CarWashWriteSerializer, CarSerializer, BoxSerializer, CarWashReadSerializer, \
    CarWashQueueSerializer
from api.car_wash.permissions import IsDirector, ReadOnly, IsCarWashOwner


class CarWashInRouteMixin:
    @property
    def car_wash(self) -> CarWash:
        return get_object_or_404(CarWash, pk=self.kwargs['car_wash_id'])

    def get_serializer_context(self):
        context = super().get_serializer_context()
        context['car_wash'] = self.car_wash
        return context

    def perform_create(self, serializer):
        return serializer.save(car_wash=self.car_wash)


class CarWashViewSet(viewsets.ModelViewSet):
    serializer_class = CarWashWriteSerializer
    lookup_url_kwarg = 'car_wash_id'
    permission_classes = (ReadOnly | IsDirector,)

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
            "queue": CarWashQueueSerializer,
        }.get(self.action, self.serializer_class)

    def perform_create(self, serializer):
        serializer.save(owner=self.request.user)

    def perform_update(self, serializer):
        serializer.save(owner=self.request.user)

    @action(detail=True, methods=[HTTPMethod.GET])
    def queue(self, request, car_wash_id, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save(car_wash_id=car_wash_id)
        return Response(serializer.data, status=status.HTTP_200_OK)


class BoxViewSet(CarWashInRouteMixin, viewsets.ModelViewSet):
    serializer_class = BoxSerializer
    lookup_url_kwarg = 'box_id'

    def get_queryset(self):
        return self.car_wash.boxes

    def get_permissions(self):
        permissions_classes = [IsCarWashOwner]
        if self.request.method in SAFE_METHODS:
            permissions_classes[0] |= IsCarWashManager
        return [permission() for permission in permissions_classes]

class CarViewSet(viewsets.ModelViewSet):
    serializer_class = CarSerializer
    permission_classes = (IsAuthenticated,)
    lookup_field='number'

    def get_queryset(self):
        return Car.objects.filter(owner=self.request.user)

    def perform_create(self, serializer):
        serializer.save(owner=self.request.user)
