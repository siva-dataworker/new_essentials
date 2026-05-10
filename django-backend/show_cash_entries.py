import os
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all

print("=" * 100)
print("CASH ENTRIES TABLE - STRUCTURE AND DATA")
print("=" * 100)

# Show table structure
print("\n📋 TABLE STRUCTURE:")
print("-" * 100)
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

if columns:
    print(f"{'Column Name':<25} {'Data Type':<20} {'Nullable':<10} {'Default':<30}")
    print("-" * 100)
    for col in columns:
        col_name = col['column_name']
        data_type = col['data_type']
        if col['character_maximum_length']:
            data_type += f"({col['character_maximum_length']})"
        nullable = 'YES' if col['is_nullable'] == 'YES' else 'NO'
        default = col['column_default'] or ''
        print(f"{col_name:<25} {data_type:<20} {nullable:<10} {default:<30}")
else:
    print("❌ Table 'cash_entries' does not exist yet. Run create_cash_entries_table.py first.")
    exit(1)

# Show constraints
print("\n🔒 CONSTRAINTS:")
print("-" * 100)
constraints = fetch_all("""
    SELECT
        tc.constraint_name,
        tc.constraint_type,
        kcu.column_name,
        ccu.table_name AS foreign_table_name,
        ccu.column_name AS foreign_column_name
    FROM information_schema.table_constraints AS tc
    LEFT JOIN information_schema.key_column_usage AS kcu
        ON tc.constraint_name = kcu.constraint_name
        AND tc.table_schema = kcu.table_schema
    LEFT JOIN information_schema.constraint_column_usage AS ccu
        ON ccu.constraint_name = tc.constraint_name
        AND ccu.table_schema = tc.table_schema
    WHERE tc.table_name = 'cash_entries'
    ORDER BY tc.constraint_type, tc.constraint_name
""")

if constraints:
    for c in constraints:
        constraint_type = c['constraint_type']
        constraint_name = c['constraint_name']
        column = c['column_name'] or 'N/A'
        
        if constraint_type == 'FOREIGN KEY':
            foreign_ref = f" -> {c['foreign_table_name']}.{c['foreign_column_name']}"
        else:
            foreign_ref = ""
        
        print(f"  {constraint_type:<15} {constraint_name:<40} Column: {column}{foreign_ref}")

# Show indexes
print("\n📊 INDEXES:")
print("-" * 100)
indexes = fetch_all("""
    SELECT
        indexname,
        indexdef
    FROM pg_indexes
    WHERE tablename = 'cash_entries'
    ORDER BY indexname
""")

if indexes:
    for idx in indexes:
        print(f"  {idx['indexname']}")
        print(f"    {idx['indexdef']}")
else:
    print("  No indexes found")

# Show data
print("\n📦 DATA (Recent 20 entries):")
print("-" * 100)
entries = fetch_all("""
    SELECT 
        ce.id,
        s.site_name,
        s.customer_name,
        ce.entry_date,
        ce.source_type,
        ce.labour_type,
        ce.labour_count,
        ce.daily_rate,
        ce.total_cost,
        ce.submitted_by_name,
        u.full_name as accountant_name,
        ce.created_at
    FROM cash_entries ce
    JOIN sites s ON ce.site_id = s.id
    JOIN users u ON ce.accountant_id = u.id
    ORDER BY ce.created_at DESC
    LIMIT 20
""")

if entries:
    print(f"\nTotal entries found: {len(entries)}")
    print("-" * 100)
    
    for i, entry in enumerate(entries, 1):
        site_display = f"{entry['customer_name']} {entry['site_name']}"
        print(f"\n{i}. {site_display}")
        print(f"   Date: {entry['entry_date']}")
        print(f"   Source: {entry['source_type']}")
        print(f"   Labour: {entry['labour_type']} x {entry['labour_count']} @ ₹{entry['daily_rate']}/day = ₹{entry['total_cost']}")
        if entry['submitted_by_name']:
            print(f"   Originally by: {entry['submitted_by_name']}")
        print(f"   Confirmed by: {entry['accountant_name']}")
        print(f"   Created: {entry['created_at']}")
else:
    print("\n  No cash entries found yet.")

# Show summary statistics
print("\n📈 SUMMARY STATISTICS:")
print("-" * 100)
stats = fetch_one("""
    SELECT 
        COUNT(DISTINCT site_id) as total_sites,
        COUNT(DISTINCT entry_date) as total_dates,
        COUNT(*) as total_entries,
        SUM(total_cost) as total_amount,
        COUNT(CASE WHEN source_type = 'supervisor' THEN 1 END) as supervisor_entries,
        COUNT(CASE WHEN source_type = 'site_engineer' THEN 1 END) as engineer_entries,
        COUNT(CASE WHEN source_type = 'accountant_created' THEN 1 END) as custom_entries
    FROM cash_entries
""")

if stats and stats['total_entries'] > 0:
    print(f"  Total Sites: {stats['total_sites']}")
    print(f"  Total Dates: {stats['total_dates']}")
    print(f"  Total Entries: {stats['total_entries']}")
    print(f"  Total Amount: ₹{stats['total_amount']:,.2f}")
    print(f"\n  By Source Type:")
    print(f"    Supervisor: {stats['supervisor_entries']}")
    print(f"    Site Engineer: {stats['engineer_entries']}")
    print(f"    Custom (Accountant): {stats['custom_entries']}")
else:
    print("  No data available for statistics")

print("\n" + "=" * 100)
