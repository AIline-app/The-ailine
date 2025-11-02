from rest_framework import viewsets

from api.accounts.serializers import UserSerializer
from api.car_wash.views import CarWashInRouteMixin
from api.car_wash.permissions import IsManagerSuperior
from api.manager.permissions import IsCarWashManager
from api.manager.serializers import ManagerWriteSerializer, WasherWriteSerializer


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
        }.get(self.action, self.serializer_class)

    def perform_destroy(self, instance):
        self.car_wash.washers.remove(instance)
