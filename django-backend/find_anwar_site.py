"""
Find the Anwar site ID
"""
import os
import sys
import django

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all

def find_site():
    print("=" * 80)
    print("Finding Anwar 6 22 Ibrahim site...")
    print("=" * 80)
    
    # Find the site
    query = """
        SELECT 
            id,
            customer_name,
            site_name,
            CONCAT(customer_name, ' ', site_name) as full_name,
            area,
            street
        FROM sites
        WHERE customer_name ILIKE '%anwar%' OR site_name ILIKE '%ibrahim%'
        OR CONCAT(customer_name, ' ', site_name) ILIKE '%anwar%ibrahim%'
    """
    
    sites = fetch_all(query)
    
    if sites:
        print(f"\n✅ Found {len(sites)} matching sites:")
        for site in sites:
            print(f"\n  ID: {site['id']}")
            print(f"  Name: {site['full_name']}")
            print(f"  Area: {site['area']}")
            print(f"  Street: {site['street']}")
            
            # Check requirements for this site
            req_query = """
                SELECT COUNT(*) as count
                FROM client_requirements
                WHERE site_id = %s
            """
            count = fetch_all(req_query, (site['id'],))
            print(f"  Requirements: {count[0]['count']}")
    else:
        print("\n❌ No matching sites found")
        
        # Show all sites
        print("\n\nAll sites in database:")
        all_sites = fetch_all("SELECT id, customer_name, site_name FROM sites LIMIT 10")
        for site in all_sites:
            print(f"  - {site['id']}: {site['customer_name']} {site['site_name']}")
    
    print("\n" + "=" * 80)

if __name__ == '__main__':
    find_site()
