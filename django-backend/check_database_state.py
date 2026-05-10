#!/usr/bin/env python3
"""
Check Database State - See what's in the database
"""

import os
import sys
import django

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.db import connection
from django.contrib.auth import get_user_model

User = get_user_model()

def main():
    print("\n" + "="*60)
    print("  DATABASE STATE CHECK")
    print("="*60 + "\n")
    
    # Check database connection
    with connection.cursor() as cursor:
        cursor.execute("SELECT current_database();")
        db_name = cursor.fetchone()[0]
        print(f"📊 Connected to database: {db_name}\n")
    
    # List all tables
    print("📋 Available tables:")
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public'
            ORDER BY table_name;
        """)
        tables = cursor.fetchall()
        for table in tables:
            print(f"   • {table[0]}")
    
    print()
    
    # Check users
    print("👥 Users in database:")
    users = User.objects.all()
    print(f"   Total: {users.count()}\n")
    
    for user in users:
        print(f"   • {user.username} ({user.full_name}) - {user.role}")
    
    print()
    
    # Check if labour_entries table exists
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT EXISTS (
                SELECT FROM information_schema.tables 
                WHERE table_schema = 'public' 
                AND table_name = 'labour_entries'
            );
        """)
        has_labour = cursor.fetchone()[0]
        
        if has_labour:
            cursor.execute("SELECT COUNT(*) FROM labour_entries;")
            count = cursor.fetchone()[0]
            print(f"✅ labour_entries table exists: {count} rows")
            
            if count > 0:
                cursor.execute("""
                    SELECT entry_date, COUNT(*) 
                    FROM labour_entries 
                    GROUP BY entry_date 
                    ORDER BY entry_date DESC 
                    LIMIT 5;
                """)
                print("   Recent dates:")
                for row in cursor.fetchall():
                    print(f"      • {row[0]}: {row[1]} entries")
        else:
            print("❌ labour_entries table does not exist")
    
    print()
    
    # Check if material_entries table exists
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT EXISTS (
                SELECT FROM information_schema.tables 
                WHERE table_schema = 'public' 
                AND table_name = 'material_entries'
            );
        """)
        has_material = cursor.fetchone()[0]
        
        if has_material:
            cursor.execute("SELECT COUNT(*) FROM material_entries;")
            count = cursor.fetchone()[0]
            print(f"✅ material_entries table exists: {count} rows")
        else:
            print("❌ material_entries table does not exist")
    
    print()
    print("="*60)
    print()

if __name__ == '__main__':
    main()
