"""
Migration: Allow global (site-independent) labour rates.
Makes site_id nullable in labour_salary_rates and drops the FK constraint.
NULL site_id = global rate that applies to all sites.
"""
import psycopg2
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from api.database import get_db_connection

def run_migration():
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        print("Running global labour rates migration...")

        # Drop the FK constraint
        cur.execute("""
            ALTER TABLE labour_salary_rates
            DROP CONSTRAINT IF EXISTS labour_salary_rates_site_id_fkey;
        """)
        print("  Dropped FK constraint on site_id")

        # Make site_id nullable
        cur.execute("""
            ALTER TABLE labour_salary_rates
            ALTER COLUMN site_id DROP NOT NULL;
        """)
        print("  Made site_id nullable (NULL = global rate)")

        conn.commit()
        print("Migration complete!")
    except Exception as e:
        conn.rollback()
        print(f"Error: {e}")
        raise
    finally:
        cur.close()
        conn.close()

if __name__ == '__main__':
    run_migration()
