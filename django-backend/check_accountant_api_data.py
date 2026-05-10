"""
Check what data the Accountant API returns
"""
import psycopg2
from psycopg2.extras import RealDictCursor
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Database connection
def get_db_connection():
    return psycopg2.connect(
        host=os.getenv('DB_HOST', 'localhost'),
        port=os.getenv('DB_PORT', '5432'),
        database=os.getenv('DB_NAME', 'construction_db'),
        user=os.getenv('DB_USER', 'postgres'),
        password=os.getenv('DB_PASSWORD', 'postgres')
    )

def format_currency(amount):
    """Format currency in Indian style (Lakhs/Crores)"""
    if amount >= 10000000:
        return f"₹{amount / 10000000:.2f} Cr"
    elif amount >= 100000:
        return f"₹{amount / 100000:.2f} L"
    elif amount >= 1000:
        return f"₹{amount / 1000:.2f} K"
    else:
        return f"₹{amount:.2f}"

def main():
    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=RealDictCursor)
    
    print("=" * 80)
    print("ACCOUNTANT API DATA CHECK")
    print("=" * 80)
    print()
    
    # This is the exact query used by the accountant API (without labour_site_rates)
    cursor.execute("""
        SELECT
            l.id,
            l.site_id,
            l.labour_type,
            l.labour_count,
            l.entry_date,
            l.entry_time,
            l.notes,
            l.extra_cost,
            l.extra_cost_notes,
            l.submitted_by_role,
            s.site_name,
            s.customer_name,
            s.area,
            s.street,
            u.full_name as supervisor_name,
            u.username as supervisor_username,
            r.role_name as user_role,
            CASE l.labour_type
                WHEN 'General' THEN 600
                WHEN 'Mason' THEN 800
                WHEN 'Helper' THEN 500
                WHEN 'Carpenter' THEN 750
                WHEN 'Plumber' THEN 700
                WHEN 'Electrician' THEN 750
                WHEN 'Painter' THEN 650
                WHEN 'Tile Layer' THEN 700
                WHEN 'Tile Layerhelper' THEN 700
                WHEN 'Kambi Fitter' THEN 900
                WHEN 'Concrete Kot' THEN 950
                WHEN 'Pile Labour' THEN 800
                ELSE 900
            END AS daily_rate,
            (l.labour_count * CASE l.labour_type
                WHEN 'General' THEN 600
                WHEN 'Mason' THEN 800
                WHEN 'Helper' THEN 500
                WHEN 'Carpenter' THEN 750
                WHEN 'Plumber' THEN 700
                WHEN 'Electrician' THEN 750
                WHEN 'Painter' THEN 650
                WHEN 'Tile Layer' THEN 700
                WHEN 'Tile Layerhelper' THEN 700
                WHEN 'Kambi Fitter' THEN 900
                WHEN 'Concrete Kot' THEN 950
                WHEN 'Pile Labour' THEN 800
                ELSE 900
            END) AS total_cost
        FROM labour_entries l
        JOIN sites s ON l.site_id = s.id
        JOIN users u ON l.supervisor_id = u.id
        LEFT JOIN roles r ON u.role_id = r.id
        ORDER BY l.entry_date DESC, l.entry_time DESC
    """)
    
    entries = cursor.fetchall()
    
    print(f"📊 Total Labour Entries: {len(entries)}")
    print()
    
    # Calculate total salary
    total_salary = sum(entry['total_cost'] for entry in entries)
    total_workers = sum(entry['labour_count'] for entry in entries)
    
    print(f"💰 Total Labour Salary: {format_currency(total_salary)}")
    print(f"👷 Total Workers: {total_workers}")
    print()
    
    # Show each entry
    print("📋 All Labour Entries:")
    print()
    for i, entry in enumerate(entries, 1):
        site_display = f"{entry['customer_name']} {entry['site_name']}" if entry['customer_name'] else entry['site_name']
        print(f"{i}. {entry['entry_date']} - {site_display}")
        print(f"   Labour Type: {entry['labour_type']}")
        print(f"   Workers: {entry['labour_count']}")
        print(f"   Daily Rate: ₹{entry['daily_rate']}")
        print(f"   Total Cost: {format_currency(entry['total_cost'])}")
        print(f"   Submitted By: {entry['supervisor_name']} ({entry['submitted_by_role']})")
        if entry['extra_cost']:
            print(f"   Extra Cost: ₹{entry['extra_cost']} - {entry['extra_cost_notes']}")
        print()
    
    
    # Check if labour_site_rates table exists
    cursor.execute("""
        SELECT EXISTS (
            SELECT FROM information_schema.tables 
            WHERE table_name = 'labour_site_rates'
        )
    """)
    table_exists = cursor.fetchone()['exists']
    
    if table_exists:
        cursor.execute("""
            SELECT COUNT(*) as count FROM labour_site_rates
        """)
        lsr_count = cursor.fetchone()['count']
        print(f"🔧 Labour Site Rates: {lsr_count} custom rates defined")
        
        if lsr_count > 0:
            cursor.execute("""
                SELECT 
                    s.site_name,
                    s.customer_name,
                    lsr.labour_type,
                    lsr.daily_rate
                FROM labour_site_rates lsr
                JOIN sites s ON lsr.site_id = s.id
                ORDER BY s.site_name, lsr.labour_type
            """)
            print("\n📝 Custom Labour Rates:")
            for row in cursor.fetchall():
                site_display = f"{row['customer_name']} {row['site_name']}" if row['customer_name'] else row['site_name']
                print(f"   {site_display} - {row['labour_type']}: ₹{row['daily_rate']}/day")
    else:
        print("🔧 Labour Site Rates: Table does not exist (using default rates)")
    
    print()
    print("=" * 80)
    print("END OF REPORT")
    print("=" * 80)
    
    cursor.close()
    conn.close()

if __name__ == '__main__':
    main()
