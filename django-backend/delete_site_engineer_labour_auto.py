#!/usr/bin/env python3
"""
Delete labour entries submitted by Site Engineers from the database (auto-confirm)
"""
import os
import sys
import django
from pathlib import Path

# Add the project directory to the Python path
BASE_DIR = Path(__file__).resolve().parent
sys.path.append(str(BASE_DIR))

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import execute_query, fetch_all

def delete_site_engineer_labour_entries():
    """Delete all labour entries from Site Engineers"""
    print("\n" + "="*60)
    print("DELETING SITE ENGINEER LABOUR ENTRIES")
    print("="*60 + "\n")
    
    # First, get count of Site Engineer labour entries
    count_result = fetch_all("""
        SELECT COUNT(*) as count
        FROM labour_entries le
        JOIN users u ON le.supervisor_id = u.id
        JOIN roles r ON u.role_id = r.id
        WHERE r.role_name = 'Site Engineer'
    """)
    
    if count_result:
        count = count_result[0]['count']
        print(f"Found {count} labour entries from Site Engineers\n")
        
        if count == 0:
            print("✓ No Site Engineer labour entries to delete")
            return
        
        # Show some details before deleting
        entries = fetch_all("""
            SELECT 
                le.id,
                le.labour_type,
                le.labour_count,
                le.entry_date,
                u.username,
                u.full_name,
                s.site_name
            FROM labour_entries le
            JOIN users u ON le.supervisor_id = u.id
            JOIN roles r ON u.role_id = r.id
            JOIN sites s ON le.site_id = s.id
            WHERE r.role_name = 'Site Engineer'
            ORDER BY le.entry_date DESC
            LIMIT 10
        """)
        
        print("Sample entries to be deleted (showing up to 10):")
        print("-" * 60)
        for entry in entries:
            print(f"  {entry['entry_date']} | {entry['username']:15} | {entry['site_name']:20} | {entry['labour_type']:15} | Count: {entry['labour_count']}")
        
        if count > 10:
            print(f"  ... and {count - 10} more entries")
        
        print("\n" + "-" * 60)
        
        # Delete the entries (auto-confirm)
        execute_query("""
            DELETE FROM labour_entries
            WHERE supervisor_id IN (
                SELECT u.id
                FROM users u
                JOIN roles r ON u.role_id = r.id
                WHERE r.role_name = 'Site Engineer'
            )
        """)
        
        print(f"\n✓ Successfully deleted {count} labour entries from Site Engineers")
    else:
        print("✗ Could not query database")
    
    print("\n" + "="*60 + "\n")

if __name__ == '__main__':
    delete_site_engineer_labour_entries()
