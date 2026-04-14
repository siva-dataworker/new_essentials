#!/usr/bin/env python3
"""
Debug script to understand the time conversion issue
Current time is 1:48 PM but data is stored as 8:17 AM
"""

import os
import sys
import django
from datetime import datetime
import pytz

# Add the project directory to Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.time_utils import get_ist_now, get_day_of_week, get_entry_metadata

def debug_time_conversion():
    print("🔍 DEBUGGING TIME CONVERSION ISSUE")
    print("=" * 50)
    
    # Current time
    now_utc = datetime.utcnow()
    print(f"Current UTC time: {now_utc}")
    
    # IST time
    ist_now = get_ist_now()
    print(f"Current IST time: {ist_now}")
    
    # Test datetime parsing
    test_datetime_str = "2025-01-27T13:48:00"  # 1:48 PM
    print(f"\nTesting datetime string: {test_datetime_str}")
    
    # Parse as if it's local time
    test_dt = datetime.fromisoformat(test_datetime_str)
    print(f"Parsed datetime (naive): {test_dt}")
    
    # Convert to IST
    ist_tz = pytz.timezone('Asia/Kolkata')
    
    # Method 1: Assume it's already IST
    test_dt_ist1 = ist_tz.localize(test_dt)
    print(f"Method 1 (localize as IST): {test_dt_ist1}")
    
    # Method 2: Assume it's UTC and convert
    utc_tz = pytz.timezone('UTC')
    test_dt_utc = utc_tz.localize(test_dt)
    test_dt_ist2 = test_dt_utc.astimezone(ist_tz)
    print(f"Method 2 (UTC to IST): {test_dt_ist2}")
    
    # Check what gets stored
    print(f"\nWhat gets stored:")
    print(f"Date: {test_dt_ist1.date()}")
    print(f"Time: {test_dt_ist1.time()}")
    print(f"Full datetime: {test_dt_ist1}")
    
    # Test entry metadata
    print(f"\nCurrent entry metadata:")
    entry_meta = get_entry_metadata()
    print(f"Entry date: {entry_meta['entry_date']}")
    print(f"Entry time: {entry_meta['entry_time']}")
    print(f"Timestamp IST: {entry_meta['timestamp_ist']}")
    print(f"Day of week: {entry_meta['day_of_week']}")

if __name__ == "__main__":
    debug_time_conversion()
