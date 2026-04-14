import psycopg2
from decouple import config

conn = psycopg2.connect(config('DATABASE_URL'))
cur = conn.cursor()

# Check timestamp columns in both tables
cur.execute("""
    SELECT 
        table_name,
        column_name, 
        data_type, 
        column_default
    FROM information_schema.columns 
    WHERE table_name IN ('labour_entries', 'material_balances')
        AND column_name IN ('entry_time', 'updated_at', 'entry_date', 'created_at')
    ORDER BY table_name, column_name
""")

print("\n=== TIMESTAMP COLUMNS ===")
for row in cur.fetchall():
    print(f"{row[0]}.{row[1]}: {row[2]} DEFAULT {row[3]}")

conn.close()
