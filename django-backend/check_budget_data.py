import psycopg2
from dotenv import load_dotenv
import os

load_dotenv()

# Database connection
conn = psycopg2.connect(
    host=os.getenv('DB_HOST', 'localhost'),
    port=os.getenv('DB_PORT', '5432'),
    database=os.getenv('DB_NAME'),
    user=os.getenv('DB_USER'),
    password=os.getenv('DB_PASSWORD')
)

cursor = conn.cursor()

# Get all budget allocations
print("\n=== BUDGET ALLOCATIONS ===")
cursor.execute("""
    SELECT 
        sba.id,
        s.site_name,
        sba.total_budget,
        sba.client_balance,
        sba.status,
        sba.allocated_date,
        sba.updated_at
    FROM site_budget_allocation sba
    JOIN sites s ON sba.site_id = s.id
    ORDER BY sba.updated_at DESC
    LIMIT 10
""")

for row in cursor.fetchall():
    print(f"\nSite: {row[1]}")
    print(f"  Total Budget: ₹{row[2]:,.2f}")
    print(f"  Client Balance: ₹{row[3]:,.2f}" if row[3] else "  Client Balance: None")
    print(f"  Status: {row[4]}")
    print(f"  Allocated: {row[5]}")
    print(f"  Updated: {row[6]}")

# Get phase payments
print("\n\n=== PHASE PAYMENTS ===")
cursor.execute("""
    SELECT 
        s.site_name,
        pp.phase_number,
        pp.phase_amount,
        pp.payment_date,
        pp.created_at
    FROM budget_phase_payments pp
    JOIN sites s ON pp.site_id = s.id
    ORDER BY pp.created_at DESC
    LIMIT 10
""")

for row in cursor.fetchall():
    print(f"\nSite: {row[0]}")
    print(f"  Phase {row[1]}: ₹{row[2]:,.2f}")
    print(f"  Payment Date: {row[3]}")
    print(f"  Recorded: {row[4]}")

cursor.close()
conn.close()

print("\n✅ Done!")
