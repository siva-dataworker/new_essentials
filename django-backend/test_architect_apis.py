#!/usr/bin/env python3
"""
Test architect APIs
"""

import os
import sys
import django
import requests
import json
from pathlib import Path

# Add the project directory to Python path
project_dir = Path(__file__).resolve().parent
sys.path.append(str(project_dir))

# Set up Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

BASE_URL = 'http://192.168.1.7:8000/api'

def get_auth_token():
    """Get authentication token for testing"""
    # Use Siva (Accountant) credentials for testing
    login_data = {
        'username': 'Siva',
        'password': 'Test123'
    }
    
    response = requests.post(f'{BASE_URL}/auth/login/', json=login_data)
    if response.status_code == 200:
        data = response.json()
        return data.get('access_token')
    else:
        print(f"❌ Login failed: {response.text}")
        return None

def test_architect_apis():
    """Test architect APIs"""
    print("🧪 Testing Architect APIs...")
    
    # Get auth token
    token = get_auth_token()
    if not token:
        print("❌ Failed to get auth token")
        return
    
    headers = {
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json'
    }
    
    print(f"✅ Got auth token: {token[:20]}...")
    
    # Test 1: Get architect documents (should be empty initially)
    print("\n📋 Test 1: Get architect documents")
    response = requests.get(f'{BASE_URL}/construction/architect-documents/', headers=headers)
    print(f"Status: {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        print(f"Documents found: {data['total_documents']}")
        print("✅ Get documents API working")
    else:
        print(f"❌ Get documents failed: {response.text}")
    
    # Test 2: Get architect complaints (should be empty initially)
    print("\n📋 Test 2: Get architect complaints")
    response = requests.get(f'{BASE_URL}/construction/architect-complaints/', headers=headers)
    print(f"Status: {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        print(f"Complaints found: {data['total_complaints']}")
        print("✅ Get complaints API working")
    else:
        print(f"❌ Get complaints failed: {response.text}")
    
    # Test 3: Get architect history
    print("\n📋 Test 3: Get architect history")
    response = requests.get(f'{BASE_URL}/construction/architect-history/', headers=headers)
    print(f"Status: {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        print(f"Documents: {data['total_documents']}, Complaints: {data['total_complaints']}")
        print("✅ Get history API working")
    else:
        print(f"❌ Get history failed: {response.text}")
    
    print("\n🎉 Architect APIs test completed!")

if __name__ == '__main__':
    test_architect_apis()
