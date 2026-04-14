"""
Test Site Engineer API Endpoints
Run this after starting the Django server to verify all endpoints work
"""
import requests
import json

BASE_URL = "http://192.168.1.7:8000/api"

# You need to login first to get a token
# Replace this with your actual token after logging in
TOKEN = "YOUR_TOKEN_HERE"

headers = {
    "Authorization": f"Bearer {TOKEN}",
    "Content-Type": "application/json"
}

def test_get_sites():
    """Test getting assigned sites"""
    print("\n1. Testing GET /engineer/sites/")
    print("-" * 50)
    
    response = requests.get(f"{BASE_URL}/engineer/sites/", headers=headers)
    print(f"Status Code: {response.status_code}")
    
    if response.status_code == 200:
        data = response.json()
        print(f"✅ Success! Found {len(data.get('sites', []))} sites")
        if data.get('sites'):
            print(f"First site: {data['sites'][0].get('display_name')}")
    else:
        print(f"❌ Error: {response.text}")

def test_get_daily_status():
    """Test getting daily status for a site"""
    print("\n2. Testing GET /engineer/daily-status/1/")
    print("-" * 50)
    
    response = requests.get(f"{BASE_URL}/engineer/daily-status/1/", headers=headers)
    print(f"Status Code: {response.status_code}")
    
    if response.status_code == 200:
        data = response.json()
        print(f"✅ Success!")
        print(f"Morning Update Done: {data.get('morning_update_done')}")
        print(f"Evening Update Done: {data.get('evening_update_done')}")
        print(f"Activities Today: {len(data.get('work_activities', []))}")
    else:
        print(f"❌ Error: {response.text}")

def test_get_complaints():
    """Test getting complaints for a site"""
    print("\n3. Testing GET /engineer/complaints/1/")
    print("-" * 50)
    
    response = requests.get(f"{BASE_URL}/engineer/complaints/1/", headers=headers)
    print(f"Status Code: {response.status_code}")
    
    if response.status_code == 200:
        data = response.json()
        print(f"✅ Success! Found {len(data.get('complaints', []))} complaints")
    else:
        print(f"❌ Error: {response.text}")

def test_submit_extra_work():
    """Test submitting extra work"""
    print("\n4. Testing POST /engineer/extra-work/")
    print("-" * 50)
    
    payload = {
        "site_id": 1,
        "description": "Test extra work",
        "amount": 1000,
        "labour_count": 2
    }
    
    response = requests.post(
        f"{BASE_URL}/engineer/extra-work/",
        headers=headers,
        json=payload
    )
    print(f"Status Code: {response.status_code}")
    
    if response.status_code == 200:
        data = response.json()
        print(f"✅ Success!")
        print(f"Message: {data.get('message')}")
        if data.get('whatsapp_message'):
            print("\nWhatsApp Message:")
            print(data['whatsapp_message'])
    else:
        print(f"❌ Error: {response.text}")

def test_get_project_files():
    """Test getting project files"""
    print("\n5. Testing GET /engineer/project-files/1/")
    print("-" * 50)
    
    response = requests.get(f"{BASE_URL}/engineer/project-files/1/", headers=headers)
    print(f"Status Code: {response.status_code}")
    
    if response.status_code == 200:
        data = response.json()
        print(f"✅ Success! Found {len(data.get('files', []))} files")
    else:
        print(f"❌ Error: {response.text}")

def main():
    print("=" * 50)
    print("SITE ENGINEER API TESTS")
    print("=" * 50)
    
    if TOKEN == "YOUR_TOKEN_HERE":
        print("\n⚠️  WARNING: You need to set your authentication token!")
        print("1. Login to get a token")
        print("2. Replace TOKEN variable in this script")
        print("3. Run this script again")
        return
    
    try:
        # Test all endpoints
        test_get_sites()
        test_get_daily_status()
        test_get_complaints()
        test_submit_extra_work()
        test_get_project_files()
        
        print("\n" + "=" * 50)
        print("ALL TESTS COMPLETED!")
        print("=" * 50)
        
    except requests.exceptions.ConnectionError:
        print("\n❌ ERROR: Cannot connect to backend!")
        print("Make sure Django server is running:")
        print("  cd django-backend")
        print("  python manage.py runserver 0.0.0.0:8000")
    except Exception as e:
        print(f"\n❌ ERROR: {str(e)}")

if __name__ == "__main__":
    main()
