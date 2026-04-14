#!/usr/bin/env python
"""
Clean Material Inventory Data
Run this to remove all existing material data
"""

import os
import sys
import django

# Add the project directory to the path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.db import connection

def clean_materials():
    print("\n" + "="*60)
    print("CLEANING MATERIAL INVENTORY DATA")
    print("="*60 + "\n")
    
    try:
        with connection.cursor() as cursor:
            # Show current data
            print("📊 Current material stock:")
            cursor.execute("""
                SELECT 
                    s.site_name,
                    ms.material_type,
                    ms.total_quantity,
                    ms.unit
                FROM material_stock ms
                JOIN sites s ON ms.site_id = s.id
                ORDER BY s.site_name, ms.material_type
            """)
            
            materials = cursor.fetchall()
            if materials:
                for site, mat_type, qty, unit in materials:
                    print(f"  - {site}: {mat_type} ({qty} {unit})")
            else:
                print("  No materials found")
            
            print("\n🧹 Cleaning data...")
            
            # Delete material usage
            cursor.execute("DELETE FROM material_usage")
            usage_deleted = cursor.rowcount
            print(f"  ✅ Deleted {usage_deleted} usage records")
            
            # Delete material stock
            cursor.execute("DELETE FROM material_stock")
            stock_deleted = cursor.rowcount
            print(f"  ✅ Deleted {stock_deleted} stock records")
            
            print("\n✅ CLEANUP COMPLETE!")
            print("\n📝 Next steps:")
            print("  1. Login as Site Engineer")
            print("  2. Add materials (e.g., Sand 2000 kg)")
            print("  3. Login as Supervisor")
            print("  4. You'll see ONLY the materials Site Engineer added")
            
    except Exception as e:
        print(f"\n❌ Error: {e}")
        import traceback
        traceback.print_exc()
        return False
    
    print("\n" + "="*60 + "\n")
    return True

if __name__ == '__main__':
    clean_materials()
