# syntax=docker/dockerfile:1.6

# --- Base stage: use slim image and install build deps only where needed
FROM python:3.12-slim AS base
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PATH="/home/appuser/.local/bin:${PATH}"

# System dependencies (runtime)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       curl \
       libpq5 \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -ms /bin/bash appuser
WORKDIR /app

# --- Build stage: install build deps and wheels
FROM base AS builder
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       build-essential \
       libpq-dev \
    && rm -rf /var/lib/apt/lists/*
COPY requirements.txt /tmp/requirements.txt
RUN python -m pip install --upgrade pip \
    && pip wheel --wheel-dir /wheels -r /tmp/requirements.txt

# --- Final stage
FROM base AS final
# Copy wheels from builder and install
COPY --from=builder /wheels /wheels
RUN pip install /wheels/*

# Copy project
COPY . /app

# Permissions
RUN chown -R appuser:appuser /app
#USER appuser  # TODO enable in PROD

EXPOSE 8000

# Copy entrypoint
COPY --chown=appuser:appuser entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Default environment
ENV DJANGO_SETTINGS_MODULE=iLine.settings

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD curl -fsS http://127.0.0.1:8000/healthz/ || exit 1

ENTRYPOINT ["/entrypoint.sh"]
CMD ["gunicorn", "iLine.wsgi:application", "-c", "/app/gunicorn.conf.py"]
