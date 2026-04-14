"""
Quick verification of Client feature setup
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
print("CLIENT FEATURE VERIFICATION")
print("="*70)

# 1. Check table
cursor.execute("SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'client_sites')")
print(f"\n✅ client_sites table: {'EXISTS' if cursor.fetchone()['exists'] else 'MISSING'}")

# 2. Check role
cursor.execute("SELECT COUNT(*) as count FROM roles WHERE role_name = 'Client'")
print(f"✅ Client role: {'EXISTS' if cursor.fetchone()['count'] > 0 else 'MISSING'}")

# 3. Check client users
cursor.execute("""
    SELECT COUNT(*) as count FROM users u
    JOIN roles r ON u.role_id = r.id
    WHERE r.role_name = 'Client'
""")
client_count = cursor.fetchone()['count']
print(f"✅ Client users: {client_count}")

# 4. Check site assignments
cursor.execute("SELECT COUNT(*) as count FROM client_sites WHERE is_active = TRUE")
assignment_count = cursor.fetchone()['count']
print(f"✅ Active site assignments: {assignment_count}")

# 5. Show client3 details
print("\n" + "-"*70)
print("CLIENT3 DETAILS")
print("-"*70)
cursor.execute("""
    SELECT u.username, u.email, u.full_name, u.status, r.role_name
    FROM users u
    JOIN roles r ON u.role_id = r.id
    WHERE u.username = 'client3'
""")
client3 = cursor.fetchone()
if client3:
    print(f"Username: {client3['username']}")
    print(f"Email: {client3['email']}")
    print(f"Name: {client3['full_name']}")
    print(f"Role: {client3['role_name']}")
    print(f"Status: {client3['status']}")
    
    # Get assigned sites
    cursor.execute("""
        SELECT s.site_name, s.customer_name, cs.assigned_date
        FROM client_sites cs
        JOIN sites s ON cs.site_id = s.id
        WHERE cs.client_id = (SELECT id FROM users WHERE username = 'client3')
        AND cs.is_active = TRUE
    """)
    sites = cursor.fetchall()
    print(f"\nAssigned Sites: {len(sites)}")
    for site in sites:
        site_display = f"{site['customer_name']} {site['site_name']}" if site['customer_name'] else site['site_name']
        print(f"  - {site_display} (assigned: {site['assigned_date'].strftime('%Y-%m-%d')})")
else:
    print("❌ client3 not found")

print("\n" + "="*70)
print("READY TO TEST")
print("="*70)
print("\n1. Restart Flutter app: flutter run")
print("2. Login as admin")
print("3. Click 'Create User'")
print("4. Select 'Client' role")
print("5. Look for site selection UI below role dropdown")
print("6. Check console for 🎯 debug messages")
print("\n" + "="*70 + "\n")

cursor.close()
conn.close()
