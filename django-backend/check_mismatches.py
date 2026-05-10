import os
import django
import sys

# Setup Django
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all

print("=" * 80)
print("CHECKING FOR LABOUR ENTRY MISMATCHES")
print("=" * 80)
print()

# Check for mismatches between Supervisor and Site Engineer entries
query = """
    SELECT 
        l.entry_date,
        l.site_id,
        s.site_name,
        l.labour_type,
        l.submitted_by_role,
        l.labour_count,
        u.full_name as submitted_by
    FROM labour_entries l
    JOIN sites s ON l.site_id = s.id
    JOIN users u ON l.supervisor_id = u.id
    ORDER BY l.entry_date DESC, l.site_id, l.labour_type
"""

entries = fetch_all(query)

print(f"📊 Total Labour Entries: {len(entries)}\n")

# Group by date, site, and labour type
from collections import defaultdict
grouped = defaultdict(lambda: {'Supervisor': [], 'Site Engineer': []})

for entry in entries:
    key = (entry['entry_date'], entry['site_id'], entry['labour_type'])
    role = entry['submitted_by_role']
    grouped[key][role].append(entry)

print("🔍 Checking for mismatches...\n")

mismatches = []
for (date, site_id, labour_type), roles in grouped.items():
    supervisor_entries = roles['Supervisor']
    engineer_entries = roles['Site Engineer']
    
    supervisor_count = sum(e['labour_count'] for e in supervisor_entries)
    engineer_count = sum(e['labour_count'] for e in engineer_entries)
    
    if supervisor_count != engineer_count:
        site_name = supervisor_entries[0]['site_name'] if supervisor_entries else engineer_entries[0]['site_name']
        mismatches.append({
            'date': date,
            'site_name': site_name,
            'labour_type': labour_type,
            'supervisor_count': supervisor_count,
            'engineer_count': engineer_count,
            'difference': abs(supervisor_count - engineer_count)
        })

if mismatches:
    print(f"⚠️  Found {len(mismatches)} mismatches:\n")
    for m in mismatches:
        print(f"Date: {m['date']}")
        print(f"Site: {m['site_name']}")
        print(f"Labour Type: {m['labour_type']}")
        print(f"Supervisor Count: {m['supervisor_count']}")
        print(f"Site Engineer Count: {m['engineer_count']}")
        print(f"Difference: {m['difference']}")
        print()
else:
    print("✅ No mismatches found!")
    print("\nThis means:")
    print("- All Supervisor entries match Site Engineer entries")
    print("- OR there are no entries from both roles for the same date/site/labour type")
    print("\nTo test the mismatch feature, you need to:")
    print("1. Have a Supervisor enter labour data for a specific date/site/labour type")
    print("2. Have a Site Engineer enter DIFFERENT labour count for the same date/site/labour type")

print("\n" + "=" * 80)
