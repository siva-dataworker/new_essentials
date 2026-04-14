"""
Apply the submitted_by_role fix using role_id
"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import execute_query, fetch_all

print("=" * 80)
print("FIXING submitted_by_role FIELD")
print("=" * 80)

# Update entries to match the actual user role from roles table
result = execute_query("""
    UPDATE labour_entries l
    SET submitted_by_role = r.role_name
    FROM users u
    JOIN roles r ON u.role_id = r.id
    WHERE l.supervisor_id = u.id
    AND (l.submitted_by_role IS NULL OR l.submitted_by_role != r.role_name)
""")

print(f"✅ Updated labour entries to match user roles from roles table")

print("\n" + "=" * 80)
print("VERIFYING THE FIX")
print("=" * 80)

entries = fetch_all("""
    SELECT 
        l.id,
        l.entry_date,
        l.labour_type,
        l.labour_count,
        u.full_name,
        r.role_name as user_role,
        l.submitted_by_role
    FROM labour_entries l
    JOIN users u ON l.supervisor_id = u.id
    JOIN roles r ON u.role_id = r.id
    WHERE l.entry_date >= '2026-02-14'
    ORDER BY l.entry_date DESC, l.labour_type
""")

for entry in entries:
    match_status = "✅" if entry['user_role'] == entry['submitted_by_role'] else "❌"
    print(f"{match_status} Date: {entry['entry_date']}, Type: {entry['labour_type']}, "
          f"Count: {entry['labour_count']}, Name: {entry['full_name']}, "
          f"User Role: {entry['user_role']}, Submitted By: {entry['submitted_by_role']}")

print("\n" + "=" * 80)
print("NOW TESTING MISMATCH DETECTION")
print("=" * 80)

from datetime import datetime, timedelta

end_date = datetime.now().date()
start_date = end_date - timedelta(days=7)

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
    JOIN users u ON l.supervisor_id = u.id
    WHERE l.entry_date >= %s AND l.entry_date <= %s
    AND l.submitted_by_role = 'Supervisor'
    ORDER BY l.entry_date DESC, l.labour_type
""", (start_date, end_date))

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
    JOIN users u ON l.supervisor_id = u.id
    WHERE l.entry_date >= %s AND l.entry_date <= %s
    AND l.submitted_by_role = 'Site Engineer'
    ORDER BY l.entry_date DESC, l.labour_type
""", (start_date, end_date))

print(f"\nSupervisor entries: {len(supervisor_entries)}")
for entry in supervisor_entries:
    print(f"  - {entry['labour_type']}: {entry['labour_count']} workers by {entry['supervisor_name']}")

print(f"\nSite Engineer entries: {len(engineer_entries)}")
for entry in engineer_entries:
    print(f"  - {entry['labour_type']}: {entry['labour_count']} workers by {entry['engineer_name']}")

# Detect mismatches
supervisor_map = {}
for entry in supervisor_entries:
    key = f"{entry['site_id']}_{entry['entry_date']}_{entry['labour_type']}"
    supervisor_map[key] = entry

engineer_map = {}
for entry in engineer_entries:
    key = f"{entry['site_id']}_{entry['entry_date']}_{entry['labour_type']}"
    engineer_map[key] = entry

all_keys = set(supervisor_map.keys()) | set(engineer_map.keys())
mismatches = []

print(f"\n" + "=" * 80)
print("MISMATCH DETECTION RESULTS")
print("=" * 80)

for key in all_keys:
    supervisor_entry = supervisor_map.get(key)
    engineer_entry = engineer_map.get(key)
    
    site_id_key, date_str, labour_type = key.split('_', 2)
    
    if supervisor_entry and engineer_entry:
        if supervisor_entry['labour_count'] != engineer_entry['labour_count']:
            print(f"✗ COUNT MISMATCH: {labour_type} on {date_str}")
            print(f"  Supervisor ({supervisor_entry['supervisor_name']}): {supervisor_entry['labour_count']} workers")
            print(f"  Site Engineer ({engineer_entry['engineer_name']}): {engineer_entry['labour_count']} workers")
            mismatches.append(key)
    elif supervisor_entry and not engineer_entry:
        print(f"✗ MISSING SITE ENGINEER ENTRY: {labour_type} on {date_str}")
        print(f"  Supervisor ({supervisor_entry['supervisor_name']}): {supervisor_entry['labour_count']} workers")
        mismatches.append(key)
    elif engineer_entry and not supervisor_entry:
        print(f"✗ MISSING SUPERVISOR ENTRY: {labour_type} on {date_str}")
        print(f"  Site Engineer ({engineer_entry['engineer_name']}): {engineer_entry['labour_count']} workers")
        mismatches.append(key)

print(f"\nTotal mismatches: {len(mismatches)}")

print("\n" + "=" * 80)
print("FIX COMPLETE!")
print("=" * 80)
