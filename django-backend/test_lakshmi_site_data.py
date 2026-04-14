#!/usr/bin/env python3
"""
Test specifically for Lakshmi site data visibility in accountant API
"""

import requests
import json

def test_lakshmi_site_data():
    print("🧪 TESTING LAKSHMI SITE DATA VISIBILITY")
    print("=" * 60)
    
    base_url = "http://localhost:8000/api"
    
    # Login as supervisor (since we don't have accountant user)
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
    
    # Test accountant API
    print(f"\n2. Testing accountant API for Lakshmi site data...")
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
        
        # Search for Lakshmi site data
        print(f"\n3. Searching for Lakshmi site data...")
        
        lakshmi_labour = []
        lakshmi_material = []
        
        for entry in labour_entries:
            customer_name = entry.get('customer_name', '').lower()
            site_name = entry.get('site_name', '').lower()
            if 'lakshmi' in customer_name or 'venkat' in site_name:
                lakshmi_labour.append(entry)
        
        for entry in material_entries:
            customer_name = entry.get('customer_name', '').lower()
            site_name = entry.get('site_name', '').lower()
            if 'lakshmi' in customer_name or 'venkat' in site_name:
                lakshmi_material.append(entry)
        
        print(f"   Lakshmi labour entries found: {len(lakshmi_labour)}")
        print(f"   Lakshmi material entries found: {len(lakshmi_material)}")
        
        if lakshmi_labour:
            print(f"\n   📋 LAKSHMI LABOUR ENTRIES:")
            for i, entry in enumerate(lakshmi_labour):
                full_site_name = f"{entry.get('customer_name', '')} {entry.get('site_name', '')}".strip()
                print(f"   [{i+1}] {entry.get('labour_type', 'N/A')} - {entry.get('labour_count', 0)} workers")
                print(f"       Full Site: {full_site_name}")
                print(f"       Customer: {entry.get('customer_name', 'N/A')}")
                print(f"       Site: {entry.get('site_name', 'N/A')}")
                print(f"       Area: {entry.get('area', 'N/A')}")
                print(f"       Street: {entry.get('street', 'N/A')}")
                print(f"       Supervisor: {entry.get('supervisor_name', 'N/A')}")
                print(f"       Date: {entry.get('entry_date', 'N/A')}")
                print()
        
        if lakshmi_material:
            print(f"   📦 LAKSHMI MATERIAL ENTRIES:")
            for i, entry in enumerate(lakshmi_material):
                full_site_name = f"{entry.get('customer_name', '')} {entry.get('site_name', '')}".strip()
                print(f"   [{i+1}] {entry.get('material_type', 'N/A')} - {entry.get('quantity', 0)} {entry.get('unit', '')}")
                print(f"       Full Site: {full_site_name}")
                print(f"       Customer: {entry.get('customer_name', 'N/A')}")
                print(f"       Site: {entry.get('site_name', 'N/A')}")
                print(f"       Area: {entry.get('area', 'N/A')}")
                print(f"       Street: {entry.get('street', 'N/A')}")
                print(f"       Supervisor: {entry.get('supervisor_name', 'N/A')}")
                print(f"       Date: {entry.get('entry_date', 'N/A')}")
                print()
        
        if not lakshmi_labour and not lakshmi_material:
            print(f"   ❌ No Lakshmi site data found!")
            print(f"   Let's check what sites are available:")
            
            unique_sites = set()
            for entry in labour_entries + material_entries:
                customer = entry.get('customer_name', '')
                site = entry.get('site_name', '')
                if customer and site:
                    unique_sites.add(f"{customer} {site}")
            
            print(f"   Available sites:")
            for site in sorted(unique_sites):
                print(f"     - {site}")
        
        # Test supervisor history API too
        print(f"\n4. Testing supervisor history API for comparison...")
        supervisor_response = requests.get(
            f"{base_url}/construction/supervisor/history/",
            headers=headers
        )
        
        if supervisor_response.status_code == 200:
            supervisor_data = supervisor_response.json()
            sup_labour = supervisor_data.get('labour_entries', [])
            sup_material = supervisor_data.get('material_entries', [])
            
            print(f"   Supervisor API - Labour: {len(sup_labour)}, Material: {len(sup_material)}")
            
            # Check if supervisor API has Lakshmi data
            sup_lakshmi_labour = [e for e in sup_labour if 'lakshmi' in e.get('customer_name', '').lower() or 'venkat' in e.get('site_name', '').lower()]
            sup_lakshmi_material = [e for e in sup_material if 'lakshmi' in e.get('customer_name', '').lower() or 'venkat' in e.get('site_name', '').lower()]
            
            print(f"   Supervisor API - Lakshmi Labour: {len(sup_lakshmi_labour)}, Material: {len(sup_lakshmi_material)}")
            
            if len(sup_lakshmi_labour) != len(lakshmi_labour) or len(sup_lakshmi_material) != len(lakshmi_material):
                print(f"   ⚠️  Data mismatch between supervisor and accountant APIs!")
            else:
                print(f"   ✅ Data consistency between supervisor and accountant APIs")
        
    else:
        print(f"   ❌ Error response: {accountant_response.text}")
    
    print(f"\n" + "=" * 60)
    print(f"TEST COMPLETE")
    print(f"=" * 60)

if __name__ == "__main__":
    test_lakshmi_site_data()
