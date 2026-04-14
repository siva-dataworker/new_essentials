#!/usr/bin/env python3
"""
Run architect tables migration
"""
import psycopg2
from dotenv import load_dotenv
import os

# Load environment variables
load_dotenv()

# Database connection
conn = psycopg2.connect(
    host=os.getenv('DB_HOST'),
    port=os.getenv('DB_PORT', 5432),
    database=os.getenv('DB_NAME'),
    user=os.getenv('DB_USER'),
    password=os.getenv('DB_PASSWORD')
)

try:
    cursor = conn.cursor()
    
    # Read and execute SQL file
    with open('add_architect_tables.sql', 'r') as f:
        sql = f.read()
        cursor.execute(sql)
    
    conn.commit()
    print("✅ Architect tables migration completed successfully!")
    print("   - project_files table created")
    print("   - notifications table created")
    print("   - complaints table updated")
    print("   - Indexes created")
    
except Exception as e:
    conn.rollback()
    print(f"❌ Error: {e}")
finally:
    cursor.close()
    conn.close()
