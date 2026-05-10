#!/usr/bin/env python3
"""
Delete all labour entries, cash entries, and total salary records
WARNING: This will permanently delete all data from these tables
"""
import os
import django
import sys

# Setup Django
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_one, execute_query

def delete_all_entries():
    """Delete all entries from labour_entries, cash_entries, and total_salary tables"""
    
    print("=" * 60)
    print("⚠️  WARNING: DELETE ALL ENTRIES")
    print("=" * 60)
    print("\nThis will permanently delete:")
    print("  - All labour entries")
    print("  - All cash entries")
    print("  - All total salary records")
    print("\n⚠️  THIS CANNOT BE UNDONE!")
    print("=" * 60)
    
    # Get current counts
    print("\n📊 Current database state:")
    try:
        labour_count = fetch_one("SELECT COUNT(*) as count FROM labour_entries")
        cash_count = fetch_one("SELECT COUNT(*) as count FROM cash_entries")
        salary_count = fetch_one("SELECT COUNT(*) as count FROM total_salary")
        
        print(f"  - Labour entries: {labour_count['count']}")
        print(f"  - Cash entries: {cash_count['count']}")
        print(f"  - Total salary records: {salary_count['count']}")
        
        total_records = labour_count['count'] + cash_count['count'] + salary_count['count']
        
        if total_records == 0:
            print("\n✅ All tables are already empty. Nothing to delete.")
            return
        
    except Exception as e:
        print(f"❌ Error checking counts: {e}")
        return
    
    # Confirmation prompt
    print("\n" + "=" * 60)
    confirmation = input("Type 'DELETE ALL' to confirm deletion: ")
    
    if confirmation != 'DELETE ALL':
        print("\n❌ Deletion cancelled. No data was deleted.")
        return
    
    print("\n🗑️  Starting deletion...")
    
    # Delete in order (respecting foreign key constraints)
    deleted_counts = {}
    
    # 1. Delete total_salary (no foreign key dependencies)
    try:
        print("\n1. Deleting total_salary records...")
        execute_query("DELETE FROM total_salary")
        result = fetch_one("SELECT COUNT(*) as count FROM total_salary")
        deleted_counts['total_salary'] = salary_count['count']
        print(f"   ✅ Deleted {deleted_counts['total_salary']} total_salary records")
        print(f"   Remaining: {result['count']}")
    except Exception as e:
        print(f"   ❌ Error deleting total_salary: {e}")
        deleted_counts['total_salary'] = 0
    
    # 2. Delete cash_entries (references labour_entries via source_entry_id)
    try:
        print("\n2. Deleting cash_entries records...")
        execute_query("DELETE FROM cash_entries")
        result = fetch_one("SELECT COUNT(*) as count FROM cash_entries")
        deleted_counts['cash_entries'] = cash_count['count']
        print(f"   ✅ Deleted {deleted_counts['cash_entries']} cash_entries records")
        print(f"   Remaining: {result['count']}")
    except Exception as e:
        print(f"   ❌ Error deleting cash_entries: {e}")
        deleted_counts['cash_entries'] = 0
    
    # 3. Delete labour_entries (parent table)
    try:
        print("\n3. Deleting labour_entries records...")
        execute_query("DELETE FROM labour_entries")
        result = fetch_one("SELECT COUNT(*) as count FROM labour_entries")
        deleted_counts['labour_entries'] = labour_count['count']
        print(f"   ✅ Deleted {deleted_counts['labour_entries']} labour_entries records")
        print(f"   Remaining: {result['count']}")
    except Exception as e:
        print(f"   ❌ Error deleting labour_entries: {e}")
        deleted_counts['labour_entries'] = 0
    
    # Summary
    print("\n" + "=" * 60)
    print("DELETION COMPLETE")
    print("=" * 60)
    print("\n📊 Deletion summary:")
    print(f"  ✅ Labour entries deleted: {deleted_counts.get('labour_entries', 0)}")
    print(f"  ✅ Cash entries deleted: {deleted_counts.get('cash_entries', 0)}")
    print(f"  ✅ Total salary records deleted: {deleted_counts.get('total_salary', 0)}")
    print(f"\n  📦 Total records deleted: {sum(deleted_counts.values())}")
    
    # Verify all tables are empty
    print("\n🔍 Verifying deletion...")
    try:
        labour_check = fetch_one("SELECT COUNT(*) as count FROM labour_entries")
        cash_check = fetch_one("SELECT COUNT(*) as count FROM cash_entries")
        salary_check = fetch_one("SELECT COUNT(*) as count FROM total_salary")
        
        if labour_check['count'] == 0 and cash_check['count'] == 0 and salary_check['count'] == 0:
            print("  ✅ All tables are now empty")
        else:
            print("  ⚠️  Some records may remain:")
            if labour_check['count'] > 0:
                print(f"     - Labour entries: {labour_check['count']}")
            if cash_check['count'] > 0:
                print(f"     - Cash entries: {cash_check['count']}")
            if salary_check['count'] > 0:
                print(f"     - Total salary: {salary_check['count']}")
    except Exception as e:
        print(f"  ❌ Error verifying: {e}")
    
    print("\n✅ Deletion process complete!")
    print("\n💡 Note: The tables still exist, only the data was deleted.")
    print("   You can add new entries through the app.")

if __name__ == '__main__':
    delete_all_entries()
