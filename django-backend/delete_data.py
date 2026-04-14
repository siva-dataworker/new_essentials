#!/usr/bin/env python
"""
Script to delete all site data (labour, materials, photos, documents)
WARNING: This is IRREVERSIBLE! Run backup_data.py first!
"""

import os
import sys
import django

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.db import connection, transaction

def delete_data():
    """Delete all site data"""
    
    print("=" * 60)
    print("⚠️  WARNING: DELETING ALL SITE DATA")
    print("=" * 60)
    print()
    print("This will delete:")
    print("  - All labour entries")
    print("  - All material usage records")
    print("  - All photos/work updates")
    print("  - All project files/documents")
    print()
    print("Sites, users, and other data will be preserved.")
    print()
    print("=" * 60)
    
    # Confirmation
    confirm = input("Type 'DELETE' to confirm (case-sensitive): ").strip()
    
    if confirm != 'DELETE':
        print("❌ Deletion cancelled. You must type 'DELETE' exactly.")
        sys.exit(0)
    
    print()
    print("Proceeding with deletion...")
    print()
    
    sql_file_path = os.path.join(os.path.dirname(__file__), 'delete_all_site_data.sql')
    
    try:
        with open(sql_file_path, 'r', encoding='utf-8') as f:
            sql = f.read()
        
        # Split SQL into individual statements
        statements = [s.strip() for s in sql.split(';') if s.strip() and not s.strip().startswith('--')]
        
        with transaction.atomic():
            with connection.cursor() as cursor:
                for statement in statements:
                    if statement.upper().startswith('SELECT'):
                        cursor.execute(statement)
                        results = cursor.fetchall()
                        
                        # Display results
                        for row in results:
                            if len(row) == 1:
                                print(row[0])
                            elif len(row) == 2:
                                print(f"{row[0]:<40} {row[1]:>10}")
                            elif len(row) == 3:
                                print(f"{row[0]:<30} {row[1]:>10} {row[2]:>15}")
                            else:
                                print(row)
                        print()
                    elif statement.upper().startswith('DELETE'):
                        cursor.execute(statement)
                        deleted_count = cursor.rowcount
                        table_name = statement.split('FROM')[1].strip().split()[0]
                        print(f"🗑️  Deleted {deleted_count} records from {table_name}")
        
        print()
        print("✅ Transaction committed")
        
        print()
        print("=" * 60)
        print("✅ All site data deleted successfully!")
        print("=" * 60)
        print()
        print("What was deleted:")
        print("  ✅ Labour entries")
        print("  ✅ Material usage")
        print("  ✅ Photos/Work updates")
        print("  ✅ Project files/Documents")
        print()
        print("What was preserved:")
        print("  ✅ Sites")
        print("  ✅ Users")
        print("  ✅ Roles")
        print("  ✅ Budget allocations")
        print("  ✅ Working sites assignments")
        print()
        
    except FileNotFoundError:
        print(f"❌ Error: SQL file not found at {sql_file_path}")
        sys.exit(1)
    except Exception as e:
        print(f"❌ Error deleting data: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == '__main__':
    delete_data()
