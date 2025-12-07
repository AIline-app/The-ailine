from django.urls import include, path


urlpatterns = [
    path('', include('api.accounts.urls')),
    path('', include('api.car_wash.urls'),),
    path('', include('api.services.urls')),
    path('', include('api.orders.urls')),
]
