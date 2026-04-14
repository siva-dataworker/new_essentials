"""
Add test data for admin features
"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.db import connection

with connection.cursor() as cursor:
    # Get first site ID
    cursor.execute("SELECT id, site_name FROM sites LIMIT 3")
    sites = cursor.fetchall()
    
    if not sites:
        print("❌ No sites found! Please create sites first.")
        exit(1)
    
    print(f"✅ Found {len(sites)} sites")
    for site in sites:
        print(f"  - {site[1]} ({site[0]})")
    
    site1_id = sites[0][0]
    site2_id = sites[1][0] if len(sites) > 1 else site1_id
    
    # Get first user ID (admin)
    cursor.execute("SELECT id, username FROM users WHERE username LIKE '%admin%' LIMIT 1")
    admin = cursor.fetchone()
    
    if not admin:
        cursor.execute("SELECT id, username FROM users LIMIT 1")
        admin = cursor.fetchone()
    
    if not admin:
        print("❌ No users found!")
        exit(1)
    
    admin_id = admin[0]
    print(f"\n✅ Using admin user: {admin[1]} ({admin_id})")
    
    # 1. Add site metrics
    print("\n📊 Adding site metrics...")
    for i, site in enumerate(sites[:2], 1):
        site_id = site[0]
        built_up = 5000.00 - (i * 500)
        project_value = 50000000.00 - (i * 5000000)
        total_cost = 45000000.00 - (i * 4500000)
        profit_loss = project_value - total_cost
        
        cursor.execute("""
            INSERT INTO site_metrics (site_id, built_up_area, project_value, total_cost, profit_loss)
            VALUES (%s, %s, %s, %s, %s)
            ON CONFLICT (site_id) DO UPDATE 
            SET built_up_area = EXCLUDED.built_up_area,
                project_value = EXCLUDED.project_value,
                total_cost = EXCLUDED.total_cost,
                profit_loss = EXCLUDED.profit_loss
        """, [site_id, built_up, project_value, total_cost, profit_loss])
        print(f"  ✓ Added metrics for {site[1]}")
    
    # 2. Add site documents
    print("\n📄 Adding site documents...")
    doc_types = [
        ('PLAN', 'Ground Floor Plan', '/uploads/plans/ground_floor.pdf'),
        ('PLAN', 'First Floor Plan', '/uploads/plans/first_floor.pdf'),
        ('ELEVATION', 'Front Elevation', '/uploads/elevations/front.pdf'),
        ('ELEVATION', 'Side Elevation', '/uploads/elevations/side.pdf'),
        ('STRUCTURE', 'Foundation Drawing', '/uploads/structure/foundation.pdf'),
        ('STRUCTURE', 'Beam Layout', '/uploads/structure/beams.pdf'),
        ('FINAL_OUTPUT', 'Completed Building - Front', '/uploads/final/front.jpg'),
        ('FINAL_OUTPUT', 'Completed Building - Side', '/uploads/final/side.jpg'),
    ]
    
    for doc_type, doc_name, file_path in doc_types:
        cursor.execute("""
            INSERT INTO site_documents (site_id, document_type, document_name, file_path, uploaded_by)
            VALUES (%s, %s, %s, %s, %s)
        """, [site1_id, doc_type, doc_name, file_path, admin_id])
    print(f"  ✓ Added {len(doc_types)} documents for {sites[0][1]}")
    
    # 3. Add work notifications
    print("\n🔔 Adding work notifications...")
    notifications = [
        ('WORK_NOT_DONE', 'Labour count not entered for yesterday'),
        ('MISSING_DATA', 'Material balance missing for 3 days'),
        ('PENDING_APPROVAL', 'Bills pending verification'),
    ]
    
    for notif_type, message in notifications:
        cursor.execute("""
            INSERT INTO work_notifications (site_id, notification_type, message, sent_to, is_read)
            VALUES (%s, %s, %s, %s, %s)
        """, [site1_id, notif_type, message, admin_id, False])
    print(f"  ✓ Added {len(notifications)} notifications")
    
    # 4. Update user access types
    print("\n👤 Setting up specialized access users...")
    cursor.execute("""
        UPDATE users 
        SET access_type = 'FULL_ACCOUNTS' 
        WHERE username LIKE '%admin%' OR username LIKE '%account%'
    """)
    print("  ✓ Set Admin/Accountant users to FULL_ACCOUNTS access")
    
    cursor.execute("""
        UPDATE users 
        SET access_type = 'STANDARD' 
        WHERE access_type IS NULL
    """)
    print("  ✓ Set default access type for other users")
    
    # 5. Log some admin access
    print("\n📝 Adding sample access logs...")
    cursor.execute("""
        INSERT INTO admin_access_log (user_id, access_type, site_id)
        VALUES 
            (%s, 'FULL_ACCOUNTS', %s),
            (%s, 'LABOUR_COUNT', %s),
            (%s, 'BILLS_VIEW', %s)
    """, [admin_id, site1_id, admin_id, site1_id, admin_id, site1_id])
    print("  ✓ Added 3 access log entries")

print("\n" + "="*50)
print("✅ Test data added successfully!")
print("\nYou can now test:")
print("  1. Labour Count View - will show labour entries")
print("  2. Bills Viewing - will show material bills")
print("  3. Complete Accounts - will show P/L metrics")
print("  4. Site Comparison - compare the 2 sites")
print("  5. Material Purchases - view material breakdown")
print("  6. Site Documents - view 8 sample documents")
print("  7. Notifications - 3 unread notifications")
