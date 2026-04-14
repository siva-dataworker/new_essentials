import os, sys, django
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.time_utils import get_ist_now
from datetime import datetime
import pytz

ist = pytz.timezone('Asia/Kolkata')
now_ist = get_ist_now()

print(f"IST Time from time_utils: {now_ist.strftime('%Y-%m-%d %H:%M:%S')}")
print(f"Hour: {now_ist.hour}")
print(f"Expected: Around 12:xx PM (not 6:xx AM)")
