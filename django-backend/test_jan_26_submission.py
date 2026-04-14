#!/usr/bin/env python3
"""
Test script to simulate a January 26, 2026 entry submission
This will help verify if the backend correctly processes custom datetime
"""

import os
import sys
import django
import requests
import json
from datetime import datetime

# Add the project directory to Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all, execute_query

def test_jan_26_submission():
    print("🧪 TESTING JANUARY 26, 2026 SUBMISSION")
    print("=" * 50)
    
    # Test data for Jan 26, 2026 at 2:00 PM
    test_datetime = "2026-01-26T14:00:00"
    
    print(f"📅 Testing with datetime: {test_datetime}")
    print(f"📅 This should be: Monday, Jan 26, 2026 at 2:00 PM")
    
    # Simulate the API call data
    test_data = {
        'site_id': 'test-site-id',
        'labour_count': 3,
        'labour_type': 'Mason',
        'custom_datetime': test_datetime,
        'notes': 'Test entry for Jan 26'
    }
    
    print("\n🔍 Test data:")
    for key, value in test_data.items():
        print(f"  {key}: {value}")
    
    # Test the datetime parsing logic from views_construction.py
    try:
        from datetime import datetime
        import pytz
        
        custom_dt = datetime.fromisoformat(test_datetime)
        ist_tz = pytz.timezone('Asia/Kolkata')
        
        if custom_dt.tzinfo is None:
            custom_dt = ist_tz.localize(custom_dt)
        else:
            custom_dt = custom_dt.astimezone(ist_tz)
        
        entry_date = custom_dt.date()
        entry_time = custom_dt
        
        # Calculate day of week
        day_of_week = custom_dt.strftime('%A')
        
        print(f"\n✅ PARSING SUCCESSFUL:")
        print(f"  Parsed datetime: {custom_dt}")
        print(f"  Entry date: {entry_date}")
        print(f"  Entry time: {entry_time}")
        print(f"  Day of week: {day_of_week}")
        
        # Verify it's Monday
        if day_of_week == 'Monday':
            print("✅ Correctly identified as Monday")
        else:
            print(f"❌ Expected Monday, got {day_of_week}")
            
    except Exception as e:
        print(f"❌ PARSING FAILED: {e}")
        return
    
    print(f"\n🔍 CHECKING IF ENTRIES ALREADY EXIST FOR JAN 26...")
    
    # Check existing entries
    labour_entries = fetch_all("""
        SELECT id, labour_type, labour_count, entry_date, entry_time, day_of_week
        FROM labour_entries 
        WHERE entry_date = '2026-01-26'
        ORDER BY entry_time DESC
    """)
    
    print(f"📊 Found {len(labour_entries)} existing labour entries for Jan 26, 2026")
    for entry in labour_entries:
        print(f"  - {entry['labour_type']}: {entry['labour_count']} workers at {entry['entry_time']}")
    
    print(f"\n💡 RECOMMENDATIONS:")
    print(f"1. User should select January 26, 2026 in the date picker")
    print(f"2. User should select 2:00 PM (or any time) in the time picker")
    print(f"3. User should see 'Selected: Jan 26, 2026 at 2:00 PM • Tap to change'")
    print(f"4. After submission, entry should appear in history under 'Monday, Jan 26, 2026'")
    
    print(f"\n🔧 TROUBLESHOOTING STEPS:")
    print(f"1. Check Flutter console logs for time picker debug messages")
    print(f"2. Verify _selectedDateTime variable is being updated")
    print(f"3. Confirm customDateTime is being passed to API")
    print(f"4. Check backend logs for custom datetime processing")

if __name__ == "__main__":
    test_jan_26_submission()
