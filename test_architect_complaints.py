import requests
import json

BASE_URL = "http://127.0.0.1:8000/api"

# Test with architect credentials
ARCHITECT_USERNAME = "architect"  # Update with actual architect username
ARCHITECT_PASSWORD = "test123"

def test_architect_complaints():
    print("=" * 60)
    print("TESTING ARCHITECT CLIENT COMPLAINTS VIEW")
    print("=" * 60)
    
    # 1. Login as architect
    print("\n1️⃣ Logging in as architect...")
    login_response = requests.post(f"{BASE_URL}/auth/login/", json={
        "username": ARCHITECT_USERNAME,
        "password": ARCHITECT_PASSWORD
    })
    
    if login_response.status_code != 200:
        print(f"❌ Login failed: {login_response.text}")
        return
    
    token = login_response.json()['access_token']
    headers = {
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json'
    }
    print(f"✅ Logged in successfully as architect")
    
    # 2. Get client complaints
    print("\n2️⃣ Fetching client complaints...")
    complaints_response = requests.get(
        f"{BASE_URL}/construction/client-complaints/",
        headers=headers
    )
    
    if complaints_response.status_code != 200:
        print(f"❌ Failed to fetch complaints: {complaints_response.text}")
        return
    
    complaints_data = complaints_response.json()
    complaints = complaints_data.get('complaints', [])
    print(f"✅ Found {len(complaints)} client complaint(s)")
    
    if not complaints:
        print("\n⚠️  No complaints found. Make sure:")
        print("   1. A client has created a complaint")
        print("   2. The complaint is assigned to this architect")
        return
    
    # Show complaints
    for comp in complaints:
        print(f"\n📋 Complaint: {comp['title']}")
        print(f"   Client: {comp['client']['name']}")
        print(f"   Site: {comp['site_name']}")
        print(f"   Priority: {comp['priority']}")
        print(f"   Status: {comp['status']}")
        print(f"   Messages: {comp['message_count']}")
    
    # 3. Get messages for first complaint
    if complaints:
        complaint_id = complaints[0]['id']
        print(f"\n3️⃣ Fetching messages for complaint: {complaints[0]['title']}")
        
        messages_response = requests.get(
            f"{BASE_URL}/construction/complaints/{complaint_id}/messages/",
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
            print(f"   {prefix}: {msg['message'][:60]}...")
        
        # 4. Send a response
        print(f"\n4️⃣ Sending response to complaint...")
        response_message = "Thank you for reporting this issue. Our team will inspect the site tomorrow and provide an update."
        
        send_response = requests.post(
            f"{BASE_URL}/construction/complaints/{complaint_id}/messages/send/",
            headers=headers,
            json={"message": response_message}
        )
        
        if send_response.status_code != 201:
            print(f"❌ Failed to send message: {send_response.text}")
            return
        
        print(f"✅ Response sent successfully")
    
    print("\n" + "=" * 60)
    print("✅ ALL TESTS PASSED!")
    print("=" * 60)
    print("\n📱 ARCHITECT APP FLOW:")
    print("1. Architect opens their dashboard")
    print("2. Clicks 'Raise Complaint' or 'View History'")
    print("3. Sees list of client complaints for their sites")
    print("4. Taps on a complaint to view details")
    print("5. Opens chat interface")
    print("6. Can read client's issue and send responses")
    print("=" * 60)

if __name__ == "__main__":
    try:
        test_architect_complaints()
    except Exception as e:
        print(f"\n❌ Error: {e}")
        import traceback
        traceback.print_exc()
