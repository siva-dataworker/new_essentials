#!/usr/bin/env python
"""
Verify cash_entries table - Check if table exists and show its structure
"""
import os
import sys
import django

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_one, fetch_all

def verify_cash_entries_table():
    """Verify the cash_entries table"""
    print("🔍 Verifying cash_entries table...\n")
    
    try:
        # Check if table exists
        result = fetch_one("""
            SELECT COUNT(*) as count
            FROM information_schema.tables
            WHERE table_schema = 'public' AND table_name = 'cash_entries'
        """)
        
        if result and result['count'] > 0:
            print("✅ cash_entries table EXISTS\n")
            
            # Show table structure
            columns = fetch_all("""
                SELECT 
                    column_name, 
                    data_type, 
                    is_nullable,
                    column_default
                FROM information_schema.columns
                WHERE table_name = 'cash_entries'
                ORDER BY ordinal_position
            """)
            
            print("📋 Table Structure:")
            print(f"{'Column Name':<25} {'Data Type':<20} {'Nullable':<10} {'Default':<30}")
            print("-" * 85)
            for col in columns:
                col_name = col['column_name']
                data_type = col['data_type']
                nullable = "YES" if col['is_nullable'] == 'YES' else "NO"
                default = col['column_default'] or ''
                print(f"{col_name:<25} {data_type:<20} {nullable:<10} {default:<30}")
            
            # Show constraints
            print("\n🔒 Constraints:")
            constraints = fetch_all("""
                SELECT 
                    conname as constraint_name,
                    contype as constraint_type
                FROM pg_constraint
                WHERE conrelid = 'cash_entries'::regclass
                ORDER BY conname
            """)
            
            constraint_types = {
                'p': 'PRIMARY KEY',
                'f': 'FOREIGN KEY',
                'u': 'UNIQUE',
                'c': 'CHECK'
            }
            
            for c in constraints:
                ctype = constraint_types.get(c['constraint_type'], c['constraint_type'])
                print(f"  - {c['constraint_name']}: {ctype}")
            
            # Show indexes
            print("\n📊 Indexes:")
            indexes = fetch_all("""
                SELECT indexname, indexdef
                FROM pg_indexes
                WHERE tablename = 'cash_entries'
                ORDER BY indexname
            """)
            
            for idx in indexes:
                print(f"  - {idx['indexname']}")
            
            # Count records
            count_result = fetch_one("SELECT COUNT(*) as count FROM cash_entries")
            record_count = count_result['count'] if count_result else 0
            print(f"\n📊 Total Records: {record_count}")
            
            if record_count > 0:
                print("\n📝 Sample Data (first 5 records):")
                samples = fetch_all("""
                    SELECT 
                        ce.id,
                        s.customer_name || ' ' || s.site_name as site_name,
                        ce.entry_date,
                        ce.labour_type,
                        ce.labour_count,
                        ce.daily_rate,
                        ce.total_cost,
                        ce.source_type
                    FROM cash_entries ce
                    JOIN sites s ON ce.site_id = s.id
                    ORDER BY ce.created_at DESC
                    LIMIT 5
                """)
                
                for sample in samples:
                    print(f"\n  Site: {sample['site_name']}")
                    print(f"  Date: {sample['entry_date']}")
                    print(f"  Labour: {sample['labour_type']} × {sample['labour_count']} @ ₹{sample['daily_rate']}")
                    print(f"  Total: ₹{sample['total_cost']}")
                    print(f"  Source: {sample['source_type']}")
            
            print("\n✅ Verification complete!")
            
        else:
            print("❌ cash_entries table DOES NOT EXIST")
            print("\n💡 To create the table, run:")
            print("   python create_cash_entries_table.py")
            
    except Exception as e:
        print(f"❌ Error verifying table: {str(e)}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == '__main__':
    verify_cash_entries_table()
