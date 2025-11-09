from django.db.models import TextChoices
from django.utils.translation import gettext_lazy as _


class OrderStatus(TextChoices):
    EN_ROUTE = ('en_route', _('En Route'))
    ON_SITE = ('on_site', _('On Site'))
    # DELAYED = ('delayed', _('Delayed'))
    IN_PROGRESS = ('in_progress', _('In Progress'))
    CANCELED = ('canceled', _('Canceled'))
    COMPLETED = ('completed', _('Completed'))
