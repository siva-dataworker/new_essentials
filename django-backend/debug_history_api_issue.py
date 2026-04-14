#!/usr/bin/env python3
"""
Debug why January 26, 2026 entries are not showing in Flutter history screen
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

def debug_history_api_issue():
    print("🔍 DEBUGGING HISTORY API ISSUE")
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
    
    # Check what the Flutter app is actually calling
    print(f"\n🔍 CHECKING HISTORY API ENDPOINT...")
    
    # This is the exact query that the Flutter history screen should be making
    # Based on the supervisor_history_screen.dart implementation
    
    # Check if there's a specific site-based history API
    print(f"\n1️⃣ CHECKING SITE-SPECIFIC ENTRIES:")
    site_entries = fetch_all("""
        SELECT 
            entry_date,
            day_of_week,
            'labour' as entry_type,
            labour_type as type_name,
            labour_count as count_value,
            entry_time as timestamp,
            notes
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
            '' as notes
        FROM material_balances 
        WHERE site_id = %s
        
        ORDER BY entry_date DESC, timestamp DESC
    """, (site_id, site_id))
    
    print(f"📊 Site-specific entries found: {len(site_entries)}")
    
    # Group by date
    entries_by_date = {}
    for entry in site_entries:
        date_key = entry['entry_date'].strftime('%Y-%m-%d')
        if date_key not in entries_by_date:
            entries_by_date[date_key] = []
        entries_by_date[date_key].append(entry)
    
    print(f"📅 Dates with entries: {list(entries_by_date.keys())}")
    
    # Check specifically for Jan 26
    jan_26_key = '2026-01-26'
    if jan_26_key in entries_by_date:
        print(f"✅ January 26, 2026 entries found: {len(entries_by_date[jan_26_key])}")
        for entry in entries_by_date[jan_26_key]:
            print(f"  - {entry['entry_type']}: {entry['type_name']} = {entry['count_value']}")
    else:
        print(f"❌ January 26, 2026 entries NOT found in site-specific query!")
    
    # Check if there's a supervisor-specific filter issue
    print(f"\n2️⃣ CHECKING SUPERVISOR FILTER:")
    
    # Get the supervisor ID that was used for dummy data
    supervisor = fetch_one("""
        SELECT id, full_name 
        FROM users 
        WHERE role_id = 2 AND status = 'APPROVED'
        LIMIT 1
    """)
    
    if supervisor:
        supervisor_id = str(supervisor['id'])
        print(f"👤 Supervisor: {supervisor['full_name']} ({supervisor_id})")
        
        # Check if entries are filtered by supervisor
        supervisor_entries = fetch_all("""
            SELECT entry_date, COUNT(*) as count
            FROM labour_entries 
            WHERE site_id = %s AND supervisor_id = %s
            GROUP BY entry_date
            ORDER BY entry_date DESC
        """, (site_id, supervisor_id))
        
        print(f"📊 Supervisor-specific labour entries by date:")
        for entry in supervisor_entries:
            print(f"  - {entry['entry_date']}: {entry['count']} entries")
    
    # Check the actual API endpoint that Flutter calls
    print(f"\n3️⃣ CHECKING FLUTTER API CALL:")
    
    # Look at the construction service to see what API it calls
    print(f"🔍 The Flutter app likely calls one of these endpoints:")
    print(f"  - GET /api/construction/history/{site_id}/")
    print(f"  - GET /api/construction/entries/{site_id}/")
    print(f"  - GET /api/construction/site-history/")
    
    # Check if there's a date range filter
    print(f"\n4️⃣ CHECKING DATE RANGE ISSUES:")
    
    # Check if there's a date range limitation in the API
    from datetime import datetime, timedelta
    today = datetime.now().date()
    jan_26 = datetime(2026, 1, 26).date()
    days_diff = (today - jan_26).days
    
    print(f"📅 Today: {today}")
    print(f"📅 Jan 26, 2026: {jan_26}")
    print(f"📅 Days difference: {days_diff}")
    
    if days_diff > 30:
        print(f"⚠️  WARNING: Jan 26 is more than 30 days ago - might be filtered out!")
    
    # Check raw database entries one more time
    print(f"\n5️⃣ RAW DATABASE CHECK:")
    
    raw_labour = fetch_all("""
        SELECT id, site_id, supervisor_id, labour_type, labour_count, entry_date, entry_time
        FROM labour_entries 
        WHERE entry_date = '2026-01-26'
        ORDER BY entry_time
    """)
    
    raw_materials = fetch_all("""
        SELECT id, site_id, supervisor_id, material_type, quantity, entry_date, updated_at
        FROM material_balances 
        WHERE entry_date = '2026-01-26'
        ORDER BY updated_at
    """)
    
    print(f"📊 Raw labour entries for Jan 26: {len(raw_labour)}")
    for entry in raw_labour:
        print(f"  - Site: {entry['site_id']}, Supervisor: {entry['supervisor_id']}")
        print(f"    {entry['labour_type']}: {entry['labour_count']} at {entry['entry_time']}")
    
    print(f"📦 Raw material entries for Jan 26: {len(raw_materials)}")
    for entry in raw_materials:
        print(f"  - Site: {entry['site_id']}, Supervisor: {entry['supervisor_id']}")
        print(f"    {entry['material_type']}: {entry['quantity']} at {entry['updated_at']}")
    
    # Check if site IDs match
    print(f"\n6️⃣ SITE ID VERIFICATION:")
    print(f"Expected site ID: {site_id}")
    
    if raw_labour:
        actual_site_id = str(raw_labour[0]['site_id'])
        print(f"Actual site ID in labour entries: {actual_site_id}")
        if site_id != actual_site_id:
            print(f"❌ SITE ID MISMATCH! This is why entries don't show!")
        else:
            print(f"✅ Site IDs match")
    
    return {
        'site_id': site_id,
        'entries_found': len(site_entries),
        'jan_26_found': jan_26_key in entries_by_date,
        'raw_labour_count': len(raw_labour),
        'raw_material_count': len(raw_materials)
    }

if __name__ == "__main__":
    result = debug_history_api_issue()
    print(f"\n🎯 SUMMARY:")
    print(f"Site ID: {result['site_id']}")
    print(f"Total entries found: {result['entries_found']}")
    print(f"Jan 26 found: {result['jan_26_found']}")
    print(f"Raw entries: {result['raw_labour_count']} labour + {result['raw_material_count']} material")
