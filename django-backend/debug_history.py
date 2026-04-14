"""
Debug script to check labour and material entries in database
"""
import psycopg2
from psycopg2.extras import RealDictCursor
import os
from dotenv import load_dotenv

load_dotenv()

# Database connection
conn = psycopg2.connect(
    host=os.getenv('DB_HOST'),
    database=os.getenv('DB_NAME'),
    user=os.getenv('DB_USER'),
    password=os.getenv('DB_PASSWORD'),
    port=os.getenv('DB_PORT', 5432)
)

cursor = conn.cursor(cursor_factory=RealDictCursor)

print("=" * 60)
print("CHECKING DATABASE TABLES AND DATA")
print("=" * 60)

# Check if tables exist
print("\n1. Checking if tables exist...")
cursor.execute("""
    SELECT table_name 
    FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name IN ('labour_entries', 'material_balances', 'sites', 'users')
    ORDER BY table_name
""")
tables = cursor.fetchall()
print(f"Found tables: {[t['table_name'] for t in tables]}")

# Check labour_entries table structure
print("\n2. Checking labour_entries table structure...")
cursor.execute("""
    SELECT column_name, data_type 
    FROM information_schema.columns 
    WHERE table_name = 'labour_entries'
    ORDER BY ordinal_position
""")
columns = cursor.fetchall()
print("Labour entries columns:")
for col in columns:
    print(f"  - {col['column_name']}: {col['data_type']}")

# Check material_balances table structure
print("\n3. Checking material_balances table structure...")
cursor.execute("""
    SELECT column_name, data_type 
    FROM information_schema.columns 
    WHERE table_name = 'material_balances'
    ORDER BY ordinal_position
""")
columns = cursor.fetchall()
print("Material balances columns:")
for col in columns:
    print(f"  - {col['column_name']}: {col['data_type']}")

# Count entries
print("\n4. Counting entries...")
cursor.execute("SELECT COUNT(*) as count FROM labour_entries")
labour_count = cursor.fetchone()['count']
print(f"Labour entries: {labour_count}")

cursor.execute("SELECT COUNT(*) as count FROM material_balances")
material_count = cursor.fetchone()['count']
print(f"Material balances: {material_count}")

# Show recent labour entries
print("\n5. Recent labour entries (last 5)...")
cursor.execute("""
    SELECT 
        l.id,
        l.labour_type,
        l.labour_count,
        l.entry_date,
        l.entry_time,
        s.site_name,
        u.full_name as supervisor_name
    FROM labour_entries l
    LEFT JOIN sites s ON l.site_id = s.id
    LEFT JOIN users u ON l.supervisor_id = u.id
    ORDER BY l.entry_time DESC
    LIMIT 5
""")
entries = cursor.fetchall()
if entries:
    for entry in entries:
        print(f"  - {entry['labour_type']}: {entry['labour_count']} workers")
        print(f"    Site: {entry['site_name']}")
        print(f"    Supervisor: {entry['supervisor_name']}")
        print(f"    Date: {entry['entry_date']}, Time: {entry['entry_time']}")
        print()
else:
    print("  No labour entries found")

# Show recent material entries
print("\n6. Recent material entries (last 5)...")
cursor.execute("""
    SELECT 
        m.id,
        m.material_type,
        m.quantity,
        m.unit,
        m.entry_date,
        m.updated_at,
        s.site_name,
        u.full_name as supervisor_name
    FROM material_balances m
    LEFT JOIN sites s ON m.site_id = s.id
    LEFT JOIN users u ON m.supervisor_id = u.id
    ORDER BY m.updated_at DESC
    LIMIT 5
""")
entries = cursor.fetchall()
if entries:
    for entry in entries:
        print(f"  - {entry['material_type']}: {entry['quantity']} {entry['unit']}")
        print(f"    Site: {entry['site_name']}")
        print(f"    Supervisor: {entry['supervisor_name']}")
        print(f"    Date: {entry['entry_date']}, Updated: {entry['updated_at']}")
        print()
else:
    print("  No material entries found")

# Check users
print("\n7. Checking users (supervisors)...")
cursor.execute("""
    SELECT u.id, u.username, u.full_name, r.role_name
    FROM users u
    JOIN roles r ON u.role_id = r.id
    WHERE r.role_name = 'Supervisor'
    AND u.status = 'APPROVED'
""")
supervisors = cursor.fetchall()
print(f"Found {len(supervisors)} approved supervisors:")
for sup in supervisors:
    print(f"  - {sup['username']} ({sup['full_name']}) - ID: {sup['id']}")

# Check sites
print("\n8. Checking sites...")
cursor.execute("SELECT id, site_name, area, street FROM sites LIMIT 5")
sites = cursor.fetchall()
print(f"Found {len(sites)} sites:")
for site in sites:
    print(f"  - {site['site_name']} ({site['area']}, {site['street']}) - ID: {site['id']}")

print("\n" + "=" * 60)
print("DEBUG COMPLETE")
print("=" * 60)

cursor.close()
conn.close()
