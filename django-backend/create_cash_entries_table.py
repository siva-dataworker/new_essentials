#!/usr/bin/env python
"""
Create cash_entries table in the database
Run this script to create the table for accountant-confirmed labour entries
"""
import os
import sys
import django

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import execute_query, fetch_one

def create_cash_entries_table():
    """Create the cash_entries table"""
    print("🔧 Creating cash_entries table...")
    
    # Read SQL file
    sql_file = os.path.join(os.path.dirname(__file__), 'create_cash_entries_table.sql')
    with open(sql_file, 'r') as f:
        sql = f.read()
    
    try:
        # Execute SQL
        execute_query(sql)
        print("✅ cash_entries table created successfully!")
        
        # Verify table exists
        result = fetch_one("""
            SELECT COUNT(*) as count
            FROM information_schema.tables
            WHERE table_name = 'cash_entries'
        """)
        
        if result and result['count'] > 0:
            print("✅ Table verified in database")
            
            # Show table structure
            columns = fetch_one("""
                SELECT column_name, data_type, is_nullable
                FROM information_schema.columns
                WHERE table_name = 'cash_entries'
                ORDER BY ordinal_position
            """)
            
            if columns:
                print("\n📋 Table structure:")
                print("  Columns:")
                from api.database import fetch_all
                all_columns = fetch_all("""
                    SELECT column_name, data_type, is_nullable
                    FROM information_schema.columns
                    WHERE table_name = 'cash_entries'
                    ORDER BY ordinal_position
                """)
                for col in all_columns:
                    nullable = "NULL" if col['is_nullable'] == 'YES' else "NOT NULL"
                    print(f"    - {col['column_name']}: {col['data_type']} ({nullable})")
        else:
            print("❌ Table not found after creation")
            
    except Exception as e:
        print(f"❌ Error creating table: {str(e)}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == '__main__':
    create_cash_entries_table()
