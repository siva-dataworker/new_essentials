"""
Fix duplicate Client roles - merge 'client' and 'Client' into one
"""
import psycopg2
from psycopg2.extras import RealDictCursor
import os
from dotenv import load_dotenv

load_dotenv()

conn = psycopg2.connect(
    dbname=os.getenv('DB_NAME', 'construction_db'),
    user=os.getenv('DB_USER', 'postgres'),
    password=os.getenv('DB_PASSWORD', 'postgres'),
    host=os.getenv('DB_HOST', 'localhost'),
    port=os.getenv('DB_PORT', '5432')
)
conn.autocommit = True
cursor = conn.cursor(cursor_factory=RealDictCursor)

print("\n" + "="*70)
print("FIXING DUPLICATE CLIENT ROLES")
print("="*70)

# Get both Client roles
cursor.execute("""
    SELECT id, role_name 
    FROM roles 
    WHERE role_name IN ('Client', 'client')
    ORDER BY role_name
""")
client_roles = cursor.fetchall()

print(f"\nFound {len(client_roles)} Client role(s):")
for role in client_roles:
    print(f"  - '{role['role_name']}' (ID: {role['id']})")

if len(client_roles) > 1:
    # Keep 'Client' (capitalized), remove 'client' (lowercase)
    keep_role = next((r for r in client_roles if r['role_name'] == 'Client'), client_roles[0])
    remove_roles = [r for r in client_roles if r['id'] != keep_role['id']]
    
    print(f"\n✅ Keeping: '{keep_role['role_name']}' (ID: {keep_role['id']})")
    
    for remove_role in remove_roles:
        print(f"\n🔄 Migrating users from '{remove_role['role_name']}' to '{keep_role['role_name']}'...")
        
        # Check how many users have this role
        cursor.execute("""
            SELECT COUNT(*) as count
            FROM users
            WHERE role_id = %s
        """, (remove_role['id'],))
        user_count = cursor.fetchone()['count']
        print(f"   Found {user_count} user(s) with role '{remove_role['role_name']}'")
        
        if user_count > 0:
            # Update users to use the kept role
            cursor.execute("""
                UPDATE users
                SET role_id = %s
                WHERE role_id = %s
            """, (keep_role['id'], remove_role['id']))
            print(f"   ✅ Migrated {user_count} user(s)")
        
        # Delete the duplicate role
        cursor.execute("DELETE FROM roles WHERE id = %s", (remove_role['id'],))
        print(f"   ✅ Deleted role '{remove_role['role_name']}'")
    
    print("\n✅ Cleanup complete!")
else:
    print("\n✅ No duplicate roles found")

# Verify final state
print("\n" + "-"*70)
print("FINAL STATE:")
print("-"*70)
cursor.execute("SELECT id, role_name FROM roles ORDER BY role_name")
roles = cursor.fetchall()
print("\nAll roles:")
for role in roles:
    cursor.execute("SELECT COUNT(*) as count FROM users WHERE role_id = %s", (role['id'],))
    user_count = cursor.fetchone()['count']
    print(f"  - '{role['role_name']}' (ID: {role['id']}) - {user_count} user(s)")

print("\n" + "="*70 + "\n")

cursor.close()
conn.close()
