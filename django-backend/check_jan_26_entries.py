#!/usr/bin/env python3
"""
Check entries for January 26, 2026 to see if time picker worked
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

def check_jan_26_entries():
    print("🔍 CHECKING ENTRIES FOR JANUARY 26, 2026")
    print("=" * 50)
    
    # Get entries for Jan 26, 2026
    labour_entries = fetch_all("""
        SELECT 
            id, 
            labour_type, 
            labour_count, 
            entry_date, 
            entry_time,
            day_of_week
        FROM labour_entries 
        WHERE entry_date = '2026-01-26'
        ORDER BY entry_time DESC
    """)
    
    material_entries = fetch_all("""
        SELECT 
            id, 
            material_type, 
            quantity,
            unit,
            entry_date, 
            updated_at,
            day_of_week
        FROM material_balances 
        WHERE entry_date = '2026-01-26'
        ORDER BY updated_at DESC
    """)
    
    print(f"📊 LABOUR ENTRIES FOR JAN 26, 2026: {len(labour_entries)}")
    for entry in labour_entries:
        print(f"  - {entry['labour_type']}: {entry['labour_count']} workers")
        print(f"    Date: {entry['entry_date']}, Time: {entry['entry_time']}")
        print(f"    Day: {entry['day_of_week']}")
        print()
    
    print(f"📦 MATERIAL ENTRIES FOR JAN 26, 2026: {len(material_entries)}")
    for entry in material_entries:
        print(f"  - {entry['material_type']}: {entry['quantity']} {entry['unit']}")
        print(f"    Date: {entry['entry_date']}, Time: {entry['updated_at']}")
        print(f"    Day: {entry['day_of_week']}")
        print()
    
    # Check what day Jan 26, 2026 should be
    from datetime import datetime
    jan_26 = datetime(2026, 1, 26)
    expected_day = jan_26.strftime('%A')
    print(f"📅 January 26, 2026 should be: {expected_day}")

if __name__ == "__main__":
    check_jan_26_entries()
