"""
Set test passwords for all users so you can login
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

from django.contrib.auth.hashers import make_password
from api.database import execute_query, fetch_all

def set_test_passwords():
    """Set known test passwords for all users"""
    print("\n" + "="*60)
    print("SETTING TEST PASSWORDS FOR ALL USERS")
    print("="*60 + "\n")
    
    # Get all users
    users = fetch_all("""
        SELECT u.id, u.username, u.email, r.role_name
        FROM users u
        LEFT JOIN roles r ON u.role_id = r.id
        ORDER BY u.username
    """)
    
    if not users:
        print("❌ No users found!")
        return
    
    print(f"Found {len(users)} user(s)\n")
    
    # Set password to "Test123" for all users
    test_password = 'Test123'
    test_hash = make_password(test_password)
    
    for user in users:
        username = user['username']
        
        # Keep admin password as admin123
        if username == 'admin':
            password = 'admin123'
            password_hash = make_password(password)
        else:
            password = test_password
            password_hash = test_hash
        
        execute_query(
            "UPDATE users SET password_hash = %s WHERE id = %s",
            (password_hash, user['id'])
        )
        
        print(f"✅ {username:15} → Password: {password:15} Role: {user['role_name']}")
    
    print("\n" + "="*60)
    print("✅ ALL PASSWORDS UPDATED!")
    print("="*60)
    print("\nYou can now login with:\n")
    
    for user in users:
        username = user['username']
        password = 'admin123' if username == 'admin' else 'Test123'
        print(f"  Username: {username:15} Password: {password:15} Role: {user['role_name']}")
    
    print("\n" + "="*60 + "\n")

if __name__ == '__main__':
    set_test_passwords()
