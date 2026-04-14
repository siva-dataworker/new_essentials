#!/usr/bin/env python3
"""Check for Basha and Anwar sites"""

import os
import sys
import django

sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.db import connection

def check_sites():
    with connection.cursor() as cursor:
        # Check all sites
        cursor.execute("""
            SELECT id, site_name, area, street, city 
            FROM sites 
            ORDER BY site_name
        """)
        
        print("=" * 60)
        print("ALL SITES IN DATABASE")
        print("=" * 60)
        
        sites = cursor.fetchall()
        for site in sites:
            site_id, name, area, street, city = site
            print(f"\nID: {site_id}")
            print(f"Name: {name}")
            print(f"Area: {area}")
            print(f"Street: {street}")
            print(f"City: {city}")
        
        print(f"\n{'=' * 60}")
        print(f"Total sites: {len(sites)}")
        print("=" * 60)
        
        # Search for Basha and Anwar
        print("\n" + "=" * 60)
        print("SEARCHING FOR 'BASHA' AND 'ANWAR'")
        print("=" * 60)
        
        cursor.execute("""
            SELECT id, site_name, area, street, city 
            FROM sites 
            WHERE LOWER(site_name) LIKE '%basha%' 
               OR LOWER(site_name) LIKE '%anwar%'
               OR LOWER(area) LIKE '%basha%'
               OR LOWER(area) LIKE '%anwar%'
               OR LOWER(street) LIKE '%basha%'
               OR LOWER(street) LIKE '%anwar%'
        """)
        
        matches = cursor.fetchall()
        if matches:
            print(f"\nFound {len(matches)} match(es):")
            for site in matches:
                site_id, name, area, street, city = site
                print(f"\nID: {site_id}")
                print(f"Name: {name}")
                print(f"Area: {area}")
                print(f"Street: {street}")
                print(f"City: {city}")
        else:
            print("\nNo sites found matching 'Basha' or 'Anwar'")
        
        # Check for NULL or empty site names
        print("\n" + "=" * 60)
        print("SITES WITH NULL OR EMPTY NAMES")
        print("=" * 60)
        
        cursor.execute("""
            SELECT id, site_name, area, street, city 
            FROM sites 
            WHERE site_name IS NULL OR site_name = ''
        """)
        
        empty_sites = cursor.fetchall()
        if empty_sites:
            print(f"\nFound {len(empty_sites)} site(s) with no name:")
            for site in empty_sites:
                site_id, name, area, street, city = site
                print(f"\nID: {site_id}")
                print(f"Name: '{name}'")
                print(f"Area: {area}")
                print(f"Street: {street}")
                print(f"City: {city}")
        else:
            print("\nAll sites have names")

if __name__ == '__main__':
    check_sites()
