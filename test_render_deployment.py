"""
Test Render deployment
"""
import requests
import json

BASE_URL = "https://essentials-construction-project.onrender.com"

print("=" * 60)
print("TESTING RENDER DEPLOYMENT")
print("=" * 60)

# Test 1: Root endpoint
print("\n1. Testing root endpoint...")
try:
    response = requests.get(f"{BASE_URL}/api/", timeout=30)
    print(f"   Status: {response.status_code}")
    if response.status_code == 200:
        print("   ✅ API is responding!")
    else:
        print(f"   Response: {response.text[:200]}")
except Exception as e:
    print(f"   ❌ Error: {e}")

# Test 2: Login endpoint
print("\n2. Testing login endpoint...")
try:
    response = requests.post(
        f"{BASE_URL}/api/auth/login/",
        json={"username": "admin", "password": "admin123"},
        timeout=30
    )
    print(f"   Status: {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        print("   ✅ Login successful!")
        print(f"   User: {data.get('user', {}).get('username')}")
        print(f"   Role: {data.get('user', {}).get('role_name')}")
        token = data.get('token')
        print(f"   Token: {token[:30]}..." if token else "   No token")
    else:
        print(f"   Response: {response.text[:200]}")
except Exception as e:
    print(f"   ❌ Error: {e}")

# Test 3: Sites endpoint (requires auth)
print("\n3. Testing sites endpoint...")
try:
    # First login to get token
    login_response = requests.post(
        f"{BASE_URL}/api/auth/login/",
        json={"username": "admin", "password": "admin123"},
        timeout=30
    )
    if login_response.status_code == 200:
        token = login_response.json().get('token')
        
        # Get sites
        sites_response = requests.get(
            f"{BASE_URL}/api/construction/sites/",
            headers={"Authorization": f"Bearer {token}"},
            timeout=30
        )
        print(f"   Status: {sites_response.status_code}")
        if sites_response.status_code == 200:
            sites = sites_response.json()
            print(f"   ✅ Found {len(sites)} sites")
            if sites:
                print(f"   First site: {sites[0].get('name')}")
        else:
            print(f"   Response: {sites_response.text[:200]}")
except Exception as e:
    print(f"   ❌ Error: {e}")

print("\n" + "=" * 60)
print("DEPLOYMENT TEST COMPLETE!")
print("=" * 60)
print(f"\nYour backend is live at:")
print(f"🌐 {BASE_URL}")
print("\nNext: Update Flutter app to use this URL")
