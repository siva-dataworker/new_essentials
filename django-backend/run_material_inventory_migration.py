#!/usr/bin/env python3
"""
Material Inventory System Migration Script
Adds material stock tracking and usage management
"""

import os
import sys
import django
from pathlib import Path

# Add the project directory to the Python path
project_dir = Path(__file__).resolve().parent
sys.path.insert(0, str(project_dir))

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.db import connection
from django.conf import settings

def run_migration():
    """Run the material inventory system migration"""
    
    print("=" * 60)
    print("MATERIAL INVENTORY SYSTEM MIGRATION")
    print("=" * 60)
    
    # Read the SQL file
    sql_file = project_dir / 'add_material_inventory_system.sql'
    
    if not sql_file.exists():
        print(f"❌ Error: SQL file not found at {sql_file}")
        return False
    
    print(f"\n📄 Reading SQL file: {sql_file.name}")
    
    with open(sql_file, 'r', encoding='utf-8') as f:
        sql_content = f.read()
    
    # Execute the SQL
    print("\n🔄 Executing migration...")
    
    try:
        with connection.cursor() as cursor:
            cursor.execute(sql_content)
        
        print("\n✅ Migration completed successfully!")
        print("\n📊 Created:")
        print("   - material_stock table (inventory)")
        print("   - material_usage table (consumption tracking)")
        print("   - material_balance_view (automatic balance calculation)")
        print("   - material_usage_history view")
        print("   - low_stock_alerts view")
        print("   - update_material_stock() function")
        print("   - record_material_usage() function")
        
        # Verify tables were created
        print("\n🔍 Verifying tables...")
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT table_name 
                FROM information_schema.tables 
                WHERE table_schema = 'public' 
                AND table_name IN ('material_stock', 'material_usage')
                ORDER BY table_name;
            """)
            tables = cursor.fetchall()
            
            if len(tables) == 2:
                print("✅ All tables created successfully:")
                for table in tables:
                    print(f"   - {table[0]}")
            else:
                print(f"⚠️  Warning: Expected 2 tables, found {len(tables)}")
        
        # Verify views were created
        print("\n🔍 Verifying views...")
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT table_name 
                FROM information_schema.views 
                WHERE table_schema = 'public' 
                AND table_name IN ('material_balance_view', 'material_usage_history', 'low_stock_alerts')
                ORDER BY table_name;
            """)
            views = cursor.fetchall()
            
            if len(views) == 3:
                print("✅ All views created successfully:")
                for view in views:
                    print(f"   - {view[0]}")
            else:
                print(f"⚠️  Warning: Expected 3 views, found {len(views)}")
        
        print("\n" + "=" * 60)
        print("MIGRATION SUMMARY")
        print("=" * 60)
        print("\n✅ Material inventory system is now ready!")
        print("\n📝 Next steps:")
        print("   1. Update Django models to include new tables")
        print("   2. Create API endpoints for material management")
        print("   3. Update Flutter UI to show material inventory")
        print("   4. Test material stock and usage tracking")
        print("\n💡 Usage examples:")
        print("   - Add stock: update_material_stock(site_id, 'Cement', 100, 'Bags', user_id)")
        print("   - Record usage: record_material_usage(site_id, supervisor_id, 'Cement', 10, 'Bags', date)")
        print("   - Check balance: SELECT * FROM material_balance_view WHERE site_id = 'your-site-id'")
        print("   - Low stock alerts: SELECT * FROM low_stock_alerts")
        
        return True
        
    except Exception as e:
        print(f"\n❌ Error during migration: {str(e)}")
        print("\n💡 Troubleshooting:")
        print("   1. Check database connection in .env file")
        print("   2. Ensure you have proper database permissions")
        print("   3. Check if tables already exist")
        return False

if __name__ == '__main__':
    print("\n🚀 Starting material inventory system migration...\n")
    success = run_migration()
    
    if success:
        print("\n🎉 Migration completed successfully!")
        sys.exit(0)
    else:
        print("\n❌ Migration failed!")
        sys.exit(1)
