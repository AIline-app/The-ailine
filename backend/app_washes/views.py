from django.http import HttpResponseNotAllowed
from django.utils.translation import gettext_lazy as _
from django.utils import timezone
from django.shortcuts import get_object_or_404
from rest_framework import generics, filters, status
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticatedOrReadOnly, IsAuthenticated
from AstSmartTime.settings import API_KEY
from app_users.models import User
from app_users.permissions import IsOwnerOrReadOnly, OwnerOnly
from app_users.views import JWTAuthenticationSafe
from app_washes.models import CarWash, Service, Administrator, Washer
from app_washes.permissions import IsMyServiceOrReadOnly, TrueForAll
from app_washes.serializers import (
    RegisterCarWashSerializer, CarWashSerializer, ServiceCreateSerializer,
    ServiceDetailSerializer, AdministratorCreateSerializer,
    AdministratorListSerializer, WashListSerializer, WasherCreateSerializer,
    WasherDetailSerializer, WasherStatsSerializer, DateRangeSerializer
)


class CreateCarWashAPI(generics.CreateAPIView):
    """Регистрация автомойки"""
    serializer_class = RegisterCarWashSerializer
    permission_classes = (IsAuthenticated,)
    http_method_names = ['post']

    def post(self, request, *args, **kwargs):
        if request.headers['api_key'] == API_KEY:
            return super().post(request)
        else:
            return HttpResponseNotAllowed(_('Give me correct api key'))


class DetailCarWashAPI(generics.RetrieveUpdateDestroyAPIView):
    """Детально об автомойке"""
    queryset = CarWash.objects.all()
    serializer_class = CarWashSerializer
    permission_classes = (AllowAny, IsOwnerOrReadOnly,)
    authentication_classes = (JWTAuthenticationSafe,)
    http_method_names = ['get', 'put', 'patch', 'delete']

    def get(self, request, *args, **kwargs):
        if request.headers['api_key'] == API_KEY:
            wash = CarWash.objects.get(id=self.kwargs['pk'])
            if wash.last_time < timezone.now():
                wash.last_time = timezone.now() + timezone.timedelta(minutes=30)
                wash.save()
            return super().get(request)
        else:
            return HttpResponseNotAllowed(_('Give me correct api key'))

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


class ListCarWashAPI(generics.ListAPIView):
    """Список автомоек"""
    serializer_class = RegisterCarWashSerializer
    authentication_classes = []
    permission_classes = (TrueForAll,)
    http_method_names = ['get']
    filter_backends = [filters.SearchFilter]

    def get_queryset(self):
        queryset = CarWash.objects.filter(soft_delete=False, is_validate=True, is_active=True)
        left = self.request.query_params.getlist('left')
        right = self.request.query_params.getlist('right')
        if left and right is not None:
            queryset = queryset.filter(
                wash_coordinates__latitude__range=(left[0], right[0]),
                wash_coordinates__longitude__range=(left[1], right[1])
            )

        return queryset

    def get(self, request, *args, **kwargs):
        if request.headers['api_key'] == API_KEY:
            return super().get(request)
        else:
            return HttpResponseNotAllowed(_('Give me correct api key'))


class CreateServiceAPI(generics.CreateAPIView):
    """Создание услуги для автомойки"""
    serializer_class = ServiceCreateSerializer
    permission_classes = (IsAuthenticated,)
    http_method_names = ['post']

    def post(self, request, *args, **kwargs):
        if request.headers['api_key'] == API_KEY:
            return super().post(request)
        else:
            return HttpResponseNotAllowed(_('Give me correct api key'))


class DetailServiceAPI(generics.RetrieveUpdateDestroyAPIView):
    """Детально об услуге"""
    queryset = Service.objects.all().only('wash_id')
    serializer_class = ServiceDetailSerializer
    permission_classes = (IsAuthenticatedOrReadOnly, IsMyServiceOrReadOnly,)
    http_method_names = ['get', 'put', 'patch', 'delete']

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


class AdminListAPI(generics.RetrieveAPIView):
    """Список администраторов автомойки"""
    queryset = User.objects.filter(soft_delete=False)
    serializer_class = AdministratorListSerializer
    permission_classes = (IsAuthenticated,)
    http_method_names = ['get']

    def get_object(self):
        return self.request.user


class AdminDetailAPI(generics.RetrieveUpdateDestroyAPIView):
    """Детально об администраторе автомойки"""
    queryset = Administrator.objects.all()
    serializer_class = AdministratorCreateSerializer
    permission_classes = (IsAuthenticated,)
    http_method_names = ['get', 'put', 'patch', 'delete']

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
            try:
                admin = Administrator.objects.get(id=self.kwargs['pk'])
                for user in User.objects.all():
                    if user.phone == admin.phone:
                        user.role = 'client'
                        user.save()
                carwash_db = CarWash.objects.get(wash_admin=admin)
                carwash_db.is_validate = False
                carwash_db.save()
            except Exception as error:
                raise ValueError(f'We have a problem {error}')
            return super().delete(request)
        else:
            return HttpResponseNotAllowed(_('Give me correct api key'))


class AdminCreateAPI(generics.CreateAPIView, generics.DestroyAPIView):
    """Добавление администратора"""
    serializer_class = AdministratorCreateSerializer
    permission_classes = (IsAuthenticated,)
    http_method_names = ['post']

    def post(self, request, *args, **kwargs):
        if request.headers['api_key'] == API_KEY:
            return super().post(request)
        else:
            return HttpResponseNotAllowed(_('Give me correct api key'))


class WasherCreateAPI(generics.CreateAPIView, generics.DestroyAPIView):
    """Добавление мойщика"""
    serializer_class = WasherCreateSerializer
    permission_classes = (IsAuthenticated,)
    http_method_names = ['post']

    def post(self, request, *args, **kwargs):
        if request.headers['api_key'] == API_KEY:
            return super().post(request)
        else:
            return HttpResponseNotAllowed(_('Give me correct api key'))


class WasherDetailAPI(generics.RetrieveUpdateDestroyAPIView):
    """Детально об мойщике"""
    queryset = Washer.objects.all()
    serializer_class = WasherCreateSerializer
    permission_classes = (IsAuthenticated,)
    http_method_names = ['get', 'put', 'patch', 'delete']

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

class WashersStatsView(generics.GenericAPIView):
    """Статистика мойщиков"""
    permission_classes = (IsAuthenticated, OwnerOnly,)
    serializer_class = DateRangeSerializer
    queryset = Washer.objects.all()  # нужно для GenericAPIView

    def post(self, request, *args, **kwargs):
        dr_serializer = self.get_serializer(data=request.data)
        dr_serializer.is_valid(raise_exception=True)
        start_date = dr_serializer.validated_data['start_date']
        end_date   = dr_serializer.validated_data['end_date']
        wash_pk = kwargs['pk']
        washers = Washer.objects.filter(wash=wash_pk)
        stats_serializer = WasherStatsSerializer(
            washers,
            many=True,
            context={
                'request': request,
                'start_date': start_date,
                'end_date': end_date,
            }
        )
        return Response(stats_serializer.data, status=status.HTTP_200_OK)


class ListWasherOwner(generics.ListAPIView):
    """Получение списка мойщиков одной мойки."""
    permission_classes = (IsAuthenticated, OwnerOnly,)
    serializer_class = WasherDetailSerializer
    http_method_names = ['get']

    def get_queryset(self):
        """Фильтруем получение мойщиков по мойке"""
        return Washer.objects.filter(wash=self.kwargs['pk'])


class ListWashesOwner(generics.ListAPIView, generics.DestroyAPIView):
    """Получение списка автомоек в профиле партнёра."""
    permission_classes = (IsAuthenticated, OwnerOnly,)
    serializer_class = WashListSerializer
    http_method_names = ['get', 'delete']

    def get_queryset(self):
        """Фильтруем получение моек по залогиненному пользователю."""
        return CarWash.objects.filter(user=self.request.user).only('user_id')


class ListAllAdminOwner(generics.ListAPIView, generics.DestroyAPIView):
    """Получение всем администраторов, созданных партнёром."""
    permission_classes = (IsAuthenticated, OwnerOnly,)
    http_method_names = ['get', 'delete']
    serializer_class = AdministratorListSerializer

    def get_queryset(self):
        Administrator.objects.filter(boss=self.request.user)
