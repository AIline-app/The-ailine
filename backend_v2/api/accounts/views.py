from http import HTTPMethod

import requests
from rest_framework import mixins
from rest_framework.exceptions import ValidationError
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.decorators import action, api_view
from rest_framework.viewsets import GenericViewSet

from accounts.models import User
from api.accounts.docs import UserViewSetDocs, SwaggerLoginDocs

from api.accounts.serializers import UserSerializer


@UserViewSetDocs
class UserViewSet(mixins.DestroyModelMixin,
                  GenericViewSet):

    serializer_class = UserSerializer
    permission_classes = (IsAuthenticated,)

    def get_queryset(self):
        return User.objects.filter(id=self.request.user.id)

    def perform_destroy(self, instance):
        if instance.owner_car_washes or instance.manager_car_washes or instance.washer_car_washes:
            raise ValidationError('Car wash employees deletion is not supported')
        instance.delete()

    @action(detail=False, methods=[HTTPMethod.GET], url_path='me')
    def me(self, request):
        """Return the currently authenticated user (including id)."""
        serializer = self.get_serializer(request.user)
        return Response(serializer.data)


@SwaggerLoginDocs
@api_view(['POST'])
def swagger_login(request):
    """
    Login endpoint for Swagger UI testing.
    After successful login, the session cookie will be automatically set.
    """

    s = requests.Session()

    # Get CSRF from allauth
    csrf_response = s.get(
        f"{request.build_absolute_uri('/_allauth/browser/v1/config')}",
    )

    s.headers.update({'X-CSRFToken': csrf_response.cookies.get_dict()['csrftoken']})

    # Forward the request to allauth login endpoint
    response = s.post(
        f"{request.build_absolute_uri('/_allauth/browser/v1/auth/login')}",
        json=request.data,
    )

    # Copy cookies from allauth response to this response
    django_response = Response(response.json(), status=response.status_code)
    for cookie_name, cookie_value in response.cookies.items():
        django_response.set_cookie(cookie_name, cookie_value)

    return django_response
