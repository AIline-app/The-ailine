# Safely expose Celery app for Django project without hard dependency during runtime
try:
    from .celery import app as celery_app  # noqa: F401
    __all__ = ('celery_app',)
except Exception:
    # Allow running Django without Celery installed or configured
    celery_app = None
    __all__ = ()
