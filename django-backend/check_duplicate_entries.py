#!/usr/bin/env python3
"""
Check for duplicate labour entries in the database
"""
import os
import django
import sys

# Setup Django
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all

def check_duplicates():
    """Check for duplicate labour entries"""
    
    print("=" * 60)
    print("CHECKING LABOUR ENTRIES FOR DUPLICATES")
    print("=" * 60)
    
    # Get all labour entries
    entries = fetch_all("""
        SELECT 
            l.id,
            l.site_id,
            s.site_name,
            l.supervisor_id,
            u.full_name as supervisor_name,
            l.entry_date,
            l.labour_type,
            l.labour_count,
            l.submitted_by_role,
            l.entry_time
        FROM labour_entries l
        JOIN sites s ON l.site_id = s.id
        JOIN users u ON l.supervisor_id = u.id
        ORDER BY l.entry_date DESC, l.entry_time ASC
    """)
    
    if not entries:
        print("\n✅ No labour entries found in database")
        return
    
    print(f"\n📊 Found {len(entries)} labour entries:")
    print("\n" + "=" * 60)
    
    # Group by date and role
    by_date_role = {}
    for entry in entries:
        date = str(entry['entry_date'])
        role = entry['submitted_by_role']
        key = f"{date}_{role}"
        
        if key not in by_date_role:
            by_date_role[key] = []
        by_date_role[key].append(entry)
    
    # Display grouped entries
    for key, group in by_date_role.items():
        date, role = key.split('_')
        print(f"\n📅 Date: {date} | Role: {role}")
        print(f"   Total entries: {len(group)}")
        print("   " + "-" * 56)
        
        # Check for duplicates by labour_type
        labour_types = {}
        for entry in group:
            labour_type = entry['labour_type']
            if labour_type not in labour_types:
                labour_types[labour_type] = []
            labour_types[labour_type].append(entry)
        
        # Display each labour type
        for labour_type, type_entries in labour_types.items():
            if len(type_entries) > 1:
                print(f"\n   ⚠️  DUPLICATE: {labour_type} ({len(type_entries)} entries)")
            else:
                print(f"\n   ✅ {labour_type} (1 entry)")
            
            for i, entry in enumerate(type_entries, 1):
                print(f"      Entry {i}:")
                print(f"      - ID: {entry['id']}")
                print(f"      - Supervisor: {entry['supervisor_name']}")
                print(f"      - Workers: {entry['labour_count']}")
                print(f"      - Time: {entry['entry_time']}")
    
    # Check for exact duplicates (same labour_type, same date, same role)
    print("\n" + "=" * 60)
    print("DUPLICATE ANALYSIS")
    print("=" * 60)
    
    duplicates_found = False
    for key, group in by_date_role.items():
        labour_types = {}
        for entry in group:
            labour_type = entry['labour_type']
            if labour_type not in labour_types:
                labour_types[labour_type] = []
            labour_types[labour_type].append(entry)
        
        for labour_type, type_entries in labour_types.items():
            if len(type_entries) > 1:
                duplicates_found = True
                date, role = key.split('_')
                print(f"\n⚠️  DUPLICATE FOUND:")
                print(f"   Date: {date}")
                print(f"   Role: {role}")
                print(f"   Labour Type: {labour_type}")
                print(f"   Count: {len(type_entries)} entries")
                print(f"\n   Entry IDs:")
                for entry in type_entries:
                    print(f"   - {entry['id']} (Time: {entry['entry_time']})")
    
    if not duplicates_found:
        print("\n✅ No duplicates found - all entries are unique")
    else:
        print("\n⚠️  Duplicates detected - see details above")
    
    print("\n" + "=" * 60)

if __name__ == '__main__':
    check_duplicates()
