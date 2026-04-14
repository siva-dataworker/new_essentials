import psycopg2

conn = psycopg2.connect(
    dbname='construction_db',
    user='postgres',
    password='admin',
    host='localhost',
    port='5432'
)

cursor = conn.cursor()

# Get all tables with 'material' in the name
cursor.execute("""
    SELECT table_name 
    FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name LIKE '%material%'
    ORDER BY table_name
""")

print("Tables with 'material' in name:")
for row in cursor.fetchall():
    print(f"  - {row[0]}")

# Get all tables
cursor.execute("""
    SELECT table_name 
    FROM information_schema.tables 
    WHERE table_schema = 'public'
    ORDER BY table_name
""")

print("\nAll tables:")
for row in cursor.fetchall():
    print(f"  - {row[0]}")

cursor.close()
conn.close()
