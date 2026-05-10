"""
Clean all material inventory data (keep material_master for admin)
"""
import psycopg2
from dotenv import load_dotenv
import os

load_dotenv()

conn = psycopg2.connect(
    host=os.getenv('DB_HOST'),
    port=os.getenv('DB_PORT'),
    database=os.getenv('DB_NAME'),
    user=os.getenv('DB_USER'),
    password=os.getenv('DB_PASSWORD')
)
conn.autocommit = True

cursor = conn.cursor()

print("=" * 80)
print("CLEANING ALL MATERIAL INVENTORY DATA")
print("=" * 80)
print("\n⚠️  This will delete:")
print("  - material_stock (site engineer inventory)")
print("  - material_usage (supervisor daily usage)")
print("  - material_balances (calculated balances)")
print("  - material_usage_backup (backup data)")
print("\n✅ This will KEEP:")
print("  - material_master (admin materials)")
print("  - material_bills (accountant bills)")
print("  - material_requirements (supervisor requests)")

# Tables to clean
tables_to_clean = {
    'material_stock': 'Site engineer inventory',
    'material_usage': 'Supervisor daily usage',
    'material_balances': 'Calculated balances',
    'material_usage_backup': 'Backup data',
}

print("\n" + "=" * 80)
print("CURRENT RECORD COUNTS:")
print("=" * 80)

for table, description in tables_to_clean.items():
    try:
        cursor.execute(f"SELECT COUNT(*) FROM {table}")
        count = cursor.fetchone()[0]
        print(f"  {table}: {count} records ({description})")
    except Exception as e:
        print(f"  {table}: Error - {e}")

print("\n" + "=" * 80)
print("DELETING RECORDS...")
print("=" * 80)

total_deleted = 0
for table, description in tables_to_clean.items():
    try:
        cursor.execute(f"DELETE FROM {table}")
        deleted = cursor.rowcount
        total_deleted += deleted
        print(f"✅ Deleted {deleted} records from {table}")
    except Exception as e:
        print(f"❌ Error deleting from {table}: {e}")

print("\n" + "=" * 80)
print("VERIFICATION:")
print("=" * 80)

for table, description in tables_to_clean.items():
    try:
        cursor.execute(f"SELECT COUNT(*) FROM {table}")
        count = cursor.fetchone()[0]
        status = "✅" if count == 0 else "⚠️"
        print(f"{status} {table}: {count} records")
    except Exception as e:
        print(f"❌ {table}: Error - {e}")

print("\n" + "=" * 80)
print(f"✅ CLEANUP COMPLETE! Deleted {total_deleted} total records")
print("=" * 80)

# Show what was preserved
print("\nPRESERVED DATA:")
preserved_tables = {
    'material_master': 'Admin materials',
    'material_bills': 'Accountant bills',
    'material_requirements': 'Supervisor requests',
}

for table, description in preserved_tables.items():
    try:
        cursor.execute(f"SELECT COUNT(*) FROM {table}")
        count = cursor.fetchone()[0]
        print(f"  {table}: {count} records ({description})")
    except Exception as e:
        print(f"  {table}: Error - {e}")

cursor.close()
conn.close()
