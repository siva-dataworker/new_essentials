#!/usr/bin/env python
"""
Create a test architect user
"""
import os
import sys
import django
from datetime import datetime
import uuid

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import execute_query, fetch_one
from django.contrib.auth.hashers import make_password

def create_test_architect():
    """Create a test architect user"""
    try:
        # Check if architect role exists
        role = fetch_one("SELECT id FROM roles WHERE id = 6")
        if not role:
            print("❌ Architect role (ID=6) not found")
            return False
        
        # Check if architect already exists
        existing = fetch_one("""
            SELECT id, username FROM users 
            WHERE username = 'architect1' OR email = 'architect@test.com'
        """)
        
        if existing:
            print(f"✅ Architect already exists: {existing['username']}")
            print(f"   ID: {existing['id']}")
            return True
        
        # Create architect user
        architect_id = str(uuid.uuid4())
        password_hash = make_password('test123')
        
        execute_query("""
            INSERT INTO users (
                id, username, password, email, full_name, 
                phone, role_id, is_active, created_at
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (
            architect_id,
            'architect1',
            password_hash,
            'architect@test.com',
            'Test Architect',
            '9876543210',
            6,  # Architect role
            True,
            datetime.now()
        ))
        
        print("✅ Test architect created successfully!")
        print(f"   Username: architect1")
        print(f"   Password: test123")
        print(f"   Email: architect@test.com")
        print(f"   ID: {architect_id}")
        
        # Assign architect to all sites (for testing)
        sites = fetch_one("SELECT COUNT(*) as count FROM sites")
        site_count = sites['count'] if sites else 0
        
        if site_count > 0:
            # Note: architect_documents table is used to track which sites an architect works on
            print(f"\n📝 Note: Architect can be assigned to sites via architect_documents table")
            print(f"   Total sites available: {site_count}")
        
        return True
        
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == '__main__':
    print("=" * 70)
    print("Creating Test Architect User")
    print("=" * 70)
    
    success = create_test_architect()
    
    if success:
        print("\n✅ Setup complete!")
        print("\nYou can now:")
        print("1. Login as architect (username: architect1, password: test123)")
        print("2. Select a site")
        print("3. View client complaints for that site")
    else:
        print("\n❌ Failed to create test architect")
        sys.exit(1)
