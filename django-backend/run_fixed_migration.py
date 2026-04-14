"""
Run fixed admin features migration
"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.db import connection

# Read the migration SQL
with open('admin_features_migration_fixed.sql', 'r') as f:
    sql = f.read()

# Execute the entire script
with connection.cursor() as cursor:
    try:
        print("Running migration...")
        cursor.execute(sql)
        print("✅ Migration completed successfully!")
    except Exception as e:
        print(f"✗ Migration failed: {e}")
        import traceback
        traceback.print_exc()

# Verify tables were created
with connection.cursor() as cursor:
    cursor.execute("""
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name IN ('site_metrics', 'site_documents', 'admin_access_log', 'work_notifications')
        ORDER BY table_name
    """)
    
    tables = cursor.fetchall()
    print("\n✅ New tables created:")
    for table in tables:
        print(f"  ✓ {table[0]}")
    
    # Check views
    cursor.execute("""
        SELECT table_name 
        FROM information_schema.views 
        WHERE table_schema = 'public' 
        AND table_name IN ('site_material_purchases', 'site_comparison_view')
        ORDER BY table_name
    """)
    
    views = cursor.fetchall()
    print("\n✅ New views created:")
    for view in views:
        print(f"  ✓ {view[0]}")
