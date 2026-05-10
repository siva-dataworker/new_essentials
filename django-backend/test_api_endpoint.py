#!/usr/bin/env python
"""Test the actual API endpoint"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.views_budget_management import get_labour_rates, CANONICAL_DEFAULT_RATES
from api.database import fetch_all
from rest_framework.test import APIRequestFactory
from unittest.mock import Mock

print("\n🧪 Testing get_labour_rates API Endpoint")
print("=" * 60)

# Create a mock request
factory = APIRequestFactory()
request = factory.get('/api/budget/labour-rates/global/')

# Mock the user authentication
request.user = {'user_id': 'test-user', 'role': 'Admin'}

# Call the actual endpoint
response = get_labour_rates(request, 'global')

print(f"\n1️⃣ API Response Status: {response.status_code}")
print(f"   Expected: 200")

if response.status_code == 200:
    data = response.data
    rates = data.get('rates', [])
    
    print(f"\n2️⃣ Total Labour Types Returned: {len(rates)}")
    print(f"   Expected: {len(CANONICAL_DEFAULT_RATES)} canonical + custom types")
    
    print("\n3️⃣ Labour Types in Response:")
    canonical_count = 0
    custom_count = 0
    
    for rate in rates:
        labour_type = rate['labour_type']
        daily_rate = rate['daily_rate']
        is_admin_set = rate['is_admin_set']
        
        if labour_type in CANONICAL_DEFAULT_RATES:
            marker = "📋"
            canonical_count += 1
        else:
            marker = "🆕"
            custom_count += 1
        
        status = "Admin set" if is_admin_set else "Default"
        print(f"   {marker} {labour_type:20} | ₹{daily_rate:,.0f}/day | {status}")
    
    print(f"\n4️⃣ Summary:")
    print(f"   Canonical types: {canonical_count}")
    print(f"   Custom types: {custom_count}")
    print(f"   Total: {len(rates)}")
    
    # Check for specific custom types
    print(f"\n5️⃣ Checking for Custom Types:")
    custom_types = ['load mam', 'loadman', 'Welder']
    for custom_type in custom_types:
        found = any(r['labour_type'] == custom_type for r in rates)
        status = "✅ Found" if found else "❌ Missing"
        print(f"   {status}: {custom_type}")
    
    print("\n" + "=" * 60)
    if custom_count > 0:
        print("✅ SUCCESS! Custom labour types are included in API response")
    else:
        print("❌ FAILED! Custom labour types are NOT included")
else:
    print(f"\n❌ API call failed with status {response.status_code}")
    print(f"   Response: {response.data}")
