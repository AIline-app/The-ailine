from rest_framework import viewsets
from rest_framework.permissions import AllowAny, SAFE_METHODS

from api.car_wash.permissions import IsDirector
from api.services.serializers import ServicesWriteSerializer, ServicesReadSerializer
from services.models import Services


class ServicesViewSet(viewsets.ModelViewSet):
    serializer_class = ServicesReadSerializer
    queryset = Services.objects.all()

    def get_permissions(self):
        if self.request.method in SAFE_METHODS:
            permission_classes = [AllowAny]
        else:
            permission_classes = [IsDirector]
        return [permission() for permission in permission_classes]

    def get_serializer_class(self):
        return {
            "create": ServicesWriteSerializer,
            "update": ServicesWriteSerializer,
            "list": ServicesReadSerializer,
            "retrieve": ServicesReadSerializer,
            "view": None,
            "view_all": None,
        }.get(self.action, self.serializer_class)

    def get_serializer_context(self):
        context = super().get_serializer_context()
        car_wash_id = self.kwargs.get('car_wash_id')
        context['car_wash_id'] = car_wash_id
        return context
