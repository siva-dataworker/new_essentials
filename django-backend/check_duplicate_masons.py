#!/usr/bin/env python3
"""
Check for duplicate Mason entries for the same supervisor
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
    print("  CHECKING FOR DUPLICATE MASON ENTRIES")
    print("="*60 + "\n")
    
    today = date.today()
    print(f"📅 Date: {today}\n")
    
    # Get all Mason entries for today
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT 
                id,
                supervisor_id,
                labour_type,
                labour_count,
                submitted_by_role,
                entry_time
            FROM labour_entries
            WHERE entry_date = %s
            AND labour_type = 'Mason'
            ORDER BY supervisor_id, entry_time;
        """, [today])
        
        columns = [col[0] for col in cursor.description]
        entries = [dict(zip(columns, row)) for row in cursor.fetchall()]
    
    print(f"📊 Total Mason entries: {len(entries)}\n")
    
    if entries:
        # Group by supervisor_id
        by_supervisor = {}
        for entry in entries:
            sup_id = entry['supervisor_id']
            if sup_id not in by_supervisor:
                by_supervisor[sup_id] = []
            by_supervisor[sup_id].append(entry)
        
        for sup_id, sup_entries in by_supervisor.items():
            print(f"👤 Supervisor ID: {sup_id}")
            print(f"   Mason entries: {len(sup_entries)}")
            
            if len(sup_entries) > 1:
                print(f"   ⚠️  DUPLICATE DETECTED!")
            
            for entry in sup_entries:
                print(f"\n   Entry ID: {entry['id']}")
                print(f"   Count: {entry['labour_count']}")
                print(f"   Role: {entry['submitted_by_role']}")
                print(f"   Entry Time: {entry['entry_time']}")
            print()
    
    # Check all entries for today grouped by supervisor
    print("="*60)
    print("  ALL ENTRIES BY SUPERVISOR")
    print("="*60 + "\n")
    
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT 
                supervisor_id,
                labour_type,
                COUNT(*) as count
            FROM labour_entries
            WHERE entry_date = %s
            GROUP BY supervisor_id, labour_type
            ORDER BY supervisor_id, labour_type;
        """, [today])
        
        results = cursor.fetchall()
        
        current_sup = None
        for row in results:
            sup_id, labour_type, count = row
            
            if sup_id != current_sup:
                if current_sup is not None:
                    print()
                print(f"👤 Supervisor: {sup_id}")
                current_sup = sup_id
            
            status = "⚠️  DUPLICATE!" if count > 1 else "✅"
            print(f"   {labour_type}: {count} entries {status}")
    
    print("\n" + "="*60)
    print()

if __name__ == '__main__':
    main()
