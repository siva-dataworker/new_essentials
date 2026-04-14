"""
Test the fixed mismatch detection
"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all
from datetime import datetime, timedelta

# Calculate date range
end_date = datetime.now().date()
start_date = end_date - timedelta(days=7)

print("=" * 80)
print("SUPERVISOR ENTRIES (submitted_by_role = 'Supervisor')")
print("=" * 80)
supervisor_entries = fetch_all("""
    SELECT 
        l.id,
        l.site_id,
        l.entry_date,
        l.labour_type,
        l.labour_count,
        u.full_name as supervisor_name,
        l.submitted_by_role
    FROM labour_entries l
    JOIN sites s ON l.site_id = s.id
    JOIN users u ON l.supervisor_id = u.id
    WHERE l.entry_date >= %s AND l.entry_date <= %s
    AND l.submitted_by_role = 'Supervisor'
    ORDER BY l.entry_date DESC, l.labour_type
""", (start_date, end_date))

for entry in supervisor_entries:
    print(f"Date: {entry['entry_date']}, Type: {entry['labour_type']}, "
          f"Count: {entry['labour_count']}, Name: {entry['supervisor_name']}, Role: {entry['submitted_by_role']}")

print("\n" + "=" * 80)
print("SITE ENGINEER ENTRIES (submitted_by_role = 'Site Engineer')")
print("=" * 80)
engineer_entries = fetch_all("""
    SELECT 
        l.id,
        l.site_id,
        l.entry_date,
        l.labour_type,
        l.labour_count,
        u.full_name as engineer_name,
        l.submitted_by_role
    FROM labour_entries l
    JOIN sites s ON l.site_id = s.id
    JOIN users u ON l.supervisor_id = u.id
    WHERE l.entry_date >= %s AND l.entry_date <= %s
    AND l.submitted_by_role = 'Site Engineer'
    ORDER BY l.entry_date DESC, l.labour_type
""", (start_date, end_date))

for entry in engineer_entries:
    print(f"Date: {entry['entry_date']}, Type: {entry['labour_type']}, "
          f"Count: {entry['labour_count']}, Name: {entry['engineer_name']}, Role: {entry['submitted_by_role']}")

print("\n" + "=" * 80)
print("MISMATCH DETECTION")
print("=" * 80)

# Group entries by site_id, date, and labour_type
supervisor_map = {}
for entry in supervisor_entries:
    key = f"{entry['site_id']}_{entry['entry_date']}_{entry['labour_type']}"
    supervisor_map[key] = entry

engineer_map = {}
for entry in engineer_entries:
    key = f"{entry['site_id']}_{entry['entry_date']}_{entry['labour_type']}"
    engineer_map[key] = entry

# Find mismatches
all_keys = set(supervisor_map.keys()) | set(engineer_map.keys())
mismatches = []

for key in all_keys:
    supervisor_entry = supervisor_map.get(key)
    engineer_entry = engineer_map.get(key)
    
    site_id_key, date_str, labour_type = key.split('_', 2)
    
    # Case 1: Entry exists in both but counts don't match
    if supervisor_entry and engineer_entry:
        if supervisor_entry['labour_count'] != engineer_entry['labour_count']:
            print(f"✗ COUNT MISMATCH: {labour_type} on {date_str}")
            print(f"  Supervisor ({supervisor_entry['supervisor_name']}): {supervisor_entry['labour_count']} workers")
            print(f"  Site Engineer ({engineer_entry['engineer_name']}): {engineer_entry['labour_count']} workers")
            mismatches.append(key)
    
    # Case 2: Entry only in Supervisor
    elif supervisor_entry and not engineer_entry:
        print(f"✗ MISSING SITE ENGINEER ENTRY: {labour_type} on {date_str}")
        print(f"  Supervisor ({supervisor_entry['supervisor_name']}): {supervisor_entry['labour_count']} workers")
        print(f"  Site Engineer: No entry")
        mismatches.append(key)
    
    # Case 3: Entry only in Site Engineer
    elif engineer_entry and not supervisor_entry:
        print(f"✗ MISSING SUPERVISOR ENTRY: {labour_type} on {date_str}")
        print(f"  Supervisor: No entry")
        print(f"  Site Engineer ({engineer_entry['engineer_name']}): {engineer_entry['labour_count']} workers")
        mismatches.append(key)

print(f"\nTotal mismatches found: {len(mismatches)}")
