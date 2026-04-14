#!/usr/bin/env python3
"""
Test architect complaint upload API
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

def test_complaint_upload():
    """Test complaint upload"""
    print("🧪 Testing Architect Complaint Upload...")
    
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
    
    # Test complaint upload
    print("\n📋 Testing complaint upload...")
    
    complaint_data = {
        'site_id': site_id,
        'title': 'Test Complaint - Poor Construction Quality',
        'description': 'This is a test complaint about construction quality issues. The work does not meet the specified standards and needs immediate attention.',
        'priority': 'HIGH'
    }
    
    response = requests.post(
        f'{BASE_URL}/construction/upload-architect-complaint/',
        headers=headers,
        json=complaint_data
    )
    
    print(f"Status: {response.status_code}")
    print(f"Response: {response.text}")
    
    if response.status_code == 201:
        print("✅ Complaint upload successful!")
        
        # Test getting complaints
        print("\n📋 Testing get complaints...")
        complaints_response = requests.get(f'{BASE_URL}/construction/architect-complaints/', headers=headers)
        if complaints_response.status_code == 200:
            complaints_data = complaints_response.json()
            print(f"Complaints found: {complaints_data['total_complaints']}")
            if complaints_data['complaints']:
                print(f"Latest complaint: {complaints_data['complaints'][0]['title']}")
                print(f"Priority: {complaints_data['complaints'][0]['priority']}")
                print(f"Status: {complaints_data['complaints'][0]['status']}")
            print("✅ Get complaints API working")
        else:
            print(f"❌ Get complaints failed: {complaints_response.text}")
    else:
        print(f"❌ Complaint upload failed: {response.text}")
    
    print("\n🎉 Complaint upload test completed!")

if __name__ == '__main__':
    test_complaint_upload()
