import requests

from AstSmartTime import settings


def send_message(phone, message):
    phone = phone.split('+')[1]
    response = requests.get(f'http://kazinfoteh.org:9507/api?action=sendmessage&username={settings.SMS_LOGIN}&password={settings.SMS_PASSWORD}&recipient={phone}&messagetype=SMS:TEXT&originator=TEXT_MSG&messagedata=Code - {str(message)}')
    return response.text
