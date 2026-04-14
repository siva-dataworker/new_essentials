#!/usr/bin/env python
"""
Test working sites API
"""

import requests

BASE_URL = 'http://192.168.1.9:8000/api'

def test_working_sites():
    """Test working sites API"""
    
    print("=" * 60)
    print("TESTING WORKING SITES API")
    print("=" * 60)
    print()
    
    # Login as supervisor
    print("1. Logging in as supervisor (nsnwjw)...")
    login_response = requests.post(
        f"{BASE_URL}/auth/login/",
        json={
            'username': 'nsnwjw',
            'password': 'Test123'
        }
    )
    
    if login_response.status_code != 200:
        print(f"❌ Login failed: {login_response.status_code}")
        print(login_response.text)
        return
    
    token = login_response.json()['access']
    print(f"✅ Login successful")
    print()
    
    # Get working sites
    print("2. Getting working sites...")
    headers = {
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json'
    }
    
    response = requests.get(
        f"{BASE_URL}/construction/working-sites/",
        headers=headers
    )
    
    print(f"Status: {response.status_code}")
    print(f"Response: {response.json()}")
    print()
    
    if response.status_code == 200:
        data = response.json()
        sites = data.get('sites', [])
        print(f"Working sites count: {len(sites)}")
        
        if sites:
            print("❌ ERROR: Working sites still exist!")
            print("Sites:")
            for site in sites:
                print(f"  - {site.get('site_name')} ({site.get('id')})")
        else:
            print("✅ No working sites (correct!)")
    
    print("=" * 60)

if __name__ == '__main__':
    test_working_sites()
