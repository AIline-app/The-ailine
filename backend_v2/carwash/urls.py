from django.urls import path
from rest_framework.routers import DefaultRouter

from carwash.views import CarWashViewSet

router = DefaultRouter()
router.register(r'carwash', CarWashViewSet, basename='carwash')
urlpatterns = router.urls
