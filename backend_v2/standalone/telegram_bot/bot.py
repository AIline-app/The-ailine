import os
import sys
import logging
import asyncio
import uuid
from typing import Final, Iterable, Tuple, Optional

# Configure logging early
LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO").upper()
logging.basicConfig(
    level=LOG_LEVEL,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
)
logger = logging.getLogger("telegram_bot")

try:
    # Use python-telegram-bot v21+ (asyncio based)
    from telegram import Update
    from telegram import ReplyKeyboardMarkup, KeyboardButton
    from telegram.ext import Application, CommandHandler, MessageHandler, ContextTypes, filters
except Exception:
    raise

# --- Django setup (required to access ORM from this standalone bot) ---
# Ensure project root is on sys.path
CURRENT_DIR = os.path.dirname(__file__)
PROJECT_ROOT = os.path.abspath(os.path.join(CURRENT_DIR, os.pardir, os.pardir))  # backend_v2
if PROJECT_ROOT not in sys.path:
    sys.path.insert(0, PROJECT_ROOT)

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "iLine.settings")
try:
    import django  # type: ignore
    django.setup()  # Initialize Django
    from car_wash.models.car_wash import CarWash, CarWashDocuments  # ORM models
except Exception as e:
    logger.exception("Failed to initialize Django for telegram bot: %s", e)
    raise

BOT_TOKEN_ENV: Final[str] = "TELEGRAM_BOT_TOKEN"
POLL_INTERVAL: Final[float] = float(os.getenv("TELEGRAM_POLL_INTERVAL", "1.0"))
WHITELIST_ENV: Final[str] = "TELEGRAM_WHITELIST"
DEFAULT_PAGE_SIZE: Final[int] = int(os.getenv("CARWASH_BOT_PAGE_SIZE", "10"))
MAX_PAGE_SIZE: Final[int] = int(os.getenv("CARWASH_BOT_MAX_PAGE_SIZE", "50"))

# --- Authorization helpers ---

def _parse_whitelist(env_val: Optional[str]) -> Tuple[set[int], set[str]]:
    ids: set[int] = set()
    usernames: set[str] = set()
    if not env_val:
        return ids, usernames
    for raw in env_val.split(","):
        item = raw.strip()
        if not item:
            continue
        if item.startswith("@"):
            usernames.add(item[1:].lower())
        elif item.isdigit():
            try:
                ids.add(int(item))
            except ValueError:
                pass
        else:
            usernames.add(item.lower())
    return ids, usernames

WHITELIST_IDS, WHITELIST_USERNAMES = _parse_whitelist(os.getenv(WHITELIST_ENV, ""))


def _is_authorized(update: Update) -> bool:
    user = update.effective_user
    if not user:
        return False
    uid_ok = user.id in WHITELIST_IDS if hasattr(user, "id") else False
    uname_ok = False
    if user.username:
        uname_ok = user.username.lower() in WHITELIST_USERNAMES
    return uid_ok or uname_ok


async def _ensure_auth(update: Update) -> bool:
    if _is_authorized(update):
        return True
    if update.message:
        await update.message.reply_text("Access denied. You are not permitted to use this bot.")
    return False


# --- Utility functions (DB access; executed in threads to avoid blocking) ---

def _list_unverified(page: int, page_size: int) -> Tuple[list[dict], int, int]:
    qs = CarWash.objects.filter(is_active=False).order_by("created_at")
    total = qs.count()
    start = (page - 1) * page_size
    end = start + page_size
    items = [
        {
            "id": str(cw.id),
            "name": cw.name,
            "address": cw.address,
            "created_at": cw.created_at.isoformat() if cw.created_at else "",
        }
        for cw in qs[start:end]
    ]
    pages = (total + page_size - 1) // page_size if page_size else 1
    return items, total, pages


def _get_carwash_info(cw_id: uuid.UUID) -> Optional[str]:
    try:
        cw = CarWash.objects.select_related("documents", "owner").get(id=cw_id)
    except CarWash.DoesNotExist:
        return None
    docs = getattr(cw, "documents", None)
    parts = [
        f"CarWash: {cw.name}",
        f"ID: {cw.id}",
        f"Address: {cw.address}",
        f"Is Active: {cw.is_active}",
    ]
    if docs:
        parts.append("Documents:")
        parts.append(f"  IIN: {getattr(docs, 'iin', '')}")
    else:
        parts.append("Documents: not uploaded")
    return "\n".join(parts)


def _verify_carwash(cw_id: uuid.UUID) -> bool:
    updated = CarWash.objects.filter(id=cw_id, is_active=False).update(is_active=True)
    return updated > 0


# --- Keyboards ---

def _kb_main() -> ReplyKeyboardMarkup:
    keyboard = [
        [KeyboardButton(text="/unverified 1")],
    ]
    return ReplyKeyboardMarkup(keyboard=keyboard, resize_keyboard=True)


def _kb_unverified(items: list[dict], page: int, pages: int, page_size: int) -> ReplyKeyboardMarkup:
    keyboard: list[list[KeyboardButton]] = []
    # For each item, add action buttons
    for item in items:
        cw_id = item["id"]
        row = [
            KeyboardButton(text=f"/carwash {cw_id}"),
            KeyboardButton(text=f"/verify {cw_id}"),
        ]
        keyboard.append(row)
    # Pagination controls
    nav_row: list[KeyboardButton] = []
    if page > 1:
        nav_row.append(KeyboardButton(text=f"/unverified {page-1} {page_size}"))
    if page < pages:
        nav_row.append(KeyboardButton(text=f"/unverified {page+1} {page_size}"))
    if nav_row:
        keyboard.append(nav_row)
    # Back to start
    keyboard.append([KeyboardButton(text="/start")])
    return ReplyKeyboardMarkup(keyboard=keyboard, resize_keyboard=True)


def _kb_carwash(cw_id: uuid.UUID) -> ReplyKeyboardMarkup:
    keyboard = [
        [KeyboardButton(text=f"/verify {cw_id}"), KeyboardButton(text=f"/deny {cw_id}")],
        [KeyboardButton(text="/unverified 1"), KeyboardButton(text="/start")],
    ]
    return ReplyKeyboardMarkup(keyboard=keyboard, resize_keyboard=True)


# --- Command handlers ---
async def start(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    if not await _ensure_auth(update):
        return
    user = update.effective_user
    name = user.first_name if user and user.first_name else "there"
    await update.message.reply_text(
        "Hello, {}!\nCommands:\n"
        "/unverified [page] [page_size] — list unverified car washes.\n"
        "/carwash <uuid> — show car wash info and documents.\n"
        "/verify <uuid> — verify car wash.\n"
        "/deny <uuid> — deny car wash (not implemented yet).".format(name),
        reply_markup=_kb_main(),
    )


async def unverified(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    if not await _ensure_auth(update):
        return
    # Parse args: /unverified [page] [page_size]
    args = context.args if hasattr(context, "args") else []
    try:
        page = int(args[0]) if len(args) >= 1 else 1
    except ValueError:
        page = 1
    try:
        page_size = int(args[1]) if len(args) >= 2 else DEFAULT_PAGE_SIZE
    except ValueError:
        page_size = DEFAULT_PAGE_SIZE
    page = max(1, page)
    page_size = max(1, min(page_size, MAX_PAGE_SIZE))

    items, total, pages = await asyncio.to_thread(_list_unverified, page, page_size)
    if not items:
        await update.message.reply_text("No unverified car washes found.")
        return
    lines = [f"Unverified CarWashes (page {page}/{pages}, total {total}):"]
    for idx, item in enumerate(items, start=1 + (page - 1) * page_size):
        lines.append(f"{idx}. {item['name']} — {item['id']}")
    lines.append("Use /carwash <id> to see details, /verify <id> to verify.")
    await update.message.reply_text("\n".join(lines))


async def carwash_info(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    if not await _ensure_auth(update):
        return
    args = context.args if hasattr(context, "args") else []
    if not args:
        await update.message.reply_text("Usage: /carwash <uuid>")
        return
    try:
        cw_uuid = uuid.UUID(args[0])
    except Exception:
        await update.message.reply_text("Invalid UUID format.")
        return
    info = await asyncio.to_thread(_get_carwash_info, cw_uuid)
    if not info:
        await update.message.reply_text("CarWash not found.")
        return
    await update.message.reply_text(info)


async def verify(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    if not await _ensure_auth(update):
        return
    args = context.args if hasattr(context, "args") else []
    if not args:
        await update.message.reply_text("Usage: /verify <uuid>")
        return
    try:
        cw_uuid = uuid.UUID(args[0])
    except Exception:
        await update.message.reply_text("Invalid UUID format.")
        return
    ok = await asyncio.to_thread(_verify_carwash, cw_uuid)
    if ok:
        await update.message.reply_text("CarWash verified (is_active=True).")
    else:
        await update.message.reply_text("Nothing changed. CarWash may not exist or already active.")


async def deny(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    if not await _ensure_auth(update):
        return
    args = context.args if hasattr(context, "args") else []
    if not args:
        await update.message.reply_text("Usage: /deny <uuid>")
        return
    await update.message.reply_text("Deny handling is not implemented yet.")


async def fallback(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    # Respond but keep minimal noise; also enforce auth
    if not await _ensure_auth(update):
        return
    if update.message and update.message.text:
        await update.message.reply_text("Unknown command. Send /start to see available commands.")


async def healthcheck() -> int:
    token = os.getenv(BOT_TOKEN_ENV)
    if not token:
        logger.error("%s is not set", BOT_TOKEN_ENV)
        return 1
    return 0


def main() -> None:
    token = os.getenv(BOT_TOKEN_ENV)
    if not token:
        raise RuntimeError(
            f"Environment variable {BOT_TOKEN_ENV} is required for the Telegram bot."
        )

    application = Application.builder().token(token).build()

    # Handlers
    application.add_handler(CommandHandler("start", start))
    application.add_handler(CommandHandler("unverified", unverified))
    application.add_handler(CommandHandler("carwash", carwash_info))
    application.add_handler(CommandHandler("verify", verify))
    application.add_handler(CommandHandler("deny", deny))
    application.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, fallback))

    logger.info("Starting Telegram bot polling ...")
    application.run_polling(poll_interval=POLL_INTERVAL)


if __name__ == "__main__":
    main()
