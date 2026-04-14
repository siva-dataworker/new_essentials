"""
Test the history APIs directly to see what's being returned
"""
import requests
import json

BASE_URL = "http://192.168.1.7:8000/api"

print("=" * 60)
print("TESTING HISTORY APIs DIRECTLY")
print("=" * 60)

# First, let's login to get a token
print("\n1. Logging in as supervisor...")
login_response = requests.post(
    f"{BASE_URL}/auth/login/",
    json={"username": "nsjskakaka", "password": "Test123"},
    headers={"Content-Type": "application/json"}
)

if login_response.status_code == 200:
    login_data = login_response.json()
    token = login_data.get('access_token')
    user = login_data.get('user')
    print(f"✅ Login successful!")
    print(f"   User: {user.get('username')} ({user.get('role')})")
    print(f"   Token: {token[:20]}...")
    
    # Test supervisor history API
    print("\n2. Testing supervisor history API...")
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {token}"
    }
    
    history_response = requests.get(
        f"{BASE_URL}/construction/supervisor/history/",
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
        
        if labour_count > 0:
            print("\n   Sample labour entry:")
            print(f"   {json.dumps(history_data['labour_entries'][0], indent=4)}")
        else:
            print("   ⚠️ No labour entries found")
            
        if material_count > 0:
            print("\n   Sample material entry:")
            print(f"   {json.dumps(history_data['material_entries'][0], indent=4)}")
        else:
            print("   ⚠️ No material entries found")
    else:
        print(f"   ❌ API Error: {history_response.text}")
    
    # Test accountant API
    print("\n3. Testing accountant all-entries API...")
    accountant_response = requests.get(
        f"{BASE_URL}/construction/accountant/all-entries/",
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
        
        if labour_count > 0:
            print("\n   Sample labour entry with supervisor:")
            print(f"   {json.dumps(accountant_data['labour_entries'][0], indent=4)}")
        else:
            print("   ⚠️ No labour entries found")
    else:
        print(f"   ❌ API Error: {accountant_response.text}")
    
    # Test sites API
    print("\n4. Testing sites API...")
    sites_response = requests.get(
        f"{BASE_URL}/construction/sites/",
        headers=headers
    )
    
    if sites_response.status_code == 200:
        sites_data = sites_response.json()
        sites_count = len(sites_data.get('sites', []))
        print(f"   ✅ Found {sites_count} sites")
        if sites_count > 0:
            print(f"   First site: {sites_data['sites'][0]}")
    else:
        print(f"   ❌ Sites API Error: {sites_response.text}")
        
else:
    print(f"❌ Login failed: {login_response.status_code}")
    print(f"   Response: {login_response.text}")

print("\n" + "=" * 60)
print("TEST COMPLETE")
print("=" * 60)
