#!/usr/bin/env python3
"""
Test the supervisor history API with accountant credentials (Siva)
to verify the 403 Forbidden issue is fixed
"""

import requests
import json

def test_accountant_history_access():
    print("🧪 TESTING SUPERVISOR HISTORY API WITH ACCOUNTANT CREDENTIALS")
    print("=" * 70)
    
    base_url = "http://localhost:8000/api"
    
    # Login as accountant Siva
    print("1. Logging in as accountant Siva...")
    login_response = requests.post(f"{base_url}/auth/login/", json={
        "username": "Siva",
        "password": "Test123"
    })
    
    if login_response.status_code != 200:
        print(f"❌ Login failed: {login_response.text}")
        return
    
    login_data = login_response.json()
    token = login_data['access_token']
    user_info = login_data['user']
    
    print(f"✅ Login successful!")
    print(f"   User: {user_info['username']} ({user_info['role']})")
    print(f"   Full Name: {user_info.get('full_name', 'N/A')}")
    
    # Test supervisor history API without site filter
    print(f"\n2. Testing supervisor history API (no site filter)...")
    headers = {
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json'
    }
    
    history_response = requests.get(
        f"{base_url}/construction/supervisor/history/",
        headers=headers
    )
    
    print(f"   Status Code: {history_response.status_code}")
    
    if history_response.status_code == 200:
        history_data = history_response.json()
        labour_entries = history_data.get('labour_entries', [])
        material_entries = history_data.get('material_entries', [])
        
        print(f"   ✅ API working!")
        print(f"   Labour entries: {len(labour_entries)}")
        print(f"   Material entries: {len(material_entries)}")
        
        # Check for Lakshmi site data
        lakshmi_labour = [e for e in labour_entries if 'lakshmi' in e.get('customer_name', '').lower()]
        print(f"   Lakshmi labour entries: {len(lakshmi_labour)}")
        
        if lakshmi_labour:
            print(f"   Sample Lakshmi entry: {lakshmi_labour[0].get('labour_type')} - {lakshmi_labour[0].get('labour_count')} workers")
    else:
        print(f"   ❌ Error: {history_response.status_code}")
        print(f"   Response: {history_response.text}")
    
    # Test with specific site filter (Lakshmi site)
    print(f"\n3. Testing with Lakshmi site filter...")
    
    # First get sites to find Lakshmi site ID
    sites_response = requests.get(f"{base_url}/construction/sites/", headers=headers)
    if sites_response.status_code == 200:
        sites_data = sites_response.json()
        sites = sites_data.get('sites', [])
        
        lakshmi_site = None
        for site in sites:
            if 'lakshmi' in site.get('customer_name', '').lower():
                lakshmi_site = site
                break
        
        if lakshmi_site:
            site_id = lakshmi_site['id']
            print(f"   Found Lakshmi site: {lakshmi_site['customer_name']} {lakshmi_site['site_name']} (ID: {site_id})")
            
            # Test history with site filter
            filtered_response = requests.get(
                f"{base_url}/construction/supervisor/history/?site_id={site_id}",
                headers=headers
            )
            
            print(f"   Filtered request status: {filtered_response.status_code}")
            
            if filtered_response.status_code == 200:
                filtered_data = filtered_response.json()
                filtered_labour = filtered_data.get('labour_entries', [])
                filtered_material = filtered_data.get('material_entries', [])
                
                print(f"   ✅ Filtered API working!")
                print(f"   Filtered labour entries: {len(filtered_labour)}")
                print(f"   Filtered material entries: {len(filtered_material)}")
            else:
                print(f"   ❌ Filtered request failed: {filtered_response.status_code}")
                print(f"   Response: {filtered_response.text}")
        else:
            print(f"   ❌ Lakshmi site not found")
    else:
        print(f"   ❌ Could not get sites: {sites_response.status_code}")
    
    print(f"\n" + "=" * 70)
    print(f"TEST COMPLETE")
    print(f"=" * 70)

if __name__ == "__main__":
    test_accountant_history_access()
