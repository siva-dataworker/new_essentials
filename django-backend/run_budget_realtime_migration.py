"""
Run Budget and Real-time Visibility Migration
"""
import os
import sys
import django
import psycopg2
from pathlib import Path

# Setup Django
sys.path.append(str(Path(__file__).parent))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.conf import settings

def run_migration():
    """Execute the SQL migration file"""
    print("=" * 60)
    print("Budget and Real-time Visibility Migration")
    print("=" * 60)
    
    # Read SQL file
    sql_file = Path(__file__).parent / 'add_budget_realtime_schema.sql'
    
    if not sql_file.exists():
        print(f"❌ Error: SQL file not found at {sql_file}")
        return False
    
    print(f"\n📄 Reading SQL file: {sql_file.name}")
    
    with open(sql_file, 'r', encoding='utf-8') as f:
        sql_content = f.read()
    
    # Connect to database
    db_config = settings.DATABASES['default']
    
    print(f"\n🔌 Connecting to database: {db_config['NAME']} at {db_config['HOST']}")
    
    try:
        conn = psycopg2.connect(
            dbname=db_config['NAME'],
            user=db_config['USER'],
            password=db_config['PASSWORD'],
            host=db_config['HOST'],
            port=db_config['PORT'],
            sslmode='require'
        )
        
        print("✓ Connected successfully")
        
        # Execute migration
        print("\n🚀 Executing migration...")
        
        cursor = conn.cursor()
        cursor.execute(sql_content)
        conn.commit()
        
        print("✓ Migration executed successfully")
        
        # Verify tables
        print("\n🔍 Verifying tables...")
        
        tables_to_check = ['site_budgets', 'realtime_updates', 'audit_logs_enhanced']
        
        for table in tables_to_check:
            cursor.execute(f"""
                SELECT EXISTS (
                    SELECT 1 FROM information_schema.tables 
                    WHERE table_name = '{table}'
                )
            """)
            exists = cursor.fetchone()[0]
            
            if exists:
                cursor.execute(f"SELECT COUNT(*) FROM {table}")
                count = cursor.fetchone()[0]
                print(f"  ✓ {table}: exists (rows: {count})")
            else:
                print(f"  ❌ {table}: NOT FOUND")
        
        # Check labour_summary modifications
        print("\n🔍 Checking daily_labour_summary modifications...")
        cursor.execute("""
            SELECT column_name 
            FROM information_schema.columns 
            WHERE table_name = 'daily_labour_summary' 
            AND column_name IN ('is_modified', 'modified_by', 'modified_at', 'modification_reason')
            ORDER BY column_name
        """)
        
        modified_columns = cursor.fetchall()
        if modified_columns:
            print(f"  ✓ Added columns: {', '.join([col[0] for col in modified_columns])}")
        else:
            print("  ⚠ No modification columns found (table may not exist yet)")
        
        cursor.close()
        conn.close()
        
        print("\n" + "=" * 60)
        print("✅ Migration completed successfully!")
        print("=" * 60)
        
        print("\n📋 Next Steps:")
        print("  1. Update Django models to use new tables")
        print("  2. Create API endpoints for budget management")
        print("  3. Implement real-time sync service")
        print("  4. Build Flutter UI components")
        
        return True
        
    except psycopg2.Error as e:
        print(f"\n❌ Database error: {e}")
        return False
    except Exception as e:
        print(f"\n❌ Unexpected error: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == '__main__':
    success = run_migration()
    sys.exit(0 if success else 1)
