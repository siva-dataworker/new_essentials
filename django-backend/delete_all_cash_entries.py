#!/usr/bin/env python
"""
Delete ALL data from cash_entries table
WARNING: This will delete all accountant-confirmed labour entries!
"""
import os
import sys
import django

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import execute_query, fetch_one, fetch_all

def delete_all_cash_entries():
    """Delete all data from cash_entries table"""
    print("🔍 Checking cash_entries table...")
    
    # Count current entries
    count_result = fetch_one("SELECT COUNT(*) as count FROM cash_entries")
    total_count = count_result['count'] if count_result else 0
    
    if total_count == 0:
        print("✅ cash_entries table is already empty!")
        return
    
    print(f"\n📊 Found {total_count} entries in cash_entries table")
    
    # Show sample data
    print("\n📝 Sample entries (first 10):")
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
        LIMIT 10
    """)
    
    for entry in samples:
        print(f"\n  Site: {entry['site_name']}")
        print(f"  Date: {entry['entry_date']}")
        print(f"  Labour: {entry['labour_type']} × {entry['labour_count']} @ ₹{entry['daily_rate']}")
        print(f"  Total: ₹{entry['total_cost']}")
        print(f"  Source: {entry['source_type']}")
    
    if total_count > 10:
        print(f"\n  ... and {total_count - 10} more entries")
    
    # Confirm deletion
    print("\n" + "=" * 80)
    print("⚠️  WARNING: This will DELETE ALL data from cash_entries table!")
    print("=" * 80)
    print("\nThis means:")
    print("  ❌ All accountant-confirmed labour entries will be deleted")
    print("  ❌ Budget utilization will show ₹0 for labour costs")
    print("  ❌ This action CANNOT be undone!")
    print("\nYou will need to:")
    print("  ✅ Go to Accountant Compare screen")
    print("  ✅ Select and confirm entries again")
    print("  ✅ Budget utilization will then show the new data")
    print()
    
    response = input("Are you SURE you want to delete ALL cash entries? (type 'DELETE ALL' to confirm): ")
    
    if response != 'DELETE ALL':
        print("\n❌ Deletion cancelled")
        print("   (You must type 'DELETE ALL' exactly to confirm)")
        return
    
    # Delete all entries
    print("\n🗑️  Deleting all cash entries...")
    execute_query("DELETE FROM cash_entries")
    
    # Verify deletion
    verify_count = fetch_one("SELECT COUNT(*) as count FROM cash_entries")
    remaining = verify_count['count'] if verify_count else 0
    
    if remaining == 0:
        print(f"\n✅ Successfully deleted {total_count} entries!")
        print("\n📊 cash_entries table is now empty")
        print("\n📱 Next steps:")
        print("   1. Restart Django backend (Ctrl+C and run again)")
        print("   2. Refresh Flutter app (press 'R' in terminal)")
        print("   3. Login as Accountant")
        print("   4. Go to Compare screen")
        print("   5. Select and confirm entries")
        print("   6. Check Admin Budget Utilization")
    else:
        print(f"\n⚠️  Warning: {remaining} entries still remain!")
        print("   There might be a database issue")

if __name__ == '__main__':
    delete_all_cash_entries()
