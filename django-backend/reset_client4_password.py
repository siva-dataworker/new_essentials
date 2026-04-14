"""
Reset client4 password to 'client4'
"""
import psycopg2
from psycopg2.extras import RealDictCursor
import os
from dotenv import load_dotenv
import sys
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.contrib.auth.hashers import make_password

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

print("\nResetting client4 password to 'client4'...")

# Hash the password
new_password_hash = make_password('client4')

# Update the password
cursor.execute("""
    UPDATE users
    SET password_hash = %s
    WHERE username = 'client4'
""", (new_password_hash,))

print("✅ Password reset successfully!")
print("   Username: client4")
print("   Password: client4")

cursor.close()
conn.close()
