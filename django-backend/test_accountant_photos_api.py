#!/usr/bin/env python3
"""
Test the accountant photos API with actual accountant credentials (Siva)
"""

import requests
import json

def test_accountant_photos_api():
    print("🧪 TESTING ACCOUNTANT PHOTOS API WITH SIVA CREDENTIALS")
    print("=" * 60)
    
    base_url = "http://localhost:8000/api"
    
    # Login as accountant Siva
    print("1. Logging in as accountant Siva...")
    login_response = requests.post(f"{base_url}/auth/login/", json={
        "username": "Siva",
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
    print(f"   Full Name: {user_info.get('full_name', 'N/A')}")
    
    # Test accountant photos API
    print(f"\n2. Testing accountant photos API...")
    headers = {
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json'
    }
    
    photos_response = requests.get(
        f"{base_url}/construction/accountant/all-photos/",
        headers=headers
    )
    
    print(f"   Status Code: {photos_response.status_code}")
    
    if photos_response.status_code == 200:
        photos_data = photos_response.json()
        photos = photos_data.get('photos', [])
        total_photos = photos_data.get('total_photos', 0)
        
        print(f"   ✅ API working!")
        print(f"   Total photos: {total_photos}")
        print(f"   Photos returned: {len(photos)}")
        
        if photos:
            print(f"\n   📸 SAMPLE PHOTOS:")
            for i, photo in enumerate(photos[:3]):  # Show first 3 photos
                print(f"   Photo {i+1}:")
                print(f"     - Site: {photo.get('full_site_name', 'N/A')}")
                print(f"     - Type: {photo.get('update_type', 'N/A')}")
                print(f"     - Uploaded by: {photo.get('uploaded_by', 'N/A')} ({photo.get('uploaded_by_role', 'N/A')})")
                print(f"     - Date: {photo.get('update_date', 'N/A')}")
                print(f"     - Image URL: {photo.get('image_url', 'N/A')}")
        
        # Test with filters
        print(f"\n3. Testing with filters...")
        
        # Filter by morning photos
        morning_response = requests.get(
            f"{base_url}/construction/accountant/all-photos/?update_type=STARTED",
            headers=headers
        )
        
        if morning_response.status_code == 200:
            morning_data = morning_response.json()
            morning_photos = morning_data.get('photos', [])
            print(f"   Morning photos (STARTED): {len(morning_photos)}")
        
        # Filter by evening photos
        evening_response = requests.get(
            f"{base_url}/construction/accountant/all-photos/?update_type=FINISHED",
            headers=headers
        )
        
        if evening_response.status_code == 200:
            evening_data = evening_response.json()
            evening_photos = evening_data.get('photos', [])
            print(f"   Evening photos (FINISHED): {len(evening_photos)}")
        
        # Get unique sites from photos
        unique_sites = set()
        for photo in photos:
            site_name = photo.get('full_site_name', '')
            if site_name:
                unique_sites.add(site_name)
        
        print(f"\n   📍 SITES WITH PHOTOS ({len(unique_sites)}):")
        for site in sorted(unique_sites):
            print(f"     - {site}")
        
    else:
        print(f"   ❌ Error response: {photos_response.text}")
    
    print(f"\n" + "=" * 60)
    print(f"TEST COMPLETE")
    print(f"=" * 60)

if __name__ == "__main__":
    test_accountant_photos_api()
