from django.urls import path, include
from rest_framework import routers

from api.accounts.views import RegisterUserView, LoginView, LogoutView, RegisterUserConfirmView, UserViewSet


router = routers.SimpleRouter()
router.register(r"user", UserViewSet, basename="user")

urlpatterns = [
    path(r'register', RegisterUserView.as_view(), name='user_register'),
    path('register/confirm', RegisterUserConfirmView.as_view(), name='user_register_confirm'),
    path('login', LoginView.as_view(), name='user_login'),
    path('logout', LogoutView.as_view(), name='user_logout'),
    path("", include(router.urls)),
]
