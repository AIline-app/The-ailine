from drf_spectacular.utils import extend_schema, extend_schema_view, OpenApiResponse

from api.accounts.serializers import UserSerializer
from api.manager.serializers import ManagerWriteSerializer, WasherWriteSerializer


ManagerViewSetDocs = extend_schema_view(
    list=extend_schema(
        summary="List managers",
        description="List managers assigned to the car wash in route.",
        responses={200: UserSerializer},
        tags=["Managers"],
    ),
    retrieve=extend_schema(
        summary="Retrieve a manager",
        responses={200: UserSerializer, 404: OpenApiResponse(description="Not found")},
        tags=["Managers"],
    ),
    create=extend_schema(
        summary="Add a manager to car wash",
        request=ManagerWriteSerializer,
        responses={201: UserSerializer, 400: OpenApiResponse(description="Validation error")},
        tags=["Managers"],
    ),
    update=extend_schema(
        summary="Update a manager",
        request=ManagerWriteSerializer,
        responses={200: UserSerializer},
        tags=["Managers"],
    ),
    partial_update=extend_schema(
        summary="Partially update a manager",
        request=ManagerWriteSerializer,
        responses={200: UserSerializer},
        tags=["Managers"],
    ),
    destroy=extend_schema(
        summary="Remove a manager from car wash",
        responses={204: OpenApiResponse(description="Removed")},
        tags=["Managers"],
    ),
)


WasherViewSetDocs = extend_schema_view(
    list=extend_schema(
        summary="List washers",
        description="List washers assigned to the car wash in route.",
        responses={200: UserSerializer},
        tags=["Washers"],
    ),
    retrieve=extend_schema(
        summary="Retrieve a washer",
        responses={200: UserSerializer, 404: OpenApiResponse(description="Not found")},
        tags=["Washers"],
    ),
    create=extend_schema(
        summary="Add a washer to car wash",
        request=WasherWriteSerializer,
        responses={201: UserSerializer, 400: OpenApiResponse(description="Validation error")},
        tags=["Washers"],
    ),
    update=extend_schema(
        summary="Update a washer",
        request=WasherWriteSerializer,
        responses={200: UserSerializer},
        tags=["Washers"],
    ),
    partial_update=extend_schema(
        summary="Partially update a washer",
        request=WasherWriteSerializer,
        responses={200: UserSerializer},
        tags=["Washers"],
    ),
    destroy=extend_schema(
        summary="Remove a washer from car wash",
        responses={204: OpenApiResponse(description="Removed")},
        tags=["Washers"],
    ),
)
