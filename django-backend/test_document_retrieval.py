"""
Test script to verify document retrieval is working
"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all

print("=" * 60)
print("TESTING DOCUMENT RETRIEVAL")
print("=" * 60)

# Test 1: Check if site_engineer_documents table exists and has data
print("\n1. Checking site_engineer_documents table...")
try:
    docs = fetch_all("""
        SELECT 
            sed.id,
            sed.site_id,
            sed.document_type,
            sed.title,
            sed.file_url,
            sed.upload_date,
            u.full_name as engineer_name
        FROM site_engineer_documents sed
        JOIN users u ON sed.site_engineer_id = u.id
        WHERE sed.is_active = TRUE
        ORDER BY sed.uploaded_at DESC
        LIMIT 5
    """)
    
    if docs:
        print(f"✅ Found {len(docs)} document(s)")
        for doc in docs:
            print(f"   - {doc['title']} ({doc['document_type']}) by {doc['engineer_name']}")
    else:
        print("⚠️  No documents found in database")
        print("   This is normal if no documents have been uploaded yet")
except Exception as e:
    print(f"❌ Error: {e}")

# Test 2: Check table structure
print("\n2. Checking table structure...")
try:
    columns = fetch_all("""
        SELECT column_name, data_type 
        FROM information_schema.columns 
        WHERE table_name = 'site_engineer_documents'
        ORDER BY ordinal_position
    """)
    
    if columns:
        print("✅ Table structure:")
        for col in columns:
            print(f"   - {col['column_name']}: {col['data_type']}")
    else:
        print("❌ Table not found!")
except Exception as e:
    print(f"❌ Error: {e}")

# Test 3: Check users table for full_name column
print("\n3. Checking users table...")
try:
    users = fetch_all("""
        SELECT id, username, full_name, role_id
        FROM users
        WHERE role_id = (SELECT id FROM roles WHERE role_name = 'Site Engineer')
        LIMIT 3
    """)
    
    if users:
        print(f"✅ Found {len(users)} Site Engineer(s)")
        for user in users:
            print(f"   - {user['username']}: {user['full_name']}")
    else:
        print("⚠️  No Site Engineers found")
except Exception as e:
    print(f"❌ Error: {e}")

print("\n" + "=" * 60)
print("TEST COMPLETE")
print("=" * 60)
