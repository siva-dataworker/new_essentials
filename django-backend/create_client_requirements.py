"""
Create client_requirements table
"""
import os
import sys
import django

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import execute_query, fetch_all

def create_client_requirements_table():
    print("=" * 80)
    print("Creating client_requirements table...")
    print("=" * 80)
    
    # Create table
    create_table_query = """
        CREATE TABLE IF NOT EXISTS client_requirements (
            requirement_id UUID PRIMARY KEY,
            site_id UUID NOT NULL,
            description TEXT NOT NULL,
            amount DECIMAL(15, 2) NOT NULL,
            added_by UUID NOT NULL,
            added_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            status VARCHAR(50) DEFAULT 'Pending',
            FOREIGN KEY (site_id) REFERENCES sites(id) ON DELETE CASCADE,
            FOREIGN KEY (added_by) REFERENCES users(id) ON DELETE CASCADE
        );
    """
    
    try:
        execute_query(create_table_query)
        print("✅ Table created successfully")
    except Exception as e:
        print(f"⚠️  Table might already exist or error: {e}")
    
    # Create indexes
    print("\nCreating indexes...")
    
    index_queries = [
        "CREATE INDEX IF NOT EXISTS idx_client_requirements_site ON client_requirements(site_id);",
        "CREATE INDEX IF NOT EXISTS idx_client_requirements_date ON client_requirements(added_date DESC);"
    ]
    
    for query in index_queries:
        try:
            execute_query(query)
            print(f"✅ Index created: {query.split('idx_')[1].split(' ')[0]}")
        except Exception as e:
            print(f"⚠️  Index might already exist or error: {e}")
    
    # Verify table
    print("\nVerifying table structure...")
    verify_query = """
        SELECT column_name, data_type, is_nullable
        FROM information_schema.columns
        WHERE table_name = 'client_requirements'
        ORDER BY ordinal_position;
    """
    
    columns = fetch_all(verify_query)
    if columns:
        print("\n✅ Table structure:")
        for col in columns:
            print(f"  - {col['column_name']}: {col['data_type']} (nullable: {col['is_nullable']})")
    else:
        print("❌ Could not verify table structure")
    
    print("\n" + "=" * 80)
    print("✅ Client requirements table setup complete!")
    print("=" * 80)

if __name__ == '__main__':
    create_client_requirements_table()
