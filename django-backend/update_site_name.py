import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.db import connection

with connection.cursor() as cursor:
    # Get client's site
    cursor.execute("""
        SELECT site_id FROM client_sites 
        WHERE client_id = (SELECT id FROM users WHERE username='sivu')
        LIMIT 1
    """)
    site = cursor.fetchone()
    
    if site:
        cursor.execute("""
            UPDATE sites 
            SET site_name = %s, customer_name = %s
            WHERE id = %s
        """, ['Test Construction Site', 'Test Customer', site[0]])
        print("✅ Site updated with name")
    else:
        print("❌ No site found")
