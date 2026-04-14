#!/usr/bin/env python3
"""
Test the supervisor history API endpoint directly to see what it returns
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

def test_supervisor_history_api():
    print("🧪 TESTING SUPERVISOR HISTORY API ENDPOINT")
    print("=" * 50)
    
    # Get supervisor credentials
    supervisor = fetch_one("""
        SELECT id, full_name, username, password_hash
        FROM users 
        WHERE role_id = 2 AND status = 'APPROVED'
        LIMIT 1
    """)
    
    if not supervisor:
        print("❌ No supervisor found!")
        return
    
    print(f"👤 Supervisor: {supervisor['full_name']} ({supervisor['username']})")
    
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
    print(f"🏗️  Site: {rahman_site['customer_name']} {rahman_site['site_name']}")
    print(f"🆔 Site ID: {site_id}")
    
    # Test the API endpoint
    base_url = "http://localhost:8000"
    
    # First, we need to login to get a token
    print(f"\n🔐 STEP 1: LOGIN TO GET TOKEN")
    login_url = f"{base_url}/api/auth/login/"
    login_data = {
        "username": supervisor['username'],
        "password": "Test123"  # Correct password from set_test_passwords.py
    }
    
    try:
        login_response = requests.post(login_url, json=login_data)
        print(f"📊 Login response status: {login_response.status_code}")
        
        if login_response.status_code == 200:
            login_result = login_response.json()
            token = login_result.get('access_token')
            print(f"✅ Login successful, got token: {token[:20]}...")
            
            # Now test the history API
            print(f"\n📊 STEP 2: CALL HISTORY API")
            history_url = f"{base_url}/api/construction/supervisor/history/"
            
            # Test without site filter first
            print(f"\n🔍 Testing without site filter:")
            headers = {"Authorization": f"Bearer {token}"}
            
            history_response = requests.get(history_url, headers=headers)
            print(f"📊 History response status: {history_response.status_code}")
            
            if history_response.status_code == 200:
                history_data = history_response.json()
                labour_count = len(history_data.get('labour_entries', []))
                material_count = len(history_data.get('material_entries', []))
                
                print(f"✅ History API successful!")
                print(f"📊 Labour entries: {labour_count}")
                print(f"📦 Material entries: {material_count}")
                
                # Check for Jan 26 entries
                jan_26_labour = [e for e in history_data.get('labour_entries', []) if '2026-01-26' in e.get('entry_date', '')]
                jan_26_material = [e for e in history_data.get('material_entries', []) if '2026-01-26' in e.get('entry_date', '')]
                
                print(f"📅 Jan 26 labour entries: {len(jan_26_labour)}")
                print(f"📅 Jan 26 material entries: {len(jan_26_material)}")
                
                if jan_26_labour or jan_26_material:
                    print(f"✅ SUCCESS: Jan 26 entries found in API response!")
                    
                    print(f"\n📋 JAN 26 LABOUR ENTRIES:")
                    for entry in jan_26_labour:
                        print(f"  - {entry['labour_type']}: {entry['labour_count']} workers")
                        print(f"    Date: {entry['entry_date']}")
                        print(f"    Time: {entry.get('entry_time', 'No time')}")
                    
                    print(f"\n📋 JAN 26 MATERIAL ENTRIES:")
                    for entry in jan_26_material:
                        print(f"  - {entry['material_type']}: {entry['quantity']} {entry['unit']}")
                        print(f"    Date: {entry['entry_date']}")
                        print(f"    Time: {entry.get('updated_at', 'No time')}")
                else:
                    print(f"❌ PROBLEM: No Jan 26 entries in API response!")
                
                # Test with site filter
                print(f"\n🔍 Testing with site filter:")
                history_url_with_site = f"{history_url}?site_id={site_id}"
                
                site_response = requests.get(history_url_with_site, headers=headers)
                print(f"📊 Site-filtered response status: {site_response.status_code}")
                
                if site_response.status_code == 200:
                    site_data = site_response.json()
                    site_labour_count = len(site_data.get('labour_entries', []))
                    site_material_count = len(site_data.get('material_entries', []))
                    
                    print(f"✅ Site-filtered API successful!")
                    print(f"📊 Labour entries: {site_labour_count}")
                    print(f"📦 Material entries: {site_material_count}")
                    
                    # Check for Jan 26 entries with site filter
                    site_jan_26_labour = [e for e in site_data.get('labour_entries', []) if '2026-01-26' in e.get('entry_date', '')]
                    site_jan_26_material = [e for e in site_data.get('material_entries', []) if '2026-01-26' in e.get('entry_date', '')]
                    
                    print(f"📅 Site-filtered Jan 26 labour entries: {len(site_jan_26_labour)}")
                    print(f"📅 Site-filtered Jan 26 material entries: {len(site_jan_26_material)}")
                    
                    if site_jan_26_labour or site_jan_26_material:
                        print(f"✅ SUCCESS: Site-filtered Jan 26 entries found!")
                    else:
                        print(f"❌ PROBLEM: No site-filtered Jan 26 entries!")
                else:
                    print(f"❌ Site-filtered API failed: {site_response.text}")
            else:
                print(f"❌ History API failed: {history_response.text}")
        else:
            print(f"❌ Login failed: {login_response.text}")
    
    except Exception as e:
        print(f"❌ Exception: {e}")
    
    print(f"\n🎯 NEXT STEPS:")
    print(f"1. If API returns Jan 26 data: Issue is in Flutter app")
    print(f"2. If API doesn't return Jan 26 data: Issue is in Django backend")
    print(f"3. Check Flutter console logs for API call details")

if __name__ == "__main__":
    test_supervisor_history_api()
