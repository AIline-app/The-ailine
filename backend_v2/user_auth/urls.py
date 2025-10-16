from django.urls import path

from user_auth.utils.choices import UserRoles
from user_auth.views import RegisterUserView, LoginView, LogoutView, RegisterUserConfirmView

urlpatterns = [
    path(r'register', RegisterUserView.as_view(), name='user_register'),
    path('register/confirm', RegisterUserConfirmView.as_view(), name='user_register_confirm'),
    path('login', LoginView.as_view(), name='user_login'),
    path('logout', LogoutView.as_view(), name='user_logout'),
]
