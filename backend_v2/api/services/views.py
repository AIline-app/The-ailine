from rest_framework import viewsets

from api.car_wash.permissions import ReadOnly, IsCarWashOwner
from api.car_wash.views import CarWashInRouteMixin
from api.services.serializers import ServicesWriteSerializer, ServicesReadSerializer
from services.models import Services


class ServicesViewSet(CarWashInRouteMixin, viewsets.ModelViewSet):
    serializer_class = ServicesReadSerializer
    lookup_url_kwarg='service_id'
    permission_classes = (ReadOnly | IsCarWashOwner,)

    def get_queryset(self):
        return Services.objects.filter(car_wash=self.car_wash)

    def get_serializer_class(self):
        return {
            "create": ServicesWriteSerializer,
            "update": ServicesWriteSerializer,
            "list": ServicesReadSerializer,
            "retrieve": ServicesReadSerializer,
        }.get(self.action, self.serializer_class)
