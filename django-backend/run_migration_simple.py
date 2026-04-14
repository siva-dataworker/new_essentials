"""
Simple migration script to add extra_cost columns
Run this from django-backend folder: python run_migration_simple.py
"""
import os
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.db import connection

def run_migration():
    """Add extra_cost columns to labour_entries and material_balances"""
    
    print("=" * 50)
    print("Adding Extra Cost Columns to Database")
    print("=" * 50)
    print()
    
    try:
        with connection.cursor() as cursor:
            print("🔄 Adding extra_cost to labour_entries...")
            
            # Add columns to labour_entries
            cursor.execute("""
                ALTER TABLE labour_entries 
                ADD COLUMN IF NOT EXISTS extra_cost DECIMAL(10, 2) DEFAULT 0 CHECK (extra_cost >= 0),
                ADD COLUMN IF NOT EXISTS extra_cost_notes TEXT;
            """)
            
            print("✅ labour_entries updated")
            print()
            print("🔄 Adding extra_cost to material_balances...")
            
            # Add columns to material_balances
            cursor.execute("""
                ALTER TABLE material_balances 
                ADD COLUMN IF NOT EXISTS extra_cost DECIMAL(10, 2) DEFAULT 0 CHECK (extra_cost >= 0),
                ADD COLUMN IF NOT EXISTS extra_cost_notes TEXT;
            """)
            
            print("✅ material_balances updated")
            print()
            print("🔄 Creating indexes...")
            
            # Create indexes
            cursor.execute("""
                CREATE INDEX IF NOT EXISTS idx_labour_extra_cost 
                ON labour_entries(extra_cost) WHERE extra_cost > 0;
            """)
            
            cursor.execute("""
                CREATE INDEX IF NOT EXISTS idx_material_extra_cost 
                ON material_balances(extra_cost) WHERE extra_cost > 0;
            """)
            
            print("✅ Indexes created")
            print()
            print("🔍 Verifying changes...")
            
            # Verify labour_entries
            cursor.execute("""
                SELECT column_name, data_type, column_default
                FROM information_schema.columns 
                WHERE table_name = 'labour_entries'
                    AND column_name IN ('extra_cost', 'extra_cost_notes', 'entry_time')
                ORDER BY column_name;
            """)
            
            print()
            print("📊 Labour Entries Columns:")
            for row in cursor.fetchall():
                print(f"  ✓ {row[0]}: {row[1]} (default: {row[2]})")
            
            # Verify material_balances
            cursor.execute("""
                SELECT column_name, data_type, column_default
                FROM information_schema.columns 
                WHERE table_name = 'material_balances'
                    AND column_name IN ('extra_cost', 'extra_cost_notes', 'updated_at')
                ORDER BY column_name;
            """)
            
            print()
            print("📦 Material Balances Columns:")
            for row in cursor.fetchall():
                print(f"  ✓ {row[0]}: {row[1]} (default: {row[2]})")
            
            print()
            print("=" * 50)
            print("✅ Migration Completed Successfully!")
            print("=" * 50)
            print()
            print("Next steps:")
            print("1. Restart Django backend (if running)")
            print("2. Test the API with extra_cost fields")
            print("3. Update Flutter frontend to use new fields")
            print()
            
    except Exception as e:
        print()
        print("=" * 50)
        print("❌ Migration Failed!")
        print("=" * 50)
        print()
        print(f"Error: {e}")
        print()
        print("This might mean:")
        print("- Columns already exist (safe to ignore)")
        print("- Database connection issue")
        print("- Permission issue")
        print()
        raise

if __name__ == '__main__':
    run_migration()
