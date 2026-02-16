import json
import logging
import os
import time
from dotenv import load_dotenv

from kafka import KafkaConsumer
import requests


load_dotenv()

KAFKA_BOOTSTRAP_SERVERS = os.getenv("KAFKA_BOOTSTRAP_SERVERS")
KAFKA_SMS_TOPIC = os.getenv("KAFKA_SMS_TOPIC")
SMS_LOGIN = os.getenv("SMS_LOGIN")
SMS_PASSWORD = os.getenv("SMS_PASSWORD")

# Environment flags and tokens
DEBUG = bool(os.getenv("DEBUG", 0))
BOT_ID = os.getenv("BOT_ID")
CHAT_ID = os.getenv("CHAT_ID")

# Get log level from environment
LOG_LEVEL = os.environ.get('LOG_LEVEL', 'INFO').upper()

# Configure root logger
logging.basicConfig(
    level=logging.WARNING,  # Set root to WARNING
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

# Suppress Kafka debug messages
logging.getLogger('kafka').setLevel(logging.ERROR)

# Your application logger
logger = logging.getLogger('sms_worker')
logger.setLevel(getattr(logging, LOG_LEVEL))

logger.info("SMS Worker started successfully")

def send_telegram(message: str) -> bool:
    logger.debug(message)

    if not BOT_ID or not CHAT_ID:
        return False

    url = f"https://api.telegram.org/bot{BOT_ID}/sendMessage"
    try:
        resp = requests.post(url, json={"chat_id": CHAT_ID, "text": message}, headers={"Content-Type": "application/json"}, timeout=10)
        if not resp.ok:
            logger.warning(f'Telegram send failed: {resp.status_code} {resp.text[:200]}')
        return resp.ok
    except Exception as e:
        logger.exception(f'Telegram send exception: {e}')
        return False


def send_sms(phone: str, message: str) -> bool:
    phone = phone.lstrip('+')
    if DEBUG:
        # In non‑production, do not send real SMS: log and forward to Telegram
        msg = f"DEBUG MODE: SMS to {phone}: message {message}"
        return send_telegram(msg)

    # Production: send real SMS via provider
    url = (
        "http://kazinfoteh.org:9507/api?action=sendmessage"
        f"&username={SMS_LOGIN}"
        f"&password={SMS_PASSWORD}"
        f"&recipient={phone}"
        "&messagetype=SMS:TEXT&originator=TEXT_MSG"
        f"&messagedata={message}"
    )
    try:
        # The real provider might require GET
        resp = requests.get(url, timeout=10)
        logger.info("SMS provider response: %s %s", resp.status_code, resp.text[:200])
        return resp.ok
    except Exception as e:
        logger.exception("Failed to send SMS: %s", e)
        return False


def main():
    backoff = 1
    while True:
        try:
            consumer = KafkaConsumer(
                KAFKA_SMS_TOPIC,
                bootstrap_servers=KAFKA_BOOTSTRAP_SERVERS,
                value_deserializer=lambda m: json.loads(m.decode('utf-8')),
                enable_auto_commit=True,
                auto_offset_reset='earliest',
                group_id='sms-worker-group',
            )
            logger.info(f'Connected to Kafka at {KAFKA_BOOTSTRAP_SERVERS}, listening topic {KAFKA_SMS_TOPIC}')
            for msg in consumer:
                payload = msg.value or {}
                phone = payload.get('phone')
                message = payload.get('message')
                if not phone or not message:
                    logger.warning(f'Invalid message payload: {payload}')
                    continue
                ok = send_sms(phone, str(message))
                if ok:
                    logger.info(f'SMS sent to {phone}')
                else:
                    logger.error(f'SMS failed for {phone}')
            # If loop ends, recreate
        except Exception:
            logger.exception(f'Kafka consumer error. Reconnecting in {backoff}')
            time.sleep(backoff)
            backoff = min(backoff * 2, 60)


if __name__ == "__main__":
    main()
