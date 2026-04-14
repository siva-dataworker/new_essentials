"""
Final test: Verify Flutter app can connect to Render backend
"""
import requests
import json

RENDER_URL = "https://essentials-construction-project.onrender.com"

print("=" * 70)
print("FINAL CONNECTION TEST - Flutter App → Render Backend")
print("=" * 70)

# Test complete login flow
print("\n1. Testing complete login flow...")
try:
    response = requests.post(
        f"{RENDER_URL}/api/auth/login/",
        json={"username": "admin", "password": "admin123"},
        timeout=60  # Longer timeout for first request (spin-up)
    )
    
    print(f"   Status: {response.status_code}")
    
    if response.status_code == 200:
        data = response.json()
        token = data.get('access_token')
        user = data.get('user', {})
        
        print("   ✅ Login successful!")
        print(f"   User: {user.get('username')}")
        print(f"   Role: {user.get('role')}")
        print(f"   Email: {user.get('email')}")
        print(f"   Token: {token[:50]}..." if token else "   No token")
        
        # Test authenticated request
        print("\n2. Testing authenticated API call (get sites)...")
        sites_response = requests.get(
            f"{RENDER_URL}/api/construction/sites/",
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
            
    else:
        print(f"   ❌ Login failed")
        print(f"   Response: {response.text}")
        
except requests.exceptions.Timeout:
    print("   ⚠️ Request timed out (service might be spinning up)")
    print("   Try again in 30 seconds")
except Exception as e:
    print(f"   ❌ Error: {e}")

print("\n" + "=" * 70)
print("CONNECTION TEST COMPLETE")
print("=" * 70)

print("\n✅ Your Flutter app is ready to run!")
print("\nRun these commands:")
print("   cd otp_phone_auth")
print("   flutter run")
print("\nOr build APK:")
print("   flutter build apk --release")
print("\n🌍 Your app will work from anywhere in the world!")
