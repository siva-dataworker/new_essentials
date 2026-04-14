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
    
    # Get total count
    cursor.execute('SELECT COUNT(*) FROM notifications')
    total = cursor.fetchone()[0]
    print(f"\n📊 Total notifications in database: {total}")
    
    if total == 0:
        print("\n❌ No notifications found!")
        print("\nPossible reasons:")
        print("1. Django server not restarted after migration")
        print("2. Material not submitted outside allowed time")
        print("3. Flutter app not sending notification")
        print("4. Authentication error preventing notification creation")
    else:
        # Get recent notifications
        cursor.execute('''
            SELECT id, entry_type, message, actual_time, created_at, 
                   supervisor_name, site_name, is_read
            FROM notifications 
            ORDER BY created_at DESC 
            LIMIT 10
        ''')
        
        print(f"\n📋 Recent notifications:\n")
        for row in cursor.fetchall():
            status = "✅ Read" if row[7] else "🔔 Unread"
            print(f"{status} | {row[1].upper()}")
            print(f"   Site: {row[6]}")
            print(f"   Supervisor: {row[5]}")
            print(f"   Message: {row[2][:80]}...")
            print(f"   Time: {row[3]}")
            print(f"   Created: {row[4]}")
            print()
    
    cursor.close()
    conn.close()
    
except Exception as e:
    print(f"❌ Error: {e}")
