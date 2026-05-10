#!/usr/bin/env python3
"""
Show current labour entries in a readable format
"""
import os, django, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all

entries = fetch_all("""
    SELECT 
        l.id,
        s.site_name,
        s.customer_name,
        u.full_name as submitted_by,
        l.submitted_by_role,
        l.entry_date,
        l.labour_type,
        l.labour_count,
        l.entry_time
    FROM labour_entries l
    JOIN sites s ON l.site_id = s.id
    JOIN users u ON l.supervisor_id = u.id
    WHERE l.entry_date = '2026-05-10'
    ORDER BY l.submitted_by_role, l.entry_time
""")

print("\n" + "=" * 80)
print("LABOUR ENTRIES FOR MAY 9, 2026")
print("=" * 80)

supervisor_entries = [e for e in entries if e['submitted_by_role'] == 'Supervisor']
engineer_entries = [e for e in entries if e['submitted_by_role'] == 'Site Engineer']

print(f"\n📊 SUPERVISOR ENTRIES ({len(supervisor_entries)} total):")
print("-" * 80)
for e in supervisor_entries:
    site = f"{e['customer_name']} {e['site_name']}"
    print(f"  • {e['labour_type']}: {e['labour_count']} workers | Site: {site} | By: {e['submitted_by']}")

print(f"\n📊 SITE ENGINEER ENTRIES ({len(engineer_entries)} total):")
print("-" * 80)
for e in engineer_entries:
    site = f"{e['customer_name']} {e['site_name']}"
    print(f"  • {e['labour_type']}: {e['labour_count']} workers | Site: {site} | By: {e['submitted_by']}")

print("\n" + "=" * 80)
print(f"TOTAL: {len(entries)} entries")
print("=" * 80 + "\n")
