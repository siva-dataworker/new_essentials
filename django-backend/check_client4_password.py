"""
Check client4 details and test password
"""
import psycopg2
from psycopg2.extras import RealDictCursor
import os
from dotenv import load_dotenv
from django.contrib.auth.hashers import check_password

load_dotenv()

conn = psycopg2.connect(
    dbname=os.getenv('DB_NAME', 'construction_db'),
    user=os.getenv('DB_USER', 'postgres'),
    password=os.getenv('DB_PASSWORD', 'postgres'),
    host=os.getenv('DB_HOST', 'localhost'),
    port=os.getenv('DB_PORT', '5432')
)
cursor = conn.cursor(cursor_factory=RealDictCursor)

print("\nChecking client4...")
cursor.execute("""
    SELECT u.id, u.username, u.email, u.password_hash, u.status, u.is_active, r.role_name
    FROM users u
    LEFT JOIN roles r ON u.role_id = r.id
    WHERE u.username = 'client4'
""")
client4 = cursor.fetchone()

if client4:
    print(f"✅ Found client4:")
    print(f"   Username: {client4['username']}")
    print(f"   Email: {client4['email']}")
    print(f"   Role: {client4['role_name']}")
    print(f"   Status: {client4['status']}")
    print(f"   Active: {client4['is_active']}")
    print(f"   Password hash: {client4['password_hash'][:50]}...")
    
    # Try common passwords
    test_passwords = ['client4', 'password', '123456', 'client4@123']
    print(f"\nTesting passwords...")
    for pwd in test_passwords:
        if check_password(pwd, client4['password_hash']):
            print(f"   ✅ Password is: '{pwd}'")
            break
    else:
        print(f"   ❌ None of the common passwords work")
        print(f"   You may need to reset the password")
else:
    print("❌ client4 not found")

cursor.close()
conn.close()
