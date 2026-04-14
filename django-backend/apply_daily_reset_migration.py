#!/usr/bin/env python
"""
Script to add daily reset functionality to working_sites table
"""

import os
import sys
import django

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.db import connection

def apply_migration():
    """Apply the daily reset migration"""
    
    print("=" * 60)
    print("Adding Daily Reset to Working Sites Table")
    print("=" * 60)
    print()
    
    sql_file_path = os.path.join(os.path.dirname(__file__), 'add_daily_reset_to_working_sites.sql')
    
    try:
        with open(sql_file_path, 'r', encoding='utf-8') as f:
            sql = f.read()
        
        print("Executing SQL migration...")
        print()
        
        with connection.cursor() as cursor:
            cursor.execute(sql)
        
        print("✅ Migration applied successfully!")
        print()
        print("Added columns:")
        print("  - last_reset_date: Tracks when sites were last reset")
        print()
        print("Working sites will now reset daily at 6 AM IST")
        
    except FileNotFoundError:
        print(f"❌ Error: SQL file not found at {sql_file_path}")
        sys.exit(1)
    except Exception as e:
        print(f"❌ Error applying migration: {e}")
        sys.exit(1)

if __name__ == '__main__':
    apply_migration()
