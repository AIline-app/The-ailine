from http import HTTPMethod

from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response

from api.accounts.serializers import UserSerializer
from api.car_wash.views import CarWashInRouteMixin
from api.car_wash.permissions import IsManagerSuperior, IsCarWashOwner
from api.manager.permissions import IsCarWashManager
from api.manager.serializers import ManagerWriteSerializer, WasherWriteSerializer, WasherEarningsWriteSerializer
from api.manager.docs import ManagerViewSetDocs, WasherViewSetDocs


@ManagerViewSetDocs
class ManagerViewSet(CarWashInRouteMixin, viewsets.ModelViewSet):
    serializer_class = UserSerializer
    permission_classes = (IsManagerSuperior,)
    lookup_url_kwarg = 'user_id'

    def get_queryset(self):
        return self.car_wash.managers

    def get_serializer_class(self):
        return {
            "create": ManagerWriteSerializer,
            "update": ManagerWriteSerializer,
            "list": UserSerializer,
            "retrieve": UserSerializer,
        }.get(self.action, self.serializer_class)

    def perform_destroy(self, instance):
        self.car_wash.managers.remove(instance)


@WasherViewSetDocs
class WasherViewSet(CarWashInRouteMixin, viewsets.ModelViewSet):
    serializer_class = UserSerializer
    permission_classes = (IsCarWashManager,)
    lookup_url_kwarg = 'user_id'

    def get_queryset(self):
        return self.car_wash.washers

    def get_serializer_class(self):
        return {
            "create": WasherWriteSerializer,
            "update": WasherWriteSerializer,
            "list": UserSerializer,
            "retrieve": UserSerializer,
            "earnings": WasherEarningsWriteSerializer,
        }.get(self.action, self.serializer_class)

    def perform_destroy(self, instance):
        self.car_wash.washers.remove(instance)

    @action(detail=False, methods=[HTTPMethod.POST], permission_classes=(IsCarWashOwner,))
    def earnings(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save(car_wash=self.car_wash)
        return Response(serializer.data, status=status.HTTP_200_OK)
