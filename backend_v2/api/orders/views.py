from http import HTTPMethod

from django_filters.rest_framework import DjangoFilterBackend
from rest_framework.filters import OrderingFilter
from rest_framework import mixins, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.viewsets import GenericViewSet

from api.car_wash.views import CarWashInRouteMixin
from api.manager.permissions import IsCarWashManager
from api.orders.permissions import IsOrderOwner
from api.orders.serializers import (
    OrdersCreateSerializer,
    OrdersReadSerializer,
    OrdersManualCreateSerializer,
    OrdersStartSerializer,
    OrdersFinishSerializer, OrdersUpdateServicesSerializer, CarWashOrderQueueSerializer,
)
from orders.utils.enums import OrderStatus


class OrdersViewSet(CarWashInRouteMixin,
                    mixins.CreateModelMixin,
                    mixins.RetrieveModelMixin,
                    mixins.DestroyModelMixin,
                    mixins.ListModelMixin,
                    GenericViewSet):
    serializer_class = OrdersReadSerializer
    permission_classes = (IsOrderOwner | IsCarWashManager,)
    filter_backends = (DjangoFilterBackend, OrderingFilter)
    filterset_fields = ('status', 'box', 'washer')
    ordering_fields = ('created_at', 'started_at', 'finished_at')
    lookup_url_kwarg = 'order_id'

    def get_queryset(self):
        queryset = self.car_wash.orders
        if not self.car_wash.managers.contains(self.request.user):
            queryset = queryset.filter(user=self.request.user)
        return queryset

    def get_serializer_context(self):
        ctx = super().get_serializer_context()
        ctx['is_manager'] = self.car_wash.managers.contains(self.request.user)
        return ctx

    def get_serializer_class(self):
        return {
            "create": OrdersCreateSerializer,
            "list": OrdersReadSerializer,
            "retrieve": OrdersReadSerializer,
            "manual": OrdersManualCreateSerializer,
            "queue": CarWashOrderQueueSerializer,
            "start": OrdersStartSerializer,
            "finish": OrdersFinishSerializer,
            "update_services": OrdersUpdateServicesSerializer,
        }.get(self.action, self.serializer_class)

    def perform_destroy(self, instance):
        instance.status = OrderStatus.CANCELED
        instance.save()

    def update(self, request, *args, **kwargs):
        order = self.get_object()
        serializer = self.get_serializer(order, data=request.data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        headers = self.get_success_headers(serializer.data)
        return Response(serializer.data, status=status.HTTP_200_OK, headers=headers)

    @action(detail=False, methods=[HTTPMethod.POST], permission_classes=(IsCarWashManager,))
    def manual(self, request, car_wash_id, *args, **kwargs):
        request.data['car_wash_id'] = car_wash_id  # TODO remove?
        return self.create(request, *args, **kwargs)

    @action(detail=True, methods=[HTTPMethod.GET])
    def queue(self, request, *args, **kwargs):
        return self.update(request, *args, **kwargs)

    @action(detail=True, methods=[HTTPMethod.PUT], permission_classes=(IsCarWashManager,))
    def start(self, request, *args, **kwargs):
        return self.update(request, *args, **kwargs)

    @action(detail=True, methods=[HTTPMethod.PUT], permission_classes=(IsCarWashManager,))
    def finish(self, request, *args, **kwargs):
        return self.update(request, *args, **kwargs)

    @action(detail=True, methods=[HTTPMethod.PUT], url_path='services', permission_classes=(IsCarWashManager,))
    def update_services(self, request, *args, **kwargs):
        return self.update(request, *args, **kwargs)
