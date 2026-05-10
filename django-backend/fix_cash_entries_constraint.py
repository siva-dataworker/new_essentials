#!/usr/bin/env python
"""
Fix cash_entries table UNIQUE constraint
Current: UNIQUE(site_id, entry_date) - WRONG
Should be: UNIQUE(site_id, entry_date, labour_type) - CORRECT
"""
import os
import sys
import django

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import execute_query, fetch_all

def fix_constraint():
    """Fix the UNIQUE constraint on cash_entries table"""
    print("=" * 100)
    print("🔧 FIXING CASH_ENTRIES UNIQUE CONSTRAINT")
    print("=" * 100)
    
    # Check current constraints
    print("\n📋 Current UNIQUE constraints:")
    constraints = fetch_all("""
        SELECT 
            conname as constraint_name,
            pg_get_constraintdef(oid) as definition
        FROM pg_constraint
        WHERE conrelid = 'cash_entries'::regclass
          AND contype = 'u'
        ORDER BY conname
    """)
    
    for c in constraints:
        print(f"  - {c['constraint_name']}: {c['definition']}")
    
    # Drop the wrong constraint
    print("\n🗑️  Dropping wrong constraint: cash_entries_site_id_entry_date_key")
    try:
        execute_query("""
            ALTER TABLE cash_entries 
            DROP CONSTRAINT IF EXISTS cash_entries_site_id_entry_date_key
        """)
        print("✅ Dropped successfully")
    except Exception as e:
        print(f"❌ Error dropping constraint: {e}")
        return False
    
    # Add the correct constraint
    print("\n➕ Adding correct constraint: UNIQUE(site_id, entry_date, labour_type)")
    try:
        execute_query("""
            ALTER TABLE cash_entries 
            ADD CONSTRAINT cash_entries_site_id_entry_date_labour_type_key 
            UNIQUE (site_id, entry_date, labour_type)
        """)
        print("✅ Added successfully")
    except Exception as e:
        print(f"❌ Error adding constraint: {e}")
        return False
    
    # Verify the new constraint
    print("\n✅ New UNIQUE constraints:")
    constraints = fetch_all("""
        SELECT 
            conname as constraint_name,
            pg_get_constraintdef(oid) as definition
        FROM pg_constraint
        WHERE conrelid = 'cash_entries'::regclass
          AND contype = 'u'
        ORDER BY conname
    """)
    
    for c in constraints:
        print(f"  - {c['constraint_name']}: {c['definition']}")
    
    print("\n" + "=" * 100)
    print("✅ CONSTRAINT FIX COMPLETE!")
    print("=" * 100)
    print("\n📝 What changed:")
    print("  BEFORE: UNIQUE(site_id, entry_date) - Only 1 row per site per date")
    print("  AFTER:  UNIQUE(site_id, entry_date, labour_type) - Multiple rows per site per date")
    print("\n💡 Now you can save multiple labour types for the same site and date!")
    print("=" * 100)
    
    return True

if __name__ == '__main__':
    success = fix_constraint()
    sys.exit(0 if success else 1)
