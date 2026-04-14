# 🔧 Fix Database Connection Issue

## ❌ Current Problem
The Django backend cannot connect to the Supabase database:

**Error:**
```
connection to server at "18.176.230.146", port 5432 failed: 
FATAL: Tenant or user not found
```

## 🔍 Root Cause
The Supabase database credentials in `django-backend/.env` are **invalid or outdated**:
- Database user: `postgres.ctwthgjuccioxivnzifb`
- Database host: `aws-1-ap-northeast-1.pooler.supabase.com`
- The tenant/user no longer exists or credentials have changed

## 🚀 Solutions

### Option 1: Update Supabase Credentials (Recommended)

#### Step 1: Get New Supabase Credentials
1. Go to [https://supabase.com/dashboard](https://supabase.com/dashboard)
2. Log in to your Supabase account
3. Select your project (or create a new one)
4. Go to **Settings** → **Database**
5. Find **Connection String** section
6. Copy the **Connection Pooler** connection string (Transaction mode)

#### Step 2: Update `.env` File
Open `django-backend/.env` and update these values:

```env
# Supabase Database Configuration
DB_NAME=postgres
DB_USER=postgres.[YOUR_PROJECT_REF]
DB_PASSWORD=[YOUR_DATABASE_PASSWORD]
DB_HOST=[YOUR_POOLER_HOST].pooler.supabase.com
DB_PORT=5432
```

**Example:**
```env
DB_NAME=postgres
DB_USER=postgres.abcdefghijklmnop
DB_PASSWORD=YourSecurePassword123!
DB_HOST=aws-0-us-west-1.pooler.supabase.com
DB_PORT=5432
```

#### Step 3: Restart Backend
```bash
cd django-backend
python manage.py runserver
```

---

### Option 2: Use Local PostgreSQL Database

If you want to use a local database instead:

#### Step 1: Install PostgreSQL
1. Download from [https://www.postgresql.org/download/windows/](https://www.postgresql.org/download/windows/)
2. Install with default settings
3. Remember the password you set for `postgres` user

#### Step 2: Create Database
```bash
# Open PostgreSQL command line (psql)
psql -U postgres

# Create database
CREATE DATABASE construction_db;

# Exit
\q
```

#### Step 3: Update `.env` File
```env
# Local PostgreSQL Configuration
DB_NAME=construction_db
DB_USER=postgres
DB_PASSWORD=[YOUR_POSTGRES_PASSWORD]
DB_HOST=localhost
DB_PORT=5432
```

#### Step 4: Run Migrations
```bash
cd django-backend
python manage.py migrate
python manage.py createsuperuser
```

---

### Option 3: Use SQLite (Quick Testing)

For quick testing without PostgreSQL:

#### Step 1: Update `django-backend/backend/settings.py`
Find the `DATABASES` section and replace with:

```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}
```

#### Step 2: Run Migrations
```bash
cd django-backend
python manage.py migrate
python manage.py createsuperuser
```

---

## 🎯 Recommended Action

**Best Option**: Update Supabase credentials (Option 1)
- ✅ Cloud-hosted database
- ✅ No local installation needed
- ✅ Production-ready
- ✅ Automatic backups

**Alternative**: Use local PostgreSQL (Option 2) for development

## 📋 Quick Checklist

- [ ] Get new Supabase credentials from dashboard
- [ ] Update `django-backend/.env` file
- [ ] Restart Django backend
- [ ] Test connection: `python manage.py migrate`
- [ ] Verify backend is running without errors

## 🔗 Helpful Links

- **Supabase Dashboard**: https://supabase.com/dashboard
- **Supabase Database Docs**: https://supabase.com/docs/guides/database
- **Django Database Settings**: https://docs.djangoproject.com/en/stable/ref/settings/#databases

---

## 🚦 Current Status

**Backend**: ❌ Running but cannot connect to database
**Frontend**: ⏳ Waiting for device selection
**Database**: ❌ Invalid credentials

**Next Step**: Update database credentials and restart backend
