from celery import Celery
import os

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'klinik_universitas.settings')

app = Celery('klinik_universitas')
app.config_from_object('django.conf:settings', namespace='CELERY')
app.autodiscover_tasks()