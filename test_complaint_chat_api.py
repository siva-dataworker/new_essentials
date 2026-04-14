import requests
import json

BASE_URL = "http://127.0.0.1:8000/api"

# Test credentials - use your client credentials
CLIENT_PHONE = "sivu"  # Client username
CLIENT_PASSWORD = "test123"

def test_complaint_chat_system():
    print("=" * 60)
    print("TESTING CLIENT COMPLAINT CHAT SYSTEM")
    print("=" * 60)
    
    # 1. Login as client
    print("\n1️⃣ Logging in as client...")
    login_response = requests.post(f"{BASE_URL}/auth/login/", json={
        "username": CLIENT_PHONE,
        "password": CLIENT_PASSWORD
    })
    
    if login_response.status_code != 200:
        print(f"❌ Login failed: {login_response.text}")
        return
    
    token = login_response.json()['access_token']
    headers = {
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json'
    }
    print(f"✅ Logged in successfully")
    
    # 2. Get client's sites
    print("\n2️⃣ Getting client sites...")
    sites_response = requests.get(f"{BASE_URL}/client/sites/", headers=headers)
    sites = sites_response.json().get('sites', [])
    
    if not sites:
        print("❌ No sites found for client")
        return
    
    site_id = sites[0]['site_id']
    site_name = sites[0]['site_name']
    print(f"✅ Found site: {site_name} ({site_id})")
    
    # 3. Create a test complaint
    print("\n3️⃣ Creating test complaint...")
    complaint_data = {
        "site_id": site_id,
        "title": "Test Issue - Water Leakage",
        "description": "There is water leakage in the bathroom. Please check and fix.",
        "priority": "HIGH"
    }
    
    create_response = requests.post(
        f"{BASE_URL}/client/complaints/create/",
        headers=headers,
        json=complaint_data
    )
    
    if create_response.status_code != 201:
        print(f"❌ Failed to create complaint: {create_response.text}")
        return
    
    complaint = create_response.json()['complaint']
    complaint_id = complaint['id']
    print(f"✅ Complaint created: {complaint['title']}")
    print(f"   ID: {complaint_id}")
    print(f"   Priority: {complaint['priority']}")
    print(f"   Status: {complaint['status']}")
    
    # 4. Get all complaints
    print("\n4️⃣ Fetching all complaints...")
    complaints_response = requests.get(
        f"{BASE_URL}/client/complaints/?site_id={site_id}",
        headers=headers
    )
    
    complaints = complaints_response.json().get('complaints', [])
    print(f"✅ Found {len(complaints)} complaint(s)")
    for c in complaints[:3]:  # Show first 3
        print(f"   - {c['title']} ({c['status']})")
    
    # 5. Send a message to the complaint
    print("\n5️⃣ Sending message to complaint...")
    message_data = {
        "message": "This is urgent. Please send someone to check today."
    }
    
    send_response = requests.post(
        f"{BASE_URL}/client/complaints/{complaint_id}/messages/send/",
        headers=headers,
        json=message_data
    )
    
    if send_response.status_code != 201:
        print(f"❌ Failed to send message: {send_response.text}")
        return
    
    print(f"✅ Message sent successfully")
    
    # 6. Get all messages for the complaint
    print("\n6️⃣ Fetching complaint messages...")
    messages_response = requests.get(
        f"{BASE_URL}/client/complaints/{complaint_id}/messages/",
        headers=headers
    )
    
    if messages_response.status_code != 200:
        print(f"❌ Failed to fetch messages: {messages_response.text}")
        return
    
    messages_data = messages_response.json()
    messages = messages_data.get('messages', [])
    print(f"✅ Found {len(messages)} message(s)")
    
    for msg in messages:
        sender = msg['sender']
        is_own = msg['is_own_message']
        prefix = "You" if is_own else f"{sender['name']} ({sender['role']})"
        print(f"   {prefix}: {msg['message'][:50]}...")
    
    print("\n" + "=" * 60)
    print("✅ ALL TESTS PASSED!")
    print("=" * 60)
    print("\n📱 FLUTTER APP FLOW:")
    print("1. Client opens Issues tab")
    print("2. Taps '+' to create new issue")
    print("3. Fills in title, description, priority")
    print("4. Issue appears in the list")
    print("5. Taps on issue card to open chat")
    print("6. Sees chat interface with messages")
    print("7. Can type and send messages")
    print("8. Builder/Architect responses appear in chat")
    print("=" * 60)

if __name__ == "__main__":
    try:
        test_complaint_chat_system()
    except Exception as e:
        print(f"\n❌ Error: {e}")
        import traceback
        traceback.print_exc()
