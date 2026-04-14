import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.db import connection

try:
    with connection.cursor() as cursor:
        # Read and execute SQL file
        with open('add_complaint_messages_table.sql', 'r') as f:
            sql = f.read()
            cursor.execute(sql)
    
    print("✅ complaint_messages table created successfully!")
    
    # Verify table exists
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT column_name, data_type 
            FROM information_schema.columns 
            WHERE table_name = 'complaint_messages'
            ORDER BY ordinal_position
        """)
        
        print("\n📋 Table structure:")
        for row in cursor.fetchall():
            print(f"   - {row[0]}: {row[1]}")
    
except Exception as e:
    print(f"❌ Error: {e}")
    import traceback
    traceback.print_exc()
