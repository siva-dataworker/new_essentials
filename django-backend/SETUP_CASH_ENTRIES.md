# Cash Entries Setup Guide

## Quick Setup

### Step 1: Create the Table
```bash
cd essential/essential/construction_flutter/django-backend
python create_cash_entries_table.py
```

Expected output:
```
🔧 Creating cash_entries table...
✅ cash_entries table created successfully!
✅ Table verified in database

📋 Table structure:
  Columns:
    - id: uuid (NOT NULL)
    - site_id: uuid (NOT NULL)
    - accountant_id: uuid (NOT NULL)
    - entry_date: date (NOT NULL)
    - source_type: character varying (NOT NULL)
    - source_entry_id: uuid (NULL)
    - labour_type: character varying (NOT NULL)
    - labour_count: integer (NOT NULL)
    - daily_rate: numeric (NOT NULL)
    - total_cost: numeric (NOT NULL)
    - notes: text (NULL)
    - submitted_by_name: character varying (NULL)
    - created_at: timestamp without time zone (NOT NULL)
    - updated_at: timestamp without time zone (NOT NULL)
```

### Step 2: Verify Table
```bash
python show_cash_entries.py
```

Expected output:
```
📊 Cash Entries Table Status

✅ Table exists: cash_entries

📋 Table Structure:
  - id (uuid)
  - site_id (uuid)
  - accountant_id (uuid)
  - entry_date (date)
  - source_type (character varying)
  - source_entry_id (uuid)
  - labour_type (character varying)
  - labour_count (integer)
  - daily_rate (numeric)
  - total_cost (numeric)
  - notes (text)
  - submitted_by_name (character varying)
  - created_at (timestamp without time zone)
  - updated_at (timestamp without time zone)

📊 Current Data:
  Total entries: 0

🔍 Constraints:
  - PRIMARY KEY: cash_entries_pkey
  - UNIQUE: cash_entries_site_id_entry_date_labour_type_key
  - FOREIGN KEY: cash_entries_accountant_id_fkey
  - FOREIGN KEY: cash_entries_site_id_fkey
  - CHECK: cash_entries_labour_count_check
  - CHECK: cash_entries_source_type_check

✅ Setup complete!
```

### Step 3: Test the System

1. **Start Backend**
   ```bash
   python manage.py runserver
   ```

2. **Start Flutter App**
   ```bash
   cd ../otp_phone_auth
   flutter run
   ```

3. **Test Flow**
   - Login as Supervisor
   - Submit labour entries
   - Login as Accountant
   - Go to Compare tab
   - Select and confirm entry
   - Login as Admin
   - Check Budget Utilization

## Troubleshooting

### Error: Table already exists
If you see this error, the table already exists. You can:
1. Drop and recreate: `DROP TABLE cash_entries CASCADE;`
2. Or skip this step and proceed to testing

### Error: Connection refused
Make sure PostgreSQL is running:
```bash
# Windows
net start postgresql-x64-14

# Linux/Mac
sudo service postgresql start
```

### Error: Permission denied
Make sure you have the correct database credentials in `.env` file:
```
DATABASE_URL=postgresql://username:password@localhost:5432/dbname
```

## Cleanup (if needed)

### Delete all cash entries
```bash
python delete_all_cash_entries.py
```

### Delete all labour entries
```bash
python delete_all_labour_entries.py
```

### Delete all utilization data
```bash
python delete_all_utilization_data.py
```

## Database Queries

### Check cash entries
```sql
SELECT * FROM cash_entries ORDER BY created_at DESC LIMIT 10;
```

### Check by site
```sql
SELECT * FROM cash_entries WHERE site_id = 'your-site-id' ORDER BY entry_date DESC;
```

### Check by date
```sql
SELECT * FROM cash_entries WHERE entry_date = '2026-05-08';
```

### Count entries per site
```sql
SELECT 
    s.customer_name || ' ' || s.site_name as site_name,
    COUNT(*) as entry_count,
    SUM(total_cost) as total_cost
FROM cash_entries ce
JOIN sites s ON ce.site_id = s.id
GROUP BY s.id, s.customer_name, s.site_name
ORDER BY total_cost DESC;
```

## Status Check

Run this to check the complete system status:
```bash
python check_utilization_data.py
```

This will show:
- Labour entries count
- Material usage count
- Labour cost calculations count
- Cash entries count
- Sample data from each table
