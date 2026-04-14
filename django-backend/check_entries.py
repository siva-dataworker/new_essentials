import psycopg2

conn = psycopg2.connect(
    dbname='construction_db',
    user='postgres',
    password='admin',
    host='localhost'
)

cur = conn.cursor()

print("=" * 80)
print("SUPERVISOR ENTRIES (labour_entries table)")
print("=" * 80)
cur.execute("""
    SELECT 
        l.id,
        l.site_id,
        l.entry_date,
        l.labour_type,
        l.labour_count,
        u.full_name as supervisor_name,
        u.role as user_role
    FROM labour_entries l
    JOIN users u ON l.supervisor_id = u.id
    WHERE l.entry_date >= '2026-02-14'
    ORDER BY l.entry_date DESC, l.labour_type
""")
for row in cur.fetchall():
    print(row)

print("\n" + "=" * 80)
print("SITE ENGINEER ENTRIES (site_engineer_entries table)")
print("=" * 80)
cur.execute("""
    SELECT 
        se.id,
        se.site_id,
        se.entry_date,
        se.labour_type,
        se.labour_count,
        u.full_name as engineer_name,
        u.role as user_role
    FROM site_engineer_entries se
    JOIN users u ON se.site_engineer_id = u.id
    WHERE se.entry_date >= '2026-02-14'
    ORDER BY se.entry_date DESC, se.labour_type
""")
for row in cur.fetchall():
    print(row)

print("\n" + "=" * 80)
print("USER ROLES")
print("=" * 80)
cur.execute("""
    SELECT id, full_name, role, phone_number
    FROM users
    WHERE full_name IN ('aravind', 'shhsjs')
""")
for row in cur.fetchall():
    print(row)

conn.close()
