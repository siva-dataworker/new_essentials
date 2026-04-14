"""
Check if client3 has any sites assigned and create the client_sites table if needed
"""
import psycopg2
import uuid

# Database connection parameters
DB_CONFIG = {
    'dbname': 'construction_db',
    'user': 'postgres',
    'password': 'admin123',
    'host': 'localhost',
    'port': '5432'
}

def check_and_fix_client_sites():
    """Check client3 site assignments and fix if needed"""
    try:
        # Connect to database
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()
        
        print("=" * 60)
        print("CHECKING CLIENT SITES")
        print("=" * 60)
        
        # Check if client_sites table exists
        cursor.execute("""
            SELECT EXISTS (
                SELECT FROM information_schema.tables 
                WHERE table_name = 'client_sites'
            )
        """)
        table_exists = cursor.fetchone()[0]
        
        if not table_exists:
            print("\n❌ client_sites table does NOT exist!")
            print("Creating client_sites table...")
            
            cursor.execute("""
                CREATE TABLE client_sites (
                    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                    client_id UUID REFERENCES users(id) ON DELETE CASCADE,
                    site_id UUID REFERENCES sites(id) ON DELETE CASCADE,
                    assigned_by UUID REFERENCES users(id) ON DELETE SET NULL,
                    assigned_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    is_active BOOLEAN DEFAULT TRUE,
                    UNIQUE(client_id, site_id)
                )
            """)
            
            cursor.execute("""
                CREATE INDEX IF NOT EXISTS idx_client_sites_client ON client_sites(client_id)
            """)
            cursor.execute("""
                CREATE INDEX IF NOT EXISTS idx_client_sites_site ON client_sites(site_id)
            """)
            cursor.execute("""
                CREATE INDEX IF NOT EXISTS idx_client_sites_active ON client_sites(is_active)
            """)
            
            conn.commit()
            print("✅ client_sites table created successfully!")
        else:
            print("\n✅ client_sites table exists")
        
        # Find client3
        cursor.execute("""
            SELECT u.id, u.username, u.full_name, r.role_name
            FROM users u
            JOIN roles r ON u.role_id = r.id
            WHERE u.username = 'client3'
        """)
        
        client = cursor.fetchone()
        
        if not client:
            print("\n❌ User 'client3' not found in database!")
            cursor.close()
            conn.close()
            return
        
        client_id, username, full_name, role = client
        print(f"\n✅ Found user: {username} ({full_name}) - Role: {role}")
        print(f"   Client ID: {client_id}")
        
        # Check assigned sites
        cursor.execute("""
            SELECT 
                cs.id,
                cs.site_id,
                s.site_name,
                s.customer_name,
                cs.assigned_date
            FROM client_sites cs
            JOIN sites s ON cs.site_id = s.id
            WHERE cs.client_id = %s AND cs.is_active = TRUE
        """, (client_id,))
        
        assigned_sites = cursor.fetchall()
        
        print(f"\n📍 Assigned Sites: {len(assigned_sites)}")
        
        if assigned_sites:
            print("\nSites assigned to client3:")
            for assignment_id, site_id, site_name, customer_name, assigned_date in assigned_sites:
                print(f"  - {customer_name} {site_name}")
                print(f"    Site ID: {site_id}")
                print(f"    Assigned: {assigned_date}")
        else:
            print("\n⚠️  No sites assigned to client3!")
            print("\nTo assign sites:")
            print("1. Login as Admin in the app")
            print("2. Go to Profile > Create User")
            print("3. Edit client3 or create a new client")
            print("4. Select sites when creating/editing")
            print("\nOR manually assign sites using SQL:")
            
            # Get first available site
            cursor.execute("""
                SELECT id, site_name, customer_name
                FROM sites
                LIMIT 3
            """)
            
            available_sites = cursor.fetchall()
            if available_sites:
                print("\nAvailable sites:")
                for site_id, site_name, customer_name in available_sites:
                    print(f"  - {customer_name} {site_name} (ID: {site_id})")
                
                print("\nTo assign first site to client3, run:")
                first_site_id = available_sites[0][0]
                print(f"""
INSERT INTO client_sites (id, client_id, site_id)
VALUES ('{uuid.uuid4()}', '{client_id}', '{first_site_id}');
                """)
        
        # Close connection
        cursor.close()
        conn.close()
        
        print("\n" + "=" * 60)
        
    except Exception as e:
        print(f"\n❌ Error: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    check_and_fix_client_sites()
