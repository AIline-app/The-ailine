from django.contrib.auth import logout
from django.db import transaction
from drf_spectacular.utils import extend_schema
from rest_framework import generics, status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.decorators import action
from rest_framework.viewsets import GenericViewSet

from accounts.models import User
from .serializers import (RegisterUserWriteSerializer, RegisterUserConfirmWriteSerializer, LoginUserSerializer,
                          UserSerializer, ExceptionSerializer)


class RegisterUserView(generics.GenericAPIView):
    """Регистрация пользователя (по смс)"""
    serializer_class = RegisterUserWriteSerializer
    permission_classes = (AllowAny,)
    authentication_classes = ()

    @extend_schema(
        responses={201: UserSerializer},
    )
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
        return Response(status=status.HTTP_200_OK)


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
        return Response(status=status.HTTP_200_OK)


class LogoutView(generics.GenericAPIView):
    permission_classes = (IsAuthenticated,)

    @extend_schema(
        responses={
            204: None,
            403: ExceptionSerializer
        },
    )
    def post(self, request, *args):
        logout(request)
        return Response(status=status.HTTP_204_NO_CONTENT)


class UserViewSet(GenericViewSet):
    serializer_class = UserSerializer
    permission_classes = (IsAuthenticated,)

    def get_queryset(self):
        return User.objects.filter(id=self.request.user.id)

    @action(detail=False, methods=["get"], url_path="me")
    def me(self, request):
        """Return the currently authenticated user (including id)."""
        serializer = self.get_serializer(request.user)
        return Response(serializer.data)
