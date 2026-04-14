"""
Verify requirements for Anwar site
"""
import os
import sys
import django

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all

def verify():
    print("=" * 80)
    print("Verifying requirements for Anwar 6 22 Ibrahim")
    print("=" * 80)
    
    site_id = '3ae88295-427b-49f6-8e50-4c02d0250617'
    
    # Test the exact API query
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
    
    print(f"\n✅ Found {len(requirements)} requirements:")
    for req in requirements:
        print(f"\n  Description: {req['description']}")
        print(f"  Amount: ₹{req['amount']}")
        print(f"  Site: {req['full_site_name']}")
        print(f"  Added by: {req['added_by_name']}")
        print(f"  Date: {req['added_date']}")
        print(f"  Status: {req['status']}")
    
    print("\n" + "=" * 80)
    print(f"Site ID to use in Flutter: {site_id}")
    print("=" * 80)

if __name__ == '__main__':
    verify()
