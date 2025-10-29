from rest_framework import viewsets

from accounts.models import User
from api.car_wash.views import CarWashInRouteMixin
from api.car_wash.permissions import IsCarWashOwner
from api.manager.serializers import ManagerWriteSerializer, ManagerReadSerializer


class ManagerViewSet(CarWashInRouteMixin, viewsets.ModelViewSet):
    serializer_class = ManagerReadSerializer
    permission_classes = (IsCarWashOwner,)
    lookup_url_kwarg = 'user_id'

    def get_serializer_class(self):
        return {
            "create": ManagerWriteSerializer,
            "update": ManagerWriteSerializer,
            "list": ManagerReadSerializer,
            "retrieve": ManagerReadSerializer,
        }.get(self.action, self.serializer_class)

    def get_queryset(self):
        return User.objects.filter(managed_car_wash=self.car_wash)
