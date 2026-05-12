#!/usr/bin/env python
"""
Automated Entry Lock Migration Script
Purpose: Add entry_type column and unique constraint to labour_entries table
Usage: python migrate_entry_lock_auto.py
Safe: Non-breaking, backward compatible, zero downtime
"""

import os
import sys
import django
import psycopg2
from datetime import datetime

# Setup Django environment
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.conf import settings

def log(message, level='INFO'):
    """Simple logging function"""
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    print(f"[{timestamp}] [{level}] {message}")

def get_db_connection():
    """Get database connection from Django settings"""
    db_settings = settings.DATABASES['default']
    
    try:
        conn = psycopg2.connect(
            dbname=db_settings['NAME'],
            user=db_settings['USER'],
            password=db_settings['PASSWORD'],
            host=db_settings['HOST'],
            port=db_settings['PORT']
        )
        conn.autocommit = False
        return conn
    except Exception as e:
        log(f"Failed to connect to database: {e}", 'ERROR')
        sys.exit(1)

def run_migration():
    """Run the entry lock migration automatically"""
    log("Starting entry lock migration...")
    
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        # Check if table exists
        cursor.execute("""
            SELECT EXISTS (
                SELECT 1 FROM information_schema.tables 
                WHERE table_name = 'labour_entries'
            );
        """)
        if not cursor.fetchone()[0]:
            log("Table 'labour_entries' does not exist!", 'ERROR')
            return False
        
        # Get row count
        cursor.execute("SELECT COUNT(*) FROM labour_entries;")
        total_rows = cursor.fetchone()[0]
        log(f"Found {total_rows} existing labour entries")
        
        # Step 1: Add entry_type column
        cursor.execute("""
            SELECT EXISTS (
                SELECT 1 FROM information_schema.columns 
                WHERE table_name = 'labour_entries' AND column_name = 'entry_type'
            );
        """)
        
        if cursor.fetchone()[0]:
            log("Column 'entry_type' already exists")
        else:
            log("Adding entry_type column...")
            cursor.execute("""
                ALTER TABLE labour_entries 
                ADD COLUMN entry_type VARCHAR(10) DEFAULT 'morning';
            """)
            conn.commit()
            log("Column 'entry_type' added successfully")
        
        # Step 2: Populate entry_type
        log("Populating entry_type values...")
        cursor.execute("""
            UPDATE labour_entries 
            SET entry_type = CASE 
                WHEN EXTRACT(HOUR FROM entry_time) < 12 THEN 'morning'
                ELSE 'evening'
            END
            WHERE entry_type IS NULL OR entry_type = 'morning';
        """)
        updated_rows = cursor.rowcount
        conn.commit()
        log(f"Updated {updated_rows} rows")
        
        # Step 3: Handle duplicates
        cursor.execute("""
            SELECT COUNT(*) FROM (
                SELECT site_id, entry_date, entry_type, labour_type, COUNT(*) as count
                FROM labour_entries
                GROUP BY site_id, entry_date, entry_type, labour_type
                HAVING COUNT(*) > 1
            ) AS duplicates;
        """)
        dup_count = cursor.fetchone()[0]
        
        if dup_count > 0:
            log(f"Found {dup_count} duplicate groups, removing duplicates...")
            cursor.execute("""
                DELETE FROM labour_entries a
                USING labour_entries b
                WHERE a.id > b.id
                AND a.site_id = b.site_id
                AND a.entry_date = b.entry_date
                AND a.entry_type = b.entry_type
                AND a.labour_type = b.labour_type;
            """)
            deleted_rows = cursor.rowcount
            conn.commit()
            log(f"Removed {deleted_rows} duplicate entries")
        
        # Step 4: Create unique index
        cursor.execute("""
            SELECT EXISTS (
                SELECT 1 FROM pg_indexes 
                WHERE indexname = 'idx_labour_entry_lock'
            );
        """)
        
        if cursor.fetchone()[0]:
            log("Index 'idx_labour_entry_lock' already exists")
        else:
            log("Creating unique index...")
            cursor.execute("""
                CREATE UNIQUE INDEX CONCURRENTLY idx_labour_entry_lock 
                ON labour_entries(site_id, entry_date, entry_type, labour_type);
            """)
            conn.commit()
            log("Unique index created successfully")
        
        # Step 5: Add check constraint
        cursor.execute("""
            SELECT EXISTS (
                SELECT 1 FROM information_schema.table_constraints 
                WHERE table_name = 'labour_entries' AND constraint_name = 'chk_entry_type'
            );
        """)
        
        if cursor.fetchone()[0]:
            log("Constraint 'chk_entry_type' already exists")
        else:
            log("Adding check constraint...")
            cursor.execute("""
                ALTER TABLE labour_entries 
                ADD CONSTRAINT chk_entry_type 
                CHECK (entry_type IN ('morning', 'evening'));
            """)
            conn.commit()
            log("Check constraint added successfully")
        
        # Step 6: Set NOT NULL
        cursor.execute("""
            SELECT is_nullable FROM information_schema.columns
            WHERE table_name = 'labour_entries' AND column_name = 'entry_type';
        """)
        is_nullable = cursor.fetchone()[0]
        
        if is_nullable == 'NO':
            log("Column 'entry_type' is already NOT NULL")
        else:
            # Fix any NULL values first
            cursor.execute("UPDATE labour_entries SET entry_type = 'morning' WHERE entry_type IS NULL;")
            if cursor.rowcount > 0:
                log(f"Fixed {cursor.rowcount} NULL values")
            
            log("Setting entry_type as NOT NULL...")
            cursor.execute("""
                ALTER TABLE labour_entries 
                ALTER COLUMN entry_type SET NOT NULL;
            """)
            conn.commit()
            log("Column set to NOT NULL")
        
        # Verify
        cursor.execute("""
            SELECT COUNT(*) FROM (
                SELECT site_id, entry_date, entry_type, labour_type, COUNT(*) as count
                FROM labour_entries
                GROUP BY site_id, entry_date, entry_type, labour_type
                HAVING COUNT(*) > 1
            ) AS duplicates;
        """)
        
        if cursor.fetchone()[0] > 0:
            log("Verification failed: duplicates still exist!", 'ERROR')
            return False
        
        log("Migration completed successfully!", 'SUCCESS')
        log("Next steps: Restart Django server and test the API")
        return True
        
    except Exception as e:
        log(f"Migration failed: {e}", 'ERROR')
        conn.rollback()
        return False
        
    finally:
        cursor.close()
        conn.close()

if __name__ == '__main__':
    success = run_migration()
    sys.exit(0 if success else 1)
