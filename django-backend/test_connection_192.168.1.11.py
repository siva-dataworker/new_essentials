#!/usr/bin/env python
"""
Test connection to Django backend at 192.168.1.9:8000
"""

import requests
import sys

BASE_URL = 'http://192.168.1.9:8000'

def test_connection():
    """Test if backend is accessible"""
    
    print("=" * 60)
    print("Testing Connection to Django Backend")
    print("=" * 60)
    print(f"URL: {BASE_URL}")
    print()
    
    try:
        # Test root endpoint
        print("1. Testing root endpoint...")
        response = requests.get(f"{BASE_URL}/api/", timeout=5)
        
        if response.status_code == 200:
            print(f"   ✅ SUCCESS - Status: {response.status_code}")
            print(f"   Response: {response.text[:100]}...")
        else:
            print(f"   ⚠️  WARNING - Status: {response.status_code}")
            
    except requests.exceptions.ConnectionError:
        print("   ❌ FAILED - Connection refused")
        print("   Make sure Django server is running:")
        print("   cd django-backend")
        print("   START_SERVER.bat")
        sys.exit(1)
    except requests.exceptions.Timeout:
        print("   ❌ FAILED - Connection timeout")
        sys.exit(1)
    except Exception as e:
        print(f"   ❌ FAILED - {e}")
        sys.exit(1)
    
    print()
    
    # Test auth endpoint
    try:
        print("2. Testing auth endpoint...")
        response = requests.get(f"{BASE_URL}/api/auth/", timeout=5)
        print(f"   ✅ Auth endpoint accessible - Status: {response.status_code}")
    except Exception as e:
        print(f"   ⚠️  Auth endpoint error: {e}")
    
    print()
    
    # Test construction endpoint
    try:
        print("3. Testing construction endpoint...")
        response = requests.get(f"{BASE_URL}/api/construction/", timeout=5)
        print(f"   ✅ Construction endpoint accessible - Status: {response.status_code}")
    except Exception as e:
        print(f"   ⚠️  Construction endpoint error: {e}")
    
    print()
    print("=" * 60)
    print("✅ Backend is accessible at http://192.168.1.9:8000")
    print("=" * 60)
    print()
    print("Next steps:")
    print("1. Rebuild Flutter app:")
    print("   cd otp_phone_auth")
    print("   flutter clean")
    print("   flutter pub get")
    print("   flutter run")
    print()
    print("2. Test login on mobile device")
    print()

if __name__ == '__main__':
    test_connection()
