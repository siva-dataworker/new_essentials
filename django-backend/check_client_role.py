"""
Check if Client role exists in the database
"""
import os
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all, execute_query

print("=" * 60)
print("CHECKING CLIENT ROLE IN DATABASE")
print("=" * 60)

# Check existing roles
roles = fetch_all("SELECT id, role_name FROM roles ORDER BY id")
print(f"\n📋 Existing roles in database:")
for role in roles:
    print(f"  - ID: {role['id']}, Name: {role['role_name']}")

# Check if Client role exists
client_role = fetch_all("SELECT * FROM roles WHERE LOWER(role_name) = 'client'")

if client_role:
    print(f"\n✅ Client role already exists!")
    print(f"   ID: {client_role[0]['id']}")
    print(f"   Name: {client_role[0]['role_name']}")
else:
    print(f"\n❌ Client role does NOT exist in database")
    print(f"\nTo create it, run: python create_client_role.py")

print("\n" + "=" * 60)
