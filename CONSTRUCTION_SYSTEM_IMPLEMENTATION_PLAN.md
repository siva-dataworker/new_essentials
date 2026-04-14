# Construction Management System - Implementation Plan

## ✅ Phase 1: Database & Backend Auth (COMPLETED)

### Created Files:
1. **`django-backend/construction_management_schema.sql`**
   - Complete PostgreSQL schema
   - 10 tables with proper relationships
   - Indexes for performance
   - Views for reporting
   - Functions for notifications
   - Sample admin user

2. **`django-backend/api/models_new.py`**
   - Django models matching the schema
   - All relationships defined
   - Proper indexes and constraints

3. **`django-backend/api/views_auth.py`**
   - Registration endpoint (with approval workflow)
   - Login endpoint (username/password)
   - Check approval status
   - Get roles
   - Admin: Get pending users
   - Admin: Approve/reject users

---

## 🔄 Phase 2: Apply Database Schema (NEXT STEP)

### Actions Required:

1. **Run the SQL schema on Supabase:**
   ```bash
   # Option A: Via Supabase Dashboard
   - Go to SQL Editor in Supabase
   - Copy content from construction_management_schema.sql
   - Execute

   # Option B: Via psql command line
   psql "postgresql://postgres.ctwthgjuccioxivnzifb:[PASSWORD]@aws-1-ap-northeast-1.pooler.supabase.com:5432/postgres" -f construction_management_schema.sql
   ```

2. **Update Django settings to use new models:**
   - Replace `api/models.py` with `api/models_new.py`
   - Run migrations

3. **Update Django URLs:**
   - Add auth endpoints to `api/urls.py`

4. **Test authentication flow:**
   - Register a user
   - Check pending status
   - Admin approves
   - User logs in

---

## 📋 Phase 3: Backend APIs (TO DO)

### 3.1 Common APIs (All Roles)
- [ ] Get areas list
- [ ] Get streets by area
- [ ] Get sites by area/street
- [ ] Get user profile
- [ ] Update user profile

### 3.2 Supervisor APIs
- [ ] Submit labour count (morning)
- [ ] Update material balance (evening)
- [ ] Upload site work images
- [ ] Get my sites
- [ ] Get today's entries

### 3.3 Site Engineer APIs
- [ ] Upload "Work Started" update
- [ ] Upload "Work Finished" images
- [ ] View complaints assigned to me
- [ ] Upload rectification proof
- [ ] Upload/download project files

### 3.4 Accountant APIs (3 separate logins)
- [ ] **Login 1 - Labour Verification:**
  - View labour counts
  - Modify labour count
  - Log modifications
- [ ] **Login 2 - Bills:**
  - Upload material bills
  - Track by material type
- [ ] **Login 3 - Extra Works:**
  - Upload extra work bills
  - Track payments
  - Mark as paid

### 3.5 Architect APIs
- [ ] Upload site estimations
- [ ] Upload revised plans
- [ ] Upload drawings/designs
- [ ] Raise complaints
- [ ] Verify rectified work

### 3.6 Owner/Chief Accountant APIs
- [ ] View labour summary
- [ ] View bills summary
- [ ] View P&L report
- [ ] Compare two sites
- [ ] View all notifications

### 3.7 Notification APIs
- [ ] Get my notifications
- [ ] Mark as read
- [ ] Trigger notification (background job)

---

## 🎨 Phase 4: Flutter Frontend (TO DO)

### 4.1 Remove Firebase/Google Auth
- [ ] Remove Firebase dependencies from `pubspec.yaml`
- [ ] Delete `google_auth_service.dart`
- [ ] Delete `firebase_config.py` from backend
- [ ] Remove Firebase initialization from `main.dart`

### 4.2 Create New Auth Screens
- [ ] **Registration Screen:**
  - Username, email, phone, password fields
  - Role dropdown
  - Submit → Show "Pending Approval" page
- [ ] **Login Screen:**
  - Username, password fields
  - Remember me checkbox
  - Login → Check status → Route to dashboard
- [ ] **Pending Approval Screen:**
  - Show message
  - Check status button
  - Auto-refresh every 30 seconds

### 4.3 Update Auth Service
- [ ] Create `auth_service.dart`:
  - register()
  - login()
  - checkStatus()
  - logout() // Clear token only
  - storeToken()
  - getToken()

### 4.4 Common UI Components
- [ ] Area dropdown widget
- [ ] Street dropdown widget
- [ ] Site selector widget (already exists, update)
- [ ] Date picker widget
- [ ] Image upload widget
- [ ] File upload widget

### 4.5 Role-Based Dashboards

#### Supervisor Dashboard
- [ ] Site selector (area → street → site)
- [ ] Morning section:
  - Labour count entry form
  - Submit button (disabled after submit)
- [ ] Evening section:
  - Material balance entry
  - Image upload
- [ ] View today's entries (read-only)

#### Site Engineer Dashboard
- [ ] Site selector
- [ ] Morning section (before 1 PM):
  - "Work Started" update
  - Image upload
- [ ] Evening section:
  - "Work Finished" images
- [ ] Complaints tab:
  - View assigned complaints
  - Upload rectification proof
- [ ] Files tab:
  - Upload/download project files

#### Accountant Dashboard (3 Tabs)
- [ ] **Tab 1 - Labour Verification:**
  - View labour counts from WhatsApp
  - Compare with supervisor data
  - Modify button
  - Modification log
- [ ] **Tab 2 - Bills:**
  - Material type selector
  - Upload bill form
  - Bills list by site
- [ ] **Tab 3 - Extra Works:**
  - Upload extra work bill
  - Payment tracking
  - Overdue alerts

#### Architect Dashboard
- [ ] Upload estimations
- [ ] Upload plans/drawings
- [ ] Raise complaint form
- [ ] View complaints
- [ ] Verify rectified work

#### Owner Dashboard
- [ ] Summary cards:
  - Total labour
  - Total materials cost
  - Total extra works
  - Profit/Loss
- [ ] Site comparison tool
- [ ] View all images
- [ ] View all plans
- [ ] Notifications list

### 4.6 Routing & Permissions
- [ ] Update `main.dart` with new auth flow
- [ ] Create route guards based on role
- [ ] Disable unauthorized features
- [ ] Show/hide UI based on permissions

---

## 🔔 Phase 5: Notifications System (TO DO)

### 5.1 Backend Notification Triggers
- [ ] Cron job: Check labour not entered (morning)
- [ ] Cron job: Check material balance not entered (evening)
- [ ] Cron job: Check work not started before 1 PM
- [ ] Trigger: Labour count modified
- [ ] Cron job: Check unpaid bills > 7 days
- [ ] Trigger: Complaint raised
- [ ] Trigger: Complaint resolved

### 5.2 Frontend Notification UI
- [ ] Notification bell icon
- [ ] Notification count badge
- [ ] Notification list screen
- [ ] Mark as read functionality
- [ ] Push notification setup (optional)

---

## 📊 Phase 6: Admin Panel (TO DO)

### 6.1 Admin Dashboard
- [ ] Pending approvals list
- [ ] Approve/reject buttons
- [ ] User management
- [ ] Site management
- [ ] System logs

### 6.2 Admin Features
- [ ] Create/edit sites
- [ ] Assign users to sites
- [ ] View audit logs
- [ ] Generate reports
- [ ] Export data

---

## 🧪 Phase 7: Testing & Deployment (TO DO)

### 7.1 Testing
- [ ] Test registration flow
- [ ] Test approval workflow
- [ ] Test each role's features
- [ ] Test notifications
- [ ] Test permissions
- [ ] Test on physical device

### 7.2 Deployment
- [ ] Deploy Django backend
- [ ] Configure production database
- [ ] Build Flutter APK
- [ ] Test on multiple devices
- [ ] User training

---

## 📝 Current Status

✅ **COMPLETED:**
- Database schema designed
- Django models created
- Authentication APIs created

🔄 **IN PROGRESS:**
- Applying database schema to Supabase

⏳ **NEXT STEPS:**
1. Run SQL schema on Supabase
2. Update Django to use new models
3. Test authentication endpoints
4. Start building Flutter auth screens

---

## 🚀 Quick Start Commands

### Apply Database Schema:
```bash
# Copy SQL to Supabase SQL Editor and run
# OR use psql:
cd django-backend
psql "your_connection_string" -f construction_management_schema.sql
```

### Update Django Models:
```bash
cd django-backend
# Backup old models
cp api/models.py api/models_old_backup.py
# Replace with new models
cp api/models_new.py api/models.py
# Run migrations
python manage.py makemigrations
python manage.py migrate
```

### Test Auth Endpoints:
```bash
# Register a user
curl -X POST http://localhost:8000/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{"username":"test","email":"test@test.com","phone":"1234567890","password":"test123","full_name":"Test User","role":"Supervisor"}'

# Login
curl -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"test123"}'
```

---

## 📞 Support

If you encounter any issues:
1. Check Django logs
2. Check Supabase logs
3. Verify database connection
4. Test endpoints with Postman/curl

---

**Last Updated:** December 20, 2025
**Status:** Phase 1 Complete, Phase 2 Ready to Start
