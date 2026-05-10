import psycopg2
from dotenv import load_dotenv
import os

load_dotenv()

# Database connection
conn = psycopg2.connect(
    host=os.getenv('DB_HOST'),
    port=os.getenv('DB_PORT'),
    database=os.getenv('DB_NAME'),
    user=os.getenv('DB_USER'),
    password=os.getenv('DB_PASSWORD')
)

cursor = conn.cursor()

# Check working_sites table
print("=" * 80)
print("WORKING SITES (assigned by accountants)")
print("=" * 80)
cursor.execute("""
    SELECT 
        ws.id,
        s.site_name,
        s.customer_name,
        s.area,
        s.street,
        ws.assigned_date,
        ws.is_active,
        u.full_name as supervisor_name
    FROM working_sites ws
    JOIN sites s ON ws.site_id = s.id
    LEFT JOIN users u ON ws.supervisor_id = u.id
    WHERE ws.is_active = TRUE
    ORDER BY ws.assigned_date DESC
""")

working_sites = cursor.fetchall()
print(f"\nTotal active working sites: {len(working_sites)}")
print("\nDetails:")
for ws in working_sites:
    print(f"  - {ws[2]} {ws[1]} ({ws[3]}, {ws[4]}) - Assigned to: {ws[7]} on {ws[5]}")

# Check unique sites (GROUP BY)
print("\n" + "=" * 80)
print("UNIQUE SITES (after GROUP BY)")
print("=" * 80)
cursor.execute("""
    SELECT 
        s.id,
        s.site_name,
        s.customer_name,
        s.area,
        s.street,
        COUNT(ws.id) as assignment_count
    FROM working_sites ws
    JOIN sites s ON ws.site_id = s.id
    WHERE ws.is_active = TRUE
    GROUP BY s.id, s.site_name, s.customer_name, s.area, s.street
    ORDER BY s.customer_name, s.site_name
""")

unique_sites = cursor.fetchall()
print(f"\nTotal unique sites: {len(unique_sites)}")
print("\nDetails:")
for site in unique_sites:
    print(f"  - {site[2]} {site[1]} ({site[3]}, {site[4]}) - Assigned {site[5]} times")

cursor.close()
conn.close()
