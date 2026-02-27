from django.contrib.sessions.models import Session
from django.utils.functional import SimpleLazyObject
from django.utils import timezone


def get_user_from_session_token(request):
    """
    Extract user from session token provided in headers
    """
    from django.contrib.auth.models import AnonymousUser
    from django.contrib.auth import get_user_model

    User = get_user_model()

    # Check for session token in X-Session-Token header
    session_token = request.headers.get('X-Session-Token')

    if not session_token:
        return AnonymousUser()

    try:
        # Get the session object
        session = Session.objects.get(session_key=session_token)

        # Check if session is expired
        if session.expire_date < timezone.now():
            return AnonymousUser()

        # Decode session data
        session_data = session.get_decoded()

        # Try to get user_id from Django's standard auth first
        user_id = session_data.get('_auth_user_id')

        if user_id:
            user = User.objects.get(pk=user_id)
            return user
    except (Session.DoesNotExist, User.DoesNotExist, KeyError):
        pass

    return AnonymousUser()


class SessionTokenMiddleware:
    """
    Middleware to authenticate users via session token in X-Session-Token header
    """

    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        # Only process if user is not already authenticated and session token is present
        if not hasattr(request, 'user') or not request.user.is_authenticated:
            session_token = request.headers.get('X-Session-Token')

            if session_token:
                # Set the session key from header
                request.session = request.session.__class__(session_token)

                # Override the user with a lazy object that loads from session token
                request.user = SimpleLazyObject(lambda: get_user_from_session_token(request))

        response = self.get_response(request)
        return response
