#!/usr/bin/env python3
"""
Test the accountant API to see what data it returns
"""

import requests
import json

def test_accountant_api():
    print("🧪 TESTING ACCOUNTANT API")
    print("=" * 60)
    
    base_url = "http://localhost:8000/api"
    
    # First, let's check what users we have
    print("1. Checking available users...")
    
    # Try to login as different users to find an accountant
    test_users = [
        {"username": "admin", "password": "Test123"},
        {"username": "accountant", "password": "Test123"},
        {"username": "nsjskakaka", "password": "Test123"},  # This is a supervisor
    ]
    
    accountant_token = None
    accountant_user = None
    
    for user in test_users:
        print(f"   Trying to login as {user['username']}...")
        login_response = requests.post(f"{base_url}/auth/login/", json=user)
        
        if login_response.status_code == 200:
            login_data = login_response.json()
            user_info = login_data['user']
            print(f"   ✅ Login successful: {user_info['username']} ({user_info['role']})")
            
            if user_info['role'] == 'Accountant':
                accountant_token = login_data['access_token']
                accountant_user = user_info
                break
        else:
            print(f"   ❌ Login failed for {user['username']}")
    
    if not accountant_token:
        print("❌ No accountant user found! Let's try with supervisor to see the data structure...")
        # Use supervisor token for testing
        login_response = requests.post(f"{base_url}/auth/login/", json={
            "username": "nsjskakaka",
            "password": "Test123"
        })
        
        if login_response.status_code == 200:
            login_data = login_response.json()
            accountant_token = login_data['access_token']
            accountant_user = login_data['user']
            print(f"   Using supervisor token for testing: {accountant_user['username']}")
        else:
            print("❌ Cannot get any valid token!")
            return
    
    # Test accountant API
    print(f"\n2. Testing accountant API...")
    headers = {
        'Authorization': f'Bearer {accountant_token}',
        'Content-Type': 'application/json'
    }
    
    accountant_response = requests.get(
        f"{base_url}/construction/accountant/all-entries/",
        headers=headers
    )
    
    print(f"   Status Code: {accountant_response.status_code}")
    
    if accountant_response.status_code == 200:
        accountant_data = accountant_response.json()
        labour_count = len(accountant_data.get('labour_entries', []))
        material_count = len(accountant_data.get('material_entries', []))
        
        print(f"   ✅ API working!")
        print(f"   Labour entries: {labour_count}")
        print(f"   Material entries: {material_count}")
        
        # Show sample entries
        if labour_count > 0:
            print(f"\n   Sample labour entries:")
            for i, entry in enumerate(accountant_data['labour_entries'][:3]):  # Show first 3
                print(f"   [{i+1}] {entry.get('labour_type', 'N/A')} - {entry.get('labour_count', 0)} workers")
                print(f"       Site: {entry.get('site_name', 'N/A')}")
                print(f"       Supervisor: {entry.get('supervisor_name', 'N/A')}")
                print(f"       Date: {entry.get('entry_date', 'N/A')}")
                print(f"       Entry Time: {entry.get('entry_time', 'N/A')}")
                print()
        
        if material_count > 0:
            print(f"   Sample material entries:")
            for i, entry in enumerate(accountant_data['material_entries'][:3]):  # Show first 3
                print(f"   [{i+1}] {entry.get('material_type', 'N/A')} - {entry.get('quantity', 0)} {entry.get('unit', '')}")
                print(f"       Site: {entry.get('site_name', 'N/A')}")
                print(f"       Supervisor: {entry.get('supervisor_name', 'N/A')}")
                print(f"       Date: {entry.get('entry_date', 'N/A')}")
                print(f"       Updated: {entry.get('updated_at', 'N/A')}")
                print()
        
        # Check for specific site data
        print(f"\n   Checking for 'Lakshmi' site data...")
        lakshmi_labour = [e for e in accountant_data.get('labour_entries', []) 
                         if 'lakshmi' in str(e.get('site_name', '')).lower() or 
                            'lakshmi' in str(e.get('supervisor_name', '')).lower()]
        lakshmi_material = [e for e in accountant_data.get('material_entries', []) 
                           if 'lakshmi' in str(e.get('site_name', '')).lower() or 
                              'lakshmi' in str(e.get('supervisor_name', '')).lower()]
        
        print(f"   Lakshmi labour entries: {len(lakshmi_labour)}")
        print(f"   Lakshmi material entries: {len(lakshmi_material)}")
        
        if lakshmi_labour:
            print(f"   Lakshmi labour details:")
            for entry in lakshmi_labour:
                print(f"     - {entry.get('labour_type', 'N/A')}: {entry.get('labour_count', 0)} workers")
                print(f"       Site: {entry.get('site_name', 'N/A')}")
                print(f"       Supervisor: {entry.get('supervisor_name', 'N/A')}")
        
        # Count unique supervisors and sites
        unique_supervisors = set()
        unique_sites = set()
        
        for entry in accountant_data.get('labour_entries', []):
            if entry.get('supervisor_name'):
                unique_supervisors.add(entry['supervisor_name'])
            if entry.get('site_name'):
                unique_sites.add(entry['site_name'])
        
        for entry in accountant_data.get('material_entries', []):
            if entry.get('supervisor_name'):
                unique_supervisors.add(entry['supervisor_name'])
            if entry.get('site_name'):
                unique_sites.add(entry['site_name'])
        
        print(f"\n   📊 SUMMARY:")
        print(f"   Unique supervisors: {len(unique_supervisors)} - {list(unique_supervisors)}")
        print(f"   Unique sites: {len(unique_sites)} - {list(unique_sites)}")
        
    else:
        print(f"   ❌ Error response: {accountant_response.text}")
    
    print(f"\n" + "=" * 60)
    print(f"TEST COMPLETE")
    print(f"=" * 60)

if __name__ == "__main__":
    test_accountant_api()
