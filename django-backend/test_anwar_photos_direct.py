#!/usr/bin/env python3
"""
Direct test of photos API for Anwar's site
"""

import os
import sys
import django

# Setup Django
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_one, fetch_all
from django.conf import settings

def main():
    print("\n" + "="*60)
    print("  DIRECT API TEST FOR ANWAR'S PHOTOS")
    print("="*60)
    
    # Get Anwar's site
    site_id = '3ae88295-427b-49f6-8e50-4c02d0250617'
    
    print(f"\nSite ID: {site_id}")
    print(f"Media URL: {settings.MEDIA_URL}")
    
    # Get supervisor photos
    print(f"\n📸 SUPERVISOR PHOTOS:")
    supervisor_photos = fetch_all("""
        SELECT 
            sp.id,
            sp.image_url as photo_url,
            sp.time_of_day,
            sp.description,
            sp.upload_date as uploaded_date,
            u.full_name as uploaded_by,
            'Supervisor' as uploaded_by_role
        FROM site_photos sp
        LEFT JOIN users u ON sp.uploaded_by = u.id
        WHERE sp.site_id = %s
        ORDER BY sp.upload_date DESC, sp.time_of_day
    """, (site_id,))
    
    print(f"   Found: {len(supervisor_photos)}")
    for photo in supervisor_photos:
        photo_url = photo['photo_url']
        # Don't prepend MEDIA_URL if photo_url already starts with /media/ or is full URL
        if photo_url.startswith('http'):
            full_url = photo_url
        elif photo_url.startswith('/media/'):
            full_url = photo_url  # Already has /media/ prefix
        elif photo_url.startswith('/'):
            full_url = photo_url
        else:
            full_url = f"{settings.MEDIA_URL}{photo_url}"
        
        print(f"\n   Date: {photo['uploaded_date']}")
        print(f"   Time: {photo['time_of_day']}")
        print(f"   By: {photo['uploaded_by']}")
        print(f"   Raw URL: {photo_url}")
        print(f"   Full URL: {full_url}")
    
    # Get engineer photos
    print(f"\n🔧 SITE ENGINEER PHOTOS:")
    engineer_photos = fetch_all("""
        SELECT 
            wu.id,
            wu.image_url as photo_url,
            CASE 
                WHEN wu.update_type = 'STARTED' THEN 'Morning'
                WHEN wu.update_type = 'FINISHED' THEN 'Evening'
                ELSE wu.update_type
            END as time_of_day,
            wu.description,
            wu.update_date as uploaded_date,
            '' as day_of_week,
            u.full_name as uploaded_by,
            'Site Engineer' as uploaded_by_role
        FROM work_updates wu
        LEFT JOIN users u ON wu.engineer_id = u.id
        WHERE wu.site_id = %s
        AND wu.update_type IN ('STARTED', 'FINISHED')
        ORDER BY wu.update_date DESC, wu.update_type
    """, (site_id,))
    
    print(f"   Found: {len(engineer_photos)}")
    for photo in engineer_photos:
        photo_url = photo['photo_url']
        # Don't prepend MEDIA_URL if photo_url already starts with /media/ or is full URL
        if photo_url.startswith('http'):
            full_url = photo_url
        elif photo_url.startswith('/media/'):
            full_url = photo_url  # Already has /media/ prefix
        elif photo_url.startswith('/'):
            full_url = photo_url
        else:
            full_url = f"{settings.MEDIA_URL}{photo_url}"
        
        print(f"\n   Date: {photo['uploaded_date']}")
        print(f"   Time: {photo['time_of_day']}")
        print(f"   By: {photo['uploaded_by']}")
        print(f"   Raw URL: {photo_url}")
        print(f"   Full URL: {full_url}")
    
    # Combine and group
    print(f"\n📊 COMBINED RESULTS:")
    all_photos = []
    
    for photo in supervisor_photos:
        photo_url = photo['photo_url']
        # Don't prepend MEDIA_URL if photo_url already starts with /media/ or is full URL
        if photo_url.startswith('http'):
            full_url = photo_url
        elif photo_url.startswith('/media/'):
            full_url = photo_url  # Already has /media/ prefix
        elif photo_url.startswith('/'):
            full_url = photo_url
        else:
            full_url = f"{settings.MEDIA_URL}{photo_url}"
        
        all_photos.append({
            'uploaded_date': photo['uploaded_date'].strftime('%Y-%m-%d'),
            'time_of_day': photo['time_of_day'],
            'uploaded_by': photo['uploaded_by'],
            'uploaded_by_role': photo['uploaded_by_role'],
            'photo_url': full_url,
        })
    
    for photo in engineer_photos:
        photo_url = photo['photo_url']
        # Don't prepend MEDIA_URL if photo_url already starts with /media/ or is full URL
        if photo_url.startswith('http'):
            full_url = photo_url
        elif photo_url.startswith('/media/'):
            full_url = photo_url  # Already has /media/ prefix
        elif photo_url.startswith('/'):
            full_url = photo_url
        else:
            full_url = f"{settings.MEDIA_URL}{photo_url}"
        
        all_photos.append({
            'uploaded_date': photo['uploaded_date'].strftime('%Y-%m-%d'),
            'time_of_day': photo['time_of_day'],
            'uploaded_by': photo['uploaded_by'],
            'uploaded_by_role': photo['uploaded_by_role'],
            'photo_url': full_url,
        })
    
    # Group by date
    photos_by_date = {}
    for photo in all_photos:
        date = photo['uploaded_date']
        if date not in photos_by_date:
            photos_by_date[date] = []
        photos_by_date[date].append(photo)
    
    print(f"   Total photos: {len(all_photos)}")
    print(f"   Unique dates: {len(photos_by_date)}")
    
    print(f"\n📅 PHOTOS BY DATE:")
    for date in sorted(photos_by_date.keys(), reverse=True):
        photos = photos_by_date[date]
        print(f"\n   {date}: {len(photos)} photos")
        for photo in photos:
            print(f"      - {photo['time_of_day']}: {photo['uploaded_by']} ({photo['uploaded_by_role']})")
            print(f"        URL: {photo['photo_url']}")
    
    print("\n" + "="*60)

if __name__ == "__main__":
    main()
