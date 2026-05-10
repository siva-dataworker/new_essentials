import os
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all, fetch_one

print("=" * 80)
print("CHECK UTILIZATION DATA")
print("=" * 80)

# Check labour entries
labour_count = fetch_one("SELECT COUNT(*) as count FROM labour_entries")['count']
print(f"\n📊 Labour entries: {labour_count}")

if labour_count > 0:
    print("\n   Recent labour entries:")
    recent_labour = fetch_all("""
        SELECT 
            l.id,
            s.site_name,
            s.customer_name,
            l.labour_type,
            l.labour_count,
            l.entry_date,
            u.full_name as submitted_by
        FROM labour_entries l
        JOIN sites s ON l.site_id = s.id
        JOIN users u ON l.supervisor_id = u.id
        ORDER BY l.entry_date DESC, l.entry_time DESC
        LIMIT 10
    """)
    
    for entry in recent_labour:
        site_display = f"{entry['customer_name']} {entry['site_name']}"
        print(f"   - {site_display}: {entry['labour_type']} x {entry['labour_count']} on {entry['entry_date']} by {entry['submitted_by']}")

# Check material usage
material_count = fetch_one("SELECT COUNT(*) as count FROM material_usage")['count']
print(f"\n📦 Material usage: {material_count}")

if material_count > 0:
    print("\n   Recent material usage:")
    recent_material = fetch_all("""
        SELECT 
            m.id,
            s.site_name,
            s.customer_name,
            m.material_type,
            m.quantity_used,
            m.usage_date,
            u.full_name as submitted_by
        FROM material_usage m
        JOIN sites s ON m.site_id = s.id
        JOIN users u ON m.supervisor_id = u.id
        ORDER BY m.usage_date DESC, m.created_at DESC
        LIMIT 10
    """)
    
    for entry in recent_material:
        site_display = f"{entry['customer_name']} {entry['site_name']}"
        print(f"   - {site_display}: {entry['material_type']} x {entry['quantity_used']} on {entry['usage_date']} by {entry['submitted_by']}")

# Check labour cost calculations
cost_count = fetch_one("SELECT COUNT(*) as count FROM labour_cost_calculation")['count']
print(f"\n💰 Labour cost calculations: {cost_count}")

# Check for specific site (Anwar 6 22 Ibrahim)
print("\n" + "=" * 80)
print("CHECKING SPECIFIC SITE: Anwar 6 22 Ibrahim")
print("=" * 80)

site_info = fetch_one("""
    SELECT id, site_name, customer_name
    FROM sites
    WHERE customer_name LIKE '%Anwar%' AND site_name LIKE '%22%'
    LIMIT 1
""")

if site_info:
    site_id = site_info['id']
    print(f"\n🏗️  Site found: {site_info['customer_name']} {site_info['site_name']}")
    print(f"   Site ID: {site_id}")
    
    # Check labour entries for this site
    site_labour = fetch_all("""
        SELECT labour_type, labour_count, entry_date
        FROM labour_entries
        WHERE site_id = %s
        ORDER BY entry_date DESC
    """, (site_id,))
    
    print(f"\n   Labour entries for this site: {len(site_labour)}")
    if site_labour:
        for entry in site_labour:
            print(f"   - {entry['labour_type']}: {entry['labour_count']} workers on {entry['entry_date']}")
    
    # Check material usage for this site
    site_material = fetch_all("""
        SELECT material_type, quantity_used, usage_date
        FROM material_usage
        WHERE site_id = %s
        ORDER BY usage_date DESC
    """, (site_id,))
    
    print(f"\n   Material usage for this site: {len(site_material)}")
    if site_material:
        for entry in site_material:
            print(f"   - {entry['material_type']}: {entry['quantity_used']} on {entry['usage_date']}")
else:
    print("\n   Site not found")

print("\n" + "=" * 80)
print("SUMMARY")
print("=" * 80)
print(f"Total labour entries: {labour_count}")
print(f"Total material usage: {material_count}")
print(f"Total cost calculations: {cost_count}")

if labour_count == 0 and material_count == 0 and cost_count == 0:
    print("\n✅ Database is clean - no utilization data found")
    print("   If you still see data in the app, try:")
    print("   1. Pull down to refresh the screen")
    print("   2. Close and reopen the app")
    print("   3. Clear app cache")
else:
    print("\n⚠️  Utilization data still exists in database")
    print("   Run delete_all_utilization_data.py to remove it")

print("\n" + "=" * 80)
