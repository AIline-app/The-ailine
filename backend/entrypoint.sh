#!/bin/sh

# Миграции
python manage.py makemigrations --no-input
python manage.py migrate --no-input

# Сборка статики
python manage.py collectstatic --no-input --clear

# Копирование статики (с проверкой)
echo "Copying static files..."
mkdir -p /var/html/static/
[ -d "/app/collected_static" ] && cp -rv /app/collected_static/. /var/html/static/
chmod -R 755 /var/html/static/
ls -la /var/html/static/ > /var/html/static_copy.log  # Логируем результат

# Запуск сервера
gunicorn AstSmartTime.wsgi:application --bind 0:8000