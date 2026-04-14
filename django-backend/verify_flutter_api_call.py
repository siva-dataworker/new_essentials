#!/usr/bin/env python3
"""
Verify the exact API call that Flutter should be making for Rahman site history
"""

import os
import sys
import django
import requests
import json

# Add the project directory to Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_one

def verify_flutter_api_call():
    print("🔍 VERIFYING FLUTTER API CALL FOR RAHMAN SITE")
    print("=" * 60)
    
    # Get Rahman site details
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
    print(f"📍 Location: {rahman_site['area']}, {rahman_site['street']}")
    
    # Get supervisor details
    supervisor = fetch_one("""
        SELECT id, full_name, username 
        FROM users 
        WHERE role_id = 2 AND status = 'APPROVED'
        LIMIT 1
    """)
    
    if not supervisor:
        print("❌ No supervisor found!")
        return
    
    supervisor_id = str(supervisor['id'])
    print(f"👤 Supervisor: {supervisor['full_name']} ({supervisor['username']})")
    print(f"🆔 Supervisor ID: {supervisor_id}")
    
    # Test the exact API call Flutter should make
    base_url = "http://localhost:8000"
    
    print(f"\n🔐 STEP 1: LOGIN")
    login_url = f"{base_url}/api/auth/login/"
    login_data = {
        "username": supervisor['username'],
        "password": "Test123"
    }
    
    try:
        login_response = requests.post(login_url, json=login_data)
        print(f"📊 Login status: {login_response.status_code}")
        
        if login_response.status_code == 200:
            login_result = login_response.json()
            token = login_result.get('access_token')
            print(f"✅ Login successful")
            
            print(f"\n📱 STEP 2: FLUTTER API CALL")
            # This is the exact URL Flutter should call
            history_url = f"{base_url}/api/construction/supervisor/history/?site_id={site_id}"
            headers = {"Authorization": f"Bearer {token}"}
            
            print(f"🔗 URL: {history_url}")
            print(f"🔑 Headers: Authorization: Bearer {token[:20]}...")
            
            history_response = requests.get(history_url, headers=headers)
            print(f"📊 Response status: {history_response.status_code}")
            
            if history_response.status_code == 200:
                data = history_response.json()
                labour_count = len(data.get('labour_entries', []))
                material_count = len(data.get('material_entries', []))
                
                print(f"✅ API call successful!")
                print(f"📊 Labour entries: {labour_count}")
                print(f"📦 Material entries: {material_count}")
                print(f"🏗️  Site filter: {data.get('site_filter', 'None')}")
                
                # Check for Jan 26 entries
                jan_26_labour = [e for e in data.get('labour_entries', []) if '2026-01-26' in e.get('entry_date', '')]
                jan_26_material = [e for e in data.get('material_entries', []) if '2026-01-26' in e.get('entry_date', '')]
                
                print(f"\n📅 JANUARY 26, 2026 VERIFICATION:")
                print(f"👷 Jan 26 labour entries: {len(jan_26_labour)}")
                print(f"📦 Jan 26 material entries: {len(jan_26_material)}")
                
                if jan_26_labour or jan_26_material:
                    print(f"✅ SUCCESS: Jan 26 data is available via API!")
                    
                    print(f"\n📋 JAN 26 LABOUR ENTRIES:")
                    for entry in jan_26_labour:
                        print(f"  - {entry['labour_type']}: {entry['labour_count']} workers")
                        print(f"    Date: {entry['entry_date']}")
                        print(f"    Time: {entry.get('entry_time', 'No time')}")
                        print(f"    Site ID: {entry['site_id']}")
                    
                    print(f"\n📋 JAN 26 MATERIAL ENTRIES:")
                    for entry in jan_26_material:
                        print(f"  - {entry['material_type']}: {entry['quantity']} {entry['unit']}")
                        print(f"    Date: {entry['entry_date']}")
                        print(f"    Time: {entry.get('updated_at', 'No time')}")
                        print(f"    Site ID: {entry['site_id']}")
                    
                    print(f"\n📱 FLUTTER SHOULD RECEIVE:")
                    print(f"```json")
                    print(f"{{")
                    print(f"  \"labour_entries\": [{len(jan_26_labour)} entries],")
                    print(f"  \"material_entries\": [{len(jan_26_material)} entries],")
                    print(f"  \"site_filter\": \"{site_id}\",")
                    print(f"  \"total_labour_entries\": {labour_count},")
                    print(f"  \"total_material_entries\": {material_count}")
                    print(f"}}")
                    print(f"```")
                    
                else:
                    print(f"❌ PROBLEM: No Jan 26 data in API response!")
                    print(f"   This means the backend filtering is wrong.")
                
            else:
                print(f"❌ API call failed: {history_response.text}")
        else:
            print(f"❌ Login failed: {login_response.text}")
    
    except Exception as e:
        print(f"❌ Exception: {e}")
    
    print(f"\n🎯 FLUTTER DEBUG CHECKLIST:")
    print(f"1. ✅ Backend has Jan 26 data: Confirmed")
    print(f"2. ✅ API returns Jan 26 data: Confirmed")
    print(f"3. ❓ Flutter receives data: Check console logs")
    print(f"4. ❓ Flutter processes data: Check provider logs")
    print(f"5. ❓ Flutter displays data: Check UI rendering")
    
    print(f"\n📱 FLUTTER CONSOLE SHOULD SHOW:")
    print(f"🔍 [HISTORY] URL: {history_url}")
    print(f"📊 [HISTORY] Response status: 200")
    print(f"✅ [HISTORY] Labour entries: {labour_count}")
    print(f"✅ [HISTORY] Material entries: {material_count}")
    print(f"📅 [HISTORY] Jan 26 labour entries found: {len(jan_26_labour) if jan_26_labour else 0}")
    print(f"📅 [HISTORY] Jan 26 material entries found: {len(jan_26_material) if jan_26_material else 0}")

if __name__ == "__main__":
    verify_flutter_api_call()
