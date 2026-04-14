"""
Debug change requests - check if they're being created
"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all

print("\n" + "=" * 70)
print("DEBUGGING CHANGE REQUESTS")
print("=" * 70)

# Check if table exists
print("\n1. Checking if change_requests table exists...")
try:
    result = fetch_all("""
        SELECT COUNT(*) as count FROM change_requests
    """)
    print(f"   ✅ Table exists with {result[0]['count']} records")
except Exception as e:
    print(f"   ❌ Error: {e}")
    print("\n   Run: python run_add_change_requests_system.py")
    exit(1)

# Check all change requests
print("\n2. Checking all change requests...")
requests = fetch_all("""
    SELECT 
        cr.id,
        cr.entry_id,
        cr.entry_type,
        cr.request_message,
        cr.status,
        cr.created_at,
        u.username as requested_by_username,
        u.full_name as requested_by_name
    FROM change_requests cr
    LEFT JOIN users u ON cr.requested_by = u.id
    ORDER BY cr.created_at DESC
""")

if len(requests) == 0:
    print("   ⚠️ No change requests found in database")
    print("\n   This means:")
    print("   - Either no requests have been sent yet")
    print("   - Or the request is not being saved to database")
else:
    print(f"   Found {len(requests)} change requests:")
    for req in requests:
        print(f"\n   Request ID: {req['id']}")
        print(f"   Entry ID: {req['entry_id']}")
        print(f"   Entry Type: {req['entry_type']}")
        print(f"   Requested by: {req['requested_by_name']} ({req['requested_by_username']})")
        print(f"   Status: {req['status']}")
        print(f"   Message: {req['request_message']}")
        print(f"   Created: {req['created_at']}")

# Check pending requests specifically
print("\n3. Checking PENDING requests (what accountant should see)...")
pending = fetch_all("""
    SELECT 
        cr.id,
        cr.entry_id,
        cr.entry_type,
        cr.request_message,
        u.full_name as requested_by_name
    FROM change_requests cr
    JOIN users u ON cr.requested_by = u.id
    WHERE cr.status = 'PENDING'
    ORDER BY cr.created_at DESC
""")

if len(pending) == 0:
    print("   ⚠️ No PENDING requests")
    print("   Accountant will see empty list")
else:
    print(f"   ✅ Found {len(pending)} PENDING requests")
    for req in pending:
        print(f"   - {req['requested_by_name']}: {req['request_message'][:50]}...")

# Check users
print("\n4. Checking users...")
users = fetch_all("""
    SELECT id, username, full_name, role_id
    FROM users
    WHERE username IN ('nsnwjw', 'accountant')
""")

for user in users:
    print(f"   {user['username']}: ID = {user['id']}, Role = {user['role_id']}")

print("\n" + "=" * 70)
print("DIAGNOSIS:")
print("=" * 70)

if len(requests) == 0:
    print("\n❌ NO REQUESTS IN DATABASE")
    print("\nPossible causes:")
    print("1. Request not being sent from Flutter app")
    print("2. Backend API not receiving the request")
    print("3. Database insert failing silently")
    print("\nNext steps:")
    print("- Check Django logs when sending request")
    print("- Check Flutter console for errors")
    print("- Try sending request again and watch logs")
elif len(pending) == 0:
    print("\n⚠️ REQUESTS EXIST BUT NONE ARE PENDING")
    print("All requests have been handled or have different status")
else:
    print(f"\n✅ SYSTEM WORKING - {len(pending)} pending requests")
    print("Accountant should be able to see these requests")

print("\n" + "=" * 70 + "\n")
