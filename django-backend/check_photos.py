#!/usr/bin/env python
"""
Script to check if photos are being stored in the database
"""

import os
import sys
import django

# Setup Django environment
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.db import connection

def check_photos():
    """Check photos in database"""
    
    print("=" * 60)
    print("Checking Site Photos in Database")
    print("=" * 60)
    print()
    
    with connection.cursor() as cursor:
        # Check if table exists
        cursor.execute("""
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public' 
            AND table_name = 'site_photos'
        """)
        
        table_exists = cursor.fetchone()
        
        if not table_exists:
            print("❌ ERROR: site_photos table does not exist!")
            print()
            print("The table needs to be created. Check if the migration was run.")
            return
        
        print("✓ site_photos table exists")
        print()
        
        # Count total photos
        cursor.execute("SELECT COUNT(*) FROM site_photos")
        total = cursor.fetchone()[0]
        
        print(f"Total photos in database: {total}")
        print()
        
        if total == 0:
            print("⚠️  No photos found in database")
            print()
            print("Possible reasons:")
            print("1. Photos haven't been uploaded yet")
            print("2. Upload API is failing")
            print("3. Check Django logs for errors")
            return
        
        # Show photos grouped by time_of_day
        cursor.execute("""
            SELECT 
                time_of_day,
                COUNT(*) as count,
                MAX(upload_date) as latest_date
            FROM site_photos
            GROUP BY time_of_day
            ORDER BY time_of_day
        """)
        
        print("Photos by time of day:")
        print("-" * 60)
        for row in cursor.fetchall():
            time_of_day, count, latest_date = row
            print(f"  {time_of_day}: {count} photos (latest: {latest_date})")
        print()
        
        # Show recent photos
        cursor.execute("""
            SELECT 
                id,
                site_id,
                image_url,
                upload_date,
                time_of_day,
                created_at
            FROM site_photos
            ORDER BY created_at DESC
            LIMIT 10
        """)
        
        print("Recent photos (last 10):")
        print("-" * 60)
        columns = [col[0] for col in cursor.description]
        
        for row in cursor.fetchall():
            print(f"  ID: {row[0]}")
            print(f"  Site ID: {row[1]}")
            print(f"  Image URL: {row[2]}")
            print(f"  Upload Date: {row[3]}")
            print(f"  Time of Day: {row[4]}")
            print(f"  Created At: {row[5]}")
            print()

if __name__ == '__main__':
    check_photos()
