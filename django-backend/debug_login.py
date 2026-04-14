"""
Debug script to check user login issues
"""
import os
import sys
import django
from pathlib import Path

# Add the project directory to the Python path
BASE_DIR = Path(__file__).resolve().parent
sys.path.append(str(BASE_DIR))

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.contrib.auth.hashers import check_password
from api.database import fetch_all, fetch_one

def debug_users():
    """Check all users in database"""
    print("\n" + "="*60)
    print("CHECKING ALL USERS IN DATABASE")
    print("="*60 + "\n")
    
    try:
        users = fetch_all("""
            SELECT u.id, u.username, u.email, u.phone, u.password_hash, 
                   u.full_name, u.status, u.is_active, r.role_name
            FROM users u
            LEFT JOIN roles r ON u.role_id = r.id
            ORDER BY u.created_at DESC
        """)
        
        if not users:
            print("❌ NO USERS FOUND IN DATABASE!")
            print("\nPossible reasons:")
            print("1. Database schema not applied")
            print("2. No users registered yet")
            print("\nSolution:")
            print("- Apply schema: django-backend/construction_management_schema.sql")
            print("- Register a user in the app")
            return
        
        print(f"✅ Found {len(users)} user(s):\n")
        
        for i, user in enumerate(users, 1):
            print(f"User #{i}:")
            print(f"  ID: {user['id']}")
            print(f"  Username: {user['username']}")
            print(f"  Email: {user['email']}")
            print(f"  Phone: {user['phone']}")
            print(f"  Full Name: {user['full_name']}")
            print(f"  Role: {user['role_name']}")
            print(f"  Status: {user['status']}")
            print(f"  Is Active: {user['is_active']}")
            print(f"  Password Hash: {user['password_hash'][:50]}...")
            print()
        
    except Exception as e:
        print(f"❌ ERROR: {e}")
        print("\nThis usually means:")
        print("1. Database schema not applied")
        print("2. Database connection issue")
        print("\nCheck:")
        print("- .env file has correct database credentials")
        print("- Schema applied in Supabase SQL Editor")


def test_login(username, password):
    """Test login for a specific user"""
    print("\n" + "="*60)
    print(f"TESTING LOGIN FOR: {username}")
    print("="*60 + "\n")
    
    try:
        user = fetch_one("""
            SELECT u.id, u.username, u.email, u.password_hash, u.status, 
                   u.is_active, r.role_name
            FROM users u
            LEFT JOIN roles r ON u.role_id = r.id
            WHERE u.username = %s
        """, (username,))
        
        if not user:
            print(f"❌ User '{username}' NOT FOUND in database")
            print("\nAvailable usernames:")
            all_users = fetch_all("SELECT username FROM users")
            for u in all_users:
                print(f"  - {u['username']}")
            return
        
        print(f"✅ User found: {user['username']}")
        print(f"   Email: {user['email']}")
        print(f"   Role: {user['role_name']}")
        print(f"   Status: {user['status']}")
        print(f"   Is Active: {user['is_active']}")
        print()
        
        # Check password
        password_match = check_password(password, user['password_hash'])
        
        if password_match:
            print(f"✅ Password is CORRECT")
        else:
            print(f"❌ Password is INCORRECT")
            print(f"\nYou entered: {password}")
            print("Make sure you're using the exact password from registration")
        print()
        
        # Check status
        if user['status'] == 'PENDING':
            print("⚠️  User status is PENDING")
            print("   Admin needs to approve this user in Supabase")
            print("   Change status from 'PENDING' to 'APPROVED' in users table")
        elif user['status'] == 'APPROVED':
            print("✅ User status is APPROVED")
        elif user['status'] == 'REJECTED':
            print("❌ User status is REJECTED")
        print()
        
        # Check active
        if not user['is_active']:
            print("❌ User is INACTIVE")
        else:
            print("✅ User is ACTIVE")
        print()
        
        # Final verdict
        if password_match and user['status'] == 'APPROVED' and user['is_active']:
            print("🎉 LOGIN SHOULD WORK!")
        else:
            print("❌ LOGIN WILL FAIL")
            if not password_match:
                print("   Reason: Wrong password")
            if user['status'] != 'APPROVED':
                print(f"   Reason: Status is {user['status']} (needs to be APPROVED)")
            if not user['is_active']:
                print("   Reason: User is inactive")
        
    except Exception as e:
        print(f"❌ ERROR: {e}")


if __name__ == '__main__':
    # First, show all users
    debug_users()
    
    # Test with actual registered users
    print("\n" + "="*60)
    print("ENTER USERNAME AND PASSWORD TO TEST:")
    print("="*60)
    username = input("Username: ").strip()
    if username:
        password = input("Password: ").strip()
        if password:
            test_login(username, password)
    else:
        print("\nSkipped login test")
        print("="*60 + "\n")
