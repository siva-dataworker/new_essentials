import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.db import connection

print("=" * 60)
print("CHECKING CLIENT DATA")
print("=" * 60)

with connection.cursor() as cursor:
    # Get client
    cursor.execute("SELECT id, username, full_name FROM users WHERE username='sivu'")
    client = cursor.fetchone()
    
    if not client:
        print("❌ Client not found")
        exit(1)
    
    print(f"\n👤 Client: {client[2]} ({client[1]})")
    print(f"   ID: {client[0]}")
    
    # Check assigned sites
    cursor.execute("""
        SELECT 
            cs.id,
            cs.site_id,
            s.site_name,
            s.customer_name,
            cs.is_active
        FROM client_sites cs
        LEFT JOIN sites s ON cs.site_id = s.id
        WHERE cs.client_id = %s
    """, [client[0]])
    
    sites = cursor.fetchall()
    print(f"\n📍 Assigned Sites: {len(sites)}")
    for site in sites:
        print(f"   - Site ID: {site[1]}")
        print(f"     Name: {site[2] or '(no name)'}")
        print(f"     Customer: {site[3] or '(no customer)'}")
        print(f"     Active: {site[4]}")
    
    # Check complaints
    cursor.execute("""
        SELECT 
            c.id,
            c.title,
            c.status,
            c.priority,
            c.created_at,
            s.site_name
        FROM complaints c
        LEFT JOIN sites s ON c.site_id = s.id
        WHERE c.raised_by = %s
        ORDER BY c.created_at DESC
    """, [client[0]])
    
    complaints = cursor.fetchall()
    print(f"\n📋 Complaints: {len(complaints)}")
    for comp in complaints:
        print(f"   - {comp[1]}")
        print(f"     Status: {comp[2]} | Priority: {comp[3]}")
        print(f"     Site: {comp[5] or '(no site name)'}")
        print(f"     Created: {comp[4]}")
        
        # Check messages for this complaint
        cursor.execute("""
            SELECT COUNT(*) FROM complaint_messages
            WHERE complaint_id = %s
        """, [comp[0]])
        msg_count = cursor.fetchone()[0]
        print(f"     Messages: {msg_count}")
        print()

print("=" * 60)
