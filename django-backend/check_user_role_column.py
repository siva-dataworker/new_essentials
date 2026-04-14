import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.db import connection

print("=" * 80)
print("CHECKING USERS TABLE FOR ROLE INFORMATION")
print("=" * 80)

with connection.cursor() as cursor:
    # Check all columns in users table
    cursor.execute("""
        SELECT column_name, data_type 
        FROM information_schema.columns 
        WHERE table_name = 'users'
        ORDER BY ordinal_position
    """)
    
    columns = cursor.fetchall()
    print("\n📋 Users table columns:")
    for col in columns:
        print(f"  - {col[0]}: {col[1]}")
    
    # Check if there's a role-related column
    print("\n🔍 Looking for role-related columns:")
    role_columns = [col for col in columns if 'role' in col[0].lower()]
    if role_columns:
        for col in role_columns:
            print(f"  ✅ Found: {col[0]} ({col[1]})")
    else:
        print("  ❌ No 'role' column found")
    
    # Check for user_type column
    user_type_columns = [col for col in columns if 'type' in col[0].lower()]
    if user_type_columns:
        print("\n🔍 Found type-related columns:")
        for col in user_type_columns:
            print(f"  ✅ Found: {col[0]} ({col[1]})")
    
    # Sample a user to see the structure
    cursor.execute("""
        SELECT * FROM users LIMIT 1
    """)
    
    if cursor.description:
        print("\n📊 Sample user record structure:")
        col_names = [desc[0] for desc in cursor.description]
        print(f"  Columns: {', '.join(col_names)}")
        
        sample = cursor.fetchone()
        if sample:
            print("\n  Sample values:")
            for i, col_name in enumerate(col_names):
                if 'password' not in col_name.lower():
                    print(f"    {col_name}: {sample[i]}")
