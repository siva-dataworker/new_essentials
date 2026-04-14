"""
Create notifications for existing late entries
This will backfill notifications for material entries that were submitted outside allowed time
"""
import os
import django
import uuid
from datetime import datetime, time
import pytz

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.db import connection

# IST timezone
IST = pytz.timezone('Asia/Kolkata')

# Define allowed time window (4 PM - 7 PM IST)
ALLOWED_START = time(16, 0)  # 4:00 PM
ALLOWED_END = time(19, 0)    # 7:00 PM

print("=" * 80)
print("CREATING NOTIFICATIONS FOR EXISTING LATE ENTRIES")
print("=" * 80)

with connection.cursor() as cursor:
    # Get material entries outside time window
    cursor.execute("""
        SELECT 
            mu.id,
            mu.created_at,
            mu.usage_date,
            mu.material_type,
            mu.quantity_used,
            mu.unit,
            mu.site_id,
            mu.supervisor_id,
            s.site_name,
            u.full_name as supervisor_name
        FROM material_usage mu
        LEFT JOIN sites s ON mu.site_id = s.id
        LEFT JOIN users u ON mu.supervisor_id = u.id
        ORDER BY mu.created_at DESC
    """)
    
    entries = cursor.fetchall()
    
    if not entries:
        print("\n❌ No material entries found")
        exit()
    
    print(f"\n📊 Found {len(entries)} material entries")
    print("\nAnalyzing entries...")
    
    notifications_created = 0
    
    for entry in entries:
        entry_id, created_at, usage_date, material_type, quantity, unit, site_id, supervisor_id, site_name, supervisor_name = entry
        
        # Convert to IST if needed
        if created_at.tzinfo is None:
            created_ist = IST.localize(created_at)
        else:
            created_ist = created_at.astimezone(IST)
        
        entry_time = created_ist.time()
        
        # Check if outside allowed window
        is_outside = entry_time < ALLOWED_START or entry_time > ALLOWED_END
        
        if is_outside:
            # Check if notification already exists for this entry
            cursor.execute("""
                SELECT id FROM notifications 
                WHERE site_id = %s 
                AND supervisor_id = %s 
                AND entry_type = 'material'
                AND actual_time = %s
            """, (site_id, supervisor_id, created_ist))
            
            existing = cursor.fetchone()
            
            if existing:
                print(f"  ⏭️  Skipping: Notification already exists for {material_type} at {created_ist.strftime('%Y-%m-%d %I:%M %p')}")
                continue
            
            # Create notification
            notification_id = str(uuid.uuid4())
            
            # Determine message based on time
            if entry_time < ALLOWED_START:
                time_status = "before"
                message = f"Material balance submitted too early at {created_ist.strftime('%I:%M %p')} (allowed: 4:00 PM - 7:00 PM)"
            else:
                time_status = "after"
                message = f"Material balance submitted too late at {created_ist.strftime('%I:%M %p')} (allowed: 4:00 PM - 7:00 PM)"
            
            cursor.execute("""
                INSERT INTO notifications (
                    id, site_id, entry_type, message, actual_time,
                    supervisor_id, supervisor_name, site_name, is_read
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, (
                notification_id, 
                site_id, 
                'material', 
                message, 
                created_ist,
                supervisor_id, 
                supervisor_name or 'Unknown Supervisor', 
                site_name or 'Unknown Site',
                False
            ))
            
            notifications_created += 1
            print(f"  ✅ Created notification: {material_type} ({quantity} {unit}) at {created_ist.strftime('%Y-%m-%d %I:%M %p')} - {site_name}")
    
    # Commit all changes
    connection.commit()
    
    print("\n" + "=" * 80)
    print(f"✅ Created {notifications_created} notifications")
    print("=" * 80)
    
    # Show summary
    cursor.execute("""
        SELECT COUNT(*) as total, COUNT(*) FILTER (WHERE is_read = FALSE) as unread
        FROM notifications
    """)
    
    summary = cursor.fetchone()
    print(f"\n📊 Notification Summary:")
    print(f"  - Total notifications: {summary[0]}")
    print(f"  - Unread notifications: {summary[1]}")
    
    if notifications_created > 0:
        print("\n✅ Admin can now view these notifications in the Alerts tab!")
    else:
        print("\n⚠️  No new notifications created (all entries were within time window or already have notifications)")
