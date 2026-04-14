"""
Add sample sites data to database
"""
import os
import sys
import django
from pathlib import Path

# Add the project directory to the Python path
BASE_DIR = Path(__file__).resolve().parent
sys.path.append(str(BASE_DIR))

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import execute_query, fetch_all

def add_sample_sites():
    """Add sample areas, streets, and sites"""
    print("\n" + "="*60)
    print("ADDING SAMPLE SITES DATA")
    print("="*60 + "\n")
    
    # Sample data structure
    areas_data = [
        {
            'name': 'Kasakudy',
            'streets': [
                {
                    'name': 'Saudha Garden',
                    'sites': [
                        'Sumaya 1 18 Sasikumar',
                        'Rahman 2 20 Abdul',
                        'Fathima 3 15 Mohammed'
                    ]
                },
                {
                    'name': 'Lakshmi Nagar',
                    'sites': [
                        'Kumar 4 25 Rajesh',
                        'Priya 5 18 Suresh'
                    ]
                }
            ]
        },
        {
            'name': 'Thiruvettakudy',
            'streets': [
                {
                    'name': 'Gandhi Street',
                    'sites': [
                        'Anwar 6 22 Ibrahim',
                        'Selvi 7 20 Murugan'
                    ]
                },
                {
                    'name': 'Beach Road',
                    'sites': [
                        'Ravi 8 30 Krishnan',
                        'Meena 9 18 Ganesh'
                    ]
                }
            ]
        },
        {
            'name': 'Karaikal',
            'streets': [
                {
                    'name': 'Main Road',
                    'sites': [
                        'Basha 10 25 Karim',
                        'Lakshmi 11 20 Venkat'
                    ]
                },
                {
                    'name': 'Temple Street',
                    'sites': [
                        'Arjun 12 22 Prakash',
                        'Divya 13 18 Ramesh'
                    ]
                }
            ]
        }
    ]
    
    # Check if data already exists
    existing_sites = fetch_all("SELECT COUNT(*) as count FROM sites")
    if existing_sites and existing_sites[0]['count'] > 0:
        print(f"⚠️  Database already has {existing_sites[0]['count']} sites")
        response = input("Do you want to add more sites? (yes/no): ").strip().lower()
        if response != 'yes':
            print("Cancelled.")
            return
    
    total_sites = 0
    
    for area_data in areas_data:
        area_name = area_data['name']
        
        # Insert area
        execute_query(
            "INSERT INTO sites (area, street, site_name, customer_name) VALUES (%s, %s, %s, %s) ON CONFLICT DO NOTHING",
            (area_name, '', '', '')  # Dummy entry to create area
        )
        
        print(f"📍 Area: {area_name}")
        
        for street_data in area_data['streets']:
            street_name = street_data['name']
            print(f"  📍 Street: {street_name}")
            
            for site_full in street_data['sites']:
                # Parse site: "Sumaya 1 18 Sasikumar" -> customer_name="Sumaya", site_name="1 18 Sasikumar"
                parts = site_full.split(' ', 1)
                customer_name = parts[0] if len(parts) > 0 else site_full
                site_name = parts[1] if len(parts) > 1 else ''
                
                execute_query("""
                    INSERT INTO sites (area, street, site_name, customer_name)
                    VALUES (%s, %s, %s, %s)
                """, (area_name, street_name, site_name, customer_name))
                
                print(f"    ✅ Site: {customer_name} - {site_name}")
                total_sites += 1
    
    print("\n" + "="*60)
    print(f"✅ Added {total_sites} sites successfully!")
    print("="*60)
    
    # Show summary
    print("\nSummary:")
    areas = fetch_all("SELECT DISTINCT area FROM sites WHERE area != '' ORDER BY area")
    for area in areas:
        area_name = area['area']
        streets = fetch_all(
            "SELECT DISTINCT street FROM sites WHERE area = %s AND street != '' ORDER BY street",
            (area_name,)
        )
        print(f"\n📍 {area_name} ({len(streets)} streets)")
        for street in streets:
            street_name = street['street']
            sites = fetch_all(
                "SELECT customer_name, site_name FROM sites WHERE area = %s AND street = %s",
                (area_name, street_name)
            )
            print(f"  📍 {street_name} ({len(sites)} sites)")
            for site in sites:
                print(f"    - {site['customer_name']} {site['site_name']}")
    
    print("\n" + "="*60 + "\n")

if __name__ == '__main__':
    add_sample_sites()
