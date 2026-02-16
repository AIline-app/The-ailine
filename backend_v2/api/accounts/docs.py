from drf_spectacular.utils import extend_schema, extend_schema_view, OpenApiResponse

from api.accounts.serializers import UserSerializer


# Documentation for User endpoints in api.accounts
UserViewSetDocs = extend_schema_view(
    destroy=extend_schema(
        summary='Delete currently authorized user',
        responses={
            204: OpenApiResponse(description='Deleted'),
            400: OpenApiResponse(description='Car wash employee cannot be deleted'),
            403: OpenApiResponse(description='Forbidden'),
        },
        tags=['Accounts'],
    ),
    me=extend_schema(
        summary='Get current user profile',
        description='Return the currently authenticated user\'s profile.',
        responses={
            200: UserSerializer,
            401: OpenApiResponse(description='Unauthorized')
        },
        tags=['Accounts'],
    ),
)

SwaggerLoginDocs = extend_schema(
    summary='Log in for Swagger UI',
    description=(
        'Authenticate using phone and password via allauth proxy. '
        'On success, sets authentication cookies in the response for subsequent authorized requests in Swagger UI.'
    ),
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
    responses={200: {'description': 'Login successful'}, 400: OpenApiResponse(description='Bad request'), 403: OpenApiResponse(description='Forbidden')},
    tags=['Authentication']
)
