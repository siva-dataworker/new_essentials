"""
Create a test Client user for testing
"""
import os
import django
import uuid

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_one, execute_query
from django.utils import timezone
from django.contrib.auth.hashers import make_password

print("=" * 60)
print("CREATING TEST CLIENT USER")
print("=" * 60)

# Get Client role ID
client_role = fetch_one("SELECT id FROM roles WHERE LOWER(role_name) = 'client'")

if not client_role:
    print("\n❌ Client role does not exist!")
    print("   Please run: python create_client_role.py first")
    exit(1)

client_role_id = client_role['id']
print(f"\n✓ Found Client role: {client_role_id}")

# Check if test client already exists
existing_user = fetch_one("SELECT * FROM users WHERE username = 'testclient'")

if existing_user:
    print(f"\n⚠️  Test client user already exists!")
    print(f"   Username: testclient")
    print(f"   Email: {existing_user['email']}")
    print(f"   Status: {'Approved' if existing_user['is_approved'] else 'Pending'}")
else:
    # Create test client user
    user_id = str(uuid.uuid4())
    username = 'testclient'
    email = 'testclient@example.com'
    password = 'client123'  # Plain text password
    hashed_password = make_password(password)
    full_name = 'Test Client User'
    phone = '1234567890'
    
    execute_query("""
        INSERT INTO users (
            id, username, email, password, full_name, phone, 
            role_id, is_approved, is_active, created_at
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """, (
        user_id, username, email, hashed_password, full_name, phone,
        client_role_id, True, True, timezone.now()
    ))
    
    print(f"\n✅ Test client user created successfully!")
    print(f"\n📋 Login Credentials:")
    print(f"   Username: {username}")
    print(f"   Password: {password}")
    print(f"   Email: {email}")
    print(f"   Full Name: {full_name}")
    print(f"   Status: Approved (can login immediately)")
    
    # Verify
    new_user = fetch_one("SELECT * FROM users WHERE id = %s", (user_id,))
    if new_user:
        print(f"\n✓ Verified in database:")
        print(f"   ID: {new_user['id']}")
        print(f"   Username: {new_user['username']}")
        print(f"   Role ID: {new_user['role_id']}")
        print(f"   Approved: {new_user['is_approved']}")

print("\n" + "=" * 60)
print("TESTING INSTRUCTIONS")
print("=" * 60)
print("""
1. Open your Flutter app
2. Go to Login screen
3. Enter credentials:
   - Username: testclient
   - Password: client123
4. Click Login
5. You should see: "Client dashboard is not yet implemented"
6. User stays on login screen (no navigation)

This confirms the Client role is working correctly!
""")
print("=" * 60)
