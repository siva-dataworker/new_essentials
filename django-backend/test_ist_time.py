"""
Quick test to check IST time
"""
import os
import sys
import django

# Setup Django
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from datetime import datetime
import pytz
from django.utils import timezone as django_tz

print("="*60)
print("IST TIME TEST")
print("="*60)

# Method 1: Using pytz directly
ist = pytz.timezone('Asia/Kolkata')
now_ist_pytz = datetime.now(ist)
print(f"\n1. Using pytz directly:")
print(f"   Time: {now_ist_pytz.strftime('%Y-%m-%d %H:%M:%S %Z')}")
print(f"   Hour: {now_ist_pytz.hour}")

# Method 2: Using Django timezone
now_django = django_tz.now()
now_django_ist = now_django.astimezone(ist)
print(f"\n2. Using Django timezone:")
print(f"   UTC Time: {now_django.strftime('%Y-%m-%d %H:%M:%S %Z')}")
print(f"   IST Time: {now_django_ist.strftime('%Y-%m-%d %H:%M:%S %Z')}")
print(f"   Hour: {now_django_ist.hour}")

# Method 3: Using our time_utils
from api.time_utils import get_ist_now, get_entry_time_status
now_utils = get_ist_now()
print(f"\n3. Using time_utils:")
print(f"   Time: {now_utils.strftime('%Y-%m-%d %H:%M:%S %Z')}")
print(f"   Hour: {now_utils.hour}")

# Get entry status
status = get_entry_time_status()
print(f"\n4. Entry Time Status:")
print(f"   Allowed: {status['allowed']}")
print(f"   Message: {status['message']}")
print(f"   Current Time: {status['current_time_ist']}")

print("\n" + "="*60)
print("If the time shown above is wrong, your system clock might be incorrect.")
print("="*60)
