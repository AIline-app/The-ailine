import os

import django
from django.core.management.base import BaseCommand
from telegram import ReplyKeyboardMarkup, ReplyKeyboardRemove, KeyboardButton
from telegram.ext import CommandHandler, ConversationHandler, MessageHandler, Filters
from telegram.ext import Updater
from AstSmartTime.settings import env
from app_users.models import User

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'AstSmartTime.settings')
django.setup()

TOKEN = env.str('TELEGRAM_TOKEN', None)
GENERAL_URL = 'https://i-line.kz'
GET_ID = 1
GET_PHONE = 2


def start(update, _):
    reply_keyboard = [['Зарегистрироваться']]
    markup_key = ReplyKeyboardMarkup(reply_keyboard, one_time_keyboard=True)
    update.message.reply_text(
        'Добро пожаловать в бот i-line.kz. Вы здесь для регистрации!',
        reply_markup=markup_key,
    )

    return GET_ID


def get_id_telegram_user(update, _):
    button = KeyboardButton(
        text='Подтвердите номер',
        request_contact=True
    )
    reply_keyboard = [[button]]
    keyboard = ReplyKeyboardMarkup(reply_keyboard, one_time_keyboard=True)
    update.message.reply_text(
        'Для регистрации требуется Ваш номер телефона',
        reply_markup=keyboard
    )

    return GET_PHONE


def contact_callback(update, _):
    contact = update.effective_message.contact
    phone = contact.phone_number

    try:
        phone_nuber = f'+{phone}'
        user = User.objects.get(phone=phone_nuber.replace(' ', ''))
        user.chat_id_telegram = update.effective_chat.id
        user.save()

        update.message.reply_text(
            'Регистрация выполнена!'
        )
    except Exception:
        update.message.reply_text(
            'Вы не найдены в системе i-line.kz'
        )
        raise ValueError(f'User try register with number {phone}. User not found.')

    return ConversationHandler.END


def cancel(update, _):
    update.message.reply_text(
        'Отказ от регистрации. Хорошего дня!',
        reply_markup=ReplyKeyboardRemove()
    )
    return ConversationHandler.END


def get_command_from_user():
    return ConversationHandler(
        entry_points=[CommandHandler('start', start)],
        states={
            GET_ID: [
                MessageHandler(Filters.regex('^(Зарегистрироваться)$'), get_id_telegram_user)
            ],
            GET_PHONE: [
                MessageHandler(Filters.contact, contact_callback)
            ]
        },
        fallbacks=[CommandHandler('cancel', cancel)],
    )


class Command(BaseCommand):
    help = 'Запуск телеграм бота.'

    def handle(self, *args, **options):
        updater = Updater(token=TOKEN)
        dispatcher = updater.dispatcher

        dispatcher.add_handler(get_command_from_user())

        updater.start_polling(timeout=5, drop_pending_updates=True)
        updater.idle()
