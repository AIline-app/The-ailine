from http import HTTPMethod

from django.db.models import Sum, Count, F
from django_filters.rest_framework.backends import DjangoFilterBackend
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response

from api.accounts.serializers import UserSerializer
from api.car_wash.views import CarWashInRouteMixin
from api.car_wash.permissions import IsManagerSuperior, IsCarWashOwner
from api.manager.permissions import IsCarWashManager
from api.manager.serializers import ManagerWriteSerializer, WasherWriteSerializer, WasherEarningsReadSerializer
from api.manager.docs import ManagerViewSetDocs, WasherViewSetDocs, WasherEarningsViewSetDocs
from api.manager.filters import OrdersFilterSet


@ManagerViewSetDocs
class ManagerViewSet(CarWashInRouteMixin, viewsets.ModelViewSet):
    serializer_class = UserSerializer
    permission_classes = (IsManagerSuperior,)
    lookup_url_kwarg = 'user_id'

    def get_queryset(self):
        return self.car_wash.managers

    def get_serializer_class(self):
        return {
            'create': ManagerWriteSerializer,
            'update': ManagerWriteSerializer,
            'list': UserSerializer,
            'retrieve': UserSerializer,
        }.get(self.action, self.serializer_class)

    def perform_destroy(self, instance):
        self.car_wash.managers.remove(instance)


@WasherViewSetDocs
class WasherViewSet(CarWashInRouteMixin, viewsets.ModelViewSet):

    serializer_class = UserSerializer
    permission_classes = (IsCarWashManager | IsCarWashOwner,)
    lookup_url_kwarg = 'user_id'

    def get_queryset(self):
        return self.car_wash.washers

    def get_serializer_class(self):
        return {
            'create': WasherWriteSerializer,
            'update': WasherWriteSerializer,
            'list': UserSerializer,
            'retrieve': UserSerializer,
        }.get(self.action, self.serializer_class)

    def perform_destroy(self, instance):
        self.car_wash.washers.remove(instance)


@WasherEarningsViewSetDocs
class WasherEarningsViewSet(CarWashInRouteMixin, viewsets.GenericViewSet):

    serializer_class = WasherEarningsReadSerializer
    filter_backends = (DjangoFilterBackend,)
    filterset_class = OrdersFilterSet

    def get_queryset(self):

        return self.car_wash.orders.get_completed()

    @action(detail=False, methods=[HTTPMethod.GET], permission_classes=(IsCarWashOwner,))
    def earnings(self, request, *args, **kwargs):

        queryset = self.filter_queryset(
            self.get_queryset().values('washer').annotate(
                orders_count=Count('id'),
                revenue=Sum('total_price'),
                percent=F('car_wash__settings__percent_washers'),
            ).annotate(
                earned=F('revenue') * F('percent') / 100,
            ).order_by('washer__phone_number')
        )

        serializer = self.get_serializer(queryset, many=True)

        return Response(serializer.data, status=status.HTTP_200_OK)
