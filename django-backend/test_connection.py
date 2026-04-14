#!/usr/bin/env python
"""Test Supabase database connection"""

import psycopg

# Test connection with pooler
try:
    print("Attempting to connect to Supabase (Connection Pooler)...")
    conn = psycopg.connect(
        host='aws-1-ap-northeast-1.pooler.supabase.com',
        port=5432,
        dbname='postgres',
        user='postgres.ctwthgjuccioxivnzifb',
        password='Appdevlopment@2026',
        sslmode='require',
        connect_timeout=10
    )
    print("✅ Connection successful!")
    
    # Test query
    with conn.cursor() as cur:
        cur.execute("SELECT version();")
        version = cur.fetchone()
        print(f"✅ PostgreSQL version: {version[0]}")
        
        cur.execute("SELECT COUNT(*) FROM users;")
        count = cur.fetchone()
        print(f"✅ Users table has {count[0]} rows")
    
    conn.close()
    print("\n✅ All tests passed! Database connection is working.")
    
except Exception as e:
    print(f"❌ Connection failed: {e}")
    print("\nTroubleshooting:")
    print("1. Check Supabase dashboard for correct pooler host")
    print("2. Verify the region (ap-northeast-1, us-east-1, etc.)")
    print("3. Check if using Transaction or Session mode")
    print("4. Verify password is correct")
