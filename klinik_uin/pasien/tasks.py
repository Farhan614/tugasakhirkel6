from celery import shared_task
from dokter.models import Konsultasi

@shared_task
def cek_timer_konsultasi():
    konsultasi_aktif = Konsultasi.objects.filter(status='Direspons')
    for konsultasi in konsultasi_aktif:
        konsultasi.cek_timer()