import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all

print("=" * 60)
print("MATERIAL_BILLS TABLE COLUMNS")
print("=" * 60)

cols = fetch_all("""
    SELECT column_name, data_type 
    FROM information_schema.columns 
    WHERE table_name = 'material_bills'
    ORDER BY ordinal_position
""")

for col in cols:
    print(f"{col['column_name']:30} {col['data_type']}")

print(f"\nTotal columns: {len(cols)}")
