#!/usr/bin/env python3
"""
Test script to simulate labour submission with current time
"""

import os
import sys
import django
import json
from datetime import datetime
import pytz

# Add the project directory to Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.test import RequestFactory
from api.views_construction import submit_labour_count
from api.authentication import JWTAuthentication

def test_labour_submission():
    print("🧪 TESTING LABOUR SUBMISSION WITH CURRENT TIME")
    print("=" * 50)
    
    # Current IST time (1:48 PM)
    ist_tz = pytz.timezone('Asia/Kolkata')
    current_ist = datetime.now(ist_tz)
    print(f"Current IST time: {current_ist}")
    
    # Format as ISO string (what Flutter would send)
    iso_string = current_ist.isoformat()
    print(f"ISO string: {iso_string}")
    
    # Test data
    test_data = {
        'site_id': 'test-site-123',
        'labour_count': 5,
        'labour_type': 'Mason',
        'notes': 'Test entry',
        'custom_datetime': iso_string,
        'custom_date': current_ist.strftime('%Y-%m-%d'),
        'custom_time': current_ist.strftime('%H:%M:%S'),
    }
    
    print(f"Test data: {json.dumps(test_data, indent=2)}")
    
    # Test parsing
    print(f"\n🔍 TESTING DATETIME PARSING:")
    
    custom_datetime_str = test_data['custom_datetime']
    print(f"Received datetime string: {custom_datetime_str}")
    
    try:
        # Parse the ISO datetime string from client
        custom_dt = datetime.fromisoformat(custom_datetime_str.replace('Z', '+00:00'))
        print(f"Parsed datetime: {custom_dt}")
        print(f"Timezone info: {custom_dt.tzinfo}")
        
        # Convert to IST if it's not already
        if custom_dt.tzinfo is None:
            # Assume it's local time, convert to IST
            custom_dt = ist_tz.localize(custom_dt)
            print(f"Localized to IST: {custom_dt}")
        else:
            custom_dt = custom_dt.astimezone(ist_tz)
            print(f"Converted to IST: {custom_dt}")
        
        entry_date = custom_dt.date()
        entry_time = custom_dt
        
        print(f"Final entry_date: {entry_date}")
        print(f"Final entry_time: {entry_time}")
        print(f"Time component: {entry_time.time()}")
        
    except Exception as e:
        print(f"❌ Error parsing datetime: {e}")

if __name__ == "__main__":
    test_labour_submission()
