"""
Test script for day-based history feature
Run this after starting the backend to verify everything works
"""

import requests
import json
from datetime import datetime

# Configuration
BASE_URL = "http://localhost:8000/api"
# You'll need to replace these with actual values
TEST_TOKEN = "YOUR_JWT_TOKEN_HERE"
TEST_SITE_ID = "YOUR_SITE_ID_HERE"

headers = {
    "Authorization": f"Bearer {TEST_TOKEN}",
    "Content-Type": "application/json"
}

def test_current_ist_time():
    """Test 1: Get current IST time"""
    print("\n" + "="*60)
    print("TEST 1: Get Current IST Time")
    print("="*60)
    
    response = requests.get(f"{BASE_URL}/construction/current-ist-time/", headers=headers)
    print(f"Status Code: {response.status_code}")
    
    if response.status_code == 200:
        data = response.json()
        print(f"✅ Current IST Time: {data.get('current_time_ist')}")
        print(f"✅ Day of Week: {data.get('day_of_week')}")
        return True
    else:
        print(f"❌ Error: {response.text}")
        return False

def test_validate_entry_time():
    """Test 2: Validate entry time"""
    print("\n" + "="*60)
    print("TEST 2: Validate Entry Time")
    print("="*60)
    
    response = requests.get(f"{BASE_URL}/construction/validate-entry-time/", headers=headers)
    print(f"Status Code: {response.status_code}")
    
    if response.status_code == 200:
        data = response.json()
        print(f"✅ Entry Allowed: {data.get('allowed')}")
        print(f"✅ Message: {data.get('message')}")
        print(f"✅ Current Time: {data.get('current_time_ist')}")
        if not data.get('allowed'):
            print(f"⏰ Next Window: {data.get('next_window')}")
        return True
    else:
        print(f"❌ Error: {response.text}")
        return False

def test_submit_labour_with_time_check():
    """Test 3: Try to submit labour entry (will check time)"""
    print("\n" + "="*60)
    print("TEST 3: Submit Labour Entry (Time Check)")
    print("="*60)
    
    payload = {
        "site_id": TEST_SITE_ID,
        "labour_count": 5,
        "labour_type": "Test Worker",
        "notes": "Test entry for day-based history"
    }
    
    response = requests.post(f"{BASE_URL}/construction/labour/", headers=headers, json=payload)
    print(f"Status Code: {response.status_code}")
    
    if response.status_code == 201:
        data = response.json()
        print(f"✅ Entry Created Successfully!")
        print(f"✅ Entry ID: {data.get('entry_id')}")
        print(f"✅ Day of Week: {data.get('day_of_week')}")
        print(f"✅ Entry Date: {data.get('entry_date')}")
        return True
    elif response.status_code == 403:
        data = response.json()
        print(f"⏰ Time Restriction Active:")
        print(f"   Message: {data.get('message')}")
        print(f"   Allowed Hours: {data.get('allowed_hours')}")
        print(f"   Current Time: {data.get('current_time_ist')}")
        print(f"   Next Window: {data.get('next_window')}")
        return True  # This is expected behavior
    elif response.status_code == 400:
        data = response.json()
        print(f"⚠️ Already Submitted: {data.get('error')}")
        return True  # This is also expected
    else:
        print(f"❌ Error: {response.text}")
        return False

def test_history_by_day():
    """Test 4: Get history grouped by day"""
    print("\n" + "="*60)
    print("TEST 4: Get History by Day")
    print("="*60)
    
    response = requests.get(
        f"{BASE_URL}/construction/history-by-day/",
        headers=headers,
        params={"site_id": TEST_SITE_ID}
    )
    print(f"Status Code: {response.status_code}")
    
    if response.status_code == 200:
        data = response.json()
        print(f"✅ Success: {data.get('success')}")
        print(f"✅ Total Labour Entries: {data.get('total_labour_entries')}")
        print(f"✅ Total Material Entries: {data.get('total_material_entries')}")
        
        labour_by_day = data.get('labour_by_day', {})
        material_by_day = data.get('material_by_day', {})
        
        print(f"\n📊 Labour Entries by Day:")
        for day, entries in labour_by_day.items():
            print(f"   {day}: {len(entries)} entries")
            if entries:
                print(f"      Sample: {entries[0].get('labour_type')} - {entries[0].get('labour_count')} workers")
        
        print(f"\n📦 Material Entries by Day:")
        for day, entries in material_by_day.items():
            print(f"   {day}: {len(entries)} entries")
            if entries:
                print(f"      Sample: {entries[0].get('material_type')} - {entries[0].get('quantity')} {entries[0].get('unit')}")
        
        return True
    else:
        print(f"❌ Error: {response.text}")
        return False

def main():
    """Run all tests"""
    print("\n" + "="*60)
    print("🧪 DAY-BASED HISTORY FEATURE TEST SUITE")
    print("="*60)
    print(f"Backend URL: {BASE_URL}")
    print(f"Test Site ID: {TEST_SITE_ID}")
    print(f"Current Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    # Check if token and site_id are configured
    if TEST_TOKEN == "YOUR_JWT_TOKEN_HERE" or TEST_SITE_ID == "YOUR_SITE_ID_HERE":
        print("\n⚠️ WARNING: Please configure TEST_TOKEN and TEST_SITE_ID in this script")
        print("   1. Login to get JWT token")
        print("   2. Get a site_id from /api/construction/sites/")
        print("   3. Update the variables at the top of this script")
        return
    
    # Run tests
    results = []
    results.append(("Current IST Time", test_current_ist_time()))
    results.append(("Validate Entry Time", test_validate_entry_time()))
    results.append(("Submit Labour Entry", test_submit_labour_with_time_check()))
    results.append(("History by Day", test_history_by_day()))
    
    # Summary
    print("\n" + "="*60)
    print("📋 TEST SUMMARY")
    print("="*60)
    
    passed = sum(1 for _, result in results if result)
    total = len(results)
    
    for test_name, result in results:
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"{status} - {test_name}")
    
    print(f"\n{passed}/{total} tests passed")
    
    if passed == total:
        print("\n🎉 All tests passed! Backend is ready.")
    else:
        print("\n⚠️ Some tests failed. Check the errors above.")

if __name__ == "__main__":
    main()
