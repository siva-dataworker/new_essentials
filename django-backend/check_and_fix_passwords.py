#!/usr/bin/env python3
"""
Check and fix user passwords in production database
Run this on Render Shell
"""
import os
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.contrib.auth.hashers import make_password, check_password
from api.db_utils import fetch_all, fetch_one, execute_query

def check_passwords():
    """Check all users and their passwords"""
    
    print("🔍 Checking all users in database...")
    print()
    
    # Get all users
    users = fetch_all("""
        SELECT u.id, u.username, u.email, u.password_hash, u.status, u.is_active, r.role_name
        FROM users u
        LEFT JOIN roles r ON u.role_id = r.id
        ORDER BY u.username
    """)
    
    if not users:
        print("❌ No users found in database!")
        return
    
    print(f"Found {len(users)} users:")
    print("=" * 80)
    
    # Common test passwords
    test_passwords = ['admin123', 'Test123', 'test123', 'password123', 'admin', 'test']
    
    for user in users:
        username = user['username']
        role = user['role_name'] or 'No role'
        status_str = user['status']
        active = user['is_active']
        
        print(f"\n👤 {username}")
        print(f"   Role: {role}")
        print(f"   Status: {status_str}")
        print(f"   Active: {active}")
        print(f"   Email: {user['email']}")
        
        # Try to find password
        password_found = None
        for pwd in test_passwords:
            try:
                if check_password(pwd, user['password_hash']):
                    password_found = pwd
                    break
            except:
                pass
        
        if password_found:
            print(f"   ✅ Password: {password_found}")
        else:
            print(f"   ❌ Password: Unknown (not in test list)")
    
    print()
    print("=" * 80)

def fix_passwords():
    """Reset passwords for all users"""
    
    print("\n🔧 Resetting passwords...")
    print()
    
    # Password mappings
    password_map = {
        'admin': 'admin123',
        'Siva': 'siva123',
        'siva': 'siva123',
        'sivaana': 'siva123',
        'balut': 'balut123',
        'rest user': 'rest123',
        'nanwjw': 'test123',
        'client4': 'client123',
        'architect': 'architect123',
    }
    
    # Get all users
    users = fetch_all("SELECT id, username FROM users")
    
    for user in users:
        username = user['username']
        
        # Determine password
        if username in password_map:
            password = password_map[username]
        elif username.startswith('client'):
            password = 'client123'
        elif username.startswith('supervisor'):
            password = 'supervisor123'
        elif username.startswith('architect'):
            password = 'architect123'
        elif username.startswith('accountant'):
            password = 'accountant123'
        else:
            password = 'test123'  # Default
        
        # Hash password
        password_hash = make_password(password)
        
        # Update
        execute_query(
            "UPDATE users SET password_hash = %s WHERE id = %s",
            (password_hash, user['id'])
        )
        
        print(f"✅ {username} → {password}")
    
    print()
    print("=" * 80)
    print("✅ All passwords reset!")
    print()
    print("You can now login with:")
    print("  - admin / admin123")
    print("  - Siva / siva123")
    print("  - balut / balut123")
    print("  - client4 / client123")
    print("  - Or any user with their respective password")

if __name__ == '__main__':
    import sys
    
    if len(sys.argv) > 1 and sys.argv[1] == 'fix':
        fix_passwords()
    else:
        check_passwords()
        print()
        print("To reset all passwords, run:")
        print("  python check_and_fix_passwords.py fix")
