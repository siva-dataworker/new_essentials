"""
Check if user IDs match between login and database entries
"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all, fetch_one

print("\n" + "=" * 70)
print("CHECKING USER ID MISMATCH")
print("=" * 70)

# Get the supervisor who just logged in
print("\n1. Checking logged in user (nsnwjw)...")
user = fetch_one("""
    SELECT u.id, u.username, u.full_name
    FROM users u
    WHERE u.username = 'nsnwjw'
""")

if user:
    print(f"   User ID: {user['id']}")
    print(f"   Username: {user['username']}")
    print(f"   Name: {user['full_name']}")
    user_id = user['id']
else:
    print("   ❌ User not found!")
    exit(1)

# Check labour entries for this user
print(f"\n2. Checking labour entries for user ID: {user_id}...")
labour = fetch_all("""
    SELECT id, labour_type, labour_count, supervisor_id
    FROM labour_entries
    WHERE supervisor_id = %s
""", (user_id,))

print(f"   Found {len(labour)} labour entries")
for entry in labour:
    print(f"   - {entry['labour_type']}: {entry['labour_count']} (supervisor_id: {entry['supervisor_id']})")

# Check ALL labour entries to see which supervisor_ids exist
print(f"\n3. Checking ALL labour entries in database...")
all_labour = fetch_all("""
    SELECT l.id, l.labour_type, l.labour_count, l.supervisor_id,
           u.username, u.full_name
    FROM labour_entries l
    LEFT JOIN users u ON l.supervisor_id = u.id
""")

print(f"   Total labour entries: {len(all_labour)}")
for entry in all_labour:
    print(f"   - {entry['labour_type']}: {entry['labour_count']}")
    print(f"     Supervisor ID: {entry['supervisor_id']}")
    print(f"     Username: {entry['username']}")
    print(f"     Name: {entry['full_name']}")
    print()

# Check if there's a mismatch
print("\n4. Diagnosis:")
if len(labour) == 0 and len(all_labour) > 0:
    print("   ❌ MISMATCH FOUND!")
    print(f"   - User '{user['username']}' has ID: {user_id}")
    print(f"   - But labour entries have different supervisor_ids")
    print("\n   This is why history is empty!")
    print("\n   The entries were created with a different user ID.")
elif len(labour) > 0:
    print("   ✅ No mismatch - entries exist for this user")
else:
    print("   ⚠️ No entries in database at all")

print("\n" + "=" * 70)
