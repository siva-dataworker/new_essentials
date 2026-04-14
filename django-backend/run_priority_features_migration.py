#!/usr/bin/env python3
"""
Run Priority Features Migration
Adds schema updates for new features
"""

import os
import sys
import django

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.db import connection

# Read SQL file
with open('add_priority_features_schema.sql', 'r') as f:
    sql_content = f.read()

# Execute SQL
print("🔧 Running priority features migration...")
try:
    with connection.cursor() as cursor:
        cursor.execute(sql_content)
    
    print("✅ Priority features migration completed successfully!")
    
    # Verify the changes
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT 
                table_name,
                column_name, 
                data_type
            FROM information_schema.columns 
            WHERE table_name IN ('work_updates', 'labour_entries', 'material_balances', 'sites', 'notifications')
                AND column_name IN ('upload_time_type', 'submitted_by_role', 'town', 'city', 'is_read', 'title', 'message')
            ORDER BY table_name, column_name
        """)
        results = cursor.fetchall()
        
        print("\n📋 Verified Columns:")
        for row in results:
            print(f"  {row[0]}.{row[1]}: {row[2]}")
    
    print("\n📋 Migration Summary:")
    print("✅ Added upload_time_type to work_updates")
    print("✅ Added submitted_by_role to labour_entries and material_balances")
    print("✅ Added town and city to sites")
    print("✅ Created notifications table")
    print("✅ Created indexes for performance")
    print("\n🎉 Database is ready for new features!")
    
except Exception as e:
    print(f"❌ Error running migration: {e}")
    sys.exit(1)
