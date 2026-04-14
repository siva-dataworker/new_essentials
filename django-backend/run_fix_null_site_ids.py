import psycopg2
import os
from dotenv import load_dotenv

load_dotenv()

print("\n" + "="*60)
print("🔧 FIXING NULL SITE IDs IN DATABASE")
print("="*60)

try:
    # Connect to database
    conn = psycopg2.connect(
        host=os.getenv('DB_HOST'),
        database=os.getenv('DB_NAME'),
        user=os.getenv('DB_USER'),
        password=os.getenv('DB_PASSWORD'),
        port=os.getenv('DB_PORT', 5432)
    )
    conn.autocommit = True
    cursor = conn.cursor()
    
    # Check current state
    print("\n📊 BEFORE FIX:")
    cursor.execute("SELECT COUNT(*) FROM labour_entries WHERE site_id IS NULL")
    null_labour = cursor.fetchone()[0]
    print(f"   Labour entries with NULL site_id: {null_labour}")
    
    cursor.execute("SELECT COUNT(*) FROM material_balances WHERE site_id IS NULL")
    null_material = cursor.fetchone()[0]
    print(f"   Material entries with NULL site_id: {null_material}")
    
    if null_labour == 0 and null_material == 0:
        print("\n✅ No NULL site_ids found! Data is already clean.")
        cursor.close()
        conn.close()
        exit(0)
    
    # Get first site
    cursor.execute("SELECT id, site_name FROM sites LIMIT 1")
    site = cursor.fetchone()
    
    if not site:
        print("\n❌ ERROR: No sites found in database!")
        print("   Please create a site first.")
        cursor.close()
        conn.close()
        exit(1)
    
    site_id, site_name = site
    print(f"\n📍 Will assign entries to: {site_name}")
    print(f"   Site ID: {site_id}")
    
    # Fix labour entries
    if null_labour > 0:
        print(f"\n🔧 Fixing {null_labour} labour entries...")
        cursor.execute("""
            UPDATE labour_entries 
            SET site_id = %s 
            WHERE site_id IS NULL
        """, (site_id,))
        print(f"   ✅ Fixed {cursor.rowcount} labour entries")
    
    # Fix material entries
    if null_material > 0:
        print(f"\n🔧 Fixing {null_material} material entries...")
        cursor.execute("""
            UPDATE material_balances 
            SET site_id = %s 
            WHERE site_id IS NULL
        """, (site_id,))
        print(f"   ✅ Fixed {cursor.rowcount} material entries")
    
    # Verify
    print("\n📊 AFTER FIX:")
    cursor.execute("SELECT COUNT(*) FROM labour_entries WHERE site_id IS NULL")
    print(f"   Labour entries with NULL site_id: {cursor.fetchone()[0]}")
    
    cursor.execute("SELECT COUNT(*) FROM material_balances WHERE site_id IS NULL")
    print(f"   Material entries with NULL site_id: {cursor.fetchone()[0]}")
    
    cursor.execute("SELECT COUNT(*) FROM labour_entries")
    print(f"   Total labour entries: {cursor.fetchone()[0]}")
    
    cursor.execute("SELECT COUNT(*) FROM material_balances")
    print(f"   Total material entries: {cursor.fetchone()[0]}")
    
    cursor.close()
    conn.close()
    
    print("\n" + "="*60)
    print("✅ ALL NULL SITE IDs FIXED!")
    print("="*60)
    print("\n🔄 Next step: Hot restart your Flutter app (press R)")
    print("   Then try opening history again.\n")
    
except Exception as e:
    print(f"\n❌ ERROR: {e}")
    print("\nTroubleshooting:")
    print("1. Make sure Django backend is running")
    print("2. Check .env file has correct database credentials")
    print("3. Verify database is accessible\n")
