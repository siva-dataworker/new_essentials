#!/usr/bin/env python3
"""
Verify User Filtering - Check if backend APIs correctly filter by user_id

This script tests the backend APIs to ensure they return only the logged-in user's entries.
"""

import os
import sys
import django
import json
from datetime import date

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.contrib.auth import get_user_model
from django.db import connection

User = get_user_model()

def print_section(title):
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}\n")

def main():
    print_section("USER FILTERING VERIFICATION")
    
    # Get today's date
    today = date.today()
    print(f"📅 Checking entries for date: {today}\n")
    
    # Get all users
    users = User.objects.all()
    print(f"👥 Total users in database: {users.count()}\n")
    
    # Check labour entries for each user
    print_section("LABOUR ENTRIES BY USER")
    
    for user in users:
        query = """
            SELECT id, labour_type, labour_count, submitted_by_role, site_id
            FROM labour_entries
            WHERE supervisor_id = %s
            AND entry_date = %s
            AND (is_modified = FALSE OR is_modified IS NULL)
        """
        
        with connection.cursor() as cursor:
            cursor.execute(query, [user.id, today])
            columns = [col[0] for col in cursor.description]
            entry_list = [dict(zip(columns, row)) for row in cursor.fetchall()]
        
        print(f"👤 User: {user.username} ({user.full_name}) - Role: {user.role}")
        print(f"   User ID: {user.id}")
        print(f"   📊 Total entries: {len(entry_list)}")
        
        if entry_list:
            print(f"   Entries:")
            for entry in entry_list:
                print(f"      • {entry['labour_type']}: {entry['labour_count']} workers")
                print(f"        ID: {entry['id']}, Role: {entry['submitted_by_role']}, Site: {entry['site_id']}")
        else:
            print(f"   ❌ No entries found")
        print()
    
    # Check material entries for each user
    print_section("MATERIAL ENTRIES BY USER")
    
    for user in users:
        query = """
            SELECT id, material_type, quantity, submitted_by_role, site_id
            FROM material_entries
            WHERE supervisor_id = %s
            AND entry_date = %s
            AND (is_modified = FALSE OR is_modified IS NULL)
        """
        
        with connection.cursor() as cursor:
            cursor.execute(query, [user.id, today])
            columns = [col[0] for col in cursor.description]
            entry_list = [dict(zip(columns, row)) for row in cursor.fetchall()]
        
        print(f"👤 User: {user.username} ({user.full_name}) - Role: {user.role}")
        print(f"   User ID: {user.id}")
        print(f"   📊 Total entries: {len(entry_list)}")
        
        if entry_list:
            print(f"   Entries:")
            for entry in entry_list:
                print(f"      • {entry['material_type']}: {entry['quantity']}")
                print(f"        ID: {entry['id']}, Role: {entry['submitted_by_role']}, Site: {entry['site_id']}")
        else:
            print(f"   ❌ No entries found")
        print()
    
    # Test the actual SQL query used by the API
    print_section("TESTING API SQL QUERY")
    
    for user in users:
        if user.role in ['Supervisor', 'Site Engineer']:
            print(f"👤 Testing for: {user.username} ({user.role})")
            print(f"   User ID: {user.id}\n")
            
            # This is the exact query from the API
            query = """
                SELECT
                    l.id,
                    l.labour_type,
                    l.labour_count,
                    l.submitted_by_role,
                    l.site_id,
                    s.site_name,
                    s.customer_name
                FROM labour_entries l
                JOIN sites s ON l.site_id = s.id
                WHERE (l.is_modified = FALSE OR l.is_modified IS NULL)
                AND l.supervisor_id = %s
                AND l.entry_date = %s
                ORDER BY l.created_at DESC
            """
            
            with connection.cursor() as cursor:
                cursor.execute(query, [user.id, today])
                columns = [col[0] for col in cursor.description]
                results = [dict(zip(columns, row)) for row in cursor.fetchall()]
            
            print(f"   📊 Query returned: {len(results)} entries")
            
            if results:
                print(f"   Entries:")
                for entry in results:
                    print(f"      • {entry['labour_type']}: {entry['labour_count']} workers")
                    print(f"        Site: {entry['customer_name']} - {entry['site_name']}")
                    print(f"        Role: {entry['submitted_by_role']}")
            else:
                print(f"   ❌ No entries found")
            print()
    
    # Summary
    print_section("SUMMARY")
    
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT COUNT(*) FROM labour_entries
            WHERE entry_date = %s
            AND (is_modified = FALSE OR is_modified IS NULL)
        """, [today])
        total_labour = cursor.fetchone()[0]
        
        cursor.execute("""
            SELECT COUNT(*) FROM material_entries
            WHERE entry_date = %s
            AND (is_modified = FALSE OR is_modified IS NULL)
        """, [today])
        total_material = cursor.fetchone()[0]
    
    print(f"📊 Total labour entries in database (today): {total_labour}")
    print(f"📊 Total material entries in database (today): {total_material}")
    print()
    
    # Check for specific users mentioned in the issue
    print_section("SPECIFIC USER CHECK")
    
    jack = User.objects.filter(username='jack').first()
    aravind = User.objects.filter(username='aravind').first()
    
    if jack:
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT COUNT(*) FROM labour_entries
                WHERE supervisor_id = %s
                AND entry_date = %s
                AND (is_modified = FALSE OR is_modified IS NULL)
            """, [jack.id, today])
            jack_entries = cursor.fetchone()[0]
        print(f"👤 jack (Supervisor): {jack_entries} entries")
    else:
        print(f"❌ User 'jack' not found")
    
    if aravind:
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT COUNT(*) FROM labour_entries
                WHERE supervisor_id = %s
                AND entry_date = %s
                AND (is_modified = FALSE OR is_modified IS NULL)
            """, [aravind.id, today])
            aravind_entries = cursor.fetchone()[0]
        print(f"👤 aravind (Site Engineer): {aravind_entries} entries")
    else:
        print(f"❌ User 'aravind' not found")
    
    print()
    print("✅ Verification complete!")
    print()
    print("EXPECTED BEHAVIOR:")
    print("- Each user should only see their own entries")
    print("- jack should see 3 entries (Carpenter, Mason, General)")
    print("- aravind should see 3 entries (General, Mason, Helper)")
    print("- Total in database: 6 entries")
    print()
    print("If the backend shows correct counts but the app shows 8 entries,")
    print("this confirms it's a FRONTEND CACHING ISSUE.")
    print()

if __name__ == '__main__':
    main()
