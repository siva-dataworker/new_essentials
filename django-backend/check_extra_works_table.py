"""
Check extra_works table structure
"""
import os
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all

# Check table structure
print("\n=== EXTRA_WORKS TABLE STRUCTURE ===")
columns = fetch_all("""
    SELECT column_name, data_type 
    FROM information_schema.columns 
    WHERE table_name = 'extra_works'
    ORDER BY ordinal_position
""")

if columns:
    for col in columns:
        print(f"{col['column_name']}: {col['data_type']}")
else:
    print("Table not found")

# Check if table exists
table_exists = fetch_all("""
    SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_name = 'extra_works'
    )
""")
print(f"\nTable exists: {table_exists[0]['exists'] if table_exists else False}")
