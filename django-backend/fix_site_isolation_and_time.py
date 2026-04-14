"""
Fix site isolation and verify IST time storage
"""
import os
import sys
import django

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all, execute_query
from datetime import datetime
import pytz

print("="*60)
print("SITE ISOLATION AND TIME VERIFICATION")
print("="*60)

# Check IST time
ist = pytz.timezone('Asia/Kolkata')
now_ist = datetime.now(ist)
print(f"\n✅ Current IST Time: {now_ist.strftime('%Y-%m-%d %H:%M:%S %Z')}")
print(f"✅ Current Hour: {now_ist.hour}")

# Check labour entries by site
print("\n" + "="*60)
print("LABOUR ENTRIES BY SITE")
print("="*60)

labour_by_site = fetch_all("""
    SELECT 
        s.site_name,
        s.area,
        s.street,
        l.supervisor_id,
        u.full_name as supervisor_name,
        COUNT(*) as entry_count,
        MIN(l.entry_date) as first_entry,
        MAX(l.entry_date) as last_entry
    FROM labour_entries l
    JOIN sites s ON l.site_id = s.id
    JOIN users u ON l.supervisor_id = u.id
    GROUP BY s.site_name, s.area, s.street, l.supervisor_id, u.full_name
    ORDER BY s.site_name, u.full_name
""")

for row in labour_by_site:
    print(f"\n📍 Site: {row['site_name']} ({row['area']}, {row['street']})")
    print(f"   Supervisor: {row['supervisor_name']}")
    print(f"   Entries: {row['entry_count']}")
    print(f"   Date Range: {row['first_entry']} to {row['last_entry']}")

# Check material entries by site
print("\n" + "="*60)
print("MATERIAL ENTRIES BY SITE")
print("="*60)

material_by_site = fetch_all("""
    SELECT 
        s.site_name,
        s.area,
        s.street,
        m.supervisor_id,
        u.full_name as supervisor_name,
        COUNT(*) as entry_count,
        MIN(m.entry_date) as first_entry,
        MAX(m.entry_date) as last_entry
    FROM material_balances m
    JOIN sites s ON m.site_id = s.id
    JOIN users u ON m.supervisor_id = u.id
    GROUP BY s.site_name, s.area, s.street, m.supervisor_id, u.full_name
    ORDER BY s.site_name, u.full_name
""")

for row in material_by_site:
    print(f"\n📦 Site: {row['site_name']} ({row['area']}, {row['street']})")
    print(f"   Supervisor: {row['supervisor_name']}")
    print(f"   Entries: {row['entry_count']}")
    print(f"   Date Range: {row['first_entry']} to {row['last_entry']}")

# Check for entries with NULL site_id
print("\n" + "="*60)
print("CHECKING FOR NULL SITE IDS")
print("="*60)

null_labour = fetch_all("SELECT COUNT(*) as count FROM labour_entries WHERE site_id IS NULL")
null_material = fetch_all("SELECT COUNT(*) as count FROM material_balances WHERE site_id IS NULL")

print(f"Labour entries with NULL site_id: {null_labour[0]['count']}")
print(f"Material entries with NULL site_id: {null_material[0]['count']}")

if null_labour[0]['count'] > 0 or null_material[0]['count'] > 0:
    print("\n⚠️ WARNING: Found entries with NULL site_id!")
    print("These entries will not be properly isolated by site.")

# Check time storage format
print("\n" + "="*60)
print("TIME STORAGE VERIFICATION")
print("="*60)

recent_labour = fetch_all("""
    SELECT 
        l.id,
        l.entry_date,
        l.entry_time,
        l.day_of_week,
        s.site_name,
        u.full_name as supervisor_name
    FROM labour_entries l
    JOIN sites s ON l.site_id = s.id
    JOIN users u ON l.supervisor_id = u.id
    ORDER BY l.entry_time DESC
    LIMIT 5
""")

print("\nRecent Labour Entries:")
for entry in recent_labour:
    print(f"\n  Site: {entry['site_name']}")
    print(f"  Supervisor: {entry['supervisor_name']}")
    print(f"  Date: {entry['entry_date']}")
    print(f"  Time: {entry['entry_time']}")
    print(f"  Day: {entry['day_of_week']}")
    
    # Check if time looks like UTC or IST
    if entry['entry_time']:
        hour = entry['entry_time'].hour
        if hour < 6:
            print(f"  ⚠️ WARNING: Time shows {hour}:xx which might be UTC (IST would be +5:30)")

# Check supervisor-site relationships
print("\n" + "="*60)
print("SUPERVISOR-SITE RELATIONSHIPS")
print("="*60)

supervisor_sites = fetch_all("""
    SELECT DISTINCT
        u.id as supervisor_id,
        u.full_name as supervisor_name,
        s.id as site_id,
        s.site_name,
        s.area,
        s.street
    FROM labour_entries l
    JOIN users u ON l.supervisor_id = u.id
    JOIN sites s ON l.site_id = s.id
    ORDER BY u.full_name, s.site_name
""")

current_supervisor = None
for row in supervisor_sites:
    if current_supervisor != row['supervisor_name']:
        current_supervisor = row['supervisor_name']
        print(f"\n👤 {current_supervisor}:")
    print(f"   - {row['site_name']} ({row['area']}, {row['street']})")

print("\n" + "="*60)
print("RECOMMENDATIONS")
print("="*60)

print("""
1. Site Isolation:
   - Each supervisor should only see entries for their assigned sites
   - Backend filters by supervisor_id AND site_id
   - Frontend should only show sites assigned to the supervisor

2. Time Display:
   - Database stores timestamps in UTC (standard practice)
   - Backend converts to IST when returning data
   - Frontend should display in IST

3. If you're seeing wrong times:
   - Check if frontend is converting UTC to local time
   - Backend should return IST timestamps
   - Database stores in UTC for consistency
""")

print("\n✅ Verification complete!")
