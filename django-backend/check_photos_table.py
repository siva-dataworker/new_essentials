"""
Check site_photos table
"""
import psycopg2
from psycopg2.extras import RealDictCursor
import os
from dotenv import load_dotenv

load_dotenv()

conn = psycopg2.connect(
    dbname=os.getenv('DB_NAME', 'construction_db'),
    user=os.getenv('DB_USER', 'postgres'),
    password=os.getenv('DB_PASSWORD', 'postgres'),
    host=os.getenv('DB_HOST', 'localhost'),
    port=os.getenv('DB_PORT', '5432')
)
cursor = conn.cursor(cursor_factory=RealDictCursor)

# Check if table exists
cursor.execute("""
    SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_name = 'site_photos'
    );
""")
exists = cursor.fetchone()['exists']
print(f"site_photos table exists: {exists}")

if exists:
    # Get table structure
    cursor.execute("""
        SELECT column_name, data_type 
        FROM information_schema.columns 
        WHERE table_name = 'site_photos'
        ORDER BY ordinal_position;
    """)
    columns = cursor.fetchall()
    print("\nTable columns:")
    for col in columns:
        print(f"  - {col['column_name']}: {col['data_type']}")
    
    # Count photos
    cursor.execute("SELECT COUNT(*) as count FROM site_photos")
    count = cursor.fetchone()['count']
    print(f"\nTotal photos: {count}")
    
    # Get sample photos for client4's site
    site_id = '3ae88295-427b-49f6-8e50-4c02d0250617'
    cursor.execute("""
        SELECT * FROM site_photos 
        WHERE site_id = %s 
        LIMIT 5
    """, (site_id,))
    photos = cursor.fetchall()
    print(f"\nPhotos for client4's site: {len(photos)}")
    for photo in photos:
        print(f"  - {photo}")

cursor.close()
conn.close()
