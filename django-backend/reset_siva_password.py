import os
import django
import psycopg

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.contrib.auth.hashers import make_password

# Connect to database
conn = psycopg.connect(
    host='db.ctwthgjuccioxivnzifb.supabase.co',
    port=5432,
    dbname='postgres',
    user='postgres',
    password='Appdevlopment@2026',
    sslmode='require'
)

cur = conn.cursor()

# Hash the password
password_hash = make_password('Test123')

# Update Siva's password
cur.execute("""
    UPDATE users 
    SET password_hash = %s 
    WHERE username = 'Siva'
""", (password_hash,))

conn.commit()

print(f"✅ Password updated for Siva")
print(f"Username: Siva")
print(f"Password: Test123")

cur.close()
conn.close()
