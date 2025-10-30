from rest_framework import viewsets

from accounts.models import User
from accounts.utils.enums import UserRoles
from api.accounts.serializers import UserSerializer
from api.car_wash.views import CarWashInRouteMixin
from api.car_wash.permissions import IsManagerSuperior
from api.manager.serializers import ManagerWriteSerializer


class ManagerViewSet(CarWashInRouteMixin, viewsets.ModelViewSet):
    serializer_class = UserSerializer
    permission_classes = (IsManagerSuperior,)
    lookup_url_kwarg = 'user_id'

    def get_serializer_class(self):
        return {
            "create": ManagerWriteSerializer,
            "update": ManagerWriteSerializer,
            "list": UserSerializer,
            "retrieve": UserSerializer,
        }.get(self.action, self.serializer_class)

    def perform_destroy(self, instance):
        instance.managed_car_wash = None
        instance.roles.remove(UserRoles.MANAGER)
        instance.save(update_fields=('managed_car_wash',))

    def get_queryset(self):
        return User.objects.filter(managed_car_wash=self.car_wash)
