#!/usr/bin/env python3
"""
Test architect document upload API
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

def create_test_file():
    """Create a test file for upload"""
    test_file_path = project_dir / 'test_document.txt'
    with open(test_file_path, 'w') as f:
        f.write("This is a test document for architect upload.\nCreated for testing purposes.")
    return test_file_path

def test_document_upload():
    """Test document upload"""
    print("🧪 Testing Architect Document Upload...")
    
    # Get auth token
    token = get_auth_token()
    if not token:
        print("❌ Failed to get auth token")
        return
    
    headers = {
        'Authorization': f'Bearer {token}',
    }
    
    print(f"✅ Got auth token: {token[:20]}...")
    
    # Create test file
    test_file = create_test_file()
    print(f"📄 Created test file: {test_file}")
    
    # Get a site ID (use first available site)
    sites_response = requests.get(f'{BASE_URL}/construction/sites/', headers=headers)
    if sites_response.status_code != 200:
        print("❌ Failed to get sites")
        return
    
    sites_data = sites_response.json()
    if not sites_data['sites']:
        print("❌ No sites available")
        return
    
    site_id = sites_data['sites'][0]['id']
    print(f"🏗️ Using site ID: {site_id}")
    
    # Test document upload
    print("\n📋 Testing document upload...")
    
    files = {
        'file': ('test_document.txt', open(test_file, 'rb'), 'text/plain')
    }
    
    data = {
        'site_id': site_id,
        'document_type': 'Design',
        'title': 'Test Document Upload',
        'description': 'This is a test document uploaded via API'
    }
    
    response = requests.post(
        f'{BASE_URL}/construction/upload-architect-document/',
        headers={'Authorization': f'Bearer {token}'},
        files=files,
        data=data
    )
    
    print(f"Status: {response.status_code}")
    print(f"Response: {response.text}")
    
    if response.status_code == 201:
        print("✅ Document upload successful!")
        
        # Test getting documents
        print("\n📋 Testing get documents...")
        docs_response = requests.get(f'{BASE_URL}/construction/architect-documents/', headers=headers)
        if docs_response.status_code == 200:
            docs_data = docs_response.json()
            print(f"Documents found: {docs_data['total_documents']}")
            if docs_data['documents']:
                print(f"Latest document: {docs_data['documents'][0]['title']}")
            print("✅ Get documents API working")
        else:
            print(f"❌ Get documents failed: {docs_response.text}")
    else:
        print(f"❌ Document upload failed: {response.text}")
    
    # Clean up
    if test_file.exists():
        test_file.unlink()
        print(f"🗑️ Cleaned up test file")
    
    print("\n🎉 Document upload test completed!")

if __name__ == '__main__':
    test_document_upload()
