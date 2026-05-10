import os
import django
import sys

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all

print("=" * 60)
print("TESTING ADMIN ALL WORKING SITES API QUERY (FIXED)")
print("=" * 60)

try:
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
                SELECT MAX(le.entry_date)
                FROM labour_entries le
                WHERE le.site_id = s.id
            ) as last_labour_date,
            (
                SELECT MAX(mb.created_at)
                FROM material_bills mb
                WHERE mb.site_id = s.id
            ) as last_material_update,
            (
                SELECT MAX(wu.uploaded_at)
                FROM work_updates wu
                WHERE wu.site_id = s.id
            ) as last_photo_update
        FROM working_sites ws
        JOIN sites s ON ws.site_id = s.id
        WHERE ws.is_active = TRUE
        ORDER BY ws.assigned_date DESC
    """)

    print(f"\n✅ Query executed successfully!")
    print(f"📊 Query returned {len(sites)} sites")
    print("-" * 60)

    if sites:
        for site in sites:
            print(f"\n✅ Site: {site['customer_name']} {site['site_name']}")
            print(f"   ID: {site['site_id']}")
            print(f"   Location: {site['area']} / {site['street']}")
            print(f"   Labour Count: {site['labour_count']}")
            print(f"   Material Count: {site['material_count']}")
            print(f"   Photo Count: {site['photo_count']}")
            print(f"   Assigned: {site['assigned_date']}")
    else:
        print("\n❌ Query returned no results!")
        print("\n🔍 Checking if there are any active working sites...")
        
        active_ws = fetch_all("""
            SELECT COUNT(*) as count FROM working_sites WHERE is_active = TRUE
        """)
        print(f"   Active working sites: {active_ws[0]['count']}")
        
        all_ws = fetch_all("""
            SELECT COUNT(*) as count FROM working_sites
        """)
        print(f"   Total working sites: {all_ws[0]['count']}")

except Exception as e:
    print(f"\n❌ ERROR: {e}")
    import traceback
    traceback.print_exc()

print("\n" + "=" * 60)
