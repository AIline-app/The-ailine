from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.decorators import action, api_view
from rest_framework.viewsets import GenericViewSet
from drf_spectacular.utils import extend_schema
import requests

from accounts.models import User
from api.accounts.serializers import UserSerializer


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


@extend_schema(
    request={
        'application/json': {
            'type': 'object',
            'properties': {
                'phone': {'type': 'string'},
                'password': {'type': 'string'},
            },
            'required': ['phone', 'password']
        }
    },
    responses={200: {'description': 'Login successful'}},
    tags=['Authentication']
)
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
