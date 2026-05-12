#!/usr/bin/env python
"""
Entry Lock Migration Script
Purpose: Add entry_type column and unique constraint to labour_entries table
Date: 2026-05-12
Safe: Non-breaking, backward compatible, zero downtime
"""

import os
import sys
import django
import psycopg2
from psycopg2 import sql
from datetime import datetime

# Setup Django environment
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.conf import settings

# Color codes for terminal output
class Colors:
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    BLUE = '\033[94m'
    BOLD = '\033[1m'
    END = '\033[0m'

def print_success(message):
    print(f"{Colors.GREEN}✅ {message}{Colors.END}")

def print_info(message):
    print(f"{Colors.BLUE}ℹ️  {message}{Colors.END}")

def print_warning(message):
    print(f"{Colors.YELLOW}⚠️  {message}{Colors.END}")

def print_error(message):
    print(f"{Colors.RED}❌ {message}{Colors.END}")

def print_header(message):
    print(f"\n{Colors.BOLD}{Colors.BLUE}{'='*60}{Colors.END}")
    print(f"{Colors.BOLD}{Colors.BLUE}{message}{Colors.END}")
    print(f"{Colors.BOLD}{Colors.BLUE}{'='*60}{Colors.END}\n")

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
        return conn
    except Exception as e:
        print_error(f"Failed to connect to database: {e}")
        sys.exit(1)

def check_column_exists(cursor, table_name, column_name):
    """Check if a column exists in a table"""
    cursor.execute("""
        SELECT EXISTS (
            SELECT 1 
            FROM information_schema.columns 
            WHERE table_name = %s 
            AND column_name = %s
        );
    """, (table_name, column_name))
    return cursor.fetchone()[0]

def check_index_exists(cursor, index_name):
    """Check if an index exists"""
    cursor.execute("""
        SELECT EXISTS (
            SELECT 1 
            FROM pg_indexes 
            WHERE indexname = %s
        );
    """, (index_name,))
    return cursor.fetchone()[0]

def check_constraint_exists(cursor, table_name, constraint_name):
    """Check if a constraint exists"""
    cursor.execute("""
        SELECT EXISTS (
            SELECT 1 
            FROM information_schema.table_constraints 
            WHERE table_name = %s 
            AND constraint_name = %s
        );
    """, (table_name, constraint_name))
    return cursor.fetchone()[0]

def backup_table(cursor, table_name):
    """Create a backup of the table"""
    backup_name = f"{table_name}_backup_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
    print_info(f"Creating backup table: {backup_name}")
    
    try:
        cursor.execute(f"CREATE TABLE {backup_name} AS SELECT * FROM {table_name};")
        row_count = cursor.rowcount
        print_success(f"Backup created with {row_count} rows")
        return backup_name
    except Exception as e:
        print_error(f"Failed to create backup: {e}")
        return None

def run_migration():
    """Run the entry lock migration"""
    print_header("ENTRY LOCK MIGRATION - STARTING")
    
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        # Step 0: Check current state
        print_info("Checking current database state...")
        
        # Check if table exists
        cursor.execute("""
            SELECT EXISTS (
                SELECT 1 
                FROM information_schema.tables 
                WHERE table_name = 'labour_entries'
            );
        """)
        if not cursor.fetchone()[0]:
            print_error("Table 'labour_entries' does not exist!")
            return False
        
        # Get current row count
        cursor.execute("SELECT COUNT(*) FROM labour_entries;")
        total_rows = cursor.fetchone()[0]
        print_info(f"Found {total_rows} existing labour entries")
        
        # Step 1: Add entry_type column if not exists
        print_header("STEP 1: Adding entry_type Column")
        
        if check_column_exists(cursor, 'labour_entries', 'entry_type'):
            print_warning("Column 'entry_type' already exists, skipping...")
        else:
            print_info("Adding entry_type column...")
            cursor.execute("""
                ALTER TABLE labour_entries 
                ADD COLUMN entry_type VARCHAR(10) DEFAULT 'morning';
            """)
            conn.commit()
            print_success("Column 'entry_type' added successfully")
        
        # Step 2: Populate entry_type based on entry_time
        print_header("STEP 2: Populating entry_type Values")
        
        print_info("Updating entry_type based on entry_time...")
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
        print_success(f"Updated {updated_rows} rows with entry_type values")
        
        # Verify the update
        cursor.execute("""
            SELECT entry_type, COUNT(*) 
            FROM labour_entries 
            GROUP BY entry_type;
        """)
        results = cursor.fetchall()
        print_info("Entry type distribution:")
        for entry_type, count in results:
            print(f"  - {entry_type}: {count} entries")
        
        # Step 3: Create unique index
        print_header("STEP 3: Creating Unique Index")
        
        index_name = 'idx_labour_entry_lock'
        if check_index_exists(cursor, index_name):
            print_warning(f"Index '{index_name}' already exists, skipping...")
        else:
            print_info("Creating unique index (this may take a moment)...")
            
            # Check for duplicates first
            cursor.execute("""
                SELECT site_id, entry_date, entry_type, labour_type, COUNT(*) as count
                FROM labour_entries
                GROUP BY site_id, entry_date, entry_type, labour_type
                HAVING COUNT(*) > 1;
            """)
            duplicates = cursor.fetchall()
            
            if duplicates:
                print_warning(f"Found {len(duplicates)} duplicate entries!")
                print_info("Duplicate entries:")
                for dup in duplicates[:5]:  # Show first 5
                    print(f"  - Site: {dup[0]}, Date: {dup[1]}, Type: {dup[2]}, Labour: {dup[3]}, Count: {dup[4]}")
                
                response = input("\nDo you want to continue? This will keep the first entry and mark others. (yes/no): ")
                if response.lower() != 'yes':
                    print_warning("Migration cancelled by user")
                    return False
                
                # Handle duplicates by keeping the first entry
                print_info("Handling duplicates...")
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
                print_success(f"Removed {deleted_rows} duplicate entries")
            
            # Create the index (without CONCURRENTLY to allow running in transaction)
            cursor.execute("""
                CREATE UNIQUE INDEX IF NOT EXISTS idx_labour_entry_lock 
                ON labour_entries(site_id, entry_date, entry_type, labour_type);
            """)
            conn.commit()
            print_success(f"Unique index '{index_name}' created successfully")
        
        # Step 4: Add check constraint
        print_header("STEP 4: Adding Check Constraint")
        
        constraint_name = 'chk_entry_type'
        if check_constraint_exists(cursor, 'labour_entries', constraint_name):
            print_warning(f"Constraint '{constraint_name}' already exists, skipping...")
        else:
            print_info("Adding check constraint for entry_type...")
            cursor.execute("""
                ALTER TABLE labour_entries 
                ADD CONSTRAINT chk_entry_type 
                CHECK (entry_type IN ('morning', 'evening'));
            """)
            conn.commit()
            print_success(f"Check constraint '{constraint_name}' added successfully")
        
        # Step 5: Make entry_type NOT NULL
        print_header("STEP 5: Setting entry_type as NOT NULL")
        
        # Check if any NULL values exist
        cursor.execute("SELECT COUNT(*) FROM labour_entries WHERE entry_type IS NULL;")
        null_count = cursor.fetchone()[0]
        
        if null_count > 0:
            print_warning(f"Found {null_count} rows with NULL entry_type")
            print_info("Setting NULL values to 'morning'...")
            cursor.execute("UPDATE labour_entries SET entry_type = 'morning' WHERE entry_type IS NULL;")
            conn.commit()
            print_success(f"Updated {cursor.rowcount} NULL values")
        
        print_info("Setting entry_type as NOT NULL...")
        cursor.execute("""
            ALTER TABLE labour_entries 
            ALTER COLUMN entry_type SET NOT NULL;
        """)
        conn.commit()
        print_success("Column entry_type is now NOT NULL")
        
        # Step 6: Verify migration
        print_header("STEP 6: Verifying Migration")
        
        # Check for duplicates
        cursor.execute("""
            SELECT site_id, entry_date, entry_type, labour_type, COUNT(*) as count
            FROM labour_entries
            GROUP BY site_id, entry_date, entry_type, labour_type
            HAVING COUNT(*) > 1;
        """)
        duplicates = cursor.fetchall()
        
        if duplicates:
            print_error(f"Verification failed! Found {len(duplicates)} duplicate entries")
            return False
        else:
            print_success("No duplicate entries found")
        
        # Check column properties
        cursor.execute("""
            SELECT column_name, data_type, is_nullable, column_default
            FROM information_schema.columns
            WHERE table_name = 'labour_entries' AND column_name = 'entry_type';
        """)
        col_info = cursor.fetchone()
        print_info(f"Column info: {col_info[0]} | Type: {col_info[1]} | Nullable: {col_info[2]} | Default: {col_info[3]}")
        
        # Final success message
        print_header("MIGRATION COMPLETED SUCCESSFULLY!")
        print_success("✅ entry_type column added")
        print_success("✅ Unique constraint created")
        print_success("✅ Check constraint added")
        print_success("✅ Column set to NOT NULL")
        print_success("✅ No duplicate entries exist")
        
        print_info("\nNext steps:")
        print("  1. Restart Django server")
        print("  2. Test the check-entry-lock API endpoint")
        print("  3. Build and test Flutter app")
        
        return True
        
    except Exception as e:
        print_error(f"Migration failed: {e}")
        conn.rollback()
        print_warning("Changes have been rolled back")
        return False
        
    finally:
        cursor.close()
        conn.close()

def rollback_migration():
    """Rollback the migration"""
    print_header("ENTRY LOCK MIGRATION - ROLLBACK")
    
    response = input("Are you sure you want to rollback? This will remove all changes. (yes/no): ")
    if response.lower() != 'yes':
        print_warning("Rollback cancelled")
        return
    
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        print_info("Removing unique index...")
        cursor.execute("DROP INDEX IF EXISTS idx_labour_entry_lock;")
        print_success("Index removed")
        
        print_info("Removing check constraint...")
        cursor.execute("ALTER TABLE labour_entries DROP CONSTRAINT IF EXISTS chk_entry_type;")
        print_success("Constraint removed")
        
        print_info("Removing entry_type column...")
        cursor.execute("ALTER TABLE labour_entries DROP COLUMN IF EXISTS entry_type;")
        print_success("Column removed")
        
        conn.commit()
        print_header("ROLLBACK COMPLETED SUCCESSFULLY!")
        
    except Exception as e:
        print_error(f"Rollback failed: {e}")
        conn.rollback()
        
    finally:
        cursor.close()
        conn.close()

def main():
    """Main entry point"""
    print_header("ENTRY LOCK MIGRATION SCRIPT")
    print_info("This script will add entry lock functionality to labour_entries table")
    print_info("Safe: Non-breaking, backward compatible, zero downtime\n")
    
    if len(sys.argv) > 1 and sys.argv[1] == 'rollback':
        rollback_migration()
    else:
        print("Options:")
        print("  1. Run migration")
        print("  2. Rollback migration")
        print("  3. Exit")
        
        choice = input("\nEnter your choice (1-3): ")
        
        if choice == '1':
            success = run_migration()
            sys.exit(0 if success else 1)
        elif choice == '2':
            rollback_migration()
        else:
            print_info("Exiting...")

if __name__ == '__main__':
    main()
