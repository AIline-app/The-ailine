import uuid

from django.contrib.postgres.fields import ArrayField
from django.utils.translation import gettext_lazy as _
from django.db import models


class Campaign(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(_('Campaign name'), max_length=255, unique=True)
    sources = ArrayField(models.CharField(max_length=31, blank=False, null=False), default=list, null=False)
    medium = models.CharField(max_length=31, blank=False, null=False)
    is_active = models.BooleanField(_('Is active'), default=True)

    def __str__(self):
        return f'<Campaign ({self.name})>'
