import os
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all

print("=" * 60)
print("TESTING ADMIN ALL WORKING SITES QUERY (FIXED)")
print("=" * 60)

# This is the exact query from get_all_working_sites endpoint (FIXED)
sites = fetch_all("""
    SELECT DISTINCT
        s.id as site_id,
        s.site_name,
        s.customer_name,
        s.area,
        s.street,
        ws.assigned_date,
        ws.description,
        (
            SELECT COUNT(*) 
            FROM labour_entries le 
            WHERE le.site_id = s.id
        ) as labour_count,
        (
            SELECT COUNT(*) 
            FROM material_bills mb 
            WHERE mb.site_id = s.id
        ) as material_count,
        (
            SELECT COUNT(*) 
            FROM work_updates wu 
            WHERE wu.site_id = s.id
        ) as photo_count,
        (
            SELECT MAX(le.created_at)
            FROM labour_entries le
            WHERE le.site_id = s.id
        ) as last_labour_update,
        (
            SELECT MAX(mb.created_at)
            FROM material_bills mb
            WHERE mb.site_id = s.id
        ) as last_material_update,
        (
            SELECT MAX(wu.created_at)
            FROM work_updates wu
            WHERE wu.site_id = s.id
        ) as last_photo_update
    FROM working_sites ws
    JOIN sites s ON ws.site_id = s.id
    WHERE ws.is_active = TRUE
    ORDER BY ws.assigned_date DESC
""")

print(f"\n📊 Query returned {len(sites)} sites")
print("-" * 60)

if sites:
    for site in sites:
        print(f"\n✅ Site: {site['customer_name']} {site['site_name']}")
        print(f"   Location: {site['area']} / {site['street']}")
        print(f"   Labour Count: {site['labour_count']}")
        print(f"   Material Count: {site['material_count']}")
        print(f"   Photo Count: {site['photo_count']}")
        print(f"   Last Labour: {site['last_labour_update']}")
        print(f"   Last Material: {site['last_material_update']}")
        print(f"   Last Photo: {site['last_photo_update']}")
        print(f"   Assigned: {site['assigned_date']}")
else:
    print("\n❌ Query returned no results!")

print("\n" + "=" * 60)
