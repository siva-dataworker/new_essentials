"""
Test script for architect documents and complaints endpoints
"""
import requests
import json

BASE_URL = "http://192.168.1.11:8000/api"

# You'll need to replace this with a valid JWT token from a supervisor login
TOKEN = "your_jwt_token_here"

headers = {
    "Authorization": f"Bearer {TOKEN}",
    "Content-Type": "application/json"
}

def test_get_architect_documents(site_id=None):
    """Test getting architect documents"""
    url = f"{BASE_URL}/construction/architect-documents/"
    if site_id:
        url += f"?site_id={site_id}"
    
    print(f"\n📄 Testing GET {url}")
    response = requests.get(url, headers=headers)
    print(f"Status: {response.status_code}")
    
    if response.status_code == 200:
        data = response.json()
        print(f"✅ Found {len(data.get('documents', []))} documents")
        if data.get('documents'):
            print(f"First document: {data['documents'][0]}")
    else:
        print(f"❌ Error: {response.text}")

def test_get_architect_complaints(site_id=None):
    """Test getting architect complaints"""
    url = f"{BASE_URL}/construction/architect-complaints/"
    if site_id:
        url += f"?site_id={site_id}"
    
    print(f"\n⚠️ Testing GET {url}")
    response = requests.get(url, headers=headers)
    print(f"Status: {response.status_code}")
    
    if response.status_code == 200:
        data = response.json()
        print(f"✅ Found {len(data.get('complaints', []))} complaints")
        if data.get('complaints'):
            print(f"First complaint: {data['complaints'][0]}")
    else:
        print(f"❌ Error: {response.text}")

if __name__ == "__main__":
    print("=" * 60)
    print("TESTING ARCHITECT ENDPOINTS FOR SUPERVISOR")
    print("=" * 60)
    
    # Test without site filter
    test_get_architect_documents()
    test_get_architect_complaints()
    
    # Test with site filter (replace with actual site ID)
    # test_get_architect_documents(site_id="your-site-id")
    # test_get_architect_complaints(site_id="your-site-id")
    
    print("\n" + "=" * 60)
    print("TESTS COMPLETE")
    print("=" * 60)
