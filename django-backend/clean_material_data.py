"""
Clean Material Inventory Data
Run this script to remove all existing material data and start fresh
"""

import os
import django
import sys

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.db import connection

def clean_material_data():
    """Remove all material inventory data"""
    print("🧹 Cleaning material inventory data...")
    
    try:
        with connection.cursor() as cursor:
            # Delete all material usage records
            cursor.execute("DELETE FROM material_usage")
            usage_deleted = cursor.rowcount
            print(f"✅ Deleted {usage_deleted} material usage records")
            
            # Delete all material stock records
            cursor.execute("DELETE FROM material_stock")
            stock_deleted = cursor.rowcount
            print(f"✅ Deleted {stock_deleted} material stock records")
            
            # Verify tables are empty
            cursor.execute("SELECT COUNT(*) FROM material_stock")
            stock_count = cursor.fetchone()[0]
            
            cursor.execute("SELECT COUNT(*) FROM material_usage")
            usage_count = cursor.fetchone()[0]
            
            print(f"\n📊 Current counts:")
            print(f"   Material stock: {stock_count}")
            print(f"   Material usage: {usage_count}")
            
            if stock_count == 0 and usage_count == 0:
                print("\n✅ Material inventory data cleaned successfully!")
                print("\n📝 Next steps:")
                print("   1. Login as Site Engineer")
                print("   2. Add only Sand (2000 kg)")
                print("   3. Login as Supervisor")
                print("   4. You should see ONLY Sand in dropdown")
            else:
                print("\n⚠️ Warning: Some data still remains")
                
    except Exception as e:
        print(f"\n❌ Error cleaning data: {e}")
        return False
    
    return True

def show_current_materials():
    """Show what materials currently exist"""
    print("\n🔍 Current materials in database:")
    
    try:
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT 
                    s.site_name,
                    s.customer_name,
                    ms.material_type,
                    ms.total_quantity,
                    ms.unit
                FROM material_stock ms
                JOIN sites s ON ms.site_id = s.id
                ORDER BY s.site_name, ms.material_type
            """)
            
            materials = cursor.fetchall()
            
            if not materials:
                print("   No materials found")
            else:
                print(f"\n   Found {len(materials)} material(s):")
                for material in materials:
                    site_name, customer_name, mat_type, quantity, unit = material
                    print(f"   - {site_name} ({customer_name}): {mat_type} - {quantity} {unit}")
                    
    except Exception as e:
        print(f"   Error: {e}")

if __name__ == '__main__':
    print("=" * 60)
    print("Material Inventory Data Cleanup")
    print("=" * 60)
    
    # Show current materials
    show_current_materials()
    
    # Ask for confirmation
    print("\n⚠️  WARNING: This will delete ALL material inventory data!")
    response = input("\nDo you want to continue? (yes/no): ")
    
    if response.lower() in ['yes', 'y']:
        clean_material_data()
    else:
        print("\n❌ Cleanup cancelled")
    
    print("\n" + "=" * 60)
