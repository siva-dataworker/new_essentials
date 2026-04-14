"""
Check sites table using Django ORM
"""
import os
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.db import connection

def dict_fetchall(cursor):
    columns = [col[0] for col in cursor.description]
    return [dict(zip(columns, row)) for row in cursor.fetchall()]

print("=" * 60)
print("CHECKING SITES TABLE")
print("=" * 60)

with connection.cursor() as cursor:
    # Check table structure (PostgreSQL syntax)
    print("\n1. Table Structure:")
    print("-" * 60)
    cursor.execute("""
        SELECT column_name, data_type 
        FROM information_schema.columns 
        WHERE table_name = 'sites'
        ORDER BY ordinal_position
    """)
    columns = dict_fetchall(cursor)
    for col in columns:
        print(f"  {col['column_name']}: {col['data_type']}")
    
    # Check row count
    print("\n2. Row Count:")
    print("-" * 60)
    cursor.execute("SELECT COUNT(*) as count FROM sites")
    result = cursor.fetchone()
    print(f"  Total sites: {result[0]}")
    
    # Show all sites
    print("\n3. All Sites:")
    print("-" * 60)
    cursor.execute("SELECT * FROM sites")
    sites = dict_fetchall(cursor)
    
    if not sites:
        print("  ❌ NO SITES FOUND IN DATABASE!")
        print("\n  You need to add sites. Run this SQL:")
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
            display_name = f"{site.get('site_name')} - {site.get('location') or ''}"
            print(f"  Display Name: {display_name}")
            print("  " + "-" * 50)
    
    # Check required columns
    print("\n4. Checking Required Columns:")
    print("-" * 60)
    column_names = [col['column_name'] for col in columns]
    
    required_columns = ['site_id', 'site_name', 'location', 'area', 'street']
    missing_columns = []
    
    for col in required_columns:
        if col in column_names:
            print(f"  ✅ {col} exists")
        else:
            print(f"  ❌ {col} MISSING!")
            missing_columns.append(col)
    
    if missing_columns:
        print("\n  To add missing columns, run:")
        for col in missing_columns:
            if col in ['area', 'street']:
                print(f"  ALTER TABLE sites ADD COLUMN {col} VARCHAR(255);")

print("\n" + "=" * 60)
print("CHECK COMPLETE")
print("=" * 60)
