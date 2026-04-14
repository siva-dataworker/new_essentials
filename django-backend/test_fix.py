import os, sys, django
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_one
import pytz

entry = fetch_one("SELECT entry_time FROM labour_entries ORDER BY entry_time DESC LIMIT 1")

if entry:
    entry_time = entry['entry_time']
    print(f"UTC from DB: {entry_time}")
    
    # Fix: localize as UTC first, then convert to IST
    ist_time = pytz.utc.localize(entry_time).astimezone(pytz.timezone('Asia/Kolkata'))
    print(f"IST converted: {ist_time}")
    print(f"ISO format: {ist_time.isoformat()}")
    print(f"Time only: {ist_time.strftime('%I:%M %p')}")
