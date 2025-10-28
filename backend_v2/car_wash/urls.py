from django.urls import path, include
from rest_framework.routers import DefaultRouter

from api.car_wash.views import CarWashViewSet, CarViewSet, BoxViewSet
from iLine.constants import UUID_REGEX

router = DefaultRouter()
router.register(fr"car-wash/(?P<car_wash_id>{UUID_REGEX})/box", BoxViewSet, basename="car-wash-boxes")
router.register(r'car-wash', CarWashViewSet, basename='car-wash')
router.register(r"user/car", CarViewSet, basename="user-car")

urlpatterns = [
    path("", include(router.urls)),
]
