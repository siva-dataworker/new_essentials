"""
Test client requirements API
"""
import os
import sys
import django

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all

def test_api():
    print("=" * 80)
    print("Testing Client Requirements API Query")
    print("=" * 80)
    
    # Get a site ID from the requirements
    site_query = """
        SELECT DISTINCT site_id, 
               s.customer_name, 
               s.site_name,
               CONCAT(s.customer_name, ' ', s.site_name) as full_name
        FROM client_requirements cr
        LEFT JOIN sites s ON cr.site_id = s.id
        LIMIT 1
    """
    
    site = fetch_all(site_query)
    if not site:
        print("No sites with requirements found")
        return
    
    site_id = site[0]['site_id']
    print(f"\nTesting with site_id: {site_id}")
    print(f"Site name: {site[0]['full_name']}")
    
    # Test the exact query used in the API
    query = """
        SELECT 
            cr.requirement_id,
            cr.description,
            cr.amount,
            cr.added_date,
            cr.status,
            u.username as added_by_name,
            s.site_name,
            s.customer_name,
            CONCAT(s.customer_name, ' ', s.site_name) as full_site_name
        FROM client_requirements cr
        LEFT JOIN users u ON cr.added_by = u.id
        LEFT JOIN sites s ON cr.site_id = s.id
        WHERE cr.site_id = %s
        ORDER BY cr.added_date DESC
    """
    
    requirements = fetch_all(query, (site_id,))
    
    print(f"\n✅ Found {len(requirements)} requirements for this site:")
    for req in requirements:
        print(f"\n  Description: {req['description']}")
        print(f"  Amount: ₹{req['amount']}")
        print(f"  Site: {req['full_site_name']}")
        print(f"  Added by: {req['added_by_name']}")
        print(f"  Date: {req['added_date']}")
    
    print("\n" + "=" * 80)

if __name__ == '__main__':
    test_api()
