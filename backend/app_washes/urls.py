from django.urls import path

from app_washes.views import (CreateCarWashAPI, DetailCarWashAPI, CreateServiceAPI,
                              DetailServiceAPI, ListCarWashAPI, AdminCreateAPI, AdminDetailAPI, ListWashesOwner)

urlpatterns = [
    path('', ListCarWashAPI.as_view(), name='wash_list'),
    path('my_washes', ListWashesOwner.as_view(), name='my_washes'),
    path('create', CreateCarWashAPI.as_view(), name='wash_create'),
    path('<int:pk>', DetailCarWashAPI.as_view(), name='wash_detail'),

    path('service/create', CreateServiceAPI.as_view(), name='service_create'),
    path('service/<int:pk>', DetailServiceAPI.as_view(), name='service_detail'),

    path('admins/create', AdminCreateAPI.as_view(), name='admin_create'),
    path('admins/<int:pk>', AdminDetailAPI.as_view(), name='admin_detail'),
]
