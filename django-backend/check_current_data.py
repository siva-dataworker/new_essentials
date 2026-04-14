"""
Check current data in database
"""
import os
import sys
import django

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all
from datetime import datetime
import pytz

ist = pytz.timezone('Asia/Kolkata')
now_ist = datetime.now(ist)

print(f"Current IST Time: {now_ist.strftime('%Y-%m-%d %H:%M:%S')}")
print(f"Current Hour: {now_ist.hour}")
print("\n" + "="*60)

# Check all entries
entries = fetch_all("""
    SELECT 
        l.id,
        l.labour_type,
        l.labour_count,
        l.entry_time,
        l.site_id,
        s.site_name,
        s.customer_name,
        u.full_name as supervisor_name
    FROM labour_entries l
    JOIN sites s ON l.site_id = s.id
    JOIN users u ON l.supervisor_id = u.id
    ORDER BY l.entry_time DESC
""")

print(f"Total entries: {len(entries)}\n")

for entry in entries:
    print(f"Site: {entry['customer_name']} {entry['site_name']}")
    print(f"  site_id: {entry['site_id']}")
    print(f"  Type: {entry['labour_type']}")
    print(f"  Count: {entry['labour_count']}")
    print(f"  Time: {entry['entry_time']}")
    print(f"  Supervisor: {entry['supervisor_name']}")
    print()
