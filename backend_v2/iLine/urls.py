"""
URL configuration for iLine project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
from django.http import JsonResponse
from django.conf import settings
from django.conf.urls.static import static


def healthz(request):
    return JsonResponse({"status": "ok"})

urlpatterns = [
    path('admin/', admin.site.urls),
    path('_allauth/', include('allauth.urls')),
    path("_allauth/", include("allauth.headless.urls")),
    path('api/v1/', include('api.urls')),
    path('healthz/', healthz, name='healthz'),
    path('admin_tools_stats/', include('admin_tools_stats.urls')),
]

# Serve media files (e.g., generated QR codes) at /media/ in this app
urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
