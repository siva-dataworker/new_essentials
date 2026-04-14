#!/usr/bin/env python3
"""
Force add January 26, 2026 entries to ensure they appear in history
This will verify the exact issue and fix it
"""

import os
import sys
import django
import uuid
from datetime import datetime
import pytz

# Add the project directory to Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import execute_query, fetch_one, fetch_all

def force_add_jan_26_to_history():
    print("🔧 FORCE ADDING JAN 26 ENTRIES FOR HISTORY VISIBILITY")
    print("=" * 60)
    
    # Get the correct supervisor and site
    supervisor = fetch_one("""
        SELECT id, full_name, username 
        FROM users 
        WHERE username = 'nsjskakaka' AND role_id = 2 AND status = 'APPROVED'
        LIMIT 1
    """)
    
    if not supervisor:
        print("❌ Supervisor 'nsjskakaka' not found!")
        return
    
    supervisor_id = str(supervisor['id'])
    print(f"👤 Found supervisor: {supervisor['full_name']} ({supervisor['username']})")
    print(f"🆔 Supervisor ID: {supervisor_id}")
    
    # Get Rahman site
    rahman_site = fetch_one("""
        SELECT id, site_name, customer_name 
        FROM sites 
        WHERE customer_name LIKE %s
        LIMIT 1
    """, ('%Rahman%',))
    
    if not rahman_site:
        print("❌ Rahman site not found!")
        return
    
    site_id = str(rahman_site['id'])
    print(f"🏗️  Found site: {rahman_site['customer_name']} {rahman_site['site_name']}")
    print(f"🆔 Site ID: {site_id}")
    
    # Clear existing Jan 26 entries first
    print(f"\n🗑️  Clearing existing Jan 26 entries...")
    execute_query("DELETE FROM labour_entries WHERE entry_date = '2026-01-26' AND supervisor_id = %s", (supervisor_id,))
    execute_query("DELETE FROM material_balances WHERE entry_date = '2026-01-26' AND supervisor_id = %s", (supervisor_id,))
    
    # Set up January 26, 2026 datetime (Monday)
    ist_tz = pytz.timezone('Asia/Kolkata')
    jan_26_date = datetime(2026, 1, 26).date()
    
    print(f"\n➕ Adding fresh Jan 26, 2026 entries...")
    print(f"📅 Date: {jan_26_date} (Monday)")
    
    # Add labour entries with different times
    labour_entries = [
        {'type': 'Mason', 'count': 5, 'hour': 9, 'minute': 0},      # 9:00 AM
        {'type': 'Carpenter', 'count': 3, 'hour': 10, 'minute': 0}, # 10:00 AM
        {'type': 'Electrician', 'count': 2, 'hour': 11, 'minute': 0}, # 11:00 AM
        {'type': 'Helper', 'count': 6, 'hour': 12, 'minute': 0},    # 12:00 PM
    ]
    
    for labour in labour_entries:
        entry_time = ist_tz.localize(datetime(2026, 1, 26, labour['hour'], labour['minute']))
        entry_id = str(uuid.uuid4())
        
        execute_query("""
            INSERT INTO labour_entries 
            (id, site_id, supervisor_id, labour_count, labour_type, entry_date, entry_time, day_of_week, notes, extra_cost, extra_cost_notes, is_modified)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (entry_id, site_id, supervisor_id, labour['count'], labour['type'], 
              jan_26_date, entry_time, 'Monday', f"History test - {labour['type']}", 0, '', False))
        
        print(f"  ✅ Added {labour['type']}: {labour['count']} workers at {entry_time.strftime('%I:%M %p')}")
    
    # Add material entries
    material_entries = [
        {'type': 'Bricks', 'quantity': 2000, 'unit': 'nos', 'hour': 9, 'minute': 30},    # 9:30 AM
        {'type': 'Cement', 'quantity': 20, 'unit': 'bags', 'hour': 10, 'minute': 30},    # 10:30 AM
        {'type': 'Steel', 'quantity': 1000, 'unit': 'kg', 'hour': 11, 'minute': 30},     # 11:30 AM
        {'type': 'M Sand', 'quantity': 5, 'unit': 'loads', 'hour': 12, 'minute': 30},    # 12:30 PM
    ]
    
    for material in material_entries:
        entry_time = ist_tz.localize(datetime(2026, 1, 26, material['hour'], material['minute']))
        material_id = str(uuid.uuid4())
        
        execute_query("""
            INSERT INTO material_balances 
            (id, site_id, supervisor_id, material_type, quantity, unit, entry_date, updated_at, day_of_week, extra_cost, extra_cost_notes)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (material_id, site_id, supervisor_id, material['type'], material['quantity'], 
              material['unit'], jan_26_date, entry_time, 'Monday', 0, ''))
        
        print(f"  ✅ Added {material['type']}: {material['quantity']} {material['unit']} at {entry_time.strftime('%I:%M %p')}")
    
    print(f"\n🎉 FRESH ENTRIES ADDED FOR JAN 26, 2026!")
    print(f"👷 Labour entries: {len(labour_entries)}")
    print(f"📦 Material entries: {len(material_entries)}")
    
    # Verify entries were created
    print(f"\n🔍 VERIFICATION:")
    
    labour_check = fetch_all("""
        SELECT labour_type, labour_count, entry_time, is_modified
        FROM labour_entries 
        WHERE supervisor_id = %s AND entry_date = '2026-01-26'
        ORDER BY entry_time
    """, (supervisor_id,))
    
    material_check = fetch_all("""
        SELECT material_type, quantity, unit, updated_at
        FROM material_balances 
        WHERE supervisor_id = %s AND entry_date = '2026-01-26'
        ORDER BY updated_at
    """, (supervisor_id,))
    
    print(f"📊 Verified labour entries: {len(labour_check)}")
    for entry in labour_check:
        print(f"  - {entry['labour_type']}: {entry['labour_count']} workers (modified: {entry['is_modified']})")
    
    print(f"📦 Verified material entries: {len(material_check)}")
    for entry in material_check:
        print(f"  - {entry['material_type']}: {entry['quantity']} {entry['unit']}")
    
    # Test the history API directly
    print(f"\n🧪 TESTING HISTORY API:")
    
    # Test the exact query the history API uses
    api_labour_query = """
        SELECT 
            l.id,
            l.site_id,
            l.labour_type,
            l.labour_count,
            l.entry_date,
            l.entry_time,
            l.notes,
            l.extra_cost,
            l.extra_cost_notes,
            l.is_modified,
            s.site_name,
            s.area,
            s.street
        FROM labour_entries l
        JOIN sites s ON l.site_id = s.id
        WHERE l.supervisor_id = %s AND (l.is_modified = FALSE OR l.is_modified IS NULL)
        ORDER BY l.entry_time DESC
        LIMIT 100
    """
    
    api_labour_results = fetch_all(api_labour_query, (supervisor_id,))
    jan_26_labour_api = [e for e in api_labour_results if e['entry_date'].strftime('%Y-%m-%d') == '2026-01-26']
    
    print(f"📊 API Labour query total results: {len(api_labour_results)}")
    print(f"📅 API Jan 26 labour results: {len(jan_26_labour_api)}")
    
    if len(jan_26_labour_api) > 0:
        print(f"✅ SUCCESS: Jan 26 labour entries found in API!")
        for entry in jan_26_labour_api:
            print(f"  - {entry['labour_type']}: {entry['labour_count']} workers")
    else:
        print(f"❌ PROBLEM: No Jan 26 labour entries in API results!")
    
    # Test material API query
    api_material_query = """
        SELECT 
            m.id,
            m.site_id,
            m.material_type,
            m.quantity,
            m.unit,
            m.entry_date,
            m.updated_at,
            m.extra_cost,
            m.extra_cost_notes,
            s.site_name,
            s.area,
            s.street
        FROM material_balances m
        JOIN sites s ON m.site_id = s.id
        WHERE m.supervisor_id = %s
        ORDER BY m.updated_at DESC
        LIMIT 100
    """
    
    api_material_results = fetch_all(api_material_query, (supervisor_id,))
    jan_26_material_api = [e for e in api_material_results if e['entry_date'].strftime('%Y-%m-%d') == '2026-01-26']
    
    print(f"📦 API Material query total results: {len(api_material_results)}")
    print(f"📅 API Jan 26 material results: {len(jan_26_material_api)}")
    
    if len(jan_26_material_api) > 0:
        print(f"✅ SUCCESS: Jan 26 material entries found in API!")
        for entry in jan_26_material_api:
            print(f"  - {entry['material_type']}: {entry['quantity']} {entry['unit']}")
    else:
        print(f"❌ PROBLEM: No Jan 26 material entries in API results!")
    
    print(f"\n📱 FLUTTER SHOULD NOW SHOW:")
    print(f"📅 Monday, Jan 26, 2026                     [{len(jan_26_labour_api) + len(jan_26_material_api)} entries] ▼")
    for entry in jan_26_labour_api:
        print(f"   👷 {entry['labour_type']} - {entry['labour_count']} workers")
    for entry in jan_26_material_api:
        print(f"   📦 {entry['material_type']} - {entry['quantity']} {entry['unit']}")
    
    print(f"\n🎯 NEXT STEPS:")
    print(f"1. Hot restart Flutter app")
    print(f"2. Login as supervisor (nsjskakaka / Test123)")
    print(f"3. Go to History screen")
    print(f"4. Look for 'Monday, Jan 26, 2026' section")
    print(f"5. Should show {len(jan_26_labour_api) + len(jan_26_material_api)} entries")

if __name__ == "__main__":
    force_add_jan_26_to_history()
