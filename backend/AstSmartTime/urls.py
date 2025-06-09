from django.conf import settings
from django.conf.urls.static import static
from django.contrib import admin
from django.urls import path, include
from rest_framework import permissions
from drf_yasg.views import get_schema_view
from drf_yasg import openapi

schema_view = get_schema_view(
    openapi.Info(
        title="AstSmartTime API",
        default_version='1.0',
        description="API service AstSmartTime",
        terms_of_service="https://www.google.com/policies/terms/",
        contact=openapi.Contact(email="admin@admin.local"),
        license=openapi.License(name="Docs"),
    ),
    public=True,
    permission_classes=[permissions.AllowAny],
)


urlpatterns = [
    path('admin/', admin.site.urls),

    path('orders/', include('app_orders.urls')),
    path('users/', include('app_users.urls')),
    path('washes/', include('app_washes.urls')),
    path('adminwork/', include('app_adminwork.urls')),

    path('swagger/', schema_view.with_ui('swagger', cache_timeout=0), name='schema_swagger-ui'),
    path('redoc/', schema_view.with_ui('redoc', cache_timeout=0), name='schema-redoc')
]

urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
