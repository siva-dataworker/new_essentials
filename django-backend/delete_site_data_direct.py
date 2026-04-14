#!/usr/bin/env python
"""
Direct deletion script - deletes all site data immediately
"""

import os
import sys
import django

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.db import connection

def delete_all_site_data():
    """Delete all site data directly"""
    
    print("=" * 60)
    print("DELETING ALL SITE DATA")
    print("=" * 60)
    print()
    
    with connection.cursor() as cursor:
        # Get counts before deletion
        cursor.execute("SELECT COUNT(*) FROM labour_entries")
        labour_before = cursor.fetchone()[0]
        
        cursor.execute("SELECT COUNT(*) FROM material_usage")
        material_before = cursor.fetchone()[0]
        
        cursor.execute("SELECT COUNT(*) FROM work_updates")
        photos_before = cursor.fetchone()[0]
        
        cursor.execute("SELECT COUNT(*) FROM project_files")
        files_before = cursor.fetchone()[0]
        
        print(f"BEFORE DELETION:")
        print(f"  Labour entries: {labour_before}")
        print(f"  Material usage: {material_before}")
        print(f"  Work updates (photos): {photos_before}")
        print(f"  Project files (documents): {files_before}")
        print()
        
        # Delete data
        print("Deleting...")
        cursor.execute("DELETE FROM labour_entries")
        print(f"  ✓ Deleted {cursor.rowcount} labour entries")
        
        cursor.execute("DELETE FROM material_usage")
        print(f"  ✓ Deleted {cursor.rowcount} material usage records")
        
        cursor.execute("DELETE FROM work_updates")
        print(f"  ✓ Deleted {cursor.rowcount} work updates (photos)")
        
        cursor.execute("DELETE FROM project_files")
        print(f"  ✓ Deleted {cursor.rowcount} project files (documents)")
        
        # Verify deletion
        print()
        cursor.execute("SELECT COUNT(*) FROM labour_entries")
        labour_after = cursor.fetchone()[0]
        
        cursor.execute("SELECT COUNT(*) FROM material_usage")
        material_after = cursor.fetchone()[0]
        
        cursor.execute("SELECT COUNT(*) FROM work_updates")
        photos_after = cursor.fetchone()[0]
        
        cursor.execute("SELECT COUNT(*) FROM project_files")
        files_after = cursor.fetchone()[0]
        
        print(f"AFTER DELETION:")
        print(f"  Labour entries: {labour_after}")
        print(f"  Material usage: {material_after}")
        print(f"  Work updates (photos): {photos_after}")
        print(f"  Project files (documents): {files_after}")
        print()
        
        if labour_after == 0 and material_after == 0 and photos_after == 0 and files_after == 0:
            print("✅ All site data deleted successfully!")
        else:
            print("⚠️  Warning: Some data may still remain")
    
    print("=" * 60)

if __name__ == '__main__':
    delete_all_site_data()
