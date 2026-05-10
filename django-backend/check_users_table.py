#!/usr/bin/env python3
import os, sys, django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.db import connection

with connection.cursor() as cursor:
    cursor.execute("""
        SELECT column_name 
        FROM information_schema.columns 
        WHERE table_name = 'users' 
        ORDER BY ordinal_position;
    """)
    print("Columns in users table:")
    for row in cursor.fetchall():
        print(f"  • {row[0]}")
    
    print()
    
    cursor.execute("SELECT COUNT(*) FROM users;")
    count = cursor.fetchone()[0]
    print(f"Total users: {count}")
    
    if count > 0:
        cursor.execute("SELECT * FROM users LIMIT 3;")
        print("\nSample users:")
        for row in cursor.fetchall():
            print(f"  {row}")
