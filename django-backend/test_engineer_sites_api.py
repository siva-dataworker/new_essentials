"""
Test the engineer sites API to see what it returns
"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.db import connection

def dict_fetchall(cursor):
    columns = [col[0] for col in cursor.description]
    return [dict(zip(columns, row)) for row in cursor.fetchall()]

print("=" * 60)
print("TESTING ENGINEER SITES API QUERY")
print("=" * 60)

with connection.cursor() as cursor:
    # Run the exact same query as the API
    cursor.execute("""
        SELECT 
            s.id as site_id,
            s.site_name,
            s.customer_name as location,
            CONCAT(s.site_name, ' - ', COALESCE(s.customer_name, '')) as display_name,
            s.area,
            s.street,
            s.created_at
        FROM sites s
        WHERE s.id IS NOT NULL AND s.site_name IS NOT NULL AND s.site_name != ''
        ORDER BY s.site_name
    """)
    
    sites = dict_fetchall(cursor)
    
    print(f"\nTotal sites returned: {len(sites)}")
    print("\nFirst 3 sites:")
    print("-" * 60)
    
    for i, site in enumerate(sites[:3]):
        print(f"\nSite {i+1}:")
        print(f"  site_id: {site.get('site_id')}")
        print(f"  site_name: {site.get('site_name')}")
        print(f"  location: {site.get('location')}")
        print(f"  display_name: {site.get('display_name')}")
        print(f"  area: {site.get('area')}")
        print(f"  street: {site.get('street')}")
    
    print("\n" + "=" * 60)
    print("This is what the API will return to Flutter")
    print("=" * 60)
    
    # Show JSON format
    import json
    response = {
        'success': True,
        'sites': sites
    }
    
    print("\nJSON Response (first site):")
    if sites:
        print(json.dumps({'success': True, 'sites': [sites[0]]}, indent=2, default=str))
