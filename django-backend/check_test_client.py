#!/usr/bin/env python3
"""
Check if test client user exists and can login
"""

import os
import sys
import django

# Setup Django
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_one, fetch_all

def main():
    print("\n" + "="*60)
    print("  CHECKING TEST CLIENT USER")
    print("="*60)
    
    # Check if client role exists
    role = fetch_one("SELECT id, role_name FROM roles WHERE role_name = 'Client'")
    if role:
        print(f"\n✅ Client role exists: ID = {role['id']}")
    else:
        print("\n❌ Client role not found!")
        return
    
    # Check if testclient user exists
    user = fetch_one("""
        SELECT 
            u.id, 
            u.username, 
            u.full_name, 
            u.email,
            u.status,
            r.role_name
        FROM users u
        JOIN roles r ON u.role_id = r.id
        WHERE u.username = 'testclient'
    """)
    
    if user:
        print(f"\n✅ Test client user exists:")
        print(f"   Username: {user['username']}")
        print(f"   Full Name: {user['full_name']}")
        print(f"   Email: {user['email']}")
        print(f"   Role: {user['role_name']}")
        print(f"   Status: {user['status']}")
        
        # Check site assignments
        sites = fetch_all("""
            SELECT 
                cs.id,
                cs.assigned_date,
                cs.is_active,
                s.site_name,
                s.customer_name,
                s.area,
                s.street
            FROM client_sites cs
            JOIN sites s ON cs.site_id = s.id
            WHERE cs.client_id = %s
        """, (user['id'],))
        
        print(f"\n📍 Sites assigned: {len(sites)}")
        if sites:
            for site in sites:
                status = "✅ Active" if site['is_active'] else "❌ Inactive"
                print(f"   {status} - {site['customer_name']} {site['site_name']}")
                print(f"      Area: {site['area']}, Street: {site['street']}")
                print(f"      Assigned: {site['assigned_date']}")
        else:
            print("   ⚠️  No sites assigned yet")
            print("\n   To assign a site, run:")
            print("   python assign_site_to_client.py")
    else:
        print("\n❌ Test client user not found!")
        print("\n   To create the user, run:")
        print("   python create_test_client.py")
    
    print("\n" + "="*60)

if __name__ == "__main__":
    main()
