#!/usr/bin/env python
"""
Check anwar's complaint and why it's not showing for architect
"""
import os
import sys
import django

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all, fetch_one

def check_anwar_complaint():
    """Check anwar's complaints and site assignments"""
    print("=" * 70)
    print("Checking Anwar's Complaint Issue")
    print("=" * 70)
    
    # Find anwar user
    anwar = fetch_one("""
        SELECT id, username, full_name, email, role_id
        FROM users
        WHERE LOWER(username) LIKE LOWER(%s) OR LOWER(full_name) LIKE LOWER(%s)
    """, ('%anwar%', '%anwar%'))
    
    if not anwar:
        print("❌ User 'anwar' not found")
        return
    
    print(f"\n✅ Found user: {anwar['full_name']} ({anwar['username']})")
    print(f"   ID: {anwar['id']}")
    print(f"   Role ID: {anwar['role_id']}")
    
    # Check if anwar is a client (role_id = 5)
    if anwar['role_id'] != 5:
        print(f"⚠️  Warning: User is not a client (role_id should be 5, got {anwar['role_id']})")
    
    # Check anwar's assigned sites
    sites = fetch_all("""
        SELECT cs.site_id, s.site_name, s.customer_name, cs.is_active
        FROM client_sites cs
        LEFT JOIN sites s ON cs.site_id = s.id
        WHERE cs.client_id = %s
    """, (anwar['id'],))
    
    print(f"\n🏗️  Anwar's Assigned Sites: {len(sites)}")
    for site in sites:
        active_status = "✅ Active" if site['is_active'] else "❌ Inactive"
        print(f"   - {site['site_name']} ({active_status})")
        print(f"     Site ID: {site['site_id']}")
    
    # Check anwar's complaints
    complaints = fetch_all("""
        SELECT 
            c.id,
            c.title,
            c.description,
            c.status,
            c.priority,
            c.created_at,
            c.site_id,
            s.site_name,
            s.customer_name
        FROM complaints c
        LEFT JOIN sites s ON c.site_id = s.id
        WHERE c.raised_by = %s
        ORDER BY c.created_at DESC
    """, (anwar['id'],))
    
    print(f"\n📋 Anwar's Complaints: {len(complaints)}")
    if complaints:
        for i, complaint in enumerate(complaints, 1):
            print(f"\n{i}. {complaint['title']}")
            print(f"   Description: {complaint['description']}")
            print(f"   Site: {complaint['site_name']} (ID: {complaint['site_id']})")
            print(f"   Status: {complaint['status']}")
            print(f"   Priority: {complaint['priority']}")
            print(f"   Created: {complaint['created_at']}")
            print(f"   Complaint ID: {complaint['id']}")
            
            # Check if this site is in anwar's assigned sites
            site_assigned = any(str(s['site_id']) == str(complaint['site_id']) for s in sites)
            if site_assigned:
                print(f"   ✅ Site is assigned to anwar")
            else:
                print(f"   ⚠️  WARNING: Site is NOT assigned to anwar!")
    else:
        print("   No complaints found")
    
    # Check architect
    architect = fetch_one("""
        SELECT id, username, full_name
        FROM users
        WHERE role_id = 6 AND is_active = TRUE
        LIMIT 1
    """)
    
    if architect:
        print(f"\n👷 Architect: {architect['full_name']} ({architect['username']})")
        print(f"   ID: {architect['id']}")
        
        # Check what complaints the architect should see
        if complaints:
            for complaint in complaints:
                # Check if architect has documents for this site
                arch_docs = fetch_one("""
                    SELECT id FROM architect_documents
                    WHERE architect_id = %s AND site_id = %s
                """, (architect['id'], complaint['site_id']))
                
                # Check if complaint is assigned to architect
                assigned = complaint.get('assigned_to') == architect['id']
                
                print(f"\n   Complaint: {complaint['title']}")
                print(f"   - Has architect documents for site: {'✅ Yes' if arch_docs else '❌ No'}")
                print(f"   - Assigned to architect: {'✅ Yes' if assigned else '❌ No'}")
                
                if arch_docs or assigned:
                    print(f"   ✅ Architect SHOULD see this complaint")
                else:
                    print(f"   ❌ Architect WILL NOT see this complaint")
    else:
        print("\n❌ No architect found")
    
    print("\n" + "=" * 70)
    print("Summary:")
    print("=" * 70)
    print("For architect to see a complaint, ONE of these must be true:")
    print("1. Complaint is assigned to the architect")
    print("2. Architect has documents for the complaint's site")
    print("3. User is Admin (sees all complaints)")
    print("=" * 70)

if __name__ == '__main__':
    check_anwar_complaint()
