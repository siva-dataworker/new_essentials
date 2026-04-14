import psycopg
import os
from dotenv import load_dotenv

load_dotenv()

# Get credentials from .env
db_name = os.getenv('DB_NAME')
db_user = os.getenv('DB_USER')
db_password = os.getenv('DB_PASSWORD')
db_host = os.getenv('DB_HOST')
db_port = os.getenv('DB_PORT')

print("Testing database connection...")
print(f"Host: {db_host}")
print(f"Port: {db_port}")
print(f"User: {db_user}")
print(f"Database: {db_name}")
print()

try:
    conn = psycopg.connect(
        dbname=db_name,
        user=db_user,
        password=db_password,
        host=db_host,
        port=db_port
    )
    print("✅ Connection successful!")
    conn.close()
except Exception as e:
    print(f"❌ Connection failed: {e}")
    print()
    print("SOLUTION:")
    print("1. Go to https://supabase.com/dashboard")
    print("2. Select your project")
    print("3. Go to Settings → Database")
    print("4. Copy the connection string")
    print("5. Update django-backend/.env with correct credentials")
