"""
Delete all material inventory/stock records
"""
import psycopg2
from dotenv import load_dotenv
import os

load_dotenv()

# Database connection
conn = psycopg2.connect(
    host=os.getenv('DB_HOST'),
    port=os.getenv('DB_PORT'),
    database=os.getenv('DB_NAME'),
    user=os.getenv('DB_USER'),
    password=os.getenv('DB_PASSWORD')
)
conn.autocommit = True  # Enable autocommit to avoid transaction issues

cursor = conn.cursor()

print("=" * 80)
print("DELETING ALL MATERIAL INVENTORY RECORDS")
print("=" * 80)

# Check which tables exist
cursor.execute("""
    SELECT table_name 
    FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name LIKE '%material%'
    ORDER BY table_name
""")
existing_tables = [row[0] for row in cursor.fetchall()]

print("\nExisting material-related tables:")
for table in existing_tables:
    print(f"  - {table}")

# Tables to clean (only inventory/stock, not master)
tables_to_clean = [
    'material_stock',
    'material_stock_history',
    'material_usage_history',
]

print("\n" + "=" * 80)
print("CURRENT RECORD COUNTS:")
print("=" * 80)

for table in tables_to_clean:
    if table in existing_tables:
        try:
            cursor.execute(f"SELECT COUNT(*) FROM {table}")
            count = cursor.fetchone()[0]
            print(f"  {table}: {count} records")
        except Exception as e:
            print(f"  {table}: Error - {e}")
    else:
        print(f"  {table}: Table does not exist (skipping)")

print("\n" + "=" * 80)
print("DELETING RECORDS...")
print("=" * 80)

# Delete from each table that exists
for table in tables_to_clean:
    if table in existing_tables:
        try:
            cursor.execute(f"DELETE FROM {table}")
            deleted = cursor.rowcount
            print(f"✅ Deleted {deleted} records from {table}")
        except Exception as e:
            print(f"❌ Error deleting from {table}: {e}")
    else:
        print(f"⏭️  Skipped {table} (table does not exist)")

print("\n" + "=" * 80)
print("VERIFICATION - Record counts after deletion:")
print("=" * 80)

for table in tables_to_clean:
    if table in existing_tables:
        try:
            cursor.execute(f"SELECT COUNT(*) FROM {table}")
            count = cursor.fetchone()[0]
            print(f"  {table}: {count} records")
        except Exception as e:
            print(f"  {table}: Error - {e}")

print("\n✅ Material inventory cleanup complete!")
print("\nNote: material_master table was NOT deleted (admin materials preserved)")

cursor.close()
conn.close()
