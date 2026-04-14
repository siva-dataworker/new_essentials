"""
Check if sites table has data and correct columns
"""
import mysql.connector
import os
from dotenv import load_dotenv

load_dotenv()

# Database connection
conn = mysql.connector.connect(
    host=os.getenv('DB_HOST'),
    user=os.getenv('DB_USER'),
    password=os.getenv('DB_PASSWORD'),
    database=os.getenv('DB_NAME')
)

cursor = conn.cursor(dictionary=True)

print("=" * 60)
print("CHECKING SITES TABLE")
print("=" * 60)

# Check table structure
print("\n1. Table Structure:")
print("-" * 60)
cursor.execute("DESCRIBE sites")
columns = cursor.fetchall()
for col in columns:
    print(f"  {col['Field']}: {col['Type']}")

# Check if table has data
print("\n2. Row Count:")
print("-" * 60)
cursor.execute("SELECT COUNT(*) as count FROM sites")
result = cursor.fetchone()
print(f"  Total sites: {result['count']}")

# Show all sites
print("\n3. All Sites:")
print("-" * 60)
cursor.execute("SELECT * FROM sites")
sites = cursor.fetchall()

if not sites:
    print("  ❌ NO SITES FOUND IN DATABASE!")
    print("\n  You need to add sites to the database.")
    print("  Run this SQL:")
    print("""
    INSERT INTO sites (site_name, location, area, street, created_at) VALUES
    ('Site A', 'Location A', 'Area 1', 'Street 1', NOW()),
    ('Site B', 'Location B', 'Area 2', 'Street 2', NOW()),
    ('Site C', 'Location C', 'Area 1', 'Street 3', NOW());
    """)
else:
    for site in sites:
        print(f"\n  Site ID: {site.get('site_id')}")
        print(f"  Name: {site.get('site_name')}")
        print(f"  Location: {site.get('location')}")
        print(f"  Area: {site.get('area')}")
        print(f"  Street: {site.get('street')}")
        print(f"  Display Name: {site.get('site_name')} - {site.get('location')}")
        print("  " + "-" * 50)

# Check if area and street columns exist
print("\n4. Checking Required Columns:")
print("-" * 60)
column_names = [col['Field'] for col in columns]

required_columns = ['site_id', 'site_name', 'location', 'area', 'street']
for col in required_columns:
    if col in column_names:
        print(f"  ✅ {col} exists")
    else:
        print(f"  ❌ {col} MISSING!")
        if col in ['area', 'street']:
            print(f"     Run: ALTER TABLE sites ADD COLUMN {col} VARCHAR(255);")

cursor.close()
conn.close()

print("\n" + "=" * 60)
print("CHECK COMPLETE")
print("=" * 60)
