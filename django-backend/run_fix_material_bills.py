import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.db import connection

print("=" * 60)
print("FIXING MATERIAL_BILLS TABLE SCHEMA")
print("=" * 60)

# Read SQL file
with open('fix_material_bills_schema.sql', 'r') as f:
    sql = f.read()

# Execute SQL
try:
    with connection.cursor() as cursor:
        cursor.execute(sql)
    print("✅ Schema updated successfully!")
    
    # Verify columns
    from api.database import fetch_all
    
    cols = fetch_all("""
        SELECT column_name 
        FROM information_schema.columns 
        WHERE table_name = 'material_bills'
        ORDER BY ordinal_position
    """)
    
    print(f"\n✅ material_bills table now has {len(cols)} columns")
    
    # Check for required columns
    required_cols = ['vendor_type', 'tax_amount', 'discount_amount', 'final_amount', 'payment_mode', 'uploaded_by']
    col_names = [c['column_name'] for c in cols]
    
    print("\nRequired columns:")
    for col in required_cols:
        status = "✅" if col in col_names else "❌"
        print(f"  {status} {col}")
    
except Exception as e:
    print(f"❌ Error: {e}")

print("\n" + "=" * 60)
print("✅ SCHEMA FIX COMPLETE!")
print("=" * 60)
