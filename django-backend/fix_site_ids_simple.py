import sys
import os
import django

sys.path.append(os.path.dirname(__file__))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import get_db_connection

print("\n" + "="*60)
print("🔧 FIXING NULL SITE IDs")
print("="*60)

conn = get_db_connection()
cursor = conn.cursor()

# Check current state
print("\n📊 BEFORE FIX:")
cursor.execute("SELECT COUNT(*) FROM labour_entries WHERE site_id IS NULL")
null_labour = cursor.fetchone()[0]
print(f"   Labour entries with NULL site_id: {null_labour}")

cursor.execute("SELECT COUNT(*) FROM material_balances WHERE site_id IS NULL")
null_material = cursor.fetchone()[0]
print(f"   Material entries with NULL site_id: {null_material}")

if null_labour == 0 and null_material == 0:
    print("\n✅ No NULL site_ids found!")
    cursor.close()
    conn.close()
    exit(0)

# Get first site
cursor.execute("SELECT id, site_name FROM sites LIMIT 1")
site = cursor.fetchone()

if not site:
    print("\n❌ No sites found!")
    cursor.close()
    conn.close()
    exit(1)

site_id, site_name = site
print(f"\n📍 Assigning to: {site_name} (ID: {site_id})")

# Fix labour entries
if null_labour > 0:
    print(f"\n🔧 Fixing {null_labour} labour entries...")
    cursor.execute("UPDATE labour_entries SET site_id = %s WHERE site_id IS NULL", (site_id,))
    conn.commit()
    print(f"   ✅ Fixed!")

# Fix material entries
if null_material > 0:
    print(f"\n🔧 Fixing {null_material} material entries...")
    cursor.execute("UPDATE material_balances SET site_id = %s WHERE site_id IS NULL", (site_id,))
    conn.commit()
    print(f"   ✅ Fixed!")

# Verify
print("\n📊 AFTER FIX:")
cursor.execute("SELECT COUNT(*) FROM labour_entries WHERE site_id IS NULL")
print(f"   Labour with NULL: {cursor.fetchone()[0]}")

cursor.execute("SELECT COUNT(*) FROM material_balances WHERE site_id IS NULL")
print(f"   Material with NULL: {cursor.fetchone()[0]}")

cursor.close()
conn.close()

print("\n✅ DONE! Hot restart Flutter app now.\n")
