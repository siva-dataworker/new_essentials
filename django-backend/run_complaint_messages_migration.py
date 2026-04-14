import psycopg2
import os

# Database connection
conn = psycopg2.connect(
    dbname="construction_management",
    user="postgres",
    password="admin",
    host="localhost",
    port="5432"
)

try:
    cursor = conn.cursor()
    
    # Read and execute SQL file
    with open('add_complaint_messages_table.sql', 'r') as f:
        sql = f.read()
        cursor.execute(sql)
    
    conn.commit()
    print("✅ complaint_messages table created successfully!")
    
    # Verify table exists
    cursor.execute("""
        SELECT column_name, data_type 
        FROM information_schema.columns 
        WHERE table_name = 'complaint_messages'
        ORDER BY ordinal_position
    """)
    
    print("\n📋 Table structure:")
    for row in cursor.fetchall():
        print(f"   - {row[0]}: {row[1]}")
    
    cursor.close()
    
except Exception as e:
    print(f"❌ Error: {e}")
    conn.rollback()
finally:
    conn.close()
