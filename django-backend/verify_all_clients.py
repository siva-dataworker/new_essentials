"""
Verify all Client users and their site assignments
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
print("ALL CLIENT USERS")
print("="*70)

# Get all Client users
cursor.execute("""
    SELECT u.id, u.username, u.email, u.full_name, u.status, r.role_name
    FROM users u
    JOIN roles r ON u.role_id = r.id
    WHERE r.role_name = 'Client'
    ORDER BY u.username
""")
clients = cursor.fetchall()

print(f"\nTotal Client users: {len(clients)}\n")

for client in clients:
    print("-" * 70)
    print(f"Username: {client['username']}")
    print(f"Email: {client['email']}")
    print(f"Full Name: {client['full_name']}")
    print(f"Status: {client['status']}")
    print(f"Role: {client['role_name']}")
    
    # Get assigned sites
    cursor.execute("""
        SELECT 
            s.id,
            s.site_name,
            s.customer_name,
            cs.assigned_date
        FROM client_sites cs
        JOIN sites s ON cs.site_id = s.id
        WHERE cs.client_id = %s AND cs.is_active = TRUE
        ORDER BY cs.assigned_date DESC
    """, (client['id'],))
    sites = cursor.fetchall()
    
    if sites:
        print(f"Assigned Sites: {len(sites)}")
        for site in sites:
            site_display = f"{site['customer_name']} {site['site_name']}" if site['customer_name'] else site['site_name']
            print(f"  ✅ {site_display}")
            print(f"     ID: {site['id']}")
            print(f"     Assigned: {site['assigned_date'].strftime('%Y-%m-%d')}")
    else:
        print("Assigned Sites: 0")
        print("  ⚠️  No sites assigned")

print("\n" + "="*70)
print("READY TO TEST")
print("="*70)
print("\n1. Restart Flutter app")
print("2. Login with any of the above Client usernames")
print("3. Should see ClientDashboard (NOT Supervisor dashboard)")
print("4. Check console for 🔐 debug messages")
print("\n" + "="*70 + "\n")

cursor.close()
conn.close()
