"""
Check client_requirements table data
"""
import os
import sys
import django

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all

def check_client_requirements():
    print("=" * 80)
    print("Checking client_requirements table...")
    print("=" * 80)
    
    # Check if table exists
    table_check = """
        SELECT EXISTS (
            SELECT FROM information_schema.tables 
            WHERE table_name = 'client_requirements'
        );
    """
    exists = fetch_all(table_check)
    print(f"\nTable exists: {exists}")
    
    # Get all requirements
    query = """
        SELECT 
            cr.requirement_id,
            cr.site_id,
            cr.description,
            cr.amount,
            cr.added_date,
            cr.status,
            cr.added_by,
            u.username as added_by_name,
            s.site_name,
            s.customer_name,
            CONCAT(s.customer_name, ' ', s.site_name) as full_site_name
        FROM client_requirements cr
        LEFT JOIN users u ON cr.added_by = u.id
        LEFT JOIN sites s ON cr.site_id = s.id
        ORDER BY cr.added_date DESC
        LIMIT 10;
    """
    
    requirements = fetch_all(query)
    
    if requirements:
        print(f"\n✅ Found {len(requirements)} client requirements:")
        for req in requirements:
            print(f"\n  ID: {req['requirement_id']}")
            print(f"  Site: {req['full_site_name']}")
            print(f"  Description: {req['description']}")
            print(f"  Amount: ₹{req['amount']}")
            print(f"  Added by: {req['added_by_name']}")
            print(f"  Date: {req['added_date']}")
            print(f"  Status: {req['status']}")
    else:
        print("\n❌ No client requirements found in database")
        
        # Check sites
        print("\n\nChecking available sites:")
        sites_query = "SELECT id, customer_name, site_name FROM sites LIMIT 5"
        sites = fetch_all(sites_query)
        if sites:
            print(f"Found {len(sites)} sites:")
            for site in sites:
                print(f"  - {site['id']}: {site['customer_name']} {site['site_name']}")
        else:
            print("No sites found")
    
    print("\n" + "=" * 80)

if __name__ == '__main__':
    check_client_requirements()
