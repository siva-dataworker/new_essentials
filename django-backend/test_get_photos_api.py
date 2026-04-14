#!/usr/bin/env python
"""
Test the GET photos API endpoint
"""

import os
import sys
import django

# Setup Django environment
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all

def test_api():
    """Test the GET photos API logic"""
    
    print("=" * 60)
    print("Testing GET Photos API")
    print("=" * 60)
    print()
    
    # Get a site_id and user_id from the database
    from django.db import connection
    
    with connection.cursor() as cursor:
        # Get the photo we just uploaded
        cursor.execute("""
            SELECT 
                site_id,
                uploaded_by
            FROM site_photos
            LIMIT 1
        """)
        
        result = cursor.fetchone()
        
        if not result:
            print("❌ No photos found in database")
            return
        
        site_id, user_id = result
        
        print(f"Testing with:")
        print(f"  Site ID: {site_id}")
        print(f"  User ID: {user_id}")
        print()
        
        # Test the query that the API uses
        photos = fetch_all("""
            SELECT 
                id,
                site_id,
                image_url,
                upload_date,
                time_of_day,
                description
            FROM site_photos
            WHERE site_id = %s AND uploaded_by = %s
            ORDER BY upload_date DESC, time_of_day DESC
        """, (site_id, user_id))
        
        print(f"Query returned {len(photos)} photo(s)")
        print()
        
        if photos:
            print("Photos found:")
            print("-" * 60)
            for photo in photos:
                print(f"  ID: {photo['id']}")
                print(f"  Site ID: {photo['site_id']}")
                print(f"  Image URL: {photo['image_url']}")
                print(f"  Upload Date: {photo['upload_date']}")
                print(f"  Time of Day: {photo['time_of_day']}")
                print(f"  Description: {photo['description']}")
                print()
        else:
            print("❌ No photos returned by query")
            print()
            print("This means the API query is not matching the data")

if __name__ == '__main__':
    test_api()
