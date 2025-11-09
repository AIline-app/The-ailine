# Minimal standalone image for the SMS worker
FROM python:3.12-slim

# Prevent Python from writing .pyc files and buffering stdout
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install runtime dependencies from requirements file
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# Create workdir and copy worker code
WORKDIR /app
COPY worker.py /app/worker.py
COPY .env /app/.env

# Default environment (can be overridden by compose)
ENV KAFKA_BROKER=localhost:9092 \
    KAFKA_REGISTER_TOPIC=register-sms

CMD ["python", "worker.py"]
