#!/usr/bin/env bash
set -euo pipefail

# Default values
: "${DJANGO_SETTINGS_MODULE:=iLine.settings}"
: "${PYTHONUNBUFFERED:=1}"

# Wait for Postgres if variables present
if [ -n "${POSTGRES_HOST:-}" ]; then
  echo "Waiting for Postgres at ${POSTGRES_HOST}:${POSTGRES_PORT:-5432}..."
  until python - <<'PYCODE'
import os, socket, sys
host=os.getenv('POSTGRES_HOST','localhost')
port=int(os.getenv('POSTGRES_PORT','5432'))
s=socket.socket()
s.settimeout(2)
try:
    s.connect((host, port))
    sys.exit(0)
except Exception:
    sys.exit(1)
PYCODE
  do
    sleep 1
  done
fi

python manage.py migrate --noinput

# If DEBUG=1, use Django's development server for simplicity
#if [ "${DEBUG:-0}" = "1" ]; then
#  echo "DEBUG=1 detected: starting Django development server"
#  exec python manage.py runserver 0.0.0.0:8000
#fi

exec "$@"
