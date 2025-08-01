from django.http import HttpResponseNotAllowed
from django.utils.translation import gettext_lazy as _
from rest_framework import generics, status
from rest_framework.exceptions import ValidationError
from rest_framework.generics import GenericAPIView
from rest_framework.parsers import JSONParser, MultiPartParser
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework_simplejwt.authentication import JWTAuthentication
from rest_framework_simplejwt.exceptions import InvalidToken
from rest_framework_simplejwt.views import TokenRefreshView

from AstSmartTime.settings import API_KEY

from .permissions import OwnerOnly, IsOwnerOrReadOnly
from .models import User, BankCard
# from .models import CashOutData
from .serializers import (MyTokenRefreshSerializer, LoginUserSerializer,
                          DetailUserSerializer, RegisterSerializer,
                          UpdateUserPasswordSerializer, BankCardSerializer,
                          ListBankCardSerializers, CashOutSerializer,
                          CallBackCashOutSerializer, RefreshTokenSerializer, CashOutStatsSerializer)


class JWTAuthenticationSafe(JWTAuthentication):
    def authenticate(self, request):
        try:
            return super().authenticate(request=request)
        except InvalidToken:
            return None


class RegisterUserAPI(generics.GenericAPIView):
    """Регистрация пользователя (по смс)"""
    serializer_class = RegisterSerializer
    permission_classes = (AllowAny,)
    http_method_names = ['post']

    def post(self, request, *args, **kwargs):
        if request.headers['api_key'] == API_KEY:
            serializer = self.get_serializer(data=request.data)
            serializer.is_valid(raise_exception=True)

            token = serializer.data.get('token')

            if token is not None:
                access = token['access']
                refresh = token['refresh']
                response = Response({'access': access}, status=status.HTTP_200_OK)
                response.set_cookie('refresh', refresh, httponly=True, max_age=1209600, samesite=None)
                return response
            else:
                return Response(serializer.data, status=status.HTTP_201_CREATED)
        else:
            return HttpResponseNotAllowed(_('Give me correct api key'))


class MyTokenRefreshView(TokenRefreshView):
    """Обновление access токена"""
    serializer_class = MyTokenRefreshSerializer
    permission_classes = (AllowAny,)
    http_method_names = ['post']

    def post(self, request, *args, **kwargs):
        if request.headers['api_key'] == API_KEY:
            return super().post(request)
        else:
            return HttpResponseNotAllowed(_('Give me correct api key'))


class LoginAPIView(generics.GenericAPIView):
    """Аутентификация пользователя """
    queryset = User.objects.filter(soft_delete=False)
    serializer_class = LoginUserSerializer
    permission_classes = (AllowAny,)
    http_method_names = ['get', 'post']

    def post(self, request, *args, **kwargs):
        if request.headers['api_key'] == API_KEY:
            try:
                serializer = self.get_serializer(data=request.data)
                serializer.is_valid(raise_exception=True)
            except Exception:
                return Response({"Error": 'Incorrect credentials.'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

            access = serializer.validated_data.get('access', None)
            refresh = serializer.validated_data.get('refresh', None)

            if access is not None:
                response = Response({'access': serializer.validated_data['access']}, status=status.HTTP_200_OK)
                response.set_cookie('refresh', refresh, httponly=True, max_age=1209600)
                return response
            return Response({"Error": 'Something went wrong'}, status=status.HTTP_400_BAD_REQUEST)
        else:
            return HttpResponseNotAllowed(_('Give me correct api key'))


class LogoutView(GenericAPIView):
    serializer_class = RefreshTokenSerializer
    permission_classes = (IsAuthenticated, )

    def post(self, request, *args):
        sz = self.get_serializer(data=request.data)
        sz.is_valid(raise_exception=True)
        sz.save()
        return Response(status=status.HTTP_204_NO_CONTENT)


class DetailUserAPI(generics.RetrieveUpdateDestroyAPIView):
    """Детально о пользователе"""
    queryset = User.objects.filter(soft_delete=False)
    serializer_class = DetailUserSerializer
    permission_classes = (IsOwnerOrReadOnly,)
    authentication_classes = (JWTAuthenticationSafe,)
    http_method_names = ['get', 'put', 'patch', 'delete']

    def get_object(self):
        return self.request.user

    def put(self, request, *args, **kwargs):
        if request.headers['api_key'] == API_KEY:
            return super().put(request)
        else:
            return HttpResponseNotAllowed(_('Give me correct api key'))

    def patch(self, request, *args, **kwargs):
        if request.headers['api_key'] == API_KEY:
            return super().patch(request)
        else:
            return HttpResponseNotAllowed(_('Give me correct api key'))

    def delete(self, request, *args, **kwargs):
        if request.headers['api_key'] == API_KEY:
            return super().delete(request)
        else:
            return HttpResponseNotAllowed(_('Give me correct api key'))


class UpdateUserPasswordView(generics.GenericAPIView):
    """Восстановление пароля, проверка токенов."""
    serializer_class = UpdateUserPasswordSerializer
    permission_classes = (AllowAny,)
    http_method_names = ['post']

    def post(self, request, *args, **kwargs):
        if request.headers['api_key'] == API_KEY:
            serializer = self.get_serializer(data=request.data)
            serializer.is_valid(raise_exception=True)

            token = serializer.data.get('token')

            if token is not None:
                access = token['access']
                refresh = token['refresh']
                response = Response({'access': access}, status=status.HTTP_200_OK)
                response.set_cookie('refresh', refresh, httponly=True, max_age=1209600)
                return response
            else:
                return Response(serializer.data, status=status.HTTP_201_CREATED)
        else:
            return HttpResponseNotAllowed(_('Give me correct api key'))


class CreateOrUpdateBankCard(generics.CreateAPIView, generics.RetrieveUpdateDestroyAPIView):
    """Добавление, редактирование или удаление банковской информации."""
    queryset = BankCard.objects.all()
    permission_classes = (IsAuthenticated, OwnerOnly,)
    serializer_class = BankCardSerializer
    http_method_names = ['get', 'post', 'put', 'delete']

    def post(self, request, *args, **kwargs):
        if request.headers['api_key'] == API_KEY:
            return super().post(request)
        else:
            return HttpResponseNotAllowed(_('Give me correct api key'))

    def put(self, request, *args, **kwargs):
        if request.headers['api_key'] == API_KEY:
            return super().patch(request)
        else:
            return HttpResponseNotAllowed(_('Give me correct api key'))

    def delete(self, request, *args, **kwargs):
        if request.headers['api_key'] == API_KEY:
            try:
                self.serializer_class.destroy(self.kwargs['pk'])
            except Exception as error:
                return f'Error {error}!'
            return super().delete(request)
        else:
            return HttpResponseNotAllowed(_('Give me correct api key'))


class ListBankCard(generics.ListAPIView):
    """Клиент может просматривать список своих карт"""
    permission_classes = (IsAuthenticated, OwnerOnly,)
    http_method_names = ['get']
    serializer_class = ListBankCardSerializers

    def get_queryset(self):
        return BankCard.objects.filter(user=self.request.user).only('id', 'last_number')


class CreateCashOutData(generics.RetrieveUpdateDestroyAPIView, generics.ListAPIView):
    """Работа с выплатой. Просмотр, вывод на карту."""
    permission_classes = (IsAuthenticated, OwnerOnly,)
    http_method_names = ['get', 'put']
    serializer_class = CashOutSerializer

    def get_object(self):
        return User.objects.get(id=self.request.user.id)

    def get_queryset(self):
        return User.objects.filter(id=self.request.user.id)

    def get(self, request, *args, **kwargs):
        if request.headers['api_key'] == API_KEY:
            return super().get(request)
        else:
            return HttpResponseNotAllowed(_('Give me correct api key'))

    def put(self, request, *args, **kwargs):
        if request.headers['api_key'] == API_KEY:
            return super().put(request)
        else:
            return HttpResponseNotAllowed(_('Give me correct api key'))


class CallBackCashOut(generics.GenericAPIView):
    """Обработка коллбека на выплату."""
    serializer_class = CallBackCashOutSerializer
    permission_classes = (AllowAny,)
    parser_classes = (JSONParser, MultiPartParser)
    http_method_names = ['post']

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        if not serializer.is_valid():
            raise ValidationError(serializer.errors)

        return Response(data={"accepted": True})


class CashOutStatsView(generics.GenericAPIView):
    """Статистика мойки"""
    serializer_class = CashOutStatsSerializer
    permission_classes = (IsAuthenticated,)

    def get_queryset(self):
        # возвращаем любой queryset — DRF только проверяет, что этот метод есть
        return User.objects.filter(pk=self.request.user.pk)

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        return Response(serializer.data)
