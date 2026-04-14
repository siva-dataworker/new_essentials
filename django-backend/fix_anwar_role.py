#!/usr/bin/env python
"""
Fix anwar's role to be a proper client (role_id = 5)
"""
import os
import sys
import django

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import execute_query, fetch_one, fetch_all

def fix_anwar_role():
    """Fix anwar's role to client"""
    print("=" * 70)
    print("Fixing Anwar's Role")
    print("=" * 70)
    
    # Find anwar
    anwar = fetch_one("""
        SELECT id, username, full_name, role_id
        FROM users
        WHERE LOWER(username) LIKE LOWER(%s)
    """, ('%anwar%',))
    
    if not anwar:
        print("❌ User anwar not found")
        return False
    
    print(f"\n✅ Found user: {anwar['full_name']} ({anwar['username']})")
    print(f"   Current role_id: {anwar['role_id']}")
    
    # Check roles table
    roles = fetch_all("SELECT id, role_name FROM roles ORDER BY id")
    print(f"\n📋 Available Roles:")
    for role in roles:
        print(f"   {role['id']}: {role['role_name']}")
    
    # Update anwar's role to client (5)
    if anwar['role_id'] != 5:
        execute_query("""
            UPDATE users
            SET role_id = 5
            WHERE id = %s
        """, (anwar['id'],))
        
        print(f"\n✅ Updated anwar's role from {anwar['role_id']} to 5 (Client)")
    else:
        print(f"\n✅ Anwar already has correct role (5 - Client)")
    
    # Verify
    updated = fetch_one("SELECT role_id FROM users WHERE id = %s", (anwar['id'],))
    print(f"\n✅ Verified: Anwar's role_id is now {updated['role_id']}")
    
    return True

if __name__ == '__main__':
    success = fix_anwar_role()
    
    if success:
        print("\n✅ Fix complete!")
        print("\nNow anwar's complaints should be visible to architects")
    else:
        print("\n❌ Failed to fix anwar's role")
        sys.exit(1)
