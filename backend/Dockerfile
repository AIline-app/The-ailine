FROM python:3.11-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       build-essential \
       libpq-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# 6. Собираем статические файлы (для Swagger UI и статики)
RUN python manage.py collectstatic --noinput

EXPOSE 8000

CMD ["gunicorn", "AstSmartTime.wsgi:application", "--bind", "0.0.0.0:8000", "--workers", "3", "--log-level", "info"]
