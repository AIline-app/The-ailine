from django.contrib.auth import logout
from django.db import transaction
from rest_framework import generics, status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response

from .models import User
from .serializers import RegisterUserWriteSerializer, RegisterUserConfirmWriteSerializer, LoginUserSerializer


class RegisterUserView(generics.GenericAPIView):
    """Регистрация пользователя (по смс)"""
    serializer_class = RegisterUserWriteSerializer
    permission_classes = (AllowAny,)
    authentication_classes = ()

    @transaction.atomic
    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data, status=status.HTTP_201_CREATED)


class RegisterUserConfirmView(generics.GenericAPIView):
    """Регистрация пользователя (по смс)"""
    serializer_class = RegisterUserConfirmWriteSerializer
    permission_classes = (AllowAny,)
    authentication_classes = ()

    @transaction.atomic
    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(status=status.HTTP_204_NO_CONTENT)


class LoginView(generics.GenericAPIView):
    """Аутентификация пользователя """
    queryset = User.objects.filter(is_active=True)
    serializer_class = LoginUserSerializer
    permission_classes = (AllowAny,)
    authentication_classes = ()

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(status=status.HTTP_204_NO_CONTENT)


class LogoutView(generics.GenericAPIView):
    queryset = User.objects.filter(is_active=True)
    permission_classes = (IsAuthenticated,)

    def post(self, request, *args):
        logout(request)
        return Response(status=status.HTTP_204_NO_CONTENT)
