from django.urls import path, include
from rest_framework import routers

from api.accounts.views import UserViewSet, swagger_login


router = routers.SimpleRouter()
router.register(r"user", UserViewSet, basename="user")

urlpatterns = [
    path("", include(router.urls)),
    path("_auth/swagger/login", swagger_login, name='swagger-login'),
]
