#!/usr/bin/env python
"""
Debug script for Compare Screen - Check why no data is showing
"""
import os
import sys
import django
from datetime import datetime, date

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all, fetch_one

def debug_compare_screen():
    """Debug the compare screen data fetching"""
    print("🔍 Debugging Compare Screen Data\n")
    print("=" * 80)
    
    # Check 1: Do we have any labour entries?
    print("\n1️⃣ Checking labour_entries table...")
    total_entries = fetch_one("SELECT COUNT(*) as count FROM labour_entries")
    print(f"   Total labour entries: {total_entries['count']}")
    
    if total_entries['count'] == 0:
        print("   ❌ No labour entries found!")
        print("   💡 Solution: Login as Supervisor and submit labour entries")
        return
    
    # Check 2: Show recent entries
    print("\n2️⃣ Recent labour entries (last 10):")
    recent = fetch_all("""
        SELECT 
            l.id,
            l.entry_date,
            l.entry_time,
            l.labour_type,
            l.labour_count,
            l.submitted_by_role,
            s.customer_name || ' ' || s.site_name as site_name,
            u.full_name as submitted_by
        FROM labour_entries l
        JOIN sites s ON l.site_id = s.id
        JOIN users u ON l.supervisor_id = u.id
        ORDER BY l.entry_time DESC
        LIMIT 10
    """)
    
    for entry in recent:
        role = entry['submitted_by_role'] or 'NULL (defaults to Supervisor)'
        print(f"\n   📝 Entry ID: {entry['id']}")
        print(f"      Site: {entry['site_name']}")
        print(f"      Date: {entry['entry_date']}")
        print(f"      Time: {entry['entry_time']}")
        print(f"      Labour: {entry['labour_type']} × {entry['labour_count']}")
        print(f"      Submitted by: {entry['submitted_by']}")
        print(f"      Role: {role}")
    
    # Check 3: Entries for today
    print(f"\n3️⃣ Entries for today ({date.today()}):")
    today_entries = fetch_all("""
        SELECT 
            l.id,
            l.labour_type,
            l.labour_count,
            l.submitted_by_role,
            s.customer_name || ' ' || s.site_name as site_name
        FROM labour_entries l
        JOIN sites s ON l.site_id = s.id
        WHERE l.entry_date = CURRENT_DATE
    """)
    
    if today_entries:
        print(f"   Found {len(today_entries)} entries for today:")
        for entry in today_entries:
            role = entry['submitted_by_role'] or 'NULL'
            print(f"   - {entry['site_name']}: {entry['labour_type']} × {entry['labour_count']} (Role: {role})")
    else:
        print("   ❌ No entries for today!")
        print("   💡 Solution: Submit entries for today's date")
    
    # Check 4: Check submitted_by_role column
    print("\n4️⃣ Checking submitted_by_role values:")
    role_counts = fetch_all("""
        SELECT 
            COALESCE(submitted_by_role, 'NULL') as role,
            COUNT(*) as count
        FROM labour_entries
        GROUP BY submitted_by_role
        ORDER BY count DESC
    """)
    
    for role in role_counts:
        print(f"   - {role['role']}: {role['count']} entries")
    
    # Check 5: Test the actual query used by compare screen
    print("\n5️⃣ Testing Compare Screen Query (Supervisor entries for today):")
    test_query = """
        SELECT
            l.id,
            l.site_id,
            s.site_name,
            s.customer_name,
            l.supervisor_id,
            u.full_name as submitted_by,
            l.labour_type,
            l.labour_count,
            l.entry_date,
            l.entry_time,
            l.entry_time as submitted_at
        FROM labour_entries l
        JOIN sites s ON l.site_id = s.id
        JOIN users u ON l.supervisor_id = u.id
        WHERE l.entry_date = CURRENT_DATE
          AND (l.submitted_by_role = 'Supervisor' OR l.submitted_by_role IS NULL)
        ORDER BY l.site_id, l.entry_time DESC
    """
    
    test_results = fetch_all(test_query)
    print(f"   Query returned: {len(test_results)} entries")
    
    if test_results:
        print("   ✅ Query works! Entries found:")
        for entry in test_results:
            print(f"   - {entry['customer_name']} {entry['site_name']}: {entry['labour_type']} × {entry['labour_count']}")
    else:
        print("   ❌ Query returned no results")
        print("   💡 Possible reasons:")
        print("      1. No entries for today's date")
        print("      2. All entries have submitted_by_role = 'Site Engineer'")
        print("      3. Date mismatch (check entry_date vs CURRENT_DATE)")
    
    # Check 6: Check for Site Engineer entries
    print("\n6️⃣ Testing Site Engineer entries for today:")
    engineer_query = """
        SELECT COUNT(*) as count
        FROM labour_entries l
        WHERE l.entry_date = CURRENT_DATE
          AND l.submitted_by_role = 'Site Engineer'
    """
    
    engineer_count = fetch_one(engineer_query)
    print(f"   Site Engineer entries today: {engineer_count['count']}")
    
    # Check 7: Date range check
    print("\n7️⃣ Checking date range of entries:")
    date_range = fetch_one("""
        SELECT 
            MIN(entry_date) as earliest,
            MAX(entry_date) as latest,
            COUNT(DISTINCT entry_date) as unique_dates
        FROM labour_entries
    """)
    
    print(f"   Earliest entry: {date_range['earliest']}")
    print(f"   Latest entry: {date_range['latest']}")
    print(f"   Unique dates: {date_range['unique_dates']}")
    print(f"   Today's date: {date.today()}")
    
    # Summary
    print("\n" + "=" * 80)
    print("📊 SUMMARY")
    print("=" * 80)
    
    if total_entries['count'] == 0:
        print("❌ No labour entries in database")
        print("✅ ACTION: Login as Supervisor and submit labour entries")
    elif len(today_entries) == 0:
        print("❌ No entries for today's date")
        print("✅ ACTION: Submit entries for today, or select a different date in Compare screen")
    elif len(test_results) == 0:
        print("❌ No Supervisor entries for today")
        print("✅ ACTION: Check if entries have correct submitted_by_role value")
    else:
        print("✅ Data looks good! Compare screen should work")
        print("💡 If still not showing, check:")
        print("   1. Flutter app is connected to correct backend URL")
        print("   2. Accountant is logged in")
        print("   3. Correct date is selected")
        print("   4. Check Flutter console for API errors")

if __name__ == '__main__':
    debug_compare_screen()
