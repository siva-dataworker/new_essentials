#!/usr/bin/env python
"""
Test script to clear working sites
"""

import requests
import json

BASE_URL = "http://192.168.1.9:8000/api"

def test_clear_working_sites():
    """Test clearing working sites"""
    
    print("=" * 60)
    print("Testing Clear Working Sites API")
    print("=" * 60)
    print()
    
    # You need to replace this with a valid accountant JWT token
    # Get it by logging in as an accountant first
    token = input("Enter accountant JWT token: ").strip()
    
    if not token:
        print("❌ Token is required")
        return
    
    headers = {
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json'
    }
    
    print("Clearing working sites...")
    print()
    
    try:
        response = requests.post(
            f"{BASE_URL}/construction/clear-working-sites/",
            headers=headers
        )
        
        print(f"Status Code: {response.status_code}")
        print()
        
        if response.status_code == 200:
            data = response.json()
            print("✅ Success!")
            print(json.dumps(data, indent=2))
        else:
            print("❌ Error:")
            print(response.text)
            
    except Exception as e:
        print(f"❌ Exception: {e}")

if __name__ == '__main__':
    test_clear_working_sites()
