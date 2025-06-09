import os
import django
from django.apps import apps
from django.utils.encoding import force_bytes, smart_str

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'AstSmartTime.settings')
django.setup()

all_models = apps.get_models()

for model in all_models:
    for obj in model.objects.all():
        for field in obj._meta.fields:
            if field.get_internal_type() == 'CharField':
                setattr(obj, field.name, smart_str(force_bytes(getattr(obj, field.name), encoding='utf-8')))

        obj.save()
