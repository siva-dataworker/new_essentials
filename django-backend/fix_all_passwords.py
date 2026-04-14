"""
Fix all user passwords - Update to Django's password format
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

def fix_all_passwords():
    """Fix all user passwords"""
    print("\n" + "="*60)
    print("FIXING ALL USER PASSWORDS")
    print("="*60 + "\n")
    
    # Get all users
    users = fetch_all("""
        SELECT u.id, u.username, u.email, u.password_hash, r.role_name
        FROM users u
        LEFT JOIN roles r ON u.role_id = r.id
        ORDER BY u.username
    """)
    
    if not users:
        print("❌ No users found!")
        return
    
    print(f"Found {len(users)} user(s)\n")
    
    # Default passwords for each user
    default_passwords = {
        'admin': 'admin123',
        'nsjskakaka': 'Test123',
        'nsnwjw': 'Test123'
    }
    
    fixed_count = 0
    
    for user in users:
        username = user['username']
        current_hash = user['password_hash']
        
        print(f"User: {username}")
        print(f"  Email: {user['email']}")
        print(f"  Role: {user['role_name']}")
        print(f"  Current hash: {current_hash[:50]}...")
        
        # Check if password needs fixing (bcrypt format or needs update)
        if current_hash.startswith('$2b$') or current_hash.startswith('$2a$'):
            # Set default password
            new_password = default_passwords.get(username, 'Test123')
            new_hash = make_password(new_password)
            
            execute_query(
                "UPDATE users SET password_hash = %s WHERE id = %s",
                (new_hash, user['id'])
            )
            
            print(f"  ✅ FIXED - New password: {new_password}")
            print(f"  New hash: {new_hash[:50]}...")
            fixed_count += 1
        else:
            print(f"  ✅ Already in correct format")
        
        print()
    
    print("="*60)
    print(f"✅ Fixed {fixed_count} user password(s)")
    print("="*60)
    print("\nYou can now login with these credentials:\n")
    
    for user in users:
        username = user['username']
        password = default_passwords.get(username, 'Test123')
        print(f"  Username: {username:15} Password: {password:15} Role: {user['role_name']}")
    
    print("\n" + "="*60 + "\n")

if __name__ == '__main__':
    fix_all_passwords()
