"""
Create Client role in the database
"""
import os
import django
import uuid

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_one, execute_query
from django.utils import timezone

print("=" * 60)
print("CREATING CLIENT ROLE")
print("=" * 60)

# Check if Client role already exists
existing_role = fetch_one("SELECT * FROM roles WHERE LOWER(role_name) = 'client'")

if existing_role:
    print(f"\n⚠️  Client role already exists!")
    print(f"   ID: {existing_role['id']}")
    print(f"   Name: {existing_role['role_name']}")
else:
    # Create Client role
    role_id = str(uuid.uuid4())
    execute_query("""
        INSERT INTO roles (id, role_name, created_at)
        VALUES (%s, %s, %s)
    """, (role_id, 'Client', timezone.now()))
    
    print(f"\n✅ Client role created successfully!")
    print(f"   ID: {role_id}")
    print(f"   Name: Client")
    
    # Verify
    new_role = fetch_one("SELECT * FROM roles WHERE id = %s", (role_id,))
    if new_role:
        print(f"\n✓ Verified in database:")
        print(f"   ID: {new_role['id']}")
        print(f"   Name: {new_role['role_name']}")
        print(f"   Created: {new_role['created_at']}")

print("\n" + "=" * 60)
print("CURRENT ROLES IN DATABASE:")
print("=" * 60)

roles = fetch_one("SELECT COUNT(*) as count FROM roles")
print(f"\nTotal roles: {roles['count']}")

all_roles = execute_query("SELECT id, role_name, created_at FROM roles ORDER BY created_at")
for role in all_roles:
    print(f"  - {role['role_name']} (ID: {role['id']})")

print("\n" + "=" * 60)
