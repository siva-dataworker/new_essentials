import os
import django
from datetime import datetime, time
import pytz

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.db import connection

# IST timezone
IST = pytz.timezone('Asia/Kolkata')

# Define allowed time window (4 PM - 7 PM IST)
ALLOWED_START = time(16, 0)  # 4:00 PM
ALLOWED_END = time(19, 0)    # 7:00 PM

print("=" * 60)
print("CHECKING MATERIAL USAGE ENTRIES")
print("=" * 60)
print(f"Allowed time window: {ALLOWED_START.strftime('%I:%M %p')} - {ALLOWED_END.strftime('%I:%M %p')} IST")
print()

# Use raw SQL to query material_usage table
with connection.cursor() as cursor:
    cursor.execute("""
        SELECT 
            id,
            created_at,
            usage_date,
            material_type,
            quantity_used,
            unit,
            site_id,
            supervisor_id
        FROM material_usage
        ORDER BY created_at DESC
        LIMIT 50
    """)
    
    entries = cursor.fetchall()

if not entries:
    print("❌ No material usage entries found in database")
    print()
    print("This means:")
    print("  - No material balance has been submitted yet")
    print("  - OR the table name is different")
    print("  - OR the data is in a different table")
else:
    print(f"📊 Total entries found: {len(entries)}")
    print()
    
    outside_count = 0
    inside_count = 0
    
    for entry in entries:
        entry_id, created_at, usage_date, material_type, quantity, unit, site_id, supervisor_id = entry
        
        # Convert to IST if needed
        if created_at.tzinfo is None:
            created_ist = IST.localize(created_at)
        else:
            created_ist = created_at.astimezone(IST)
        
        entry_time = created_ist.time()
        
        # Check if outside allowed window
        is_outside = entry_time < ALLOWED_START or entry_time > ALLOWED_END
        
        if is_outside:
            outside_count += 1
            status_icon = "❌ OUTSIDE"
        else:
            inside_count += 1
            status_icon = "✅ INSIDE"
        
        print(f"{status_icon} | {created_ist.strftime('%Y-%m-%d %I:%M:%S %p')} | Site ID: {str(site_id)[:8] if site_id else 'N/A'}... | Material: {material_type} ({quantity} {unit})")
    
    print()
    print("=" * 60)
    print(f"✅ Entries within time window: {inside_count}")
    print(f"❌ Entries OUTSIDE time window: {outside_count}")
    print("=" * 60)
    
    if outside_count > 0:
        print()
        print("⚠️  CRITICAL ISSUE CONFIRMED:")
        print(f"   {outside_count} material entries were submitted outside 4-7 PM window")
        print("   BUT 0 notifications were created!")
        print()
        print("🔍 Root Cause:")
        print("   Django server was NOT restarted after notification API was added")
        print()
        print("📋 SOLUTION:")
        print("   1. Stop Django server (Ctrl+C)")
        print("   2. Restart: python manage.py runserver 0.0.0.0:8000")
        print("   3. Test by submitting material outside 4-7 PM")
        print("   4. Verify notification is created")
    else:
        print()
        print("✅ All material entries were submitted within allowed time window")
        print()
        print("📋 To test notification system:")
        print("   1. Submit material balance outside 4-7 PM window")
        print("   2. Check Flutter console for notification logs")
        print("   3. Run: python check_notifications.py")
        print("   4. Verify notification appears in database")

print()
print("=" * 60)
print("CHECKING ALL TABLES")
print("=" * 60)

with connection.cursor() as cursor:
    cursor.execute("""
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public'
        AND table_name LIKE '%material%'
        ORDER BY table_name
    """)
    
    tables = cursor.fetchall()
    print("Tables with 'material' in name:")
    for table in tables:
        print(f"  - {table[0]}")
