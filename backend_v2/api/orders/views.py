from http import HTTPMethod

from django_filters.rest_framework import DjangoFilterBackend
from rest_framework.filters import OrderingFilter
from rest_framework import mixins, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.viewsets import GenericViewSet

from api.car_wash.permissions import IsCarWashOwner
from api.car_wash.views import CarWashInRouteMixin
from api.manager.permissions import IsCarWashManager
from api.orders.filters import OrdersSearchFilter, OrdersFilterSet
from api.orders.permissions import IsOrderOwner
from api.orders.serializers import (
    OrdersCreateSerializer,
    OrdersReadSerializer,
    OrdersManualCreateSerializer,
    OrdersStartSerializer,
    OrdersFinishSerializer,
    OrdersUpdateServicesSerializer,
)
from api.orders.docs import OrdersViewSetDocs
from orders.utils.enums import OrderStatus
from iLine.enums import EventEnum
from django_attribution.shortcuts import record_conversion
from django_attribution.decorators import conversion_events


@OrdersViewSetDocs
class OrdersViewSet(CarWashInRouteMixin,
                    mixins.CreateModelMixin,
                    mixins.RetrieveModelMixin,
                    mixins.DestroyModelMixin,
                    mixins.ListModelMixin,
                    GenericViewSet):
    serializer_class = OrdersReadSerializer
    permission_classes = (IsOrderOwner | IsCarWashManager,)
    filter_backends = (DjangoFilterBackend, OrderingFilter, OrdersSearchFilter)
    search_fields = ('^car__number',)
    filterset_class = OrdersFilterSet
    ordering_fields = ('created_at', 'started_at', 'finished_at')
    lookup_url_kwarg = 'order_id'

    def get_queryset(self):
        queryset = self.car_wash.orders
        if not self.car_wash.managers.contains(self.request.user) and self.request.user != self.car_wash.owner:
            queryset = queryset.filter(user=self.request.user)
        return queryset.all()

    def get_serializer_context(self):
        ctx = super().get_serializer_context()
        ctx['is_manager'] = self.car_wash.managers.contains(self.request.user)
        return ctx

    def get_serializer_class(self):
        return {
            'create': OrdersCreateSerializer,
            'list': OrdersReadSerializer,
            'retrieve': OrdersReadSerializer,
            'manual': OrdersManualCreateSerializer,
            'start': OrdersStartSerializer,
            'finish': OrdersFinishSerializer,
            'update_services': OrdersUpdateServicesSerializer,
        }.get(self.action, self.serializer_class)

    @conversion_events(EventEnum.ORDER_CANCELED)
    def perform_destroy(self, instance):
        # record previous status before cancel
        prev_status = instance.status
        instance.status = OrderStatus.CANCELED
        instance.save()
        # Remove from queue if it was in waiting status
        if instance.car_wash and prev_status in (OrderStatus.EN_ROUTE, OrderStatus.ON_SITE):
            instance.car_wash.remove_from_queue(instance)
        # Track conversion for order cancellation
        try:
            record_conversion(
                self.request,
                EventEnum.ORDER_CANCELED,
                source_object=instance,
                is_confirmed=True,
                custom_data={
                    'previous_status': prev_status,
                    'canceled_by_user_id': str(self.request.user.id) if getattr(self.request, 'user', None) else None,
                },
            )
        except Exception:
            # Avoid failing the API if attribution tracking has issues
            pass

    def _update(self, request, *args, **kwargs):
        order = self.get_object()
        serializer = self.get_serializer(order, data=request.data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        headers = self.get_success_headers(serializer.data)
        return Response(serializer.data, status=status.HTTP_200_OK, headers=headers)

    @action(detail=False, methods=[HTTPMethod.POST], permission_classes=(IsCarWashManager | IsCarWashOwner,))
    def manual(self, request, car_wash_id, *args, **kwargs):
        request.data['car_wash_id'] = car_wash_id  # TODO remove?
        return self.create(request, *args, **kwargs)

    @action(detail=True, methods=[HTTPMethod.GET])
    def queue(self, request, *args, **kwargs):

        return Response(self.get_object().get_queue_data(), status=status.HTTP_200_OK)

    @action(detail=True, methods=[HTTPMethod.PUT], permission_classes=(IsCarWashManager,))
    def start(self, request, *args, **kwargs):

        return self._update(request, *args, **kwargs)

    @action(detail=True, methods=[HTTPMethod.PUT], permission_classes=(IsCarWashManager,))
    def finish(self, request, *args, **kwargs):

        return self._update(request, *args, **kwargs)

    @action(detail=True, methods=[HTTPMethod.PUT], url_path='services', permission_classes=(IsCarWashManager,))
    def update_services(self, request, *args, **kwargs):

        return self._update(request, *args, **kwargs)
