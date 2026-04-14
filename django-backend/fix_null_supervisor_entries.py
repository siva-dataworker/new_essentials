"""
Delete labour and material entries with NULL supervisor_id
These were created before the JWT fix
"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import execute_query, fetch_all

print("\n" + "=" * 70)
print("CLEANING UP NULL SUPERVISOR ENTRIES")
print("=" * 70)

# Check current entries
print("\n1. Checking current entries...")
labour = fetch_all("SELECT COUNT(*) as count FROM labour_entries WHERE supervisor_id IS NULL")
material = fetch_all("SELECT COUNT(*) as count FROM material_balances WHERE supervisor_id IS NULL")

print(f"   Labour entries with NULL supervisor_id: {labour[0]['count']}")
print(f"   Material entries with NULL supervisor_id: {material[0]['count']}")

# Delete them
print("\n2. Deleting entries with NULL supervisor_id...")
execute_query("DELETE FROM labour_entries WHERE supervisor_id IS NULL")
execute_query("DELETE FROM material_balances WHERE supervisor_id IS NULL")

print("   ✅ Deleted successfully!")

# Verify
print("\n3. Verifying deletion...")
labour_after = fetch_all("SELECT COUNT(*) as count FROM labour_entries")
material_after = fetch_all("SELECT COUNT(*) as count FROM material_balances")

print(f"   Remaining labour entries: {labour_after[0]['count']}")
print(f"   Remaining material entries: {material_after[0]['count']}")

print("\n" + "=" * 70)
print("✅ CLEANUP COMPLETE!")
print("=" * 70)
print("\nNow the user needs to:")
print("1. Stop the backend (Ctrl+C)")
print("2. Restart the backend: python manage.py runserver 0.0.0.0:8000")
print("3. Login again on the mobile app")
print("4. Submit new labour entries")
print("5. Check history - it should now show the entries!")
print("=" * 70 + "\n")
