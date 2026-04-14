#!/usr/bin/env python3
"""
Debug Client Photos Issue
Check what photos exist for client Anwar's site
"""

import os
import sys
import django

# Setup Django
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_one, fetch_all

def main():
    print("\n" + "="*60)
    print("  DEBUG: CLIENT PHOTOS FOR ANWAR")
    print("="*60)
    
    # Find client Anwar
    client = fetch_one("""
        SELECT u.id, u.username, u.full_name, r.role_name
        FROM users u
        JOIN roles r ON u.role_id = r.id
        WHERE LOWER(u.full_name) LIKE %s OR LOWER(u.username) LIKE %s
    """, ('%anwar%', '%anwar%'))
    
    if not client:
        print("\n❌ Client 'Anwar' not found")
        return
    
    print(f"\n✅ Found client:")
    print(f"   ID: {client['id']}")
    print(f"   Username: {client['username']}")
    print(f"   Full Name: {client['full_name']}")
    print(f"   Role: {client['role_name']}")
    
    # Get assigned sites
    sites = fetch_all("""
        SELECT 
            cs.site_id,
            s.site_name,
            s.customer_name,
            s.area,
            s.street
        FROM client_sites cs
        JOIN sites s ON cs.site_id = s.id
        WHERE cs.client_id = %s AND cs.is_active = TRUE
    """, (client['id'],))
    
    print(f"\n📍 Assigned sites: {len(sites)}")
    if not sites:
        print("   ⚠️  No sites assigned")
        return
    
    for site in sites:
        site_id = site['site_id']
        print(f"\n   Site: {site['customer_name']} {site['site_name']}")
        print(f"   Area: {site['area']}, Street: {site['street']}")
        print(f"   Site ID: {site_id}")
        
        # Check supervisor photos
        print(f"\n   📸 SUPERVISOR PHOTOS (site_photos table):")
        supervisor_photos = fetch_all("""
            SELECT 
                sp.id,
                sp.image_url,
                sp.time_of_day,
                sp.upload_date,
                sp.uploaded_by,
                u.full_name as uploaded_by_name
            FROM site_photos sp
            LEFT JOIN users u ON sp.uploaded_by = u.id
            WHERE sp.site_id = %s
            ORDER BY sp.upload_date DESC
        """, (site_id,))
        
        print(f"      Total: {len(supervisor_photos)}")
        if supervisor_photos:
            for photo in supervisor_photos[:10]:  # Show first 10
                print(f"      - {photo['upload_date']}: {photo['time_of_day']} by {photo['uploaded_by_name']}")
                print(f"        URL: {photo['image_url'][:80]}...")
        else:
            print("      ⚠️  No supervisor photos found")
        
        # Check site engineer photos
        print(f"\n   🔧 SITE ENGINEER PHOTOS (work_updates table):")
        engineer_photos = fetch_all("""
            SELECT 
                wu.id,
                wu.image_url,
                wu.update_type,
                wu.update_date,
                wu.engineer_id,
                u.full_name as engineer_name
            FROM work_updates wu
            LEFT JOIN users u ON wu.engineer_id = u.id
            WHERE wu.site_id = %s
            AND wu.update_type IN ('STARTED', 'FINISHED')
            ORDER BY wu.update_date DESC
        """, (site_id,))
        
        print(f"      Total: {len(engineer_photos)}")
        if engineer_photos:
            for photo in engineer_photos[:10]:  # Show first 10
                time_of_day = 'Morning' if photo['update_type'] == 'STARTED' else 'Evening'
                print(f"      - {photo['update_date']}: {time_of_day} ({photo['update_type']}) by {photo['engineer_name']}")
                print(f"        URL: {photo['image_url'][:80]}...")
        else:
            print("      ⚠️  No engineer photos found")
        
        # Check for March 27-28 specifically
        print(f"\n   🔍 MARCH 27-28, 2026 PHOTOS:")
        march_photos = fetch_all("""
            SELECT 
                sp.upload_date,
                sp.time_of_day,
                sp.image_url,
                u.full_name as uploaded_by
            FROM site_photos sp
            LEFT JOIN users u ON sp.uploaded_by = u.id
            WHERE sp.site_id = %s
            AND sp.upload_date BETWEEN '2026-03-27' AND '2026-03-28'
            ORDER BY sp.upload_date DESC, sp.time_of_day
        """, (site_id,))
        
        print(f"      Found: {len(march_photos)}")
        for photo in march_photos:
            print(f"      - {photo['upload_date']}: {photo['time_of_day']} by {photo['uploaded_by']}")
            print(f"        URL: {photo['image_url']}")
        
        # Check for January photos
        print(f"\n   🔍 JANUARY 2026 PHOTOS:")
        jan_photos = fetch_all("""
            SELECT 
                sp.upload_date,
                sp.time_of_day,
                sp.image_url,
                u.full_name as uploaded_by
            FROM site_photos sp
            LEFT JOIN users u ON sp.uploaded_by = u.id
            WHERE sp.site_id = %s
            AND sp.upload_date BETWEEN '2026-01-01' AND '2026-01-31'
            ORDER BY sp.upload_date DESC, sp.time_of_day
        """, (site_id,))
        
        print(f"      Found: {len(jan_photos)}")
        for photo in jan_photos:
            print(f"      - {photo['upload_date']}: {photo['time_of_day']} by {photo['uploaded_by']}")
    
    print("\n" + "="*60)

if __name__ == "__main__":
    main()
