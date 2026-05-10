#!/usr/bin/env python
"""Apply area column migration to labour_salary_rates table"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import execute_query

print("🔧 Adding area column to labour_salary_rates table...")

try:
    # Add area column
    execute_query("""
        ALTER TABLE labour_salary_rates 
        ADD COLUMN IF NOT EXISTS area VARCHAR(255)
    """)
    print("✅ Area column added")
    
    # Add index for area
    execute_query("""
        CREATE INDEX IF NOT EXISTS idx_labour_salary_rates_area 
        ON labour_salary_rates(area)
    """)
    print("✅ Area index created")
    
    # Add composite index
    execute_query("""
        CREATE INDEX IF NOT EXISTS idx_labour_salary_rates_area_labour_type 
        ON labour_salary_rates(area, labour_type) 
        WHERE is_active = TRUE
    """)
    print("✅ Composite index created")
    
    print("\n✅ Migration completed successfully!")
    print("\nℹ️  The labour_salary_rates table now supports:")
    print("   - Global rates (area = NULL, site_id = NULL)")
    print("   - Area-specific rates (area = 'Area Name', site_id = NULL)")
    print("   - Site-specific rates (area = NULL, site_id = 'site_id')")
    
except Exception as e:
    print(f"❌ Migration failed: {e}")
