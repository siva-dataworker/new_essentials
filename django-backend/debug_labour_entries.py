#!/usr/bin/env python3
"""
Debug labour entries to see what's actually in the database
"""
import os
import django
from django.conf import settings

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all

def debug_labour_entries():
    print("🔍 DEBUGGING LABOUR ENTRIES...")
    
    try:
        # Get all labour entries
        entries = fetch_all("""
            SELECT 
                l.id,
                l.labour_type,
                l.labour_count,
                l.entry_date,
                l.entry_time,
                l.site_id,
                s.site_name,
                u.full_name as supervisor_name
            FROM labour_entries l
            JOIN sites s ON l.site_id = s.id
            JOIN users u ON l.supervisor_id = u.id
            ORDER BY l.entry_time DESC
        """)
        
        print(f"📊 Total labour entries in database: {len(entries)}")
        
        if entries:
            print("\n📝 All labour entries:")
            for i, entry in enumerate(entries, 1):
                print(f"   {i}. {entry['labour_type']} - {entry['labour_count']} workers")
                print(f"      Site: {entry['site_name']}")
                print(f"      Date: {entry['entry_date']}")
                print(f"      Time: {entry['entry_time']}")
                print(f"      Supervisor: {entry['supervisor_name']}")
                print(f"      ID: {entry['id']}")
                print()
        else:
            print("❌ No labour entries found in database")
            
        # Check for today's entries specifically
        from datetime import date
        today = date.today()
        
        today_entries = fetch_all("""
            SELECT 
                l.labour_type,
                l.labour_count,
                l.entry_time,
                s.site_name
            FROM labour_entries l
            JOIN sites s ON l.site_id = s.id
            WHERE l.entry_date = %s
            ORDER BY l.entry_time DESC
        """, (today,))
        
        print(f"📅 Today's entries ({today}): {len(today_entries)}")
        for entry in today_entries:
            print(f"   - {entry['labour_type']}: {entry['labour_count']} workers at {entry['site_name']}")
            
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    debug_labour_entries()
