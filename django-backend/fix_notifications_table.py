import psycopg2
from dotenv import load_dotenv
import os

load_dotenv()

try:
    conn = psycopg2.connect(
        host=os.getenv('DB_HOST', 'localhost'),
        database=os.getenv('DB_NAME', 'construction_db'),
        user=os.getenv('DB_USER', 'postgres'),
        password=os.getenv('DB_PASSWORD', 'postgres'),
        port=os.getenv('DB_PORT', '5432')
    )
    
    cursor = conn.cursor()
    
    # Check if notifications table exists
    cursor.execute("""
        SELECT EXISTS (
            SELECT FROM information_schema.tables 
            WHERE table_name = 'notifications'
        )
    """)
    exists = cursor.fetchone()[0]
    
    if exists:
        print("Notifications table exists. Checking structure...")
        cursor.execute("""
            SELECT column_name, data_type 
            FROM information_schema.columns 
            WHERE table_name = 'notifications' 
            ORDER BY ordinal_position
        """)
        print("Current columns:")
        for row in cursor.fetchall():
            print(f"  {row[0]}: {row[1]}")
        
        # Drop the table
        print("\nDropping existing notifications table...")
        cursor.execute("DROP TABLE IF EXISTS notifications CASCADE")
        conn.commit()
        print("✅ Table dropped successfully")
    else:
        print("Notifications table does not exist yet")
    
    cursor.close()
    conn.close()
    
except Exception as e:
    print(f"❌ Error: {e}")
