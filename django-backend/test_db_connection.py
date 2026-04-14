"""
Test database connection with current credentials
"""
import psycopg2
from decouple import config

print("Testing database connection...")
print("-" * 50)

# Get credentials from .env
db_name = config('DB_NAME', default='postgres')
db_user = config('DB_USER')
db_password = config('DB_PASSWORD')
db_host = config('DB_HOST')
db_port = config('DB_PORT', default='5432')

print(f"DB_NAME: {db_name}")
print(f"DB_USER: {db_user}")
print(f"DB_PASSWORD: {'*' * len(db_password)}")
print(f"DB_HOST: {db_host}")
print(f"DB_PORT: {db_port}")
print("-" * 50)

try:
    # Attempt connection
    conn = psycopg2.connect(
        dbname=db_name,
        user=db_user,
        password=db_password,
        host=db_host,
        port=db_port,
        sslmode='require'
    )
    
    print("✅ CONNECTION SUCCESSFUL!")
    
    # Test query
    cursor = conn.cursor()
    cursor.execute("SELECT version();")
    db_version = cursor.fetchone()
    print(f"\n✅ Database Version: {db_version[0]}")
    
    # Check tables
    cursor.execute("""
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
        ORDER BY table_name;
    """)
    tables = cursor.fetchall()
    print(f"\n✅ Found {len(tables)} tables in database")
    print("\nTables:")
    for table in tables[:10]:  # Show first 10 tables
        print(f"  - {table[0]}")
    if len(tables) > 10:
        print(f"  ... and {len(tables) - 10} more tables")
    
    cursor.close()
    conn.close()
    
    print("\n" + "=" * 50)
    print("✅ ALL CREDENTIALS ARE CORRECT!")
    print("=" * 50)
    
except psycopg2.OperationalError as e:
    print("\n❌ CONNECTION FAILED!")
    print(f"Error: {e}")
    print("\nPossible issues:")
    print("1. Wrong password")
    print("2. Wrong host/IP address")
    print("3. Database not accessible")
    print("4. Firewall blocking connection")
    
except Exception as e:
    print(f"\n❌ ERROR: {e}")
