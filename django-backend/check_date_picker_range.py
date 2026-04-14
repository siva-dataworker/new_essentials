#!/usr/bin/env python3
"""
Check if January 26, 2026 is within the date picker range
"""

from datetime import datetime, timedelta

def check_date_picker_range():
    print("📅 DATE PICKER RANGE ANALYSIS")
    print("=" * 40)
    
    # Current date (today)
    today = datetime.now()
    print(f"Today: {today.strftime('%A, %B %d, %Y')}")
    
    # Date picker range (from Flutter code)
    first_date = today - timedelta(days=30)  # 30 days back
    last_date = today + timedelta(days=1)    # 1 day forward
    
    print(f"Date picker allows: {first_date.strftime('%B %d, %Y')} to {last_date.strftime('%B %d, %Y')}")
    
    # Target date
    target_date = datetime(2026, 1, 26)
    print(f"Target date: {target_date.strftime('%A, %B %d, %Y')}")
    
    # Check if target is in range
    if first_date.date() <= target_date.date() <= last_date.date():
        print("✅ January 26, 2026 is WITHIN the date picker range")
    else:
        print("❌ January 26, 2026 is OUTSIDE the date picker range")
        print(f"   Target: {target_date.date()}")
        print(f"   Range: {first_date.date()} to {last_date.date()}")
    
    # Calculate days difference
    days_diff = (target_date.date() - today.date()).days
    print(f"Days difference: {days_diff} ({'future' if days_diff > 0 else 'past' if days_diff < 0 else 'today'})")
    
    if days_diff == -1:
        print("✅ January 26, 2026 is YESTERDAY - should be selectable")
    elif days_diff == 0:
        print("✅ January 26, 2026 is TODAY - should be selectable")
    elif days_diff == 1:
        print("✅ January 26, 2026 is TOMORROW - should be selectable")
    else:
        print(f"⚠️  January 26, 2026 is {abs(days_diff)} days {'in the future' if days_diff > 0 else 'in the past'}")

if __name__ == "__main__":
    check_date_picker_range()
