#!/usr/bin/env python
"""
Check cash_entries table structure - show all columns
"""
import os
import sys
import django

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all, fetch_one

def check_cash_entries_columns():
    """Check cash_entries table structure"""
    print("=" * 100)
    print("📊 CASH_ENTRIES TABLE STRUCTURE")
    print("=" * 100)
    
    # Check if table exists
    table_exists = fetch_one("""
        SELECT COUNT(*) as count
        FROM information_schema.tables
        WHERE table_schema = 'public' AND table_name = 'cash_entries'
    """)
    
    if not table_exists or table_exists['count'] == 0:
        print("\n❌ cash_entries table does NOT exist!")
        print("\n💡 Run this command to create it:")
        print("   python create_cash_entries_table.py")
        return
    
    print("\n✅ Table exists: cash_entries\n")
    
    # Get column information
    columns = fetch_all("""
        SELECT 
            column_name,
            data_type,
            character_maximum_length,
            is_nullable,
            column_default
        FROM information_schema.columns
        WHERE table_name = 'cash_entries'
        ORDER BY ordinal_position
    """)
    
    print(f"{'Column Name':<25} {'Data Type':<20} {'Nullable':<10} {'Default':<30}")
    print("-" * 100)
    
    for col in columns:
        col_name = col['column_name']
        data_type = col['data_type']
        
        # Add length for varchar
        if col['character_maximum_length']:
            data_type += f"({col['character_maximum_length']})"
        
        nullable = "YES" if col['is_nullable'] == 'YES' else "NO"
        default = col['column_default'] or ''
        
        # Truncate long defaults
        if len(default) > 30:
            default = default[:27] + '...'
        
        print(f"{col_name:<25} {data_type:<20} {nullable:<10} {default:<30}")
    
    # Show constraints
    print("\n" + "=" * 100)
    print("🔒 CONSTRAINTS")
    print("=" * 100 + "\n")
    
    constraints = fetch_all("""
        SELECT 
            conname as constraint_name,
            contype as constraint_type,
            pg_get_constraintdef(oid) as definition
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
        print(f"{ctype:<15} {c['constraint_name']}")
        print(f"                {c['definition']}")
        print()
    
    # Show indexes
    print("=" * 100)
    print("📊 INDEXES")
    print("=" * 100 + "\n")
    
    indexes = fetch_all("""
        SELECT 
            indexname,
            indexdef
        FROM pg_indexes
        WHERE tablename = 'cash_entries'
        ORDER BY indexname
    """)
    
    for idx in indexes:
        print(f"Index: {idx['indexname']}")
        print(f"  {idx['indexdef']}")
        print()
    
    # Show row count
    count_result = fetch_one("SELECT COUNT(*) as count FROM cash_entries")
    row_count = count_result['count'] if count_result else 0
    
    print("=" * 100)
    print(f"📊 TOTAL ROWS: {row_count}")
    print("=" * 100)
    
    if row_count > 0:
        print("\n📝 Sample Data (first 3 rows):\n")
        samples = fetch_all("""
            SELECT 
                id,
                site_id,
                entry_date,
                labour_type,
                labour_count,
                daily_rate,
                total_cost,
                source_type
            FROM cash_entries
            ORDER BY created_at DESC
            LIMIT 3
        """)
        
        for i, sample in enumerate(samples, 1):
            print(f"Row {i}:")
            print(f"  ID: {sample['id']}")
            print(f"  Site ID: {sample['site_id']}")
            print(f"  Date: {sample['entry_date']}")
            print(f"  Labour: {sample['labour_type']} × {sample['labour_count']}")
            print(f"  Rate: ₹{sample['daily_rate']}")
            print(f"  Total: ₹{sample['total_cost']}")
            print(f"  Source: {sample['source_type']}")
            print()
    else:
        print("\n✅ Table is empty (no data)")
    
    print("=" * 100)
    print("✅ Check complete!")
    print("=" * 100)

if __name__ == '__main__':
    check_cash_entries_columns()
