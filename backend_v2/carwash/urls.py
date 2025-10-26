from django.urls import path, include
from rest_framework.routers import DefaultRouter

from api.carwash.views import CarWashViewSet, CarViewSet

router = DefaultRouter()
router.register(r'carwash', CarWashViewSet, basename='carwash')
router.register(r"user/car", CarViewSet, basename="user-car")

urlpatterns = [
    path("", include(router.urls)),
]
