import os, sys, django
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_one
import pytz

# Get latest entry
entry = fetch_one("""
    SELECT entry_time FROM labour_entries 
    ORDER BY entry_time DESC LIMIT 1
""")

if entry:
    entry_time = entry['entry_time']
    print(f"Raw from DB: {entry_time}")
    print(f"Type: {type(entry_time)}")
    print(f"Has timezone: {entry_time.tzinfo}")
    
    if entry_time.tzinfo:
        ist = pytz.timezone('Asia/Kolkata')
        ist_time = entry_time.astimezone(ist)
        print(f"Converted to IST: {ist_time}")
        print(f"ISO format: {ist_time.isoformat()}")
    else:
        print("ERROR: No timezone info!")
