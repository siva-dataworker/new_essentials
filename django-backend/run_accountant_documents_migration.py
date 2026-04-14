"""
Run migration to add accountant documents system
(Material Bills, Vendor Bills, Site Agreements)
"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import execute_query

print("=" * 60)
print("ADDING ACCOUNTANT DOCUMENTS SYSTEM")
print("=" * 60)

# Read SQL file
with open('add_accountant_documents_system.sql', 'r') as f:
    sql = f.read()

# Execute SQL
try:
    print("\n📝 Creating tables...")
    execute_query(sql)
    print("✅ Tables created successfully!")
    
    print("\n📊 Verifying tables...")
    
    from api.database import fetch_all
    
    # Check material_bills table
    result = fetch_all("""
        SELECT column_name, data_type 
        FROM information_schema.columns 
        WHERE table_name = 'material_bills'
        ORDER BY ordinal_position
    """)
    print(f"✅ material_bills table: {len(result)} columns")
    
    # Check vendor_bills table
    result = fetch_all("""
        SELECT column_name, data_type 
        FROM information_schema.columns 
        WHERE table_name = 'vendor_bills'
        ORDER BY ordinal_position
    """)
    print(f"✅ vendor_bills table: {len(result)} columns")
    
    # Check site_agreements table
    result = fetch_all("""
        SELECT column_name, data_type 
        FROM information_schema.columns 
        WHERE table_name = 'site_agreements'
        ORDER BY ordinal_position
    """)
    print(f"✅ site_agreements table: {len(result)} columns")
    
    print("\n" + "=" * 60)
    print("✅ MIGRATION COMPLETE!")
    print("=" * 60)
    print("\nTables created:")
    print("1. material_bills - For material vendor bills")
    print("2. vendor_bills - For service provider bills")
    print("3. site_agreements - For signed agreements")
    
except Exception as e:
    print(f"\n❌ Error: {e}")
    print("\nIf tables already exist, this is normal.")

