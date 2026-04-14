#!/usr/bin/env python3
"""
Enhanced Budget Management Schema Migration
Adds project quote management, cost breakdown, and financial timeline
"""

import os
import sys
import django
import psycopg2
from pathlib import Path

# Setup Django environment
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.conf import settings

def run_migration():
    """Execute the enhanced budget schema migration"""
    
    # Get database connection details from Django settings
    db_settings = settings.DATABASES['default']
    
    print("=" * 60)
    print("Enhanced Budget Management Schema Migration")
    print("=" * 60)
    print()
    
    try:
        # Connect to database
        print("Connecting to database...")
        conn = psycopg2.connect(
            dbname=db_settings['NAME'],
            user=db_settings['USER'],
            password=db_settings['PASSWORD'],
            host=db_settings['HOST'],
            port=db_settings['PORT']
        )
        conn.autocommit = False
        cursor = conn.cursor()
        print("✓ Connected successfully")
        print()
        
        # Read SQL file
        sql_file = Path(__file__).parent / 'enhance_budget_schema.sql'
        print(f"Reading SQL file: {sql_file}")
        
        with open(sql_file, 'r') as f:
            sql_script = f.read()
        
        print("✓ SQL file loaded")
        print()
        
        # Execute migration
        print("Executing migration...")
        print("-" * 60)
        
        cursor.execute(sql_script)
        
        print("-" * 60)
        print()
        
        # Commit transaction
        conn.commit()
        print("✓ Migration committed successfully")
        print()
        
        # Verify tables
        print("Verifying enhanced schema...")
        
        tables_to_check = [
            'site_budgets',
            'extra_cost_requests',
            'financial_timeline',
            'budget_mismatch_alerts'
        ]
        
        for table in tables_to_check:
            cursor.execute(f"""
                SELECT EXISTS (
                    SELECT 1 FROM information_schema.tables 
                    WHERE table_name = '{table}'
                )
            """)
            exists = cursor.fetchone()[0]
            status = "✓" if exists else "✗"
            print(f"{status} {table}")
        
        # Check new columns in site_budgets
        print()
        print("Checking new columns in site_budgets...")
        cursor.execute("""
            SELECT column_name 
            FROM information_schema.columns 
            WHERE table_name = 'site_budgets'
            AND column_name IN (
                'initial_quote', 'extra_cost_approved', 'labour_cost', 
                'material_cost', 'extra_cost', 'project_status'
            )
            ORDER BY column_name
        """)
        
        columns = cursor.fetchall()
        for col in columns:
            print(f"✓ {col[0]}")
        
        # Check view
        print()
        print("Checking views...")
        cursor.execute("""
            SELECT EXISTS (
                SELECT 1 FROM information_schema.views 
                WHERE table_name = 'v_site_cost_breakdown'
            )
        """)
        view_exists = cursor.fetchone()[0]
        status = "✓" if view_exists else "✗"
        print(f"{status} v_site_cost_breakdown")
        
        # Check triggers
        print()
        print("Checking triggers...")
        triggers_to_check = [
            'trigger_update_budget_totals',
            'trigger_financial_timeline',
            'trigger_budget_mismatch'
        ]
        
        for trigger in triggers_to_check:
            cursor.execute(f"""
                SELECT EXISTS (
                    SELECT 1 FROM information_schema.triggers 
                    WHERE trigger_name = '{trigger}'
                )
            """)
            exists = cursor.fetchone()[0]
            status = "✓" if exists else "✗"
            print(f"{status} {trigger}")
        
        print()
        print("=" * 60)
        print("✓ Enhanced Budget Schema Migration Complete!")
        print("=" * 60)
        print()
        print("New Features Available:")
        print("  • Project quote management (initial + extra costs)")
        print("  • Separate cost tracking (Labour, Material, Extra)")
        print("  • Financial timeline with complete history")
        print("  • Budget mismatch alerts")
        print("  • Extra cost request workflow")
        print("  • Automatic budget calculations")
        print()
        
        cursor.close()
        conn.close()
        
        return True
        
    except psycopg2.Error as e:
        print(f"✗ Database error: {e}")
        if conn:
            conn.rollback()
            conn.close()
        return False
        
    except FileNotFoundError:
        print(f"✗ SQL file not found: {sql_file}")
        return False
        
    except Exception as e:
        print(f"✗ Unexpected error: {e}")
        if conn:
            conn.rollback()
            conn.close()
        return False

if __name__ == '__main__':
    success = run_migration()
    sys.exit(0 if success else 1)
