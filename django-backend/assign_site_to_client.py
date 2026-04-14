import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.db import connection

with connection.cursor() as cursor:
    # Get client
    cursor.execute("SELECT id, username FROM users WHERE username='sivu'")
    client = cursor.fetchone()
    
    if not client:
        print("❌ Client 'sivu' not found")
        exit(1)
    
    # Get a site
    cursor.execute("SELECT id, site_name FROM sites LIMIT 1")
    site = cursor.fetchone()
    
    if not site:
        print("❌ No sites found")
        exit(1)
    
    # Assign site to client
    cursor.execute("""
        INSERT INTO client_sites (client_id, site_id, assigned_date, is_active)
        VALUES (%s, %s, CURRENT_TIMESTAMP, TRUE)
        ON CONFLICT DO NOTHING
    """, [client[0], site[0]])
    
    print(f"✅ Assigned site '{site[1]}' to client '{client[1]}'")
