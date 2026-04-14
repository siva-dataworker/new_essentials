"""
Test script to verify notification creation works
Run this AFTER starting the Django server
"""
import requests
import json
from datetime import datetime

# Configuration
BASE_URL = "http://192.168.1.9:8000/api"

# You need to get a valid token first by logging in
# Replace this with an actual supervisor token
TOKEN = "YOUR_SUPERVISOR_TOKEN_HERE"

def test_create_notification():
    """Test creating a late entry notification"""
    
    print("Testing Late Entry Notification Creation")
    print("=" * 60)
    
    # Test data
    test_data = {
        "site_id": "3ae88295-427b-49f6-8e50-4c02d0250617",  # Replace with actual site ID
        "entry_type": "material",
        "message": "Material entry submitted at 11:59 AM. Should be submitted between 4:00 PM - 7:00 PM IST.",
        "actual_time": datetime.now().isoformat()
    }
    
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {TOKEN}"
    }
    
    try:
        print(f"\n1. Sending POST request to {BASE_URL}/notifications/late-entry/")
        print(f"   Data: {json.dumps(test_data, indent=2)}")
        
        response = requests.post(
            f"{BASE_URL}/notifications/late-entry/",
            headers=headers,
            json=test_data,
            timeout=10
        )
        
        print(f"\n2. Response Status: {response.status_code}")
        print(f"   Response Body: {json.dumps(response.json(), indent=2)}")
        
        if response.status_code in [200, 201]:
            print("\n✅ SUCCESS! Notification created successfully")
            return True
        else:
            print(f"\n❌ FAILED! Status code: {response.status_code}")
            return False
            
    except requests.exceptions.ConnectionError:
        print("\n❌ ERROR: Cannot connect to Django server")
        print("   Make sure Django server is running: python manage.py runserver 0.0.0.0:8000")
        return False
    except Exception as e:
        print(f"\n❌ ERROR: {e}")
        return False

def test_get_notifications():
    """Test getting notifications (admin only)"""
    
    print("\n\nTesting Get Notifications (Admin)")
    print("=" * 60)
    
    # You need an admin token for this
    ADMIN_TOKEN = "YOUR_ADMIN_TOKEN_HERE"
    
    headers = {
        "Authorization": f"Bearer {ADMIN_TOKEN}"
    }
    
    try:
        print(f"\n1. Sending GET request to {BASE_URL}/notifications/")
        
        response = requests.get(
            f"{BASE_URL}/notifications/",
            headers=headers,
            timeout=10
        )
        
        print(f"\n2. Response Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"   Total notifications: {data.get('total_count', 0)}")
            print(f"   Unread count: {data.get('unread_count', 0)}")
            
            if data.get('notifications'):
                print("\n   Recent notifications:")
                for notif in data['notifications'][:3]:
                    print(f"   - {notif['entry_type']}: {notif['message'][:50]}...")
            
            print("\n✅ SUCCESS! Retrieved notifications")
            return True
        else:
            print(f"   Response: {response.json()}")
            print(f"\n❌ FAILED! Status code: {response.status_code}")
            return False
            
    except requests.exceptions.ConnectionError:
        print("\n❌ ERROR: Cannot connect to Django server")
        return False
    except Exception as e:
        print(f"\n❌ ERROR: {e}")
        return False

if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("NOTIFICATION API TEST SCRIPT")
    print("=" * 60)
    print("\nIMPORTANT: Update TOKEN variables in this script first!")
    print("You can get tokens by logging in through the app or API")
    print("\nMake sure Django server is running before testing")
    print("=" * 60)
    
    # Uncomment these when you have valid tokens
    # test_create_notification()
    # test_get_notifications()
    
    print("\n\nTo use this script:")
    print("1. Start Django server: python manage.py runserver 0.0.0.0:8000")
    print("2. Get a valid token by logging in")
    print("3. Update TOKEN variables in this script")
    print("4. Uncomment the test function calls")
    print("5. Run: python test_notification_creation.py")
