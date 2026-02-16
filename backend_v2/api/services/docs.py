from drf_spectacular.utils import extend_schema, extend_schema_view, OpenApiResponse

from api.services.serializers import ServicesWriteSerializer, ServicesReadSerializer


ServicesViewSetDocs = extend_schema_view(
    list=extend_schema(
        summary='List services',
        description='List services available for the car wash in route.',
        responses={200: ServicesReadSerializer},
        tags=['Services'],
    ),
    retrieve=extend_schema(
        summary='Retrieve a service',
        responses={200: ServicesReadSerializer, 404: OpenApiResponse(description='Not found')},
        tags=['Services'],
    ),
    create=extend_schema(
        summary='Create a service',
        request=ServicesWriteSerializer,
        responses={201: ServicesReadSerializer, 400: OpenApiResponse(description='Validation error')},
        tags=['Services'],
    ),
    update=extend_schema(
        summary='Update a service',
        request=ServicesWriteSerializer,
        responses={200: ServicesReadSerializer},
        tags=['Services'],
    ),
    partial_update=extend_schema(
        summary='Partially update a service',
        request=ServicesWriteSerializer,
        responses={200: ServicesReadSerializer},
        tags=['Services'],
    ),
    destroy=extend_schema(
        summary='Delete a service',
        responses={204: OpenApiResponse(description='Deleted')},
        tags=['Services'],
    ),
)
