import os, sys, django
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()
from api.database import fetch_all

# Check material_bills table
try:
    rows = fetch_all("SELECT id, file_url, site_id, created_at FROM material_bills ORDER BY created_at DESC LIMIT 5")
    print("=== material_bills ===")
    for r in rows:
        print(f"  file_url: [{r['file_url']}]")
except Exception as e:
    print(f"material_bills error: {e}")

# Check bills table
try:
    rows = fetch_all("SELECT id, bill_url, vendor_name, created_at FROM bills ORDER BY created_at DESC LIMIT 5")
    print("=== bills ===")
    for r in rows:
        print(f"  bill_url: [{r['bill_url']}]")
except Exception as e:
    print(f"bills error: {e}")
