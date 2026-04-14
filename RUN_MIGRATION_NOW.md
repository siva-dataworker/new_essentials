# Run Database Migration - Simple Method

## Quick Fix for psycopg2 Error

You don't need psycopg2 installed separately. Use Django's built-in database tools instead.

## Method 1: Using Batch File (Easiest)

```bash
cd django-backend
run_migration.bat
```

This will automatically run the SQL migration.

## Method 2: Manual Command

```bash
cd django-backend
python manage.py dbshell < add_extra_cost_columns.sql
```

## Method 3: Using Django Shell

```bash
cd django-backend
python manage.py shell
```

Then paste this:

```python
from django.db import connection

with open('add_extra_cost_columns.sql', 'r') as f:
    sql = f.read()
    
with connection.cursor() as cursor:
    cursor.execute(sql)
    
print("✅ Migration completed!")
```

## Method 4: Direct SQL (If you have psql)

```bash
cd django-backend
psql -h your_host -U your_user -d your_database -f add_extra_cost_columns.sql
```

## After Migration:

1. Restart Django backend:
```bash
python manage.py runserver
```

2. Test the API to verify extra_cost fields work

## Verify Migration Worked:

Run this to check:

```bash
python manage.py dbshell
```

Then in the SQL prompt:

```sql
\d labour_entries
\d material_balances
```

You should see `extra_cost` and `extra_cost_notes` columns.

---

**Recommended**: Use Method 1 (run_migration.bat) - it's the simplest!
