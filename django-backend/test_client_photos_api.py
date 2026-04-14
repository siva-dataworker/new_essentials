#!/usr/bin/env python3
"""
Test Client Photos By Date API
Tests the new photos-by-date endpoint with filtering
"""

import requests
import json
from datetime import datetime

# Configuration
BASE_URL = "http://192.168.1.9:8000/api"

def print_section(title):
    """Print formatted section header"""
    print("\n" + "="*60)
    print(f"  {title}")
    print("="*60)

def test_photos_by_date(token, site_id):
    """Test GET /api/client/photos-by-date/"""
    print_section("TEST: Photos By Date (All)")
    
    if not site_id:
        print("⚠️  Skipping - no site_id available")
        return None
    
    headers = {"Authorization": f"Bearer {token}"}
    response = requests.get(
        f"{BASE_URL}/client/photos-by-date/?site_id={site_id}",
        headers=headers
    )
    
    if response.status_code == 200:
        data = response.json()
        print(f"✅ API call successful!")
        print(f"   Total photos: {data.get('total_photos', 0)}")
        print(f"   - Supervisor: {data.get('supervisor_photos', 0)}")
        print(f"   - Site Engineer: {data.get('engineer_photos', 0)}")
        
        dates = data.get('dates', [])
        print(f"\n   Available dates: {len(dates)}")
        for date in dates[:5]:  # Show first 5 dates
            photos = data.get('photos_by_date', {}).get(date, [])
            morning = [p for p in photos if p['time_of_day'].lower() == 'morning']
            evening = [p for p in photos if p['time_of_day'].lower() == 'evening']
            print(f"   - {date}: {len(photos)} photos (Morning: {len(morning)}, Evening: {len(evening)})")
            
            # Show who uploaded
            for photo in photos[:2]:  # Show first 2 photos per date
                print(f"      • {photo['time_of_day']} by {photo['uploaded_by']} ({photo['uploaded_by_role']})")
        
        return dates[0] if dates else None
    else:
        print(f"❌ API call failed: {response.status_code}")
        print(f"   Response: {response.text}")
        return None

def test_photos_filtered(token, site_id, filter_date):
    """Test GET /api/client/photos-by-date/ with date filter"""
    print_section(f"TEST: Photos Filtered By Date ({filter_date})")
    
    if not site_id or not filter_date:
        print("⚠️  Skipping - no site_id or filter_date available")
        return
    
    headers = {"Authorization": f"Bearer {token}"}
    response = requests.get(
        f"{BASE_URL}/client/photos-by-date/?site_id={site_id}&date={filter_date}",
        headers=headers
    )
    
    if response.status_code == 200:
        data = response.json()
        print(f"✅ API call successful!")
        print(f"   Filter applied: {data.get('filter_date')}")
        print(f"   Total photos: {data.get('total_photos', 0)}")
        print(f"   - Supervisor: {data.get('supervisor_photos', 0)}")
        print(f"   - Site Engineer: {data.get('engineer_photos', 0)}")
        
        photos_by_date = data.get('photos_by_date', {})
        if filter_date in photos_by_date:
            photos = photos_by_date[filter_date]
            print(f"\n   Photos for {filter_date}:")
            for photo in photos:
                print(f"   - {photo['time_of_day']}: {photo['uploaded_by']} ({photo['uploaded_by_role']})")
        else:
            print(f"\n   ⚠️  No photos found for {filter_date}")
    else:
        print(f"❌ API call failed: {response.status_code}")
        print(f"   Response: {response.text}")

def main():
    """Run all tests"""
    print("\n" + "🔍 CLIENT PHOTOS API TEST".center(60))
    print(f"Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    # You need to provide a valid token and site_id
    print("\n⚠️  This test requires:")
    print("   1. A valid JWT token from a client user")
    print("   2. A site_id that the client has access to")
    print("\nTo get these:")
    print("   1. Run: python test_client_api.py")
    print("   2. Copy the token and site_id from the output")
    print("   3. Update this script with those values")
    
    # Example usage (replace with actual values):
    # token = "your_jwt_token_here"
    # site_id = "your_site_id_here"
    # 
    # # Test all photos
    # latest_date = test_photos_by_date(token, site_id)
    # 
    # # Test filtered photos
    # if latest_date:
    #     test_photos_filtered(token, site_id, latest_date)

if __name__ == "__main__":
    main()
