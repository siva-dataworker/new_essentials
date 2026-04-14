#!/usr/bin/env python3
"""
Test the history API to see if January 26, 2026 entries are visible
This simulates what the Flutter app would see when loading history
"""

import os
import sys
import django

# Add the project directory to Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all, fetch_one

def test_history_api_for_jan_26():
    print("📱 TESTING HISTORY API FOR JANUARY 26, 2026")
    print("=" * 50)
    
    # Find Rahman site
    rahman_site = fetch_one("""
        SELECT id, site_name, customer_name, area, street 
        FROM sites 
        WHERE customer_name LIKE %s
        LIMIT 1
    """, ('%Rahman%',))
    
    if not rahman_site:
        print("❌ Rahman site not found!")
        return
    
    site_id = str(rahman_site['id'])
    print(f"🏗️  Site: {rahman_site['customer_name']} {rahman_site['site_name']}")
    print(f"🆔 Site ID: {site_id}")
    
    # This simulates the history API call that the Flutter app makes
    print(f"\n📊 SIMULATING HISTORY API CALL...")
    
    # Get all entries grouped by date (this is what the history screen does)
    history_query = """
        SELECT 
            entry_date,
            day_of_week,
            'labour' as entry_type,
            labour_type as type_name,
            labour_count as count_value,
            entry_time as timestamp,
            notes,
            extra_cost,
            extra_cost_notes
        FROM labour_entries 
        WHERE site_id = %s
        
        UNION ALL
        
        SELECT 
            entry_date,
            day_of_week,
            'material' as entry_type,
            material_type as type_name,
            quantity as count_value,
            updated_at as timestamp,
            '' as notes,
            extra_cost,
            extra_cost_notes
        FROM material_balances 
        WHERE site_id = %s
        
        ORDER BY entry_date DESC, timestamp DESC
    """
    
    all_entries = fetch_all(history_query, (site_id, site_id))
    
    print(f"📋 Total entries found: {len(all_entries)}")
    
    # Group by date (like the Flutter app does)
    entries_by_date = {}
    for entry in all_entries:
        date_key = entry['entry_date']
        if date_key not in entries_by_date:
            entries_by_date[date_key] = {
                'date': date_key,
                'day_of_week': entry['day_of_week'],
                'entries': []
            }
        entries_by_date[date_key]['entries'].append(entry)
    
    print(f"\n📅 ENTRIES GROUPED BY DATE:")
    for date_key in sorted(entries_by_date.keys(), reverse=True):
        date_group = entries_by_date[date_key]
        entry_count = len(date_group['entries'])
        
        print(f"\n📅 {date_group['day_of_week']}, {date_key.strftime('%B %d, %Y')} ({entry_count} entries)")
        
        for entry in sorted(date_group['entries'], key=lambda x: x['timestamp'], reverse=True):
            time_str = entry['timestamp'].strftime('%I:%M %p') if entry['timestamp'] else 'No time'
            
            if entry['entry_type'] == 'labour':
                print(f"  👷 {entry['type_name']}: {int(entry['count_value'])} workers - {time_str}")
            else:
                print(f"  📦 {entry['type_name']}: {entry['count_value']} - {time_str}")
    
    # Check specifically for January 26, 2026
    jan_26_entries = [entry for entry in all_entries if entry['entry_date'].strftime('%Y-%m-%d') == '2026-01-26']
    
    print(f"\n🎯 JANUARY 26, 2026 SPECIFIC CHECK:")
    print(f"📊 Entries found for Jan 26, 2026: {len(jan_26_entries)}")
    
    if jan_26_entries:
        print(f"✅ SUCCESS: January 26, 2026 entries are visible in history!")
        print(f"📱 Flutter app should show:")
        print(f"   📅 Monday, January 26, 2026 ({len(jan_26_entries)} entries)")
        
        labour_entries = [e for e in jan_26_entries if e['entry_type'] == 'labour']
        material_entries = [e for e in jan_26_entries if e['entry_type'] == 'material']
        
        print(f"   👷 Labour entries: {len(labour_entries)}")
        print(f"   📦 Material entries: {len(material_entries)}")
        
        print(f"\n📋 DETAILED BREAKDOWN:")
        for entry in sorted(jan_26_entries, key=lambda x: x['timestamp']):
            time_str = entry['timestamp'].strftime('%I:%M %p')
            icon = "👷" if entry['entry_type'] == 'labour' else "📦"
            print(f"   {icon} {entry['type_name']}: {entry['count_value']} - {time_str}")
    else:
        print(f"❌ PROBLEM: No entries found for January 26, 2026!")
        print(f"   This means the history screen will be empty for that date.")
    
    print(f"\n🔍 TROUBLESHOOTING INFO:")
    print(f"Site ID used: {site_id}")
    print(f"Total entries in database: {len(all_entries)}")
    print(f"Unique dates with entries: {len(entries_by_date)}")
    
    return len(jan_26_entries) > 0

if __name__ == "__main__":
    success = test_history_api_for_jan_26()
    if success:
        print(f"\n✅ RESULT: History API test PASSED")
        print(f"📱 January 26, 2026 entries should be visible in Flutter app")
    else:
        print(f"\n❌ RESULT: History API test FAILED")
        print(f"📱 January 26, 2026 entries will NOT be visible in Flutter app")
