"""
Check work_updates table structure
"""
import os
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all

# Check table structure
print("\n=== WORK_UPDATES TABLE STRUCTURE ===")
columns = fetch_all("""
    SELECT column_name, data_type 
    FROM information_schema.columns 
    WHERE table_name = 'work_updates'
    ORDER BY ordinal_position
""")

if columns:
    for col in columns:
        print(f"{col['column_name']}: {col['data_type']}")
else:
    print("Table not found or no columns")

# Check if table exists
print("\n=== CHECKING IF TABLE EXISTS ===")
table_exists = fetch_all("""
    SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_name = 'work_updates'
    )
""")
print(f"Table exists: {table_exists}")

# Try to get any data
print("\n=== TRYING TO GET DATA ===")
try:
    data = fetch_all("SELECT * FROM work_updates LIMIT 5")
    print(f"Rows found: {len(data) if data else 0}")
    if data:
        print("Sample row:", data[0])
except Exception as e:
    print(f"Error: {e}")
