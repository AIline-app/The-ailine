import asyncio
import json
import logging
import os
from dotenv_vault import load_dotenv

import aiohttp
from aiokafka import AIOKafkaConsumer

load_dotenv()

KAFKA_BOOTSTRAP_SERVERS = os.getenv("KAFKA_BOOTSTRAP_SERVERS")
KAFKA_SMS_TOPIC = os.getenv("KAFKA_SMS_TOPIC")
SMS_LOGIN = os.getenv("SMS_LOGIN")
SMS_PASSWORD = os.getenv("SMS_PASSWORD")

# Environment flags and tokens
DEBUG = bool(os.getenv("DEBUG", 0))
BOT_ID = os.getenv("BOT_ID")
CHAT_ID = os.getenv("CHAT_ID")
THREAD_ID = os.getenv("THREAD_ID")

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


async def send_telegram(session: aiohttp.ClientSession, message: str) -> bool:
    logger.debug(message)

    if not BOT_ID or not CHAT_ID:
        return False

    url = f"https://api.telegram.org/bot{BOT_ID}/sendMessage"
    try:
        body = {"chat_id": CHAT_ID, "text": message}
        if THREAD_ID:
            body["message_thread_id"] = THREAD_ID
        async with session.post(url, json=body, headers={"Content-Type": "application/json"}, timeout=aiohttp.ClientTimeout(total=10)) as resp:
            if resp.status != 200:
                text = await resp.text()
                logger.warning(f'Telegram send failed: {resp.status} {text[:200]}')
            return resp.status == 200
    except Exception as e:
        logger.exception(f'Telegram send exception: {e}')
        return False


async def send_sms(session: aiohttp.ClientSession, phone: str, message: str) -> bool:
    phone = phone.lstrip('+')
    if DEBUG:
        # In non‑production, do not send real SMS: log and forward to Telegram
        msg = f"DEBUG MODE: SMS to {phone}: message {message}"
        return await send_telegram(session, msg)

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
        async with session.get(url, timeout=aiohttp.ClientTimeout(total=10)) as resp:
            text = await resp.text()
            logger.info("SMS provider response: %s %s", resp.status, text[:200])
            return 200 <= resp.status < 300
    except Exception as e:
        logger.exception("Failed to send SMS: %s", e)
        return False


async def consume_loop():
    backoff = 1
    while True:
        consumer = AIOKafkaConsumer(
            KAFKA_SMS_TOPIC,
            bootstrap_servers=KAFKA_BOOTSTRAP_SERVERS,
            value_deserializer=lambda m: json.loads(m.decode('utf-8')),
            enable_auto_commit=False,  # manual commit
            auto_offset_reset='earliest',
            group_id='sms-worker-group',
        )
        try:
            await consumer.start()
            logger.info(f'Connected to Kafka at {KAFKA_BOOTSTRAP_SERVERS}, listening topic {KAFKA_SMS_TOPIC}')
            async with aiohttp.ClientSession() as session:
                async for msg in consumer:
                    payload = msg.value or {}
                    phone = payload.get('phone')
                    message = payload.get('message')
                    if not phone or not message:
                        logger.warning(f'Invalid message payload: {payload}')
                        # Commit to skip invalid message
                        try:
                            await consumer.commit()
                        except Exception:
                            logger.exception('Commit failed for invalid message')
                        continue

                    # Retry sending up to 3 times (non-blocking)
                    attempts = 0
                    ok = False
                    delay = 1.0
                    while attempts < 3 and not ok:
                        attempts += 1
                        ok = await send_sms(session, str(phone), str(message))
                        if not ok and attempts < 3:
                            logger.warning(f'SMS send failed for {phone}, attempt {attempts}/3. Retrying in {delay:.1f}s')
                            await asyncio.sleep(delay)
                            delay = min(delay * 2, 10)

                    if ok:
                        logger.info(f'SMS sent to {phone}')
                    else:
                        logger.error(f'SMS failed for {phone} after {attempts} attempts; committing offset to skip')

                    # Commit on success OR after 3 retries
                    try:
                        await consumer.commit()
                    except Exception:
                        logger.exception('Commit failed after processing message')
        except Exception:
            logger.exception(f'Kafka consumer error. Reconnecting in {backoff}s')
            await asyncio.sleep(backoff)
            backoff = min(backoff * 2, 60)
        finally:
            try:
                await consumer.stop()
            except Exception:
                # Ignore errors on stop
                pass


def main():
    asyncio.run(consume_loop())


if __name__ == "__main__":
    main()
