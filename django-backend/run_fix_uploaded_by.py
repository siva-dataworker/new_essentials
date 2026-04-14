#!/usr/bin/env python
"""
Fix uploaded_by column in bills and agreements tables
"""
import os
import sys
import django

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import execute_query

def main():
    print("=" * 60)
    print("FIXING UPLOADED_BY COLUMN")
    print("=" * 60)
    print()
    
    try:
        # Read and execute the SQL file
        sql_file = os.path.join(os.path.dirname(__file__), 'fix_uploaded_by_column.sql')
        
        with open(sql_file, 'r') as f:
            sql = f.read()
        
        print("📝 Adding uploaded_by column if missing...")
        execute_query(sql)
        print("✅ Fix applied successfully!")
        print()
        
    except Exception as e:
        print(f"❌ Error: {e}")
        return 1
    
    print("=" * 60)
    print("✅ FIX COMPLETE!")
    print("=" * 60)
    return 0

if __name__ == '__main__':
    sys.exit(main())
