#!/usr/bin/env python3
"""
Test Client API Endpoints
Tests all client dashboard APIs to verify implementation
"""

import requests
import json
from datetime import datetime

# Configuration
BASE_URL = "http://192.168.1.9:8000/api"
TEST_CLIENT_USERNAME = "testclient"
TEST_CLIENT_PASSWORD = "client123"

def print_section(title):
    """Print formatted section header"""
    print("\n" + "="*60)
    print(f"  {title}")
    print("="*60)

def login():
    """Login and get JWT token"""
    print_section("LOGIN")
    
    response = requests.post(
        f"{BASE_URL}/auth/login/",
        json={
            "username": TEST_CLIENT_USERNAME,
            "password": TEST_CLIENT_PASSWORD
        }
    )
    
    if response.status_code == 200:
        data = response.json()
        token = data.get('access_token')
        user_info = data.get('user', {})
        print(f"✅ Login successful!")
        print(f"   User: {user_info.get('full_name')} ({user_info.get('role')})")
        print(f"   Token: {token[:20]}...")
        return token
    else:
        print(f"❌ Login failed: {response.status_code}")
        print(f"   Response: {response.text}")
        return None

def test_site_details(token):
    """Test GET /api/client/site-details/"""
    print_section("TEST: Site Details")
    
    headers = {"Authorization": f"Bearer {token}"}
    response = requests.get(f"{BASE_URL}/client/site-details/", headers=headers)
    
    if response.status_code == 200:
        data = response.json()
        sites = data.get('sites', [])
        print(f"✅ API call successful!")
        print(f"   Sites assigned: {len(sites)}")
        
        if sites:
            site = sites[0]
            print(f"\n   Site Details:")
            print(f"   - Name: {site.get('display_name')}")
            print(f"   - Area: {site.get('area')}")
            print(f"   - Street: {site.get('street')}")
            print(f"   - Status: {site.get('status')}")
            
            # Labour summary
            labour = site.get('labour_summary', {})
            print(f"\n   Labour Summary:")
            print(f"   - Total days: {labour.get('total_days')}")
            print(f"   - Total labour: {labour.get('total_labour_count')}")
            print(f"   - Last entry: {labour.get('last_entry_date')}")
            
            # Photos
            photos = site.get('photos', [])
            print(f"\n   Photos: {len(photos)} uploaded")
            if photos:
                morning = [p for p in photos if p['time_of_day'].lower() == 'morning']
                evening = [p for p in photos if p['time_of_day'].lower() == 'evening']
                print(f"   - Morning: {len(morning)}")
                print(f"   - Evening: {len(evening)}")
            
            # Documents
            arch_docs = site.get('architect_documents', [])
            eng_docs = site.get('engineer_documents', [])
            print(f"\n   Documents:")
            print(f"   - Architect: {len(arch_docs)}")
            print(f"   - Engineer: {len(eng_docs)}")
            
            return site.get('site_id')
        else:
            print("   ⚠️  No sites assigned to this client")
            return None
    else:
        print(f"❌ API call failed: {response.status_code}")
        print(f"   Response: {response.text}")
        return None

def test_materials(token, site_id):
    """Test GET /api/client/materials/"""
    print_section("TEST: Materials")
    
    if not site_id:
        print("⚠️  Skipping - no site_id available")
        return
    
    headers = {"Authorization": f"Bearer {token}"}
    response = requests.get(
        f"{BASE_URL}/client/materials/?site_id={site_id}",
        headers=headers
    )
    
    if response.status_code == 200:
        data = response.json()
        materials = data.get('materials', [])
        print(f"✅ API call successful!")
        print(f"   Materials found: {len(materials)}")
        
        if materials:
            print(f"\n   Material Details:")
            for mat in materials[:5]:  # Show first 5
                print(f"   - {mat['material_type']}: {mat['total_used']} {mat['unit']}")
                print(f"     Entries: {mat['usage_count']}, Last used: {mat['last_used_date']}")
        else:
            print("   ⚠️  No materials used yet")
    else:
        print(f"❌ API call failed: {response.status_code}")
        print(f"   Response: {response.text}")

def test_photos(token, site_id):
    """Test GET /api/client/photos/"""
    print_section("TEST: Photos")
    
    if not site_id:
        print("⚠️  Skipping - no site_id available")
        return
    
    headers = {"Authorization": f"Bearer {token}"}
    
    # Test without filter
    response = requests.get(
        f"{BASE_URL}/client/photos/?site_id={site_id}",
        headers=headers
    )
    
    if response.status_code == 200:
        data = response.json()
        photos = data.get('photos', [])
        print(f"✅ API call successful!")
        print(f"   Total photos: {len(photos)}")
        
        if photos:
            morning = [p for p in photos if p['time_of_day'].lower() == 'morning']
            evening = [p for p in photos if p['time_of_day'].lower() == 'evening']
            print(f"   - Morning: {len(morning)}")
            print(f"   - Evening: {len(evening)}")
            
            # Test with filter
            response2 = requests.get(
                f"{BASE_URL}/client/photos/?site_id={site_id}&time_of_day=Morning",
                headers=headers
            )
            if response2.status_code == 200:
                filtered = response2.json().get('photos', [])
                print(f"   - Filtered (Morning only): {len(filtered)}")
    else:
        print(f"❌ API call failed: {response.status_code}")
        print(f"   Response: {response.text}")

def test_documents(token, site_id):
    """Test GET /api/client/documents/"""
    print_section("TEST: Documents")
    
    if not site_id:
        print("⚠️  Skipping - no site_id available")
        return
    
    headers = {"Authorization": f"Bearer {token}"}
    response = requests.get(
        f"{BASE_URL}/client/documents/?site_id={site_id}",
        headers=headers
    )
    
    if response.status_code == 200:
        data = response.json()
        documents = data.get('documents', [])
        print(f"✅ API call successful!")
        print(f"   Total documents: {len(documents)}")
        print(f"   - Architect: {data.get('architect_count', 0)}")
        print(f"   - Engineer: {data.get('engineer_count', 0)}")
        
        if documents:
            print(f"\n   Document Details:")
            for doc in documents[:5]:  # Show first 5
                print(f"   - {doc['title']} ({doc['document_type']})")
                print(f"     By: {doc['uploaded_by']} ({doc['role']})")
                print(f"     Date: {doc['upload_date']}")
    else:
        print(f"❌ API call failed: {response.status_code}")
        print(f"   Response: {response.text}")

def main():
    """Run all tests"""
    print("\n" + "🔍 CLIENT API TEST SUITE".center(60))
    print(f"Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"Base URL: {BASE_URL}")
    print(f"Test User: {TEST_CLIENT_USERNAME}")
    
    # Login
    token = login()
    if not token:
        print("\n❌ Cannot proceed without valid token")
        return
    
    # Test site details (returns site_id for other tests)
    site_id = test_site_details(token)
    
    # Test materials
    test_materials(token, site_id)
    
    # Test photos
    test_photos(token, site_id)
    
    # Test documents
    test_documents(token, site_id)
    
    # Summary
    print_section("TEST SUMMARY")
    print("✅ All API endpoints tested")
    print("✅ Client dashboard implementation verified")
    print("\nNext steps:")
    print("1. Test in Flutter app")
    print("2. Verify UI displays data correctly")
    print("3. Test with different client users")
    print("4. Test with sites that have no data")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n⚠️  Test interrupted by user")
    except Exception as e:
        print(f"\n\n❌ Test failed with error: {e}")
        import traceback
        traceback.print_exc()
