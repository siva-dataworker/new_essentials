#!/usr/bin/env python3
"""
Debug the labour submission API
"""
import os
import django
from django.conf import settings

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.views_construction import submit_labour_count
from django.test import RequestFactory
from django.contrib.auth.models import AnonymousUser
import json

def test_labour_api():
    print("🔍 Testing labour submission API...")
    
    # Create a mock request
    factory = RequestFactory()
    
    # Test data
    test_data = {
        'site_id': '168a9ec5-15ce-4b65-af67-7adbedc50dfd',
        'labour_count': 5,
        'labour_type': 'Mason',
        'notes': 'Test entry'
    }
    
    # Create POST request
    request = factory.post(
        '/api/construction/labour/',
        data=json.dumps(test_data),
        content_type='application/json'
    )
    
    # Mock user (this will fail without proper auth, but we can see the error)
    request.user = AnonymousUser()
    
    try:
        response = submit_labour_count(request)
        print(f"Status: {response.status_code}")
        print(f"Response: {response.data}")
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    test_labour_api()
