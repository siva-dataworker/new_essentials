import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.db import connection

with connection.cursor() as cursor:
    # Get client 'sivu'
    cursor.execute("SELECT id, username FROM users WHERE username='sivu'")
    client = cursor.fetchone()
    
    if not client:
        print("❌ Client 'sivu' not found")
        exit(1)
    
    # Get client's assigned site
    cursor.execute("""
        SELECT cs.site_id, s.site_name 
        FROM client_sites cs
        JOIN sites s ON cs.site_id = s.id
        WHERE cs.client_id = %s AND cs.is_active = TRUE
        LIMIT 1
    """, [client[0]])
    
    site = cursor.fetchone()
    
    if not site:
        print("❌ No site assigned to client")
        exit(1)
    
    print(f"📍 Client: {client[1]}")
    print(f"📍 Site: {site[1]}")
    
    # Get architect to assign complaint to
    cursor.execute("SELECT id FROM users WHERE role_id = 6 AND is_active = TRUE LIMIT 1")
    architect = cursor.fetchone()
    assigned_to = architect[0] if architect else None
    
    # Create test complaint
    cursor.execute("""
        INSERT INTO complaints (
            site_id,
            raised_by,
            assigned_to,
            title,
            description,
            status,
            priority,
            created_at
        ) VALUES (%s, %s, %s, %s, %s, 'OPEN', %s, CURRENT_TIMESTAMP)
        RETURNING id, title, priority, status
    """, [
        site[0],
        client[0],
        assigned_to,
        "Water Leakage in Bathroom",
        "There is water leaking from the bathroom ceiling. It started yesterday and is getting worse. Please send someone to check urgently.",
        "HIGH"
    ])
    
    complaint = cursor.fetchone()
    
    print(f"\n✅ Test complaint created!")
    print(f"   ID: {complaint[0]}")
    print(f"   Title: {complaint[1]}")
    print(f"   Priority: {complaint[2]}")
    print(f"   Status: {complaint[3]}")
    
    # Add a response message from architect
    if assigned_to:
        cursor.execute("""
            INSERT INTO complaint_messages (
                complaint_id,
                sender_id,
                message,
                created_at
            ) VALUES (%s, %s, %s, CURRENT_TIMESTAMP)
        """, [
            complaint[0],
            assigned_to,
            "We have received your complaint. Our team will visit the site tomorrow morning to inspect the issue."
        ])
        print(f"\n💬 Added response message from architect")
    
    print("\n🎉 Test data created successfully!")
    print("\n📱 Now open the Flutter app and:")
    print("   1. Login as client (username: sivu, password: test123)")
    print("   2. Go to Issues tab")
    print("   3. You should see the complaint")
    print("   4. Tap on it to see the chat with architect's response")
