#!/usr/bin/env python3
"""
Check the is_modified status of January 26, 2026 entries
This might be why they're not showing in the history
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

def check_is_modified_status():
    print("🔍 CHECKING IS_MODIFIED STATUS FOR JAN 26, 2026")
    print("=" * 50)
    
    # Check labour entries
    labour_entries = fetch_all("""
        SELECT 
            id, 
            labour_type, 
            labour_count, 
            entry_date, 
            entry_time,
            is_modified,
            modified_by,
            modified_at,
            modification_reason,
            supervisor_id,
            site_id
        FROM labour_entries 
        WHERE entry_date = '2026-01-26'
        ORDER BY entry_time
    """)
    
    print(f"📊 LABOUR ENTRIES FOR JAN 26, 2026: {len(labour_entries)}")
    for entry in labour_entries:
        print(f"  - {entry['labour_type']}: {entry['labour_count']} workers")
        print(f"    is_modified: {entry['is_modified']}")
        print(f"    modified_by: {entry['modified_by']}")
        print(f"    modified_at: {entry['modified_at']}")
        print(f"    supervisor_id: {entry['supervisor_id']}")
        print(f"    site_id: {entry['site_id']}")
        print()
    
    # Check material entries
    material_entries = fetch_all("""
        SELECT 
            id, 
            material_type, 
            quantity,
            unit,
            entry_date, 
            updated_at,
            supervisor_id,
            site_id
        FROM material_balances 
        WHERE entry_date = '2026-01-26'
        ORDER BY updated_at
    """)
    
    print(f"📦 MATERIAL ENTRIES FOR JAN 26, 2026: {len(material_entries)}")
    for entry in material_entries:
        print(f"  - {entry['material_type']}: {entry['quantity']} {entry['unit']}")
        print(f"    supervisor_id: {entry['supervisor_id']}")
        print(f"    site_id: {entry['site_id']}")
        print()
    
    # Now test the exact query that the API uses
    print(f"🔍 TESTING API QUERY CONDITIONS:")
    
    # Get the supervisor ID
    supervisor = fetch_one("""
        SELECT id, full_name 
        FROM users 
        WHERE role_id = 2 AND status = 'APPROVED'
        LIMIT 1
    """)
    
    if not supervisor:
        print("❌ No supervisor found!")
        return
    
    supervisor_id = str(supervisor['id'])
    print(f"👤 Testing with supervisor: {supervisor['full_name']} ({supervisor_id})")
    
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
    print(f"🏗️  Testing with site: {rahman_site['customer_name']} {rahman_site['site_name']} ({site_id})")
    
    # Test the exact API query for labour entries
    print(f"\n1️⃣ TESTING LABOUR API QUERY:")
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
        WHERE l.supervisor_id = %s AND (l.is_modified = FALSE OR l.is_modified IS NULL) AND l.site_id = %s
        ORDER BY l.entry_time DESC
        LIMIT 100
    """
    
    api_labour_results = fetch_all(api_labour_query, (supervisor_id, site_id))
    print(f"📊 API Labour query results: {len(api_labour_results)}")
    
    for entry in api_labour_results:
        if entry['entry_date'].strftime('%Y-%m-%d') == '2026-01-26':
            print(f"  ✅ Found Jan 26 entry: {entry['labour_type']} - {entry['labour_count']} workers")
            print(f"     is_modified: {entry['is_modified']}")
    
    # Test the exact API query for material entries
    print(f"\n2️⃣ TESTING MATERIAL API QUERY:")
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
        WHERE m.supervisor_id = %s AND m.site_id = %s
        ORDER BY m.updated_at DESC
        LIMIT 100
    """
    
    api_material_results = fetch_all(api_material_query, (supervisor_id, site_id))
    print(f"📦 API Material query results: {len(api_material_results)}")
    
    for entry in api_material_results:
        if entry['entry_date'].strftime('%Y-%m-%d') == '2026-01-26':
            print(f"  ✅ Found Jan 26 entry: {entry['material_type']} - {entry['quantity']} {entry['unit']}")
    
    # Summary
    jan_26_labour_api = [e for e in api_labour_results if e['entry_date'].strftime('%Y-%m-%d') == '2026-01-26']
    jan_26_material_api = [e for e in api_material_results if e['entry_date'].strftime('%Y-%m-%d') == '2026-01-26']
    
    print(f"\n🎯 SUMMARY:")
    print(f"Total Jan 26 labour entries in DB: {len([e for e in labour_entries if e['entry_date'].strftime('%Y-%m-%d') == '2026-01-26'])}")
    print(f"Jan 26 labour entries returned by API: {len(jan_26_labour_api)}")
    print(f"Total Jan 26 material entries in DB: {len([e for e in material_entries if e['entry_date'].strftime('%Y-%m-%d') == '2026-01-26'])}")
    print(f"Jan 26 material entries returned by API: {len(jan_26_material_api)}")
    
    if len(jan_26_labour_api) == 0 and len(jan_26_material_api) == 0:
        print(f"❌ PROBLEM: API returns 0 entries for Jan 26, 2026!")
        print(f"   This explains why Flutter app doesn't show Jan 26 data.")
        
        # Check why labour entries are filtered out
        if len(labour_entries) > 0:
            print(f"\n🔍 LABOUR FILTER ANALYSIS:")
            for entry in labour_entries:
                if entry['entry_date'].strftime('%Y-%m-%d') == '2026-01-26':
                    print(f"  Entry: {entry['labour_type']}")
                    print(f"    supervisor_id matches: {str(entry['supervisor_id']) == supervisor_id}")
                    print(f"    site_id matches: {str(entry['site_id']) == site_id}")
                    print(f"    is_modified: {entry['is_modified']}")
                    print(f"    passes filter: {entry['is_modified'] is False or entry['is_modified'] is None}")
    else:
        print(f"✅ SUCCESS: API returns {len(jan_26_labour_api) + len(jan_26_material_api)} entries for Jan 26, 2026")

if __name__ == "__main__":
    check_is_modified_status()
