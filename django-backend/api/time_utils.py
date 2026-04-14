"""
Time validation utilities for construction entry system
Handles IST timezone and entry time restrictions (8 AM - 1 PM)
"""

from datetime import datetime, time
import pytz

# IST Timezone
IST = pytz.timezone('Asia/Kolkata')

# Allowed entry hours (8 AM to 1 PM IST)
ENTRY_START_HOUR = 8  # 8 AM
ENTRY_END_HOUR = 13    # 1 PM (13:00 in 24-hour format)

def get_ist_now():
    """Get current time in IST timezone - timezone aware"""
    from django.utils import timezone
    # Get current UTC time and convert to IST
    utc_now = timezone.now()
    return utc_now.astimezone(IST)

def get_day_of_week(dt=None):
    """
    Get day of week name from datetime
    Args:
        dt: datetime object (if None, uses current IST time)
    Returns:
        str: Day name (Monday, Tuesday, etc.)
    """
    if dt is None:
        dt = get_ist_now()
    elif dt.tzinfo is None:
        # If naive datetime, assume it's IST
        dt = IST.localize(dt)
    
    day_names = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
    return day_names[dt.weekday()]

def is_within_entry_hours(dt=None):
    """
    Check if given time is within allowed entry hours (8 AM - 1 PM IST)
    Args:
        dt: datetime object (if None, uses current IST time)
    Returns:
        bool: True if within allowed hours, False otherwise
    """
    if dt is None:
        dt = get_ist_now()
    elif dt.tzinfo is None:
        dt = IST.localize(dt)
    
    current_hour = dt.hour
    return ENTRY_START_HOUR <= current_hour < ENTRY_END_HOUR

def get_entry_time_status():
    """
    Get detailed status of entry time validation
    Returns:
        dict: {
            'allowed': bool,
            'current_time_ist': str,
            'current_hour': int,
            'message': str,
            'next_window': str (optional)
        }
    """
    now_ist = get_ist_now()
    current_hour = now_ist.hour
    allowed = is_within_entry_hours(now_ist)
    
    status = {
        'allowed': allowed,
        'current_time_ist': now_ist.strftime('%Y-%m-%d %H:%M:%S %Z'),
        'current_hour': current_hour,
        'day_of_week': get_day_of_week(now_ist),
    }
    
    if allowed:
        # Calculate remaining time
        end_time = now_ist.replace(hour=ENTRY_END_HOUR, minute=0, second=0, microsecond=0)
        remaining = end_time - now_ist
        hours_remaining = remaining.seconds // 3600
        minutes_remaining = (remaining.seconds % 3600) // 60
        
        status['message'] = f'Entry allowed. {hours_remaining}h {minutes_remaining}m remaining until 1:00 PM'
        status['remaining_minutes'] = remaining.seconds // 60
    else:
        if current_hour < ENTRY_START_HOUR:
            # Before 8 AM
            status['message'] = f'Entry not allowed. Window opens at {ENTRY_START_HOUR}:00 AM IST'
            status['next_window'] = 'today at 8:00 AM'
        else:
            # After 1 PM
            status['message'] = f'Entry not allowed. Entries only allowed between {ENTRY_START_HOUR}:00 AM - {ENTRY_END_HOUR}:00 PM IST'
            status['next_window'] = 'tomorrow at 8:00 AM'
    
    return status

def format_ist_time(dt):
    """
    Format datetime in IST timezone
    Args:
        dt: datetime object
    Returns:
        str: Formatted time string
    """
    if dt.tzinfo is None:
        dt = IST.localize(dt)
    return dt.astimezone(IST).strftime('%Y-%m-%d %H:%M:%S %Z')

def get_entry_metadata():
    """
    Get metadata for new entry (day of week, IST time, etc.)
    Returns:
        dict: {
            'day_of_week': str,
            'entry_date': date,
            'entry_time': time,
            'timestamp_ist': datetime
        }
    """
    now_ist = get_ist_now()
    return {
        'day_of_week': get_day_of_week(now_ist),
        'entry_date': now_ist.date(),
        'entry_time': now_ist.time(),
        'timestamp_ist': now_ist
    }
