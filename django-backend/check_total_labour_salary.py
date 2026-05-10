"""
Check Total Labour Entries and Salary in Database
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
    print("TOTAL LABOUR ENTRIES AND SALARY REPORT")
    print("=" * 80)
    print()
    
    # 1. Total labour entries count
    cursor.execute("""
        SELECT COUNT(*) as total_entries
        FROM labour_entries
    """)
    result = cursor.fetchone()
    total_entries = result['total_entries']
    print(f"📊 Total Labour Entries: {total_entries}")
    print()
    
    # 2. Total labour entries by role
    cursor.execute("""
        SELECT 
            submitted_by_role,
            COUNT(*) as count
        FROM labour_entries
        GROUP BY submitted_by_role
        ORDER BY count DESC
    """)
    print("📋 Entries by Role:")
    for row in cursor.fetchall():
        print(f"   {row['submitted_by_role']}: {row['count']} entries")
    print()
    
    # 3. Total salary calculation
    cursor.execute("""
        SELECT 
            SUM(l.labour_count * 
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
                END
            ) as total_salary,
            SUM(l.labour_count) as total_workers
        FROM labour_entries l
    """)
    result = cursor.fetchone()
    total_salary = result['total_salary'] or 0
    total_workers = result['total_workers'] or 0
    
    print(f"💰 Total Labour Salary: {format_currency(total_salary)}")
    print(f"👷 Total Workers: {total_workers}")
    print()
    
    # 4. Salary by role
    cursor.execute("""
        SELECT 
            l.submitted_by_role,
            SUM(l.labour_count * 
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
                END
            ) as total_salary,
            SUM(l.labour_count) as total_workers,
            COUNT(*) as entry_count
        FROM labour_entries l
        GROUP BY l.submitted_by_role
        ORDER BY total_salary DESC
    """)
    print("💵 Salary Breakdown by Role:")
    for row in cursor.fetchall():
        salary = row['total_salary'] or 0
        print(f"   {row['submitted_by_role']}:")
        print(f"      Salary: {format_currency(salary)}")
        print(f"      Workers: {row['total_workers']}")
        print(f"      Entries: {row['entry_count']}")
    print()
    
    # 5. Salary by labour type
    cursor.execute("""
        SELECT 
            l.labour_type,
            SUM(l.labour_count * 
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
                END
            ) as total_salary,
            SUM(l.labour_count) as total_workers,
            COUNT(*) as entry_count,
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
            END as avg_daily_rate
        FROM labour_entries l
        GROUP BY l.labour_type
        ORDER BY total_salary DESC
    """)
    print("🔧 Salary Breakdown by Labour Type:")
    for row in cursor.fetchall():
        salary = row['total_salary'] or 0
        print(f"   {row['labour_type']}:")
        print(f"      Total Salary: {format_currency(salary)}")
        print(f"      Workers: {row['total_workers']}")
        print(f"      Entries: {row['entry_count']}")
        print(f"      Avg Daily Rate: ₹{row['avg_daily_rate']:.2f}")
    print()
    
    # 6. Salary by site
    cursor.execute("""
        SELECT 
            s.site_name,
            s.customer_name,
            s.area,
            s.street,
            SUM(l.labour_count * 
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
                END
            ) as total_salary,
            SUM(l.labour_count) as total_workers,
            COUNT(*) as entry_count
        FROM labour_entries l
        JOIN sites s ON l.site_id = s.id
        GROUP BY s.id, s.site_name, s.customer_name, s.area, s.street
        ORDER BY total_salary DESC
    """)
    print("🏗️ Salary Breakdown by Site:")
    for row in cursor.fetchall():
        salary = row['total_salary'] or 0
        site_display = f"{row['customer_name']} {row['site_name']}" if row['customer_name'] else row['site_name']
        print(f"   {site_display} ({row['area']}, {row['street']}):")
        print(f"      Total Salary: {format_currency(salary)}")
        print(f"      Workers: {row['total_workers']}")
        print(f"      Entries: {row['entry_count']}")
    print()
    
    # 7. Recent entries (last 10)
    cursor.execute("""
        SELECT 
            l.entry_date,
            l.labour_type,
            l.labour_count,
            l.submitted_by_role,
            s.site_name,
            s.customer_name,
            u.full_name as submitted_by,
            (l.labour_count * 
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
                END
            ) as total_cost
        FROM labour_entries l
        JOIN sites s ON l.site_id = s.id
        JOIN users u ON l.supervisor_id = u.id
        ORDER BY l.entry_date DESC, l.entry_time DESC
        LIMIT 10
    """)
    print("📅 Recent Labour Entries (Last 10):")
    for row in cursor.fetchall():
        site_display = f"{row['customer_name']} {row['site_name']}" if row['customer_name'] else row['site_name']
        print(f"   {row['entry_date']} - {site_display}")
        print(f"      {row['labour_type']}: {row['labour_count']} workers")
        print(f"      Cost: {format_currency(row['total_cost'])}")
        print(f"      By: {row['submitted_by']} ({row['submitted_by_role']})")
    print()
    
    print("=" * 80)
    print("END OF REPORT")
    print("=" * 80)
    
    cursor.close()
    conn.close()

if __name__ == '__main__':
    main()
