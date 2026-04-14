import psycopg2
from datetime import datetime, time
import pytz

# Database connection
conn = psycopg2.connect(
    dbname='construction_db',
    user='postgres',
    password='admin',
    host='localhost',
    port='5432'
)

cursor = conn.cursor()

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

# Get all material usage entries with their creation times
cursor.execute("""
    SELECT 
        mu.id,
        mu.created_at,
        mu.usage_date,
        mu.material_type,
        mu.quantity_used,
        mu.unit,
        s.site_name,
        u.name as supervisor_name
    FROM material_usage mu
    LEFT JOIN sites s ON mu.site_id = s.id
    LEFT JOIN users u ON mu.supervisor_id = u.user_id
    ORDER BY mu.created_at DESC
    LIMIT 50
""")

entries = cursor.fetchall()

if not entries:
    print("❌ No material usage entries found in database")
else:
    print(f"📊 Total entries found: {len(entries)}")
    print()
    
    outside_count = 0
    inside_count = 0
    
    for entry in entries:
        entry_id, created_at, usage_date, material_type, quantity, unit, site_name, supervisor = entry
        
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
        
        print(f"{status_icon} | {created_ist.strftime('%Y-%m-%d %I:%M:%S %p')} | Site: {site_name or 'N/A'} | Material: {material_type} ({quantity} {unit})")
    
    print()
    print("=" * 60)
    print(f"✅ Entries within time window: {inside_count}")
    print(f"❌ Entries OUTSIDE time window: {outside_count}")
    print("=" * 60)
    
    if outside_count > 0:
        print()
        print("⚠️  ISSUE FOUND:")
        print(f"   {outside_count} material entries were submitted outside 4-7 PM window")
        print("   These should have triggered admin notifications")
        print()
        print("🔍 Possible reasons notifications weren't sent:")
        print("   1. Django server not restarted after notification API was added")
        print("   2. Flutter app notification service has authentication issues")
        print("   3. Network connectivity problems between app and backend")
        print("   4. Time validation logic not properly integrated")
        print()
        print("📋 Next steps:")
        print("   1. Restart Django server: python manage.py runserver 0.0.0.0:8000")
        print("   2. Check notifications table: python check_notifications.py")
        print("   3. Test by submitting material outside 4-7 PM window")
        print("   4. Check Flutter console for notification logs")

cursor.close()
conn.close()
