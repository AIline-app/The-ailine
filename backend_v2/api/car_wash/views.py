from http import HTTPMethod

from django.db.models import Q, F, Count, Sum
from django.shortcuts import get_object_or_404
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated, SAFE_METHODS
from rest_framework.response import Response

from car_wash.models import Car
from car_wash.models.car_wash import CarWash
from api.car_wash.serializers import (CarWashWriteSerializer, CarSerializer, BoxSerializer, CarWashReadSerializer,
                                      CarWashEarningsReadSerializer, CarWashChangeSerializer)
from api.car_wash.docs import CarWashViewSetDocs, BoxViewSetDocs, CarViewSetDocs, CarWashEarningsViewSetDocs
from api.car_wash.permissions import IsDirector, ReadOnly, IsCarWashOwner
from api.manager.permissions import IsCarWashManager
from api.manager.filters import OrdersFilterSet


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


@CarWashViewSetDocs
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
            "update": CarWashChangeSerializer,
            "list": CarWashReadSerializer,
            "retrieve": CarWashReadSerializer,
        }.get(self.action, self.serializer_class)

    def perform_create(self, serializer):
        serializer.save(owner=self.request.user)

    def perform_update(self, serializer):
        serializer.save(owner=self.request.user)

    @property
    def car_wash(self) -> CarWash:
        return get_object_or_404(CarWash, pk=self.kwargs['car_wash_id'])

    @action(detail=True, methods=[HTTPMethod.GET])
    def queue(self, request, *args, **kwargs):

        return Response(self.car_wash.get_queue_data(), status=status.HTTP_200_OK)


@CarWashEarningsViewSetDocs
class CarWashEarningsViewSet(CarWashInRouteMixin, viewsets.GenericViewSet):

    serializer_class = CarWashEarningsReadSerializer
    filter_backends = (DjangoFilterBackend,)
    filterset_class = OrdersFilterSet
    lookup_url_kwarg = 'car_wash_id'

    def get_queryset(self):

        return self.car_wash.orders.get_completed()

    @action(detail=True, methods=[HTTPMethod.GET], permission_classes=(IsCarWashOwner,))
    def earnings(self, request, *args, **kwargs):

        queryset = self.filter_queryset(self.get_queryset())

        car_wash_data = queryset.values("car_wash").annotate(
            orders_count=Count('id'),
            revenue=Sum('total_price'),
        )

        by_car_types = queryset.values(car_type=F("services__car_type")).annotate(
            orders_count=Count('id', distinct=True),
        )

        serializer = self.get_serializer(
            car_wash_data[0] | {"by_car_types": by_car_types},
            many=False,
        )

        return Response(serializer.data, status=status.HTTP_200_OK)


@BoxViewSetDocs
class BoxViewSet(CarWashInRouteMixin, viewsets.ModelViewSet):

    serializer_class = BoxSerializer
    lookup_url_kwarg = 'box_id'

    def get_queryset(self):

        return self.car_wash.boxes.all()

    def get_permissions(self):

        permissions_classes = [IsCarWashOwner]
        if self.request.method in SAFE_METHODS:
            permissions_classes[0] |= IsCarWashManager
        return [permission() for permission in permissions_classes]


@CarViewSetDocs
class CarViewSet(viewsets.ModelViewSet):
    serializer_class = CarSerializer
    permission_classes = (IsAuthenticated,)
    lookup_field='number'

    def get_queryset(self):
        return Car.objects.filter(owner=self.request.user)

    def perform_create(self, serializer):
        serializer.save(owner=self.request.user)
