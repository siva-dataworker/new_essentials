import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.db import connection

print("=" * 80)
print("CHECKING USER ROLES DATA")
print("=" * 80)

with connection.cursor() as cursor:
    # Check roles table
    cursor.execute("""
        SELECT id, role_name FROM roles ORDER BY id
    """)
    
    roles = cursor.fetchall()
    print("\n📋 Roles table:")
    for role in roles:
        print(f"  - ID {role[0]}: {role[1]}")
    
    # Check users with their roles
    cursor.execute("""
        SELECT 
            u.id,
            u.username,
            u.role,
            u.role_id,
            r.role_name
        FROM users u
        LEFT JOIN roles r ON u.role_id = r.id
        LIMIT 10
    """)
    
    users = cursor.fetchall()
    print("\n📊 Sample users with roles:")
    for user in users:
        print(f"  - {user[1]}: role='{user[2]}', role_id={user[3]}, role_name='{user[4]}'")
    
    # Check if role column has values
    cursor.execute("""
        SELECT 
            COUNT(*) as total,
            COUNT(role) as with_role,
            COUNT(role_id) as with_role_id
        FROM users
    """)
    
    counts = cursor.fetchone()
    print(f"\n📈 Role column statistics:")
    print(f"  - Total users: {counts[0]}")
    print(f"  - Users with 'role' value: {counts[1]}")
    print(f"  - Users with 'role_id' value: {counts[2]}")
    
    # Check admin users
    cursor.execute("""
        SELECT id, username, role, role_id
        FROM users
        WHERE role_id = 1 OR role = 'admin' OR role ILIKE '%admin%'
    """)
    
    admins = cursor.fetchall()
    print(f"\n👑 Admin users:")
    if admins:
        for admin in admins:
            print(f"  - {admin[1]}: role='{admin[2]}', role_id={admin[3]}")
    else:
        print("  ❌ No admin users found!")
