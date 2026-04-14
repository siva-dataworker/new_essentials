#!/usr/bin/env python3
"""
Add dummy labour and material data for Rahman site on January 26, 2026
This will test if the time picker and history system are working correctly
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

def add_jan_26_dummy_data():
    print("🏗️  ADDING DUMMY DATA FOR JANUARY 26, 2026")
    print("=" * 50)
    
    # First, find Rahman site
    rahman_site = fetch_one("""
        SELECT id, site_name, customer_name, area, street 
        FROM sites 
        WHERE customer_name LIKE %s OR site_name LIKE %s
        LIMIT 1
    """, ('%Rahman%', '%Rahman%'))
    
    if not rahman_site:
        print("❌ Rahman site not found! Let's check all sites...")
        all_sites = fetch_all("""
            SELECT id, site_name, customer_name, area, street 
            FROM sites 
            ORDER BY customer_name, site_name
        """)
        
        print(f"📋 Available sites ({len(all_sites)}):")
        for site in all_sites:
            print(f"  - {site['customer_name']} {site['site_name']} ({site['area']}, {site['street']})")
        
        # Use the first site if Rahman not found
        if all_sites:
            rahman_site = all_sites[0]
            print(f"\n🎯 Using first available site: {rahman_site['customer_name']} {rahman_site['site_name']}")
        else:
            print("❌ No sites found in database!")
            return
    else:
        print(f"✅ Found Rahman site: {rahman_site['customer_name']} {rahman_site['site_name']}")
    
    site_id = str(rahman_site['id'])
    
    # Find a supervisor user
    supervisor = fetch_one("""
        SELECT id, full_name, phone 
        FROM users 
        WHERE role_id = 2 AND status = 'APPROVED'
        LIMIT 1
    """)
    
    if not supervisor:
        print("❌ No approved supervisor found!")
        return
    
    supervisor_id = str(supervisor['id'])
    print(f"✅ Using supervisor: {supervisor['full_name']} ({supervisor['phone']})")
    
    # Set up January 26, 2026 datetime (Monday, 2:00 PM IST)
    ist_tz = pytz.timezone('Asia/Kolkata')
    jan_26_datetime = ist_tz.localize(datetime(2026, 1, 26, 14, 0, 0))  # 2:00 PM IST
    entry_date = jan_26_datetime.date()
    day_of_week = jan_26_datetime.strftime('%A')  # Should be Monday
    
    print(f"📅 Target date: {entry_date} ({day_of_week})")
    print(f"🕒 Target time: {jan_26_datetime}")
    
    # Check if entries already exist for this date
    existing_labour = fetch_all("""
        SELECT id, labour_type, labour_count 
        FROM labour_entries 
        WHERE site_id = %s AND entry_date = %s
    """, (site_id, entry_date))
    
    existing_materials = fetch_all("""
        SELECT id, material_type, quantity, unit
        FROM material_balances 
        WHERE site_id = %s AND entry_date = %s
    """, (site_id, entry_date))
    
    if existing_labour or existing_materials:
        print(f"⚠️  Entries already exist for {entry_date}:")
        for entry in existing_labour:
            print(f"  Labour: {entry['labour_type']} - {entry['labour_count']} workers")
        for entry in existing_materials:
            print(f"  Material: {entry['material_type']} - {entry['quantity']} {entry['unit']}")
        
        print("\n🗑️  Clearing existing entries...")
        execute_query("DELETE FROM labour_entries WHERE site_id = %s AND entry_date = %s", (site_id, entry_date))
        execute_query("DELETE FROM material_balances WHERE site_id = %s AND entry_date = %s", (site_id, entry_date))
    
    print(f"\n➕ Adding dummy labour entries...")
    
    # Add labour entries
    labour_data = [
        {'type': 'Mason', 'count': 3, 'hour': 14, 'minute': 0},      # 2:00 PM
        {'type': 'Carpenter', 'count': 2, 'hour': 14, 'minute': 30}, # 2:30 PM
        {'type': 'Electrician', 'count': 1, 'hour': 15, 'minute': 0}, # 3:00 PM
        {'type': 'Helper', 'count': 4, 'hour': 15, 'minute': 30},    # 3:30 PM
    ]
    
    for labour in labour_data:
        entry_time = jan_26_datetime.replace(hour=labour['hour'], minute=labour['minute'])
        entry_id = str(uuid.uuid4())
        
        execute_query("""
            INSERT INTO labour_entries 
            (id, site_id, supervisor_id, labour_count, labour_type, entry_date, entry_time, day_of_week, notes, extra_cost, extra_cost_notes)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (entry_id, site_id, supervisor_id, labour['count'], labour['type'], 
              entry_date, entry_time, day_of_week, f"Dummy data for testing - {labour['type']}", 0, ''))
        
        print(f"  ✅ Added {labour['type']}: {labour['count']} workers at {entry_time.strftime('%I:%M %p')}")
    
    print(f"\n➕ Adding dummy material entries...")
    
    # Add material entries
    material_data = [
        {'type': 'Bricks', 'quantity': 1000, 'unit': 'nos', 'hour': 14, 'minute': 15},    # 2:15 PM
        {'type': 'Cement', 'quantity': 10, 'unit': 'bags', 'hour': 14, 'minute': 45},     # 2:45 PM
        {'type': 'M Sand', 'quantity': 2, 'unit': 'loads', 'hour': 15, 'minute': 15},     # 3:15 PM
        {'type': 'Steel', 'quantity': 500, 'unit': 'kg', 'hour': 15, 'minute': 45},      # 3:45 PM
    ]
    
    for material in material_data:
        entry_time = jan_26_datetime.replace(hour=material['hour'], minute=material['minute'])
        material_id = str(uuid.uuid4())
        
        execute_query("""
            INSERT INTO material_balances 
            (id, site_id, supervisor_id, material_type, quantity, unit, entry_date, updated_at, day_of_week, extra_cost, extra_cost_notes)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (material_id, site_id, supervisor_id, material['type'], material['quantity'], 
              material['unit'], entry_date, entry_time, day_of_week, 0, ''))
        
        print(f"  ✅ Added {material['type']}: {material['quantity']} {material['unit']} at {entry_time.strftime('%I:%M %p')}")
    
    print(f"\n🎉 DUMMY DATA ADDED SUCCESSFULLY!")
    print(f"📊 Site: {rahman_site['customer_name']} {rahman_site['site_name']}")
    print(f"📅 Date: {day_of_week}, {entry_date.strftime('%B %d, %Y')}")
    print(f"👷 Labour entries: {len(labour_data)}")
    print(f"📦 Material entries: {len(material_data)}")
    
    print(f"\n🔍 Verification - checking entries...")
    
    # Verify entries were created
    labour_check = fetch_all("""
        SELECT labour_type, labour_count, entry_time
        FROM labour_entries 
        WHERE site_id = %s AND entry_date = %s
        ORDER BY entry_time
    """, (site_id, entry_date))
    
    material_check = fetch_all("""
        SELECT material_type, quantity, unit, updated_at
        FROM material_balances 
        WHERE site_id = %s AND entry_date = %s
        ORDER BY updated_at
    """, (site_id, entry_date))
    
    print(f"\n✅ VERIFICATION RESULTS:")
    print(f"📊 Labour entries found: {len(labour_check)}")
    for entry in labour_check:
        print(f"  - {entry['labour_type']}: {entry['labour_count']} workers at {entry['entry_time'].strftime('%I:%M %p')}")
    
    print(f"📦 Material entries found: {len(material_check)}")
    for entry in material_check:
        print(f"  - {entry['material_type']}: {entry['quantity']} {entry['unit']} at {entry['updated_at'].strftime('%I:%M %p')}")
    
    print(f"\n📱 NEXT STEPS:")
    print(f"1. Open Flutter app and go to History screen")
    print(f"2. Look for 'Monday, Jan 26, 2026' section")
    print(f"3. Expand the section to see {len(labour_check) + len(material_check)} entries")
    print(f"4. Entries should show times from 2:00 PM to 3:45 PM")
    
    return {
        'site_id': site_id,
        'site_name': f"{rahman_site['customer_name']} {rahman_site['site_name']}",
        'date': entry_date,
        'day_of_week': day_of_week,
        'labour_entries': len(labour_check),
        'material_entries': len(material_check)
    }

if __name__ == "__main__":
    result = add_jan_26_dummy_data()
    if result:
        print(f"\n🎯 SUMMARY:")
        print(f"Site: {result['site_name']}")
        print(f"Date: {result['day_of_week']}, {result['date']}")
        print(f"Total entries: {result['labour_entries'] + result['material_entries']}")
