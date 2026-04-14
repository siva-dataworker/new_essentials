#!/usr/bin/env python
"""
Script to backup data before deletion
"""

import os
import sys
import django

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.db import connection

def backup_data():
    """Create backup of all data before deletion"""
    
    print("=" * 60)
    print("BACKING UP DATA BEFORE DELETION")
    print("=" * 60)
    print()
    
    try:
        print("Creating backup tables...")
        print()
        
        with connection.cursor() as cursor:
            # Create backup tables (these don't return results)
            cursor.execute("CREATE TABLE IF NOT EXISTS labour_entries_backup AS SELECT * FROM labour_entries;")
            print("✓ Created labour_entries_backup")
            
            cursor.execute("CREATE TABLE IF NOT EXISTS material_usage_backup AS SELECT * FROM material_usage;")
            print("✓ Created material_usage_backup")
            
            cursor.execute("CREATE TABLE IF NOT EXISTS work_updates_backup AS SELECT * FROM work_updates;")
            print("✓ Created work_updates_backup")
            
            cursor.execute("CREATE TABLE IF NOT EXISTS project_files_backup AS SELECT * FROM project_files;")
            print("✓ Created project_files_backup")
            
            print()
            print("Verifying backup counts...")
            print()
            
            # Get counts from original and backup tables
            cursor.execute("""
                SELECT 'labour_entries' as table_name, COUNT(*) as count FROM labour_entries
                UNION ALL
                SELECT 'labour_entries_backup', COUNT(*) FROM labour_entries_backup
                UNION ALL
                SELECT 'material_usage', COUNT(*) FROM material_usage
                UNION ALL
                SELECT 'material_usage_backup', COUNT(*) FROM material_usage_backup
                UNION ALL
                SELECT 'work_updates', COUNT(*) FROM work_updates
                UNION ALL
                SELECT 'work_updates_backup', COUNT(*) FROM work_updates_backup
                UNION ALL
                SELECT 'project_files', COUNT(*) FROM project_files
                UNION ALL
                SELECT 'project_files_backup', COUNT(*) FROM project_files_backup
            """)
            
            results = cursor.fetchall()
            
            print("Backup Summary:")
            print("-" * 60)
            for row in results:
                print(f"{row[0]:<30} {row[1]:>10}")
            print("-" * 60)
        
        print()
        print("✅ Backup completed successfully!")
        print()
        print("You can now run delete_data.py to delete the data")
        
    except Exception as e:
        print(f"❌ Error creating backup: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == '__main__':
    backup_data()
