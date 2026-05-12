#!/usr/bin/env python
"""
Test Entry Lock Migration
Purpose: Verify that the migration was successful
Usage: python test_migration.py
"""

import os
import sys
import django
import psycopg2

# Setup Django environment
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.conf import settings

def get_db_connection():
    """Get database connection from Django settings"""
    db_settings = settings.DATABASES['default']
    return psycopg2.connect(
        dbname=db_settings['NAME'],
        user=db_settings['USER'],
        password=db_settings['PASSWORD'],
        host=db_settings['HOST'],
        port=db_settings['PORT']
    )

def test_migration():
    """Test that migration was successful"""
    print("=" * 60)
    print("TESTING ENTRY LOCK MIGRATION")
    print("=" * 60)
    print()
    
    conn = get_db_connection()
    cursor = conn.cursor()
    
    all_passed = True
    
    try:
        # Test 1: Check column exists
        print("Test 1: Checking if entry_type column exists...")
        cursor.execute("""
            SELECT EXISTS (
                SELECT 1 FROM information_schema.columns 
                WHERE table_name = 'labour_entries' AND column_name = 'entry_type'
            );
        """)
        if cursor.fetchone()[0]:
            print("✅ PASS: entry_type column exists")
        else:
            print("❌ FAIL: entry_type column does not exist")
            all_passed = False
        print()
        
        # Test 2: Check column is NOT NULL
        print("Test 2: Checking if entry_type is NOT NULL...")
        cursor.execute("""
            SELECT is_nullable FROM information_schema.columns
            WHERE table_name = 'labour_entries' AND column_name = 'entry_type';
        """)
        is_nullable = cursor.fetchone()[0]
        if is_nullable == 'NO':
            print("✅ PASS: entry_type is NOT NULL")
        else:
            print("❌ FAIL: entry_type allows NULL values")
            all_passed = False
        print()
        
        # Test 3: Check all rows have entry_type
        print("Test 3: Checking if all rows have entry_type value...")
        cursor.execute("SELECT COUNT(*) FROM labour_entries WHERE entry_type IS NULL;")
        null_count = cursor.fetchone()[0]
        if null_count == 0:
            print("✅ PASS: All rows have entry_type value")
        else:
            print(f"❌ FAIL: Found {null_count} rows with NULL entry_type")
            all_passed = False
        print()
        
        # Test 4: Check entry_type values are valid
        print("Test 4: Checking if entry_type values are valid...")
        cursor.execute("""
            SELECT COUNT(*) FROM labour_entries 
            WHERE entry_type NOT IN ('morning', 'evening');
        """)
        invalid_count = cursor.fetchone()[0]
        if invalid_count == 0:
            print("✅ PASS: All entry_type values are valid (morning/evening)")
        else:
            print(f"❌ FAIL: Found {invalid_count} rows with invalid entry_type")
            all_passed = False
        print()
        
        # Test 5: Check unique index exists
        print("Test 5: Checking if unique index exists...")
        cursor.execute("""
            SELECT EXISTS (
                SELECT 1 FROM pg_indexes 
                WHERE indexname = 'idx_labour_entry_lock'
            );
        """)
        if cursor.fetchone()[0]:
            print("✅ PASS: Unique index 'idx_labour_entry_lock' exists")
        else:
            print("❌ FAIL: Unique index does not exist")
            all_passed = False
        print()
        
        # Test 6: Check check constraint exists
        print("Test 6: Checking if check constraint exists...")
        cursor.execute("""
            SELECT EXISTS (
                SELECT 1 FROM information_schema.table_constraints 
                WHERE table_name = 'labour_entries' AND constraint_name = 'chk_entry_type'
            );
        """)
        if cursor.fetchone()[0]:
            print("✅ PASS: Check constraint 'chk_entry_type' exists")
        else:
            print("❌ FAIL: Check constraint does not exist")
            all_passed = False
        print()
        
        # Test 7: Check for duplicates
        print("Test 7: Checking for duplicate entries...")
        cursor.execute("""
            SELECT COUNT(*) FROM (
                SELECT site_id, entry_date, entry_type, labour_type, COUNT(*) as count
                FROM labour_entries
                GROUP BY site_id, entry_date, entry_type, labour_type
                HAVING COUNT(*) > 1
            ) AS duplicates;
        """)
        dup_count = cursor.fetchone()[0]
        if dup_count == 0:
            print("✅ PASS: No duplicate entries found")
        else:
            print(f"❌ FAIL: Found {dup_count} duplicate entry groups")
            all_passed = False
        print()
        
        # Test 8: Check entry_type distribution
        print("Test 8: Checking entry_type distribution...")
        cursor.execute("""
            SELECT entry_type, COUNT(*) 
            FROM labour_entries 
            GROUP BY entry_type 
            ORDER BY entry_type;
        """)
        results = cursor.fetchall()
        if results:
            print("✅ PASS: Entry type distribution:")
            for entry_type, count in results:
                print(f"     - {entry_type}: {count} entries")
        else:
            print("⚠️  WARNING: No entries found in table")
        print()
        
        # Test 9: Test unique constraint (try to insert duplicate)
        print("Test 9: Testing unique constraint enforcement...")
        try:
            # Get a sample entry
            cursor.execute("""
                SELECT site_id, entry_date, entry_type, labour_type 
                FROM labour_entries 
                LIMIT 1;
            """)
            sample = cursor.fetchone()
            
            if sample:
                # Try to insert duplicate
                cursor.execute("""
                    INSERT INTO labour_entries 
                    (id, site_id, entry_date, entry_type, labour_type, supervisor_id, labour_count, entry_time, day_of_week)
                    VALUES (gen_random_uuid(), %s, %s, %s, %s, gen_random_uuid(), 1, NOW(), 'Monday');
                """, sample)
                conn.rollback()
                print("❌ FAIL: Unique constraint did not prevent duplicate")
                all_passed = False
            else:
                print("⚠️  SKIP: No entries to test with")
        except psycopg2.IntegrityError as e:
            conn.rollback()
            if 'idx_labour_entry_lock' in str(e):
                print("✅ PASS: Unique constraint prevents duplicates")
            else:
                print(f"⚠️  WARNING: Different constraint triggered: {e}")
        print()
        
        # Test 10: Test check constraint (try to insert invalid value)
        print("Test 10: Testing check constraint enforcement...")
        try:
            cursor.execute("""
                INSERT INTO labour_entries 
                (id, site_id, entry_date, entry_type, labour_type, supervisor_id, labour_count, entry_time, day_of_week)
                VALUES (gen_random_uuid(), gen_random_uuid(), CURRENT_DATE, 'invalid', 'General', gen_random_uuid(), 1, NOW(), 'Monday');
            """)
            conn.rollback()
            print("❌ FAIL: Check constraint did not prevent invalid value")
            all_passed = False
        except psycopg2.IntegrityError as e:
            conn.rollback()
            if 'chk_entry_type' in str(e):
                print("✅ PASS: Check constraint prevents invalid values")
            else:
                print(f"⚠️  WARNING: Different constraint triggered: {e}")
        print()
        
        # Final result
        print("=" * 60)
        if all_passed:
            print("🎉 ALL TESTS PASSED!")
            print("Migration was successful!")
        else:
            print("⚠️  SOME TESTS FAILED")
            print("Please review the migration")
        print("=" * 60)
        
        return all_passed
        
    except Exception as e:
        print(f"❌ ERROR: {e}")
        return False
        
    finally:
        cursor.close()
        conn.close()

if __name__ == '__main__':
    success = test_migration()
    sys.exit(0 if success else 1)
