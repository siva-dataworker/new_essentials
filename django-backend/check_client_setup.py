"""
Check and setup client_sites table and verify client3 user
"""
import psycopg2
from psycopg2.extras import RealDictCursor
import os
from dotenv import load_dotenv

load_dotenv()

# Database connection
conn = psycopg2.connect(
    dbname=os.getenv('DB_NAME', 'construction_db'),
    user=os.getenv('DB_USER', 'postgres'),
    password=os.getenv('DB_PASSWORD', 'postgres'),
    host=os.getenv('DB_HOST', 'localhost'),
    port=os.getenv('DB_PORT', '5432')
)
conn.autocommit = True
cursor = conn.cursor(cursor_factory=RealDictCursor)

print("=" * 60)
print("CHECKING CLIENT SETUP")
print("=" * 60)

# 1. Check if client_sites table exists
print("\n1. Checking client_sites table...")
cursor.execute("""
    SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_name = 'client_sites'
    );
""")
table_exists = cursor.fetchone()['exists']
print(f"   client_sites table exists: {table_exists}")

if not table_exists:
    print("   Creating client_sites table...")
    with open('create_client_sites_table.sql', 'r') as f:
        sql = f.read()
        cursor.execute(sql)
    print("   ✅ Table created successfully!")

# 2. Check for client3 user
print("\n2. Checking client3 user...")
cursor.execute("""
    SELECT u.id, u.username, u.email, u.full_name, r.role_name, u.status
    FROM users u
    LEFT JOIN roles r ON u.role_id = r.id
    WHERE u.username = 'client3'
""")
client3 = cursor.fetchone()
if client3:
    print(f"   ✅ Found client3:")
    print(f"      ID: {client3['id']}")
    print(f"      Email: {client3['email']}")
    print(f"      Name: {client3['full_name']}")
    print(f"      Role: {client3['role_name']}")
    print(f"      Status: {client3['status']}")
    
    # Check assigned sites
    print("\n3. Checking assigned sites for client3...")
    cursor.execute("""
        SELECT 
            cs.id as assignment_id,
            cs.site_id,
            cs.assigned_date,
            s.site_name,
            s.customer_name
        FROM client_sites cs
        JOIN sites s ON cs.site_id = s.id
        WHERE cs.client_id = %s AND cs.is_active = TRUE
    """, (client3['id'],))
    sites = cursor.fetchall()
    
    if sites:
        print(f"   ✅ Found {len(sites)} assigned site(s):")
        for site in sites:
            print(f"      - {site['customer_name']} {site['site_name']} (ID: {site['site_id']})")
            print(f"        Assigned: {site['assigned_date']}")
    else:
        print("   ⚠️  No sites assigned to client3")
        print("\n   Available sites:")
        cursor.execute("SELECT id, site_name, customer_name FROM sites LIMIT 5")
        available_sites = cursor.fetchall()
        for site in available_sites:
            print(f"      - {site['customer_name']} {site['site_name']} (ID: {site['id']})")
else:
    print("   ⚠️  client3 user not found")
    print("\n   Available users with Client role:")
    cursor.execute("""
        SELECT u.username, u.email, r.role_name
        FROM users u
        LEFT JOIN roles r ON u.role_id = r.id
        WHERE r.role_name = 'Client'
    """)
    clients = cursor.fetchall()
    if clients:
        for client in clients:
            print(f"      - {client['username']} ({client['email']})")
    else:
        print("      No Client users found")

# 4. Check Client role exists
print("\n4. Checking Client role...")
cursor.execute("SELECT id, role_name FROM roles WHERE role_name = 'Client'")
client_role = cursor.fetchone()
if client_role:
    print(f"   ✅ Client role exists (ID: {client_role['id']})")
else:
    print("   ⚠️  Client role not found. Creating...")
    cursor.execute("INSERT INTO roles (role_name) VALUES ('Client')")
    print("   ✅ Client role created!")

cursor.close()
conn.close()

print("\n" + "=" * 60)
print("CHECK COMPLETE")
print("=" * 60)
