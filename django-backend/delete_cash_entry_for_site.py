#!/usr/bin/env python
"""
Delete cash entry for a specific site and date
This allows accountant to select a different entry
"""
import os
import sys
import django
from datetime import date

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import execute_query, fetch_all, fetch_one

def delete_cash_entry():
    """Delete cash entry for today"""
    print("🔍 Finding cash entries for today...")
    
    # Show all cash entries for today
    today = date.today()
    entries = fetch_all("""
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
        WHERE ce.entry_date = %s
        ORDER BY s.site_name, ce.labour_type
    """, (today,))
    
    if not entries:
        print(f"❌ No cash entries found for {today}")
        return
    
    print(f"\n📊 Found {len(entries)} cash entries for {today}:\n")
    
    # Group by site
    sites = {}
    for entry in entries:
        site_name = entry['site_name']
        if site_name not in sites:
            sites[site_name] = []
        sites[site_name].append(entry)
    
    # Display entries
    for site_name, site_entries in sites.items():
        print(f"🏗️  {site_name}")
        total = 0
        for entry in site_entries:
            print(f"   - {entry['labour_type']}: {entry['labour_count']} × ₹{entry['daily_rate']} = ₹{entry['total_cost']}")
            total += float(entry['total_cost'])
        print(f"   Total: ₹{total}")
        print(f"   Source: {site_entries[0]['source_type']}")
        print()
    
    # Confirm deletion
    print("⚠️  WARNING: This will delete ALL cash entries for today!")
    print("   You can then select a different entry in the Compare screen.")
    print()
    response = input("Do you want to delete these entries? (yes/no): ")
    
    if response.lower() != 'yes':
        print("❌ Deletion cancelled")
        return
    
    # Delete entries
    execute_query("""
        DELETE FROM cash_entries
        WHERE entry_date = %s
    """, (today,))
    
    print(f"\n✅ Deleted {len(entries)} cash entries for {today}")
    print("\n📱 Next steps:")
    print("   1. Go to Accountant Compare screen")
    print("   2. Select the Supervisor's entry (green card)")
    print("   3. Click 'Confirm Selection'")
    print("   4. Check Admin Budget Utilization")
    print("   5. Should now show all 4 labour types!")

if __name__ == '__main__':
    delete_cash_entry()
