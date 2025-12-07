from django.urls import path, include
from rest_framework.routers import DefaultRouter

from api.car_wash.views import CarWashViewSet, CarViewSet, BoxViewSet
from api.manager.views import ManagerViewSet, WasherViewSet
from iLine.constants import UUID_REGEX

router = DefaultRouter()
router.register(fr"car-wash/(?P<car_wash_id>{UUID_REGEX})/box", BoxViewSet, basename="car-wash-boxes")
router.register(fr"car-wash/(?P<car_wash_id>{UUID_REGEX})/manager", ManagerViewSet, basename="car-wash-managers")
router.register(fr"car-wash/(?P<car_wash_id>{UUID_REGEX})/washer", WasherViewSet, basename="car-wash-washers")
router.register(r'car-wash', CarWashViewSet, basename='car-wash')
router.register(r"user/car", CarViewSet, basename="user-car")
urlpatterns = [
    path("", include(router.urls)),
]
