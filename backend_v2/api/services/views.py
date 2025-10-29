from rest_framework import viewsets
from rest_framework.permissions import AllowAny, SAFE_METHODS

from api.car_wash.permissions import IsDirector
from api.services.serializers import ServicesWriteSerializer, ServicesReadSerializer
from car_wash.models import CarWash
from services.models import Services


class ServicesViewSet(viewsets.ModelViewSet):
    serializer_class = ServicesReadSerializer
    lookup_url_kwarg='service_id'

    def get_permissions(self):
        if self.request.method in SAFE_METHODS:
            permission_classes = [AllowAny]
        else:
            permission_classes = [IsDirector]
        return [permission() for permission in permission_classes]

    def get_queryset(self):
        car_wash_id = self.kwargs.get('car_wash_id')
        return Services.objects.filter(car_wash=car_wash_id)

    def get_serializer_class(self):
        return {
            "create": ServicesWriteSerializer,
            "update": ServicesWriteSerializer,
            "list": ServicesReadSerializer,
            "retrieve": ServicesReadSerializer,
        }.get(self.action, self.serializer_class)

    def get_serializer_context(self):
        context = super().get_serializer_context()
        car_wash = CarWash.objects.get(id=self.kwargs.get('car_wash_id'))
        context['car_wash'] = car_wash
        return context

    def perform_create(self, serializer):
        self.check_object_permissions(self.request, serializer.context['car_wash'])
        return super().perform_create(serializer)
