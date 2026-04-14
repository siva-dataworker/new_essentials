#!/usr/bin/env python
"""
Test architect client complaints API
"""
import os
import sys
import django

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all, fetch_one

def test_complaints_data():
    """Check if there are complaints in the database"""
    print("=" * 70)
    print("Testing Architect Client Complaints API")
    print("=" * 70)
    
    # Check if there are any complaints from clients
    complaints = fetch_all("""
        SELECT 
            c.id,
            c.title,
            c.status,
            c.priority,
            c.created_at,
            s.site_name,
            u_client.full_name as client_name,
            u_client.role_id as client_role_id
        FROM complaints c
        LEFT JOIN sites s ON c.site_id = s.id
        LEFT JOIN users u_client ON c.raised_by = u_client.id
        WHERE u_client.role_id = 5
        ORDER BY c.created_at DESC
    """)
    
    print(f"\n📊 Total Client Complaints: {len(complaints)}")
    
    if complaints:
        print("\n" + "=" * 70)
        print("Complaint Details:")
        print("=" * 70)
        for i, complaint in enumerate(complaints, 1):
            print(f"\n{i}. {complaint['title']}")
            print(f"   Site: {complaint['site_name']}")
            print(f"   Client: {complaint['client_name']}")
            print(f"   Status: {complaint['status']}")
            print(f"   Priority: {complaint['priority']}")
            print(f"   Created: {complaint['created_at']}")
            print(f"   ID: {complaint['id']}")
    else:
        print("\n⚠️  No client complaints found in database")
        print("\nTo create a test complaint:")
        print("1. Login as client (username: sivu, password: test123)")
        print("2. Go to Issues tab")
        print("3. Create a new complaint")
    
    # Check architects
    architects = fetch_all("""
        SELECT id, username, full_name, email
        FROM users
        WHERE role_id = 6 AND is_active = TRUE
    """)
    
    print(f"\n👷 Total Architects: {len(architects)}")
    if architects:
        for arch in architects:
            print(f"   - {arch['full_name']} ({arch['username']})")
    
    # Check sites
    sites = fetch_all("""
        SELECT id, site_name, customer_name
        FROM sites
        LIMIT 5
    """)
    
    print(f"\n🏗️  Total Sites: {len(sites)}")
    if sites:
        for site in sites[:3]:
            print(f"   - {site['site_name']} (Customer: {site['customer_name']})")
    
    print("\n" + "=" * 70)
    print("API Endpoint: GET /api/construction/client-complaints/")
    print("Query Params:")
    print("  - site_id (optional): Filter by site")
    print("  - status (optional): OPEN, IN_PROGRESS, RESOLVED, CLOSED")
    print("=" * 70)

if __name__ == '__main__':
    test_complaints_data()
