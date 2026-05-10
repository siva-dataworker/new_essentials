#!/usr/bin/env python3
"""
Show Labour Entries Directly - Check what's in labour_entries table
"""

import os
import sys
import django

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.db import connection
from datetime import date

def main():
    print("\n" + "="*60)
    print("  LABOUR ENTRIES - DIRECT CHECK")
    print("="*60 + "\n")
    
    today = date.today()
    print(f"📅 Checking entries for: {today}\n")
    
    # Get all labour entries for today
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT 
                id,
                supervisor_id,
                site_id,
                labour_type,
                labour_count,
                submitted_by_role,
                entry_date,
                is_modified
            FROM labour_entries
            WHERE entry_date = %s
            ORDER BY supervisor_id, labour_type;
        """, [today])
        
        columns = [col[0] for col in cursor.description]
        entries = [dict(zip(columns, row)) for row in cursor.fetchall()]
    
    print(f"📊 Total entries found: {len(entries)}\n")
    
    if entries:
        # Group by supervisor_id
        by_supervisor = {}
        for entry in entries:
            sup_id = entry['supervisor_id']
            if sup_id not in by_supervisor:
                by_supervisor[sup_id] = []
            by_supervisor[sup_id].append(entry)
        
        print("Entries grouped by supervisor_id:\n")
        for sup_id, sup_entries in by_supervisor.items():
            print(f"👤 Supervisor ID: {sup_id}")
            print(f"   Total entries: {len(sup_entries)}")
            print(f"   Entries:")
            for entry in sup_entries:
                print(f"      • {entry['labour_type']}: {entry['labour_count']} workers")
                print(f"        ID: {entry['id']}, Role: {entry['submitted_by_role']}, Site: {entry['site_id']}")
                print(f"        Modified: {entry['is_modified']}")
            print()
    
    # Check users table
    print("="*60)
    print("  USERS TABLE CHECK")
    print("="*60 + "\n")
    
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT id, username, full_name, role
            FROM users
            ORDER BY id;
        """)
        
        users = cursor.fetchall()
        
        if users:
            print(f"👥 Total users: {len(users)}\n")
            for user in users:
                print(f"   • ID: {user[0]}, Username: {user[1]}, Name: {user[2]}, Role: {user[3]}")
        else:
            print("❌ No users found in users table!")
            print("   This might be why the API is not working correctly.")
    
    print()
    
    # Check if supervisor_ids in labour_entries match user IDs
    print("="*60)
    print("  SUPERVISOR ID VALIDATION")
    print("="*60 + "\n")
    
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT DISTINCT supervisor_id
            FROM labour_entries
            WHERE entry_date = %s;
        """, [today])
        
        supervisor_ids = [row[0] for row in cursor.fetchall()]
        
        print(f"Supervisor IDs in labour_entries: {supervisor_ids}\n")
        
        for sup_id in supervisor_ids:
            cursor.execute("""
                SELECT username, full_name, role
                FROM users
                WHERE id = %s;
            """, [sup_id])
            
            user = cursor.fetchone()
            if user:
                print(f"✅ Supervisor ID {sup_id}: {user[0]} ({user[1]}) - {user[2]}")
            else:
                print(f"❌ Supervisor ID {sup_id}: NOT FOUND in users table!")
    
    print()
    print("="*60)
    print()
    
    # Summary
    print("SUMMARY:")
    print(f"• Labour entries: {len(entries)}")
    print(f"• Unique supervisors: {len(by_supervisor)}")
    print(f"• Users in database: {len(users) if users else 0}")
    print()
    
    if len(users) == 0:
        print("⚠️  WARNING: No users in database!")
        print("   The backend API will not work correctly without users.")
        print("   Labour entries exist but cannot be linked to users.")
    
    print()

if __name__ == '__main__':
    main()
