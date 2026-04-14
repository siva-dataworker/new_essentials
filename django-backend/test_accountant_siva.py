#!/usr/bin/env python3
"""
Test the accountant API with actual accountant credentials (Siva)
"""

import requests
import json

def test_accountant_siva():
    print("🧪 TESTING ACCOUNTANT API WITH SIVA CREDENTIALS")
    print("=" * 60)
    
    base_url = "http://localhost:8000/api"
    
    # Login as accountant Siva
    print("1. Logging in as accountant Siva...")
    login_response = requests.post(f"{base_url}/auth/login/", json={
        "username": "Siva",
        "password": "Test123"
    })
    
    if login_response.status_code != 200:
        print(f"❌ Login failed: {login_response.text}")
        print("   Let's check what users exist...")
        
        # Try to find the user in database
        return
    
    login_data = login_response.json()
    token = login_data['access_token']
    user_info = login_data['user']
    
    print(f"✅ Login successful!")
    print(f"   User: {user_info['username']} ({user_info['role']})")
    print(f"   Full Name: {user_info.get('full_name', 'N/A')}")
    print(f"   User ID: {user_info.get('id', 'N/A')}")
    
    # Test accountant API
    print(f"\n2. Testing accountant API...")
    headers = {
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json'
    }
    
    accountant_response = requests.get(
        f"{base_url}/construction/accountant/all-entries/",
        headers=headers
    )
    
    print(f"   Status Code: {accountant_response.status_code}")
    
    if accountant_response.status_code == 200:
        accountant_data = accountant_response.json()
        labour_entries = accountant_data.get('labour_entries', [])
        material_entries = accountant_data.get('material_entries', [])
        
        print(f"   ✅ API working!")
        print(f"   Total labour entries: {len(labour_entries)}")
        print(f"   Total material entries: {len(material_entries)}")
        print(f"   Message: {accountant_data.get('message', 'N/A')}")
        
        # Check for Lakshmi site data specifically
        lakshmi_labour = [e for e in labour_entries if 'lakshmi' in e.get('customer_name', '').lower()]
        lakshmi_material = [e for e in material_entries if 'lakshmi' in e.get('customer_name', '').lower()]
        
        print(f"\n   📋 LAKSHMI SITE DATA:")
        print(f"   Labour entries: {len(lakshmi_labour)}")
        print(f"   Material entries: {len(lakshmi_material)}")
        
        if lakshmi_labour:
            print(f"   Sample Lakshmi labour entry:")
            entry = lakshmi_labour[0]
            print(f"     - {entry.get('labour_type', 'N/A')}: {entry.get('labour_count', 0)} workers")
            print(f"     - Site: {entry.get('customer_name', '')} {entry.get('site_name', '')}")
            print(f"     - Supervisor: {entry.get('supervisor_name', 'N/A')}")
            print(f"     - Date: {entry.get('entry_date', 'N/A')}")
        
        # Show all unique sites
        unique_sites = set()
        for entry in labour_entries + material_entries:
            customer = entry.get('customer_name', '')
            site = entry.get('site_name', '')
            if customer and site:
                unique_sites.add(f"{customer} {site}")
        
        print(f"\n   📍 ALL AVAILABLE SITES ({len(unique_sites)}):")
        for site in sorted(unique_sites):
            print(f"     - {site}")
        
        # Test multiple API calls to check consistency
        print(f"\n3. Testing API consistency (multiple calls)...")
        for i in range(3):
            test_response = requests.get(
                f"{base_url}/construction/accountant/all-entries/",
                headers=headers
            )
            
            if test_response.status_code == 200:
                test_data = test_response.json()
                test_labour = len(test_data.get('labour_entries', []))
                test_material = len(test_data.get('material_entries', []))
                print(f"   Call {i+1}: Labour={test_labour}, Material={test_material}")
            else:
                print(f"   Call {i+1}: Failed with status {test_response.status_code}")
        
    else:
        print(f"   ❌ Error response: {accountant_response.text}")
    
    print(f"\n" + "=" * 60)
    print(f"TEST COMPLETE")
    print(f"=" * 60)

if __name__ == "__main__":
    test_accountant_siva()
