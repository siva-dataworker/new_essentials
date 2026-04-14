import psycopg2
from dotenv import load_dotenv
import os

# Load environment variables
load_dotenv()

def run_migration():
    try:
        # Connect to database
        conn = psycopg2.connect(
            host=os.getenv('DB_HOST', 'localhost'),
            database=os.getenv('DB_NAME', 'construction_db'),
            user=os.getenv('DB_USER', 'postgres'),
            password=os.getenv('DB_PASSWORD', 'postgres'),
            port=os.getenv('DB_PORT', '5432')
        )
        
        cursor = conn.cursor()
        
        # Read and execute SQL file
        with open('create_notifications_system.sql', 'r') as f:
            sql = f.read()
            cursor.execute(sql)
        
        conn.commit()
        print("✅ Notifications system migration completed successfully!")
        
        # Verify table creation
        cursor.execute("""
            SELECT COUNT(*) FROM information_schema.tables 
            WHERE table_name = 'notifications'
        """)
        count = cursor.fetchone()[0]
        
        if count > 0:
            print("✅ Notifications table created successfully")
        else:
            print("❌ Notifications table not found")
        
        cursor.close()
        conn.close()
        
    except Exception as e:
        print(f"❌ Error running migration: {e}")
        raise

if __name__ == '__main__':
    run_migration()
