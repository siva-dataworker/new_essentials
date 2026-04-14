import psycopg2
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

cursor = conn.cursor()

print("\n" + "="*60)
print("🔍 DEBUGGING HISTORY DATA")
print("="*60)

# Check sites
print("\n📍 SITES:")
cursor.execute("SELECT id, site_name, area, street FROM sites ORDER BY id LIMIT 5")
sites = cursor.fetchall()
for site in sites:
    print(f"  ID: {site[0]} (type: {type(site[0]).__name__}) - {site[1]} ({site[2]}, {site[3]})")

# Check labour entries
print("\n👷 LABOUR ENTRIES:")
cursor.execute("""
    SELECT le.id, le.site_id, s.site_name, le.labour_type, le.labour_count, le.entry_date
    FROM labour_entries le
    LEFT JOIN sites s ON le.site_id = s.id
    ORDER BY le.entry_date DESC
    LIMIT 10
""")
labour = cursor.fetchall()
if labour:
    for entry in labour:
        print(f"  Entry ID: {entry[0]}, Site ID: {entry[1]} (type: {type(entry[1]).__name__}) - {entry[2]} - {entry[3]}: {entry[4]} on {entry[5]}")
else:
    print("  ❌ No labour entries found")

# Check material entries
print("\n📦 MATERIAL ENTRIES:")
cursor.execute("""
    SELECT mb.id, mb.site_id, s.site_name, mb.material_type, mb.quantity, mb.entry_date
    FROM material_balances mb
    LEFT JOIN sites s ON mb.site_id = s.id
    ORDER BY mb.entry_date DESC
    LIMIT 10
""")
materials = cursor.fetchall()
if materials:
    for entry in materials:
        print(f"  Entry ID: {entry[0]}, Site ID: {entry[1]} (type: {type(entry[1]).__name__}) - {entry[2]} - {entry[3]}: {entry[4]} on {entry[5]}")
else:
    print("  ❌ No material entries found")

# Check user assignments
print("\n👤 USER SITE ASSIGNMENTS:")
cursor.execute("""
    SELECT u.id, u.email, u.role, u.assigned_sites
    FROM users u
    WHERE u.role = 'SUPERVISOR'
    LIMIT 5
""")
users = cursor.fetchall()
for user in users:
    print(f"  User: {user[1]} ({user[2]}) - Assigned Sites: {user[3]}")

cursor.close()
conn.close()

print("\n" + "="*60)
print("✅ Debug complete!")
print("="*60 + "\n")
