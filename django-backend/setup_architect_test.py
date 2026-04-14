import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.db import connection
from django.contrib.auth.hashers import make_password

with connection.cursor() as cursor:
    # Create architect user if doesn't exist
    cursor.execute("SELECT id FROM users WHERE username='architect_test'")
    architect = cursor.fetchone()
    
    if not architect:
        # Hash password using Django's hasher
        password = "test123"
        hashed = make_password(password)
        
        cursor.execute("""
            INSERT INTO users (username, password, full_name, role_id, is_active)
            VALUES ('architect_test', %s, 'Test Architect', 6, TRUE)
            RETURNING id
        """, [hashed])
        architect_id = cursor.fetchone()[0]
        print(f"✅ Created architect user: architect_test")
    else:
        architect_id = architect[0]
        print(f"✅ Architect user exists: architect_test")
    
    # Update the test complaint to be assigned to this architect
    cursor.execute("""
        UPDATE complaints
        SET assigned_to = %s
        WHERE title = 'Water Leakage in Bathroom'
        RETURNING id, title
    """, [architect_id])
    
    complaint = cursor.fetchone()
    if complaint:
        print(f"✅ Assigned complaint '{complaint[1]}' to architect")
    
    print("\n📝 Test Credentials:")
    print("   Username: architect_test")
    print("   Password: test123")
