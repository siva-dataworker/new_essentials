#!/usr/bin/env python
"""
Add test material usage data for client testing
"""
import os
import sys
import django
from datetime import datetime, timedelta
import uuid

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import execute_query, fetch_all, fetch_one

def add_test_materials():
    """Add test material usage data"""
    try:
        # Get the test site
        site = fetch_one("""
            SELECT id, site_name 
            FROM sites 
            WHERE site_name = 'Test Construction Site'
            LIMIT 1
        """)
        
        if not site:
            print("❌ Test Construction Site not found")
            return False
        
        site_id = site['id']
        print(f"✅ Found site: {site['site_name']} (ID: {site_id})")
        
        # Get a supervisor
        supervisor = fetch_one("""
            SELECT id, username 
            FROM users 
            WHERE role_id = 2
            LIMIT 1
        """)
        
        if not supervisor:
            print("❌ No supervisor found")
            return False
        
        supervisor_id = supervisor['id']
        print(f"✅ Found supervisor: {supervisor['username']} (ID: {supervisor_id})")
        
        # Delete existing test materials
        execute_query("""
            DELETE FROM material_usage WHERE site_id = %s
        """, (site_id,))
        print("🗑️  Cleared existing material data")
        
        # Add test material usage
        materials = [
            ('Cement', 50.0, 'bags', 5, 'Foundation work'),
            ('Cement', 30.0, 'bags', 3, 'Column work'),
            ('Sand', 100.0, 'cubic feet', 5, 'Foundation work'),
            ('Sand', 75.0, 'cubic feet', 2, 'Plastering'),
            ('Steel', 500.0, 'kg', 7, 'Reinforcement'),
            ('Steel', 300.0, 'kg', 4, 'Column reinforcement'),
            ('Brick', 2000.0, 'pieces', 6, 'Wall construction'),
            ('Brick', 1500.0, 'pieces', 1, 'Wall construction'),
            ('Gravel', 150.0, 'cubic feet', 5, 'Foundation work'),
        ]
        
        today = datetime.now().date()
        
        for material_type, quantity, unit, days_ago, notes in materials:
            usage_date = today - timedelta(days=days_ago)
            
            execute_query("""
                INSERT INTO material_usage 
                (id, site_id, material_type, quantity_used, unit, usage_date, supervisor_id, notes, created_at)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, (
                str(uuid.uuid4()),
                site_id,
                material_type,
                quantity,
                unit,
                usage_date,
                supervisor_id,
                notes,
                datetime.now()
            ))
        
        print(f"✅ Added {len(materials)} material usage records")
        
        # Verify the data
        summary = fetch_all("""
            SELECT 
                material_type,
                SUM(quantity_used) as total_used,
                unit,
                COUNT(*) as usage_count,
                MAX(usage_date) as last_used
            FROM material_usage
            WHERE site_id = %s
            GROUP BY material_type, unit
            ORDER BY material_type
        """, (site_id,))
        
        print("\n📊 Material Usage Summary:")
        print("-" * 70)
        for row in summary:
            print(f"  {row['material_type']:15} | {row['total_used']:8.1f} {row['unit']:15} | Used {row['usage_count']} times")
        print("-" * 70)
        
        return True
        
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == '__main__':
    print("=" * 70)
    print("Adding Test Material Usage Data")
    print("=" * 70)
    
    success = add_test_materials()
    
    if success:
        print("\n✅ Test material data added successfully!")
        print("\nYou can now:")
        print("1. Login as client (username: sivu, password: test123)")
        print("2. Go to Materials tab")
        print("3. See the material usage summary")
    else:
        print("\n❌ Failed to add test material data")
        sys.exit(1)
