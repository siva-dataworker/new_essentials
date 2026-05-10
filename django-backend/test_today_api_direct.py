#!/usr/bin/env python3
"""
Test the today entries API directly using Django ORM
"""
import os
import django
import sys
from datetime import date

# Setup Django
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all

def test_today_api():
    print("=" * 60)
    print("TESTING TODAY ENTRIES API (DIRECT)")
    print("=" * 60)
    
    # Get today's date (May 10, 2026 based on your entries)
    today = date(2026, 5, 10)
    
    # Get jack's user_id (username is nsnwjw, full_name is jack)
    jack = fetch_all("SELECT id, full_name, username FROM users WHERE full_name = 'jack'")
    if not jack:
        print("❌ User 'jack' not found")
        return
    jack_id = jack[0]['id']
    print(f"\n👤 Jack's ID: {jack_id} (username: {jack[0]['username']})")
    
    # Get aravind's user_id
    aravind = fetch_all("SELECT id, full_name, username FROM users WHERE username = 'aravind'")
    if not aravind:
        print("❌ User 'aravind' not found")
        return
    aravind_id = aravind[0]['id']
    print(f"👤 Aravind's ID: {aravind_id}")
    
    # Test 1: Get jack's entries (Supervisor)
    print("\n" + "=" * 60)
    print("TEST 1: Jack's Entries (Supervisor)")
    print("=" * 60)
    
    jack_query = """
        SELECT
            l.id,
            l.labour_type,
            l.labour_count,
            l.entry_date,
            l.submitted_by_role,
            u.full_name as supervisor_name
        FROM labour_entries l
        JOIN users u ON l.supervisor_id = u.id
        WHERE l.supervisor_id = %s AND l.entry_date = %s
        ORDER BY l.entry_time ASC
    """
    
    jack_entries = fetch_all(jack_query, (jack_id, today))
    
    print(f"\n📊 Jack's entries count: {len(jack_entries)}")
    if jack_entries:
        print("\nEntries:")
        for entry in jack_entries:
            print(f"  • {entry['labour_type']}: {entry['labour_count']} workers")
            print(f"    Role: {entry['submitted_by_role']}")
            print(f"    By: {entry['supervisor_name']}")
    else:
        print("  No entries found")
    
    # Test 2: Get aravind's entries (Site Engineer)
    print("\n" + "=" * 60)
    print("TEST 2: Aravind's Entries (Site Engineer)")
    print("=" * 60)
    
    aravind_entries = fetch_all(jack_query, (aravind_id, today))
    
    print(f"\n📊 Aravind's entries count: {len(aravind_entries)}")
    if aravind_entries:
        print("\nEntries:")
        for entry in aravind_entries:
            print(f"  • {entry['labour_type']}: {entry['labour_count']} workers")
            print(f"    Role: {entry['submitted_by_role']}")
            print(f"    By: {entry['supervisor_name']}")
    else:
        print("  No entries found")
    
    # Test 3: Get ALL entries (what Accountant would see)
    print("\n" + "=" * 60)
    print("TEST 3: All Entries (Accountant View)")
    print("=" * 60)
    
    all_query = """
        SELECT
            l.id,
            l.labour_type,
            l.labour_count,
            l.entry_date,
            l.submitted_by_role,
            u.full_name as supervisor_name
        FROM labour_entries l
        JOIN users u ON l.supervisor_id = u.id
        WHERE l.entry_date = %s
        ORDER BY l.submitted_by_role, l.entry_time ASC
    """
    
    all_entries = fetch_all(all_query, (today,))
    
    print(f"\n📊 Total entries count: {len(all_entries)}")
    if all_entries:
        print("\nEntries:")
        for entry in all_entries:
            print(f"  • {entry['labour_type']}: {entry['labour_count']} workers")
            print(f"    Role: {entry['submitted_by_role']}")
            print(f"    By: {entry['supervisor_name']}")
    else:
        print("  No entries found")
    
    # Summary
    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print(f"\n✅ Jack (Supervisor) entries: {len(jack_entries)}")
    print(f"✅ Aravind (Site Engineer) entries: {len(aravind_entries)}")
    print(f"✅ Total entries: {len(all_entries)}")
    
    print("\n📋 Expected Results:")
    print("  - Jack should see 3 entries (Carpenter, Mason, General)")
    print("  - Aravind should see 3 entries (General, Mason, Helper)")
    print("  - Total should be 6 entries")
    
    print("\n🔍 API Filtering:")
    if len(jack_entries) == 3:
        print("  ✅ Jack's API filter working correctly")
    else:
        print(f"  ❌ Jack's API filter WRONG (expected 3, got {len(jack_entries)})")
    
    if len(aravind_entries) == 3:
        print("  ✅ Aravind's API filter working correctly")
    else:
        print(f"  ❌ Aravind's API filter WRONG (expected 3, got {len(aravind_entries)})")
    
    if len(all_entries) == 6:
        print("  ✅ Total count correct")
    else:
        print(f"  ❌ Total count WRONG (expected 6, got {len(all_entries)})")
    
    print("\n" + "=" * 60)

if __name__ == '__main__':
    test_today_api()
