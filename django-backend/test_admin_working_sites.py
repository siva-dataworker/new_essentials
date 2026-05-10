"""
Test script for Admin All Working Sites endpoint
"""
import requests
import json

# Test configuration
BASE_URL = "http://localhost:8000/api"

# You need to replace this with a valid admin token
# To get a token, login as admin through the app or use the login endpoint
ADMIN_TOKEN = "YOUR_ADMIN_TOKEN_HERE"

def test_admin_working_sites():
    """Test the admin all working sites endpoint"""
    
    print("=" * 80)
    print("Testing Admin All Working Sites Endpoint")
    print("=" * 80)
    
    # Make request
    url = f"{BASE_URL}/construction/admin/all-working-sites/"
    headers = {
        "Authorization": f"Bearer {ADMIN_TOKEN}",
        "Content-Type": "application/json"
    }
    
    print(f"\nRequest URL: {url}")
    print(f"Headers: {headers}")
    
    try:
        response = requests.get(url, headers=headers)
        
        print(f"\nResponse Status: {response.status_code}")
        print(f"Response Headers: {dict(response.headers)}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"\n✅ SUCCESS!")
            print(f"Total sites: {data.get('count', 0)}")
            print(f"\nSites:")
            
            for i, site in enumerate(data.get('sites', []), 1):
                print(f"\n{i}. {site.get('display_name', 'N/A')}")
                print(f"   Area: {site.get('area', 'N/A')}")
                print(f"   Street: {site.get('street', 'N/A')}")
                print(f"   Labour Count: {site.get('labour_count', 0)}")
                print(f"   Material Count: {site.get('material_count', 0)}")
                print(f"   Photo Count: {site.get('photo_count', 0)}")
                print(f"   Last Update: {site.get('last_update', 'N/A')}")
        else:
            print(f"\n❌ ERROR!")
            print(f"Response: {response.text}")
            
    except Exception as e:
        print(f"\n❌ EXCEPTION: {e}")

if __name__ == "__main__":
    if ADMIN_TOKEN == "YOUR_ADMIN_TOKEN_HERE":
        print("\n⚠️  Please update ADMIN_TOKEN in the script with a valid admin token")
        print("You can get a token by:")
        print("1. Login as admin through the Flutter app")
        print("2. Check the console logs for the JWT token")
        print("3. Or use the /api/auth/login/ endpoint directly")
    else:
        test_admin_working_sites()
