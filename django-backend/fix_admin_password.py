"""
Fix admin password - Set it to 'admin123' using Django's password hasher
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
from api.database import execute_query, fetch_one

def fix_admin_password():
    """Fix admin password to 'admin123'"""
    print("\n" + "="*60)
    print("FIXING ADMIN PASSWORD")
    print("="*60 + "\n")
    
    # Check if admin exists
    admin = fetch_one("SELECT id, username, password_hash FROM users WHERE username = 'admin'")
    
    if not admin:
        print("❌ Admin user not found!")
        return
    
    print(f"✅ Found admin user: {admin['username']}")
    print(f"   Current password hash: {admin['password_hash'][:50]}...")
    print()
    
    # Generate new password hash for 'admin123'
    new_password = 'admin123'
    new_hash = make_password(new_password)
    
    print(f"🔧 Generating new password hash for: {new_password}")
    print(f"   New hash: {new_hash[:50]}...")
    print()
    
    # Update password
    execute_query(
        "UPDATE users SET password_hash = %s WHERE username = 'admin'",
        (new_hash,)
    )
    
    print("✅ Password updated successfully!")
    print()
    print("You can now login with:")
    print("  Username: admin")
    print("  Password: admin123")
    print()
    print("="*60 + "\n")

if __name__ == '__main__':
    fix_admin_password()
