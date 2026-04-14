#!/usr/bin/env python
"""
Check working sites data
"""

import os
import sys
import django

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.db import connection

def check_working_sites():
    """Check working sites data"""
    
    print("=" * 60)
    print("CHECKING WORKING SITES DATA")
    print("=" * 60)
    print()
    
    with connection.cursor() as cursor:
        # Get all working sites
        cursor.execute("SELECT * FROM working_sites")
        rows = cursor.fetchall()
        
        print(f"Total working sites: {len(rows)}")
        print()
        
        if rows:
            print("Working sites data:")
            print("-" * 60)
            cursor.execute("SELECT column_name FROM information_schema.columns WHERE table_name = 'working_sites' ORDER BY ordinal_position")
            columns = [row[0] for row in cursor.fetchall()]
            print(f"Columns: {', '.join(columns)}")
            print("-" * 60)
            
            for row in rows:
                print(row)
            print("-" * 60)
        else:
            print("✅ No working sites data found")
        
        # Check if there are active working sites
        cursor.execute("SELECT COUNT(*) FROM working_sites WHERE is_active = TRUE")
        active_count = cursor.fetchone()[0]
        print(f"\nActive working sites: {active_count}")
        
        # Check last reset date
        cursor.execute("SELECT DISTINCT last_reset_date FROM working_sites")
        reset_dates = cursor.fetchall()
        if reset_dates:
            print(f"Last reset dates: {reset_dates}")
    
    print("=" * 60)

if __name__ == '__main__':
    check_working_sites()
