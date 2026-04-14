"""
Manually assign a site to client3 for testing
"""
import psycopg2
from psycopg2.extras import RealDictCursor
import os
from dotenv import load_dotenv
import uuid

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

print("Assigning site to client3...")

# Get client3 ID
cursor.execute("SELECT id FROM users WHERE username = 'client3'")
client3 = cursor.fetchone()

if not client3:
    print("❌ client3 not found!")
    exit(1)

client_id = client3['id']
print(f"✅ Found client3: {client_id}")

# Get first available site
cursor.execute("SELECT id, site_name, customer_name FROM sites LIMIT 1")
site = cursor.fetchone()

if not site:
    print("❌ No sites available!")
    exit(1)

site_id = site['id']
site_name = f"{site['customer_name']} {site['site_name']}" if site['customer_name'] else site['site_name']
print(f"✅ Found site: {site_name} ({site_id})")

# Get admin user (for assigned_by)
cursor.execute("SELECT id FROM users WHERE username = 'admin' LIMIT 1")
admin = cursor.fetchone()
admin_id = admin['id'] if admin else None

# Assign site to client
assignment_id = str(uuid.uuid4())
cursor.execute("""
    INSERT INTO client_sites (id, client_id, site_id, assigned_by, is_active)
    VALUES (%s, %s, %s, %s, TRUE)
    ON CONFLICT (client_id, site_id) DO NOTHING
""", (assignment_id, client_id, site_id, admin_id))

print(f"✅ Assigned site '{site_name}' to client3!")

# Verify
cursor.execute("""
    SELECT COUNT(*) as count
    FROM client_sites
    WHERE client_id = %s AND is_active = TRUE
""", (client_id,))
count = cursor.fetchone()['count']
print(f"✅ client3 now has {count} assigned site(s)")

cursor.close()
conn.close()
