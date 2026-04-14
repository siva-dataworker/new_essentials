"""
Check client4 user details
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
cursor = conn.cursor(cursor_factory=RealDictCursor)

print("\n" + "="*70)
print("CHECKING CLIENT4 USER")
print("="*70)

# Check client4
cursor.execute("""
    SELECT u.id, u.username, u.email, u.full_name, u.status, r.role_name, r.id as role_id
    FROM users u
    LEFT JOIN roles r ON u.role_id = r.id
    WHERE u.username = 'client4'
""")
client4 = cursor.fetchone()

if client4:
    print(f"\n✅ Found client4:")
    print(f"   ID: {client4['id']}")
    print(f"   Username: {client4['username']}")
    print(f"   Email: {client4['email']}")
    print(f"   Full Name: {client4['full_name']}")
    print(f"   Status: {client4['status']}")
    print(f"   Role Name: '{client4['role_name']}'")
    print(f"   Role ID: {client4['role_id']}")
    
    # Check for extra spaces or case issues
    role_name = client4['role_name']
    print(f"\n   Role Analysis:")
    print(f"   - Length: {len(role_name)}")
    print(f"   - Lowercase: '{role_name.lower()}'")
    print(f"   - Has spaces: {' ' in role_name}")
    print(f"   - Starts with space: {role_name.startswith(' ')}")
    print(f"   - Ends with space: {role_name.endswith(' ')}")
    
    # Check assigned sites
    cursor.execute("""
        SELECT COUNT(*) as count
        FROM client_sites
        WHERE client_id = %s AND is_active = TRUE
    """, (client4['id'],))
    site_count = cursor.fetchone()['count']
    print(f"\n   Assigned Sites: {site_count}")
    
    # Check all roles in database
    print("\n" + "-"*70)
    print("ALL ROLES IN DATABASE:")
    print("-"*70)
    cursor.execute("SELECT id, role_name FROM roles ORDER BY role_name")
    roles = cursor.fetchall()
    for role in roles:
        print(f"   - '{role['role_name']}' (ID: {role['id']})")
    
else:
    print("\n❌ client4 user not found")
    print("\nSearching for similar usernames:")
    cursor.execute("SELECT username, email FROM users WHERE username LIKE 'client%'")
    users = cursor.fetchall()
    for user in users:
        print(f"   - {user['username']} ({user['email']})")

print("\n" + "="*70 + "\n")

cursor.close()
conn.close()
