from django.utils.translation import gettext_lazy as _

TYPE_AUTO = [
    (_('Sedan'), _('Sedan')),
    (_('Jeep'), _('Jeep')),
    (_('Minivan'), _('Minivan')),
    (_('Crossover'), _('Crossover')),
    (_('Minibus'), _('Minibus')),
]

ROLE = [
    (_('light_client'), _('light_client')),
    (_('client'), _('client')),
    (_('light_partner'), _('light_partner')),
    (_('partner'), _('partner')),
    (_('light_manager'), _('light_manager')),
    (_('manager'), _('manager')),
]

RATING = [
    (_('1'), _('1')),
    (_('2'), _('2')),
    (_('3'), _('3')),
    (_('4'), _('4')),
    (_('5'), _('5')),
]

STATUS_ORDER = [
    (_('Free'), _('Free')),
    (_('Reserve'), _('Reserve')),
    (_('On site'), _('On site')),
    (_('In progress'), _('In progress')),
    (_('Done'), _('Done')),
    (_('Canceled'), _('Canceled')),
]

STATUS_PAYMENT = [
    (_('Pending'), _('Pending')),
    (_('Created'), _('Created')),
    (_('Sent'), _('Sent')),
    (_('InProgress'), _('InProgress')),
    (_('Fulfilled'), _('Fulfilled')),
    (_('Timeout'), _('Timeout')),
    (_('Reject'), _('Reject')),
    (_('Canceled'), _('Canceled')),
]

MESSENGERS = [
    (_('Telegram'), _('Telegram')),
    (_('WhatsApp'), _('WhatsApp')),
]
