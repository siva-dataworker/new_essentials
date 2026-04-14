#!/usr/bin/env python3

import os
import sys
import django
import json

# Add the project directory to Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.test import RequestFactory
from django.contrib.auth.models import AnonymousUser
from api.views_construction import get_supervisor_history
from api.database import fetch_one

print("=== TESTING get_supervisor_history API DIRECTLY ===")

# Get supervisor
supervisor = fetch_one("SELECT id, username FROM users WHERE role_id = 2 LIMIT 1")
if not supervisor:
    print("❌ No supervisor found!")
    exit(1)

print(f"Testing with supervisor: {supervisor['username']} (ID: {supervisor['id']})")

# Create a mock request
factory = RequestFactory()
request = factory.get('/api/construction/supervisor/history/')

# Mock the authenticated user
class MockUser:
    def __init__(self, user_id, username):
        self.user_id = user_id
        self.username = username
    
    def get(self, key, default=None):
        if key == 'user_id':
            return self.user_id
        elif key == 'username':
            return self.username
        return default

request.user = MockUser(str(supervisor['id']), supervisor['username'])

# Call the API function directly
try:
    response = get_supervisor_history(request)
    
    print(f"\n=== API RESPONSE ===")
    print(f"Status Code: {response.status_code}")
    
    if response.status_code == 200:
        data = response.data
        labour_count = len(data.get('labour_entries', []))
        material_count = len(data.get('material_entries', []))
        
        print(f"Labour entries returned: {labour_count}")
        print(f"Material entries returned: {material_count}")
        
        if labour_count > 0:
            print(f"\n=== SAMPLE LABOUR ENTRY ===")
            sample_labour = data['labour_entries'][0]
            print(json.dumps(sample_labour, indent=2, default=str))
        
        if material_count > 0:
            print(f"\n=== SAMPLE MATERIAL ENTRY ===")
            sample_material = data['material_entries'][0]
            print(json.dumps(sample_material, indent=2, default=str))
        
        if labour_count == 0 and material_count == 0:
            print("❌ API returned empty results!")
    else:
        print(f"❌ API Error: {response.data}")
        
except Exception as e:
    print(f"❌ Exception calling API: {e}")
    import traceback
    traceback.print_exc()
