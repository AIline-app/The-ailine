# syntax=docker/dockerfile:1.6
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_DEFAULT_TIMEOUT=120 \
    PIP_RETRIES=5

# System runtime deps (psycopg2, certs)
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates libpq5 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Python deps from project requirements (includes Django and PTB)
COPY requirements.txt /tmp/requirements.txt
RUN python -m pip install --upgrade pip --timeout 120 --retries 5 \
    && pip install --no-cache-dir -r /tmp/requirements.txt --timeout 120 --retries 5

# Copy entire project so Django apps are available
COPY . /app

ENV LOG_LEVEL=INFO \
    DJANGO_SETTINGS_MODULE=iLine.settings

CMD ["python", "-m", "standalone.telegram_bot.bot"]
