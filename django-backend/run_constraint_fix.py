"""
Script to remove UNIQUE constraint from labour_entries table
Run with: python run_constraint_fix.py
"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import execute_query, fetch_all

print("=" * 60)
print("FIXING LABOUR_ENTRIES UNIQUE CONSTRAINT")
print("=" * 60)

# Check if constraint exists
print("\n1. Checking for existing constraints...")
constraints = fetch_all("""
    SELECT conname, contype 
    FROM pg_constraint 
    WHERE conrelid = 'labour_entries'::regclass
""")

print(f"Found {len(constraints)} constraints:")
for c in constraints:
    print(f"  - {c['conname']}: {c['contype']}")

# Drop the UNIQUE constraint
print("\n2. Dropping UNIQUE constraint...")
success = execute_query("""
    ALTER TABLE labour_entries 
    DROP CONSTRAINT IF EXISTS labour_entries_site_id_entry_date_key
""")

if success:
    print("✅ Constraint dropped successfully!")
else:
    print("❌ Failed to drop constraint")

# Verify
print("\n3. Verifying constraints after fix...")
constraints_after = fetch_all("""
    SELECT conname, contype 
    FROM pg_constraint 
    WHERE conrelid = 'labour_entries'::regclass
""")

print(f"Remaining constraints: {len(constraints_after)}")
for c in constraints_after:
    print(f"  - {c['conname']}: {c['contype']}")

print("\n" + "=" * 60)
print("FIX COMPLETE!")
print("Now restart Django backend:")
print("  python manage.py runserver 192.168.1.7:8000")
print("=" * 60)
