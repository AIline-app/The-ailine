from django.urls import path, include
from rest_framework.routers import DefaultRouter

from api.services.views import ServicesViewSet
from iLine.constants import UUID_REGEX

router = DefaultRouter()
router.register(fr"car-wash/(?P<car_wash_id>{UUID_REGEX})/service", ServicesViewSet, basename="car-wash-services")

urlpatterns = [
    path("", include(router.urls)),
]
