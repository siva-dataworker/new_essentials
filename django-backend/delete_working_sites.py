#!/usr/bin/env python
"""
Delete all working sites data
"""

import os
import sys
import django

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.db import connection

def delete_working_sites():
    """Delete all working sites assignments"""
    
    print("=" * 60)
    print("DELETING WORKING SITES DATA")
    print("=" * 60)
    print()
    
    with connection.cursor() as cursor:
        # Get count before deletion
        cursor.execute("SELECT COUNT(*) FROM working_sites")
        count_before = cursor.fetchone()[0]
        
        print(f"Working sites before deletion: {count_before}")
        print()
        
        if count_before == 0:
            print("✅ No working sites to delete")
            return
        
        # Delete all working sites
        print("Deleting all working sites...")
        cursor.execute("DELETE FROM working_sites")
        deleted_count = cursor.rowcount
        
        print(f"✅ Deleted {deleted_count} working site assignments")
        print()
        
        # Verify deletion
        cursor.execute("SELECT COUNT(*) FROM working_sites")
        count_after = cursor.fetchone()[0]
        
        print(f"Working sites after deletion: {count_after}")
        print()
        
        if count_after == 0:
            print("✅ All working sites data deleted successfully!")
        else:
            print("⚠️  Warning: Some data may still remain")
    
    print("=" * 60)

if __name__ == '__main__':
    delete_working_sites()
