import os
import django

# Setup Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all

print("=" * 80)
print("DATABASE SITES REPORT")
print("=" * 80)

# Get all areas
areas = fetch_all("SELECT DISTINCT area FROM sites WHERE area != '' ORDER BY area")
print(f"\n📍 TOTAL AREAS: {len(areas)}")
print("-" * 80)

for area_row in areas:
    area = area_row['area']
    print(f"\n🏙️  AREA: {area}")
    
    # Get streets in this area
    streets = fetch_all(
        "SELECT DISTINCT street FROM sites WHERE area = %s AND street != '' ORDER BY street",
        (area,)
    )
    print(f"   Streets: {len(streets)}")
    
    for street_row in streets:
        street = street_row['street']
        print(f"\n   📍 STREET: {street}")
        
        # Get sites in this area/street
        sites = fetch_all("""
            SELECT 
                id,
                site_name,
                customer_name,
                created_at
            FROM sites 
            WHERE area = %s AND street = %s 
            ORDER BY created_at DESC
        """, (area, street))
        
        print(f"      Sites: {len(sites)}")
        
        for site in sites:
            display_name = f"{site['customer_name']} {site['site_name']}"
            created = site['created_at'].strftime('%Y-%m-%d %H:%M') if site['created_at'] else 'Unknown'
            print(f"      🏗️  {display_name}")
            print(f"         ID: {site['id']}")
            print(f"         Created: {created}")
            print()

# Summary
print("\n" + "=" * 80)
print("SUMMARY")
print("=" * 80)

total_sites = fetch_all("SELECT COUNT(*) as count FROM sites")[0]['count']
total_areas = len(areas)
total_streets = fetch_all("SELECT COUNT(DISTINCT street) as count FROM sites WHERE street != ''")[0]['count']

print(f"Total Areas:   {total_areas}")
print(f"Total Streets: {total_streets}")
print(f"Total Sites:   {total_sites}")
print("=" * 80)

# Recent sites
print("\n📅 RECENTLY CREATED SITES (Last 10)")
print("-" * 80)

recent_sites = fetch_all("""
    SELECT 
        area,
        street,
        site_name,
        customer_name,
        created_at
    FROM sites 
    ORDER BY created_at DESC 
    LIMIT 10
""")

for i, site in enumerate(recent_sites, 1):
    display_name = f"{site['customer_name']} {site['site_name']}"
    created = site['created_at'].strftime('%Y-%m-%d %H:%M:%S') if site['created_at'] else 'Unknown'
    print(f"{i:2d}. {display_name}")
    print(f"    Location: {site['area']} / {site['street']}")
    print(f"    Created: {created}")
    print()

print("=" * 80)
