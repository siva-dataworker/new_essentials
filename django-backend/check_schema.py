"""
Check existing database schema
"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.db import connection

with connection.cursor() as cursor:
    # Check if sites table exists and its structure
    cursor.execute("""
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_type = 'BASE TABLE'
        ORDER BY table_name
    """)
    
    tables = cursor.fetchall()
    print("Existing tables:")
    for table in tables:
        print(f"  - {table[0]}")
    
    print("\n" + "="*50)
    
    # Check sites table structure if it exists
    cursor.execute("""
        SELECT column_name, data_type 
        FROM information_schema.columns 
        WHERE table_name = 'sites'
        ORDER BY ordinal_position
    """)
    
    columns = cursor.fetchall()
    if columns:
        print("\nSites table columns:")
        for col in columns:
            print(f"  - {col[0]}: {col[1]}")
    else:
        print("\nSites table does not exist!")
    
    # Check users table structure
    cursor.execute("""
        SELECT column_name, data_type 
        FROM information_schema.columns 
        WHERE table_name = 'users'
        ORDER BY ordinal_position
    """)
    
    columns = cursor.fetchall()
    if columns:
        print("\nUsers table columns:")
        for col in columns:
            print(f"  - {col[0]}: {col[1]}")
    else:
        print("\nUsers table does not exist!")
