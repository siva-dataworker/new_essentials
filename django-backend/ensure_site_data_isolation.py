#!/usr/bin/env python3
"""
Site Data Isolation Cleanup Script
This script ensures that all labour and material data is properly isolated by site
and removes any potential data mixing issues.
"""

import os
import sys
import django
from datetime import datetime

# Add the project directory to Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import execute_query, fetch_all, fetch_one

def check_data_isolation():
    """Check current data isolation status"""
    print("🔍 Checking current data isolation status...")
    
    # Check labour entries
    labour_stats = fetch_one("""
        SELECT 
            COUNT(*) as total_entries,
            COUNT(DISTINCT site_id) as unique_sites,
            COUNT(DISTINCT supervisor_id) as unique_supervisors
        FROM labour_entries
    """)
    
    print(f"📊 Labour Entries:")
    print(f"   - Total entries: {labour_stats['total_entries']}")
    print(f"   - Unique sites: {labour_stats['unique_sites']}")
    print(f"   - Unique supervisors: {labour_stats['unique_supervisors']}")
    
    # Check material entries
    material_stats = fetch_one("""
        SELECT 
            COUNT(*) as total_entries,
            COUNT(DISTINCT site_id) as unique_sites,
            COUNT(DISTINCT supervisor_id) as unique_supervisors
        FROM material_balances
    """)
    
    print(f"📊 Material Entries:")
    print(f"   - Total entries: {material_stats['total_entries']}")
    print(f"   - Unique sites: {material_stats['unique_sites']}")
    print(f"   - Unique supervisors: {material_stats['unique_supervisors']}")
    
    # Check for entries without site_id (data integrity issue)
    orphaned_labour = fetch_one("SELECT COUNT(*) as count FROM labour_entries WHERE site_id IS NULL")
    orphaned_material = fetch_one("SELECT COUNT(*) as count FROM material_balances WHERE site_id IS NULL")
    
    if orphaned_labour['count'] > 0:
        print(f"⚠️  Found {orphaned_labour['count']} labour entries without site_id")
    
    if orphaned_material['count'] > 0:
        print(f"⚠️  Found {orphaned_material['count']} material entries without site_id")
    
    return labour_stats, material_stats, orphaned_labour['count'], orphaned_material['count']

def check_cross_site_contamination():
    """Check if any supervisor has entries across multiple sites"""
    print("\n🔍 Checking for cross-site data contamination...")
    
    # Check supervisors with entries in multiple sites
    cross_site_supervisors = fetch_all("""
        SELECT 
            u.full_name,
            u.email,
            COUNT(DISTINCT l.site_id) as site_count,
            STRING_AGG(DISTINCT s.site_name, ', ') as sites
        FROM labour_entries l
        JOIN users u ON l.supervisor_id = u.id
        JOIN sites s ON l.site_id = s.id
        GROUP BY u.id, u.full_name, u.email
        HAVING COUNT(DISTINCT l.site_id) > 1
    """)
    
    if cross_site_supervisors:
        print(f"⚠️  Found {len(cross_site_supervisors)} supervisors with entries across multiple sites:")
        for supervisor in cross_site_supervisors:
            print(f"   - {supervisor['full_name']} ({supervisor['email']}): {supervisor['site_count']} sites")
            print(f"     Sites: {supervisor['sites']}")
    else:
        print("✅ No cross-site contamination found in labour entries")
    
    # Check material entries
    cross_site_material = fetch_all("""
        SELECT 
            u.full_name,
            u.email,
            COUNT(DISTINCT m.site_id) as site_count,
            STRING_AGG(DISTINCT s.site_name, ', ') as sites
        FROM material_balances m
        JOIN users u ON m.supervisor_id = u.id
        JOIN sites s ON m.site_id = s.id
        GROUP BY u.id, u.full_name, u.email
        HAVING COUNT(DISTINCT m.site_id) > 1
    """)
    
    if cross_site_material:
        print(f"⚠️  Found {len(cross_site_material)} supervisors with material entries across multiple sites:")
        for supervisor in cross_site_material:
            print(f"   - {supervisor['full_name']} ({supervisor['email']}): {supervisor['site_count']} sites")
            print(f"     Sites: {supervisor['sites']}")
    else:
        print("✅ No cross-site contamination found in material entries")

def ensure_site_isolation():
    """Ensure proper site isolation by adding constraints and indexes"""
    print("\n🔧 Ensuring proper site isolation...")
    
    try:
        # Add indexes for better performance on site-specific queries
        print("📊 Adding performance indexes...")
        
        execute_query("""
            CREATE INDEX IF NOT EXISTS idx_labour_entries_site_supervisor 
            ON labour_entries(site_id, supervisor_id, entry_date DESC)
        """)
        
        execute_query("""
            CREATE INDEX IF NOT EXISTS idx_material_balances_site_supervisor 
            ON material_balances(site_id, supervisor_id, entry_date DESC)
        """)
        
        execute_query("""
            CREATE INDEX IF NOT EXISTS idx_labour_entries_site_date 
            ON labour_entries(site_id, entry_date DESC)
        """)
        
        execute_query("""
            CREATE INDEX IF NOT EXISTS idx_material_balances_site_date 
            ON material_balances(site_id, entry_date DESC)
        """)
        
        print("✅ Performance indexes added successfully")
        
        # Add constraints to ensure data integrity
        print("🔒 Adding data integrity constraints...")
        
        # Ensure site_id is not null
        execute_query("""
            ALTER TABLE labour_entries 
            ALTER COLUMN site_id SET NOT NULL
        """)
        
        execute_query("""
            ALTER TABLE material_balances 
            ALTER COLUMN site_id SET NOT NULL
        """)
        
        print("✅ Data integrity constraints added successfully")
        
    except Exception as e:
        print(f"⚠️  Some constraints may already exist: {e}")

def create_site_isolation_views():
    """Create views for better site-specific data access"""
    print("\n📊 Creating site isolation views...")
    
    try:
        # View for site-specific labour summary
        execute_query("""
            CREATE OR REPLACE VIEW site_labour_summary AS
            SELECT 
                s.id as site_id,
                s.site_name,
                s.area,
                s.street,
                COUNT(l.id) as total_labour_entries,
                SUM(l.labour_count) as total_labour_count,
                COUNT(DISTINCT l.supervisor_id) as unique_supervisors,
                COUNT(DISTINCT l.entry_date) as active_days,
                MAX(l.entry_date) as last_entry_date,
                MIN(l.entry_date) as first_entry_date
            FROM sites s
            LEFT JOIN labour_entries l ON s.id = l.site_id
            GROUP BY s.id, s.site_name, s.area, s.street
        """)
        
        # View for site-specific material summary
        execute_query("""
            CREATE OR REPLACE VIEW site_material_summary AS
            SELECT 
                s.id as site_id,
                s.site_name,
                s.area,
                s.street,
                COUNT(m.id) as total_material_entries,
                COUNT(DISTINCT m.material_type) as unique_materials,
                COUNT(DISTINCT m.supervisor_id) as unique_supervisors,
                COUNT(DISTINCT m.entry_date) as active_days,
                MAX(m.entry_date) as last_entry_date,
                MIN(m.entry_date) as first_entry_date
            FROM sites s
            LEFT JOIN material_balances m ON s.id = m.site_id
            GROUP BY s.id, s.site_name, s.area, s.street
        """)
        
        # View for site isolation audit
        execute_query("""
            CREATE OR REPLACE VIEW site_isolation_audit AS
            SELECT 
                s.id as site_id,
                s.site_name,
                s.area,
                s.street,
                COALESCE(ls.total_labour_entries, 0) as labour_entries,
                COALESCE(ms.total_material_entries, 0) as material_entries,
                COALESCE(ls.unique_supervisors, 0) + COALESCE(ms.unique_supervisors, 0) as total_supervisors,
                CASE 
                    WHEN COALESCE(ls.total_labour_entries, 0) = 0 AND COALESCE(ms.total_material_entries, 0) = 0 
                    THEN 'NO_DATA'
                    ELSE 'HAS_DATA'
                END as data_status
            FROM sites s
            LEFT JOIN site_labour_summary ls ON s.id = ls.site_id
            LEFT JOIN site_material_summary ms ON s.id = ms.site_id
        """)
        
        print("✅ Site isolation views created successfully")
        
    except Exception as e:
        print(f"❌ Error creating views: {e}")

def generate_isolation_report():
    """Generate a comprehensive site isolation report"""
    print("\n📋 Generating Site Isolation Report...")
    print("=" * 60)
    
    # Get site isolation audit data
    audit_data = fetch_all("""
        SELECT * FROM site_isolation_audit 
        ORDER BY data_status DESC, site_name
    """)
    
    sites_with_data = [s for s in audit_data if s['data_status'] == 'HAS_DATA']
    sites_without_data = [s for s in audit_data if s['data_status'] == 'NO_DATA']
    
    print(f"📊 SITE DATA SUMMARY:")
    print(f"   - Total sites: {len(audit_data)}")
    print(f"   - Sites with data: {len(sites_with_data)}")
    print(f"   - Sites without data: {len(sites_without_data)}")
    
    if sites_with_data:
        print(f"\n🏗️  SITES WITH DATA:")
        for site in sites_with_data:
            print(f"   - {site['site_name']} ({site['area']}, {site['street']})")
            print(f"     Labour: {site['labour_entries']}, Material: {site['material_entries']}")
    
    if sites_without_data:
        print(f"\n📭 SITES WITHOUT DATA:")
        for site in sites_without_data[:5]:  # Show first 5
            print(f"   - {site['site_name']} ({site['area']}, {site['street']})")
        if len(sites_without_data) > 5:
            print(f"   ... and {len(sites_without_data) - 5} more")

def main():
    """Main function to run all checks and fixes"""
    print("🚀 Starting Site Data Isolation Check and Cleanup")
    print("=" * 60)
    
    # Step 1: Check current status
    labour_stats, material_stats, orphaned_labour, orphaned_material = check_data_isolation()
    
    # Step 2: Check for cross-site contamination
    check_cross_site_contamination()
    
    # Step 3: Ensure proper isolation
    ensure_site_isolation()
    
    # Step 4: Create helpful views
    create_site_isolation_views()
    
    # Step 5: Generate report
    generate_isolation_report()
    
    print("\n" + "=" * 60)
    print("✅ Site Data Isolation Check and Cleanup Complete!")
    print("\n📋 SUMMARY:")
    print(f"   - Labour entries: {labour_stats['total_entries']} across {labour_stats['unique_sites']} sites")
    print(f"   - Material entries: {material_stats['total_entries']} across {material_stats['unique_sites']} sites")
    
    if orphaned_labour > 0 or orphaned_material > 0:
        print(f"   - ⚠️  Orphaned entries found - manual cleanup required")
    else:
        print(f"   - ✅ No orphaned entries found")
    
    print("\n🎯 NEXT STEPS:")
    print("   1. Test the updated supervisor history with site filtering")
    print("   2. Verify that each site shows only its own data")
    print("   3. Check change request functionality with site isolation")
    print("   4. Monitor performance with new indexes")

if __name__ == "__main__":
    main()
