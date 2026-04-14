#!/usr/bin/env python3
"""
Check recent labour entries to see what time is actually being stored
"""

import os
import sys
import django

# Add the project directory to Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all

def check_recent_entries():
    print("🔍 CHECKING RECENT LABOUR ENTRIES")
    print("=" * 50)
    
    # Get recent labour entries
    entries = fetch_all("""
        SELECT 
            id, 
            labour_type, 
            labour_count, 
            entry_date, 
            entry_time,
            day_of_week
        FROM labour_entries 
        ORDER BY entry_date DESC, entry_time DESC 
        LIMIT 10
    """)
    
    if not entries:
        print("No entries found")
        return
    
    for entry in entries:
        print(f"\nEntry ID: {entry['id']}")
        print(f"Labour Type: {entry['labour_type']}")
        print(f"Count: {entry['labour_count']}")
        print(f"Entry Date: {entry['entry_date']}")
        print(f"Entry Time: {entry['entry_time']}")
        print(f"Day of Week: {entry['day_of_week']}")
        print("-" * 30)

if __name__ == "__main__":
    check_recent_entries()
