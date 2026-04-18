# Essential Homes Construction App - Architecture

## ✅ Your API Endpoint is Correct

**Base URL**: `https://new-essentials.onrender.com/api`

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     FLUTTER APP                             │
│  (Mobile: Android/iOS | Web: Chrome/Safari)                 │
│                                                              │
│  - Login Screen                                              │
│  - Dashboard (Admin, Accountant, Supervisor, etc.)          │
│  - Site Management                                           │
│  - Photo Upload                                              │
│  - Document Upload                                           │
│  - Material Tracking                                         │
│  - Budget Management                                         │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   │ HTTPS API Calls
                   │ (JSON requests/responses)
                   ↓
┌─────────────────────────────────────────────────────────────┐
│              RENDER (Django Backend)                        │
│         https://new-essentials.onrender.com                 │
│                                                              │
│  Django REST Framework APIs:                                │
│  - /api/auth/login/          → Authentication              │
│  - /api/sites/               → Site management             │
│  - /api/construction/        → Entries (labour, material)  │
│  - /api/budget/              → Budget operations           │
│  - /api/notifications/       → Notifications               │
│  - /api/export/              → Excel exports               │
│  - /media/                   → Photos & documents          │
│                                                              │
│  Business Logic:                                             │
│  - User authentication (JWT tokens)                         │
│  - Data validation                                           │
│  - File uploads                                              │
│  - Excel generation                                          │
│  - Permissions & authorization                              │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   │ PostgreSQL Queries
                   │ (SQL commands)
                   ↓
┌─────────────────────────────────────────────────────────────┐
│           SUPABASE (PostgreSQL Database)                    │
│      db.ctwthgjuccioxivnzifb.supabase.co                   │
│                                                              │
│  Database Tables:                                            │
│  - auth_user              → User accounts                   │
│  - construction_role      → User roles                      │
│  - construction_userprofile → User profiles                 │
│  - construction_site      → Construction sites              │
│  - construction_labourentry → Labour entries                │
│  - construction_materialentry → Material entries            │
│  - construction_budget    → Budget data                     │
│  - construction_notification → Notifications                │
│  - construction_photo     → Photo metadata                  │
│  - construction_document  → Document metadata               │
│  - ... and more                                              │
│                                                              │
│  Data Storage:                                               │
│  - All user data                                             │
│  - All site data                                             │
│  - All entries (labour, material)                           │
│  - All budget information                                    │
│  - Photo & document metadata                                │
└─────────────────────────────────────────────────────────────┘
```

## How Authentication Works

### Login Flow:

```
1. User enters username & password in Flutter app
   ↓
2. Flutter sends POST to: https://new-essentials.onrender.com/api/auth/login/
   Body: {"username": "admin", "password": "admin123"}
   ↓
3. Render Django receives request
   ↓
4. Django queries Supabase database:
   SELECT * FROM auth_user WHERE username='admin'
   ↓
5. Supabase returns user data
   ↓
6. Django verifies password (hashed comparison)
   ↓
7. If correct: Django generates JWT token
   ↓
8. Django returns to Flutter:
   {
     "token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
     "user": {
       "id": 1,
       "username": "admin",
       "role": "admin",
       ...
     }
   }
   ↓
9. Flutter stores token and shows dashboard
```

### Subsequent API Calls:

```
1. Flutter makes API call with token in header:
   GET https://new-essentials.onrender.com/api/sites/
   Header: Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGc...
   ↓
2. Django verifies token
   ↓
3. Django queries Supabase for sites data
   ↓
4. Supabase returns sites
   ↓
5. Django returns JSON to Flutter
   ↓
6. Flutter displays sites in UI
```

## Data Flow Examples

### Example 1: Creating a Labour Entry

```
Flutter App (Supervisor enters labour data)
    ↓ POST /api/construction/labour-entry/
Render Django (Validates data, checks permissions)
    ↓ INSERT INTO construction_labourentry
Supabase (Stores the entry)
    ↓ Returns success
Render Django (Returns success response)
    ↓ Shows success message
Flutter App (Updates UI)
```

### Example 2: Uploading a Photo

```
Flutter App (User selects photo)
    ↓ POST /api/construction/upload-photo/ (multipart/form-data)
Render Django (Receives file, saves to /media/)
    ↓ INSERT INTO construction_photo (metadata)
Supabase (Stores photo metadata with file path)
    ↓ Returns photo ID
Render Django (Returns photo URL)
    ↓ Displays photo
Flutter App (Shows uploaded photo)
```

### Example 3: Viewing Budget

```
Flutter App (Admin opens budget screen)
    ↓ GET /api/budget/utilization/123/
Render Django (Checks user has admin role)
    ↓ SELECT * FROM construction_budget WHERE site_id=123
Supabase (Returns budget data)
    ↓ Calculates totals, percentages
Render Django (Returns formatted data)
    ↓ Displays charts and numbers
Flutter App (Shows budget dashboard)
```

## Why This Architecture?

### Render (Backend):
- ✅ Runs your Django code
- ✅ Handles business logic
- ✅ Manages authentication
- ✅ Processes file uploads
- ✅ Generates Excel reports
- ✅ Enforces permissions
- ❌ Does NOT store data permanently (ephemeral filesystem)

### Supabase (Database):
- ✅ Stores ALL data permanently
- ✅ Fast PostgreSQL queries
- ✅ Automatic backups
- ✅ Scalable storage
- ✅ Reliable and persistent
- ❌ Does NOT run application code

### Flutter (Frontend):
- ✅ User interface
- ✅ Makes API calls
- ✅ Displays data
- ✅ Handles user input
- ❌ Does NOT store data (except cache)
- ❌ Does NOT have direct database access

## Your Current Setup

### ✅ Correct Configuration:

1. **Flutter App**:
   - Base URL: `https://new-essentials.onrender.com/api` ✅
   - All service files updated ✅

2. **Render Backend**:
   - URL: `https://new-essentials.onrender.com` ✅
   - Django running ✅
   - Environment variables set ✅

3. **Supabase Database**:
   - Host: `db.ctwthgjuccioxivnzifb.supabase.co` ✅
   - Connected to Render ✅
   - Database: `postgres` ✅

### ⚠️ Missing Step:

**Database is empty!** You need to:
1. Run migrations (create tables)
2. Create users (admin, etc.)

## Quick Fix

Run these commands in Render Shell:

```bash
cd django-backend
python manage.py migrate          # Creates tables in Supabase
python manage.py createsuperuser  # Creates admin user in Supabase
```

Then login will work!

## Summary

**Your understanding is 100% correct!**

- ✅ API endpoint: `https://new-essentials.onrender.com/api`
- ✅ Data stored in: Supabase PostgreSQL database
- ✅ Render: Gets data from Supabase and checks authentication
- ✅ Flutter: Calls Render API, displays data

The only issue is the database is empty. Once you run migrations and create users, everything will work perfectly!

## Testing Your Setup

### 1. Test Backend is Running:
```bash
curl https://new-essentials.onrender.com/api/
```
✅ Should return JSON with API endpoints

### 2. Test Database Connection:
After running migrations and creating user:
```bash
curl -X POST https://new-essentials.onrender.com/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```
✅ Should return JWT token

### 3. Test in Flutter App:
- Open app
- Login with admin/admin123
- ✅ Should show dashboard

Everything is configured correctly. Just need to populate the database!
