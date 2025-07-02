python manage.py makemigrations --no-input
python manage.py migrate --no-input
#python manage.py run_import
python manage.py collectstatic --no-input --clear
#cp -r /app/collected_static/. /backend_static/static/
gunicorn AstSmartTime.wsgi:application --bind 0:8000