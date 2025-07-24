from django.urls import path

from app_washes.views import (CreateCarWashAPI, DetailCarWashAPI, CreateServiceAPI,
                              DetailServiceAPI, ListCarWashAPI, AdminCreateAPI,
                              AdminDetailAPI, ListWashesOwner, WasherCreateAPI,
                              WasherDetailAPI, ListWasherOwner, WashersStatsView)

urlpatterns = [
    path('', ListCarWashAPI.as_view(), name='wash_list'),
    path('my_washes', ListWashesOwner.as_view(), name='my_washes'),
    path('create', CreateCarWashAPI.as_view(), name='wash_create'),
    path('<int:pk>', DetailCarWashAPI.as_view(), name='wash_detail'),
    path('<int:pk>/washers', ListWasherOwner.as_view(), name='washer_list'),
    path('<int:pk>/washers/stats', WashersStatsView.as_view(), name='washers-stats'),

    path('service/create', CreateServiceAPI.as_view(), name='service_create'),
    path('service/<int:pk>', DetailServiceAPI.as_view(), name='service_detail'),

    path('admins/create', AdminCreateAPI.as_view(), name='admin_create'),
    path('admins/<int:pk>', AdminDetailAPI.as_view(), name='admin_detail'),

    path('washer/create', WasherCreateAPI.as_view(), name='washer_create'),
    path('washer/<int:pk>', WasherDetailAPI.as_view(), name='washer_detail'),
]
