import multiprocessing
import os

# Basic network binding is provided via docker run/compose port mapping
bind = os.getenv("GUNICORN_BIND", "0.0.0.0:8000")

# Workers: prefer WEB_CONCURRENCY, else CPU*2+1
workers = int(os.getenv("WEB_CONCURRENCY", multiprocessing.cpu_count() * 2 + 1))
threads = int(os.getenv("GUNICORN_THREADS", "1"))
worker_class = os.getenv("GUNICORN_WORKER_CLASS", "gthread" if threads > 1 else "sync")

timeout = int(os.getenv("GUNICORN_TIMEOUT", "60"))
graceful_timeout = int(os.getenv("GUNICORN_GRACEFUL_TIMEOUT", "30"))
keepalive = int(os.getenv("GUNICORN_KEEPALIVE", "5"))
max_requests = int(os.getenv("GUNICORN_MAX_REQUESTS", "0"))
max_requests_jitter = int(os.getenv("GUNICORN_MAX_REQUESTS_JITTER", "0"))

# Logging
accesslog = os.getenv("GUNICORN_ACCESSLOG", "-")
errorlog = os.getenv("GUNICORN_ERRORLOG", "-")
loglevel = os.getenv("GUNICORN_LOG_LEVEL", os.getenv("DJANGO_LOG_LEVEL", "info")).lower()
