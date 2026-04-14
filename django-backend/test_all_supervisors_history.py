#!/usr/bin/env python3
"""
Test the updated supervisor history API that shows ALL entries from ALL supervisors
"""

import requests
import json

def test_all_supervisors_history():
    print("🧪 TESTING ALL SUPERVISORS HISTORY API")
    print("=" * 60)
    
    base_url = "http://localhost:8000/api"
    
    # Login as supervisor
    print("1. Logging in as supervisor...")
    login_response = requests.post(f"{base_url}/auth/login/", json={
        "username": "nsjskakaka",
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
    print(f"   Token: {token[:20]}...")
    
    # Test supervisor history API
    print(f"\n2. Testing supervisor history API (ALL entries)...")
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
        labour_count = len(history_data.get('labour_entries', []))
        material_count = len(history_data.get('material_entries', []))
        
        print(f"   ✅ API working!")
        print(f"   Labour entries: {labour_count}")
        print(f"   Material entries: {material_count}")
        print(f"   Message: {history_data.get('message', 'N/A')}")
        
        # Show sample entries with supervisor info
        if labour_count > 0:
            print(f"\n   Sample labour entry:")
            sample_labour = history_data['labour_entries'][0]
            print(f"   {{")
            print(f"    \"labour_type\": \"{sample_labour.get('labour_type', 'N/A')}\",")
            print(f"    \"labour_count\": {sample_labour.get('labour_count', 0)},")
            print(f"    \"site_name\": \"{sample_labour.get('site_name', 'N/A')}\",")
            print(f"    \"customer_name\": \"{sample_labour.get('customer_name', 'N/A')}\",")
            print(f"    \"area\": \"{sample_labour.get('area', 'N/A')}\",")
            print(f"    \"street\": \"{sample_labour.get('street', 'N/A')}\",")
            print(f"    \"supervisor_name\": \"{sample_labour.get('supervisor_name', 'N/A')}\",")
            print(f"    \"entry_date\": \"{sample_labour.get('entry_date', 'N/A')}\",")
            print(f"    \"entry_time\": \"{sample_labour.get('entry_time', 'N/A')}\"")
            print(f"   }}")
        
        if material_count > 0:
            print(f"\n   Sample material entry:")
            sample_material = history_data['material_entries'][0]
            print(f"   {{")
            print(f"    \"material_type\": \"{sample_material.get('material_type', 'N/A')}\",")
            print(f"    \"quantity\": {sample_material.get('quantity', 0)},")
            print(f"    \"unit\": \"{sample_material.get('unit', 'N/A')}\",")
            print(f"    \"site_name\": \"{sample_material.get('site_name', 'N/A')}\",")
            print(f"    \"customer_name\": \"{sample_material.get('customer_name', 'N/A')}\",")
            print(f"    \"area\": \"{sample_material.get('area', 'N/A')}\",")
            print(f"    \"street\": \"{sample_material.get('street', 'N/A')}\",")
            print(f"    \"supervisor_name\": \"{sample_material.get('supervisor_name', 'N/A')}\",")
            print(f"    \"entry_date\": \"{sample_material.get('entry_date', 'N/A')}\",")
            print(f"    \"updated_at\": \"{sample_material.get('updated_at', 'N/A')}\"")
            print(f"   }}")
        
        # Count unique supervisors and sites
        unique_supervisors = set()
        unique_sites = set()
        
        for entry in history_data.get('labour_entries', []):
            if entry.get('supervisor_name'):
                unique_supervisors.add(entry['supervisor_name'])
            if entry.get('site_name'):
                unique_sites.add(f"{entry.get('customer_name', '')} {entry.get('site_name', '')}")
        
        for entry in history_data.get('material_entries', []):
            if entry.get('supervisor_name'):
                unique_supervisors.add(entry['supervisor_name'])
            if entry.get('site_name'):
                unique_sites.add(f"{entry.get('customer_name', '')} {entry.get('site_name', '')}")
        
        print(f"\n   📊 SUMMARY:")
        print(f"   Unique supervisors: {len(unique_supervisors)} - {list(unique_supervisors)}")
        print(f"   Unique sites: {len(unique_sites)} - {list(unique_sites)}")
        
        # Check for Jan 26 entries specifically
        jan_26_labour = [e for e in history_data.get('labour_entries', []) if '2026-01-26' in str(e.get('entry_date', ''))]
        jan_26_material = [e for e in history_data.get('material_entries', []) if '2026-01-26' in str(e.get('entry_date', ''))]
        
        print(f"\n   📅 JANUARY 26, 2026 ENTRIES:")
        print(f"   Labour: {len(jan_26_labour)} entries")
        print(f"   Material: {len(jan_26_material)} entries")
        
        if jan_26_labour:
            print(f"   Jan 26 Labour types: {[e.get('labour_type') for e in jan_26_labour]}")
        if jan_26_material:
            print(f"   Jan 26 Material types: {[e.get('material_type') for e in jan_26_material]}")
        
    else:
        print(f"   ❌ Error response: {history_response.text}")
    
    print(f"\n" + "=" * 60)
    print(f"TEST COMPLETE")
    print(f"=" * 60)

if __name__ == "__main__":
    test_all_supervisors_history()
