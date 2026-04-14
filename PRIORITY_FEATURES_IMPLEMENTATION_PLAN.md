# 🚀 PRIORITY FEATURES IMPLEMENTATION PLAN

## Implementation Order

### PHASE 1: Backend Foundation
1. Database schema updates
2. API endpoints for new features
3. Data models

### PHASE 2: HIGH PRIORITY Features
1. ✅ Accountant - Create New Sites (Center + button)
2. ✅ Accountant - Role-Based Filter (Supervisor/Site Engineer)
3. ✅ Site Engineer - History Tab
4. ✅ Site Engineer - Project Files Download

### PHASE 3: MEDIUM PRIORITY Features
5. ✅ Site Engineer - Photo Enforcement (Morning/Evening)
6. ✅ Accountant - Extra Cost from Site Engineer
7. ✅ Architect - Complaint Notifications

---

## DETAILED IMPLEMENTATION

### 1. ACCOUNTANT - CREATE NEW SITES ✅

**Backend**:
- API: `POST /api/sites/create`
- Fields: site_name, area, town, street, city, customer_name
- Auto-generate site ID
- Set created_by to accountant user_id

**Frontend**:
- Update bottom navigation to 5 items with center + button
- Create `create_site_screen.dart`
- Form with validation
- Success message and navigation

**Files**:
- `django-backend/api/views_construction.py` - Add create_site endpoint
- `otp_phone_auth/lib/screens/create_site_screen.dart` - New
- `otp_phone_auth/lib/screens/accountant_dashboard.dart` - Update nav
- `otp_phone_auth/lib/services/construction_service.dart` - Add createSite method

---

### 2. ACCOUNTANT - ROLE-BASED FILTER ✅

**Backend**:
- Extend existing endpoints to include `submitted_by_role` field
- Filter entries by role in queries

**Frontend**:
- Add toggle buttons in `accountant_site_detail_screen.dart`
- Filter displayed entries by selected role
- Show "All", "Supervisor", "Site Engineer" options

**Files**:
- `otp_phone_auth/lib/screens/accountant_site_detail_screen.dart` - Add filter UI

---

### 3. SITE ENGINEER - HISTORY TAB ✅

**Backend**:
- API: `GET /api/site-engineer/history`
- Return: photos, extra costs, notes with timestamps
- Group by date

**Frontend**:
- Create `site_engineer_history_screen.dart`
- Similar to supervisor history
- Show photos, extra costs, notes
- Grouped by date with timestamps

**Files**:
- `django-backend/api/views_site_engineer.py` - Add history endpoint
- `otp_phone_auth/lib/screens/site_engineer_history_screen.dart` - New
- Update Site Engineer dashboard to include History button

---

### 4. SITE ENGINEER - PROJECT FILES ✅

**Backend**:
- API: `GET /api/sites/{id}/project-files`
- Return list of files uploaded by architect
- Include file URLs, names, types, upload dates

**Frontend**:
- Create `project_files_screen.dart`
- List files with download buttons
- Open files in browser/viewer
- Show upload date and file type

**Files**:
- `django-backend/api/views_construction.py` - Add project_files endpoint
- `otp_phone_auth/lib/screens/project_files_screen.dart` - New
- Add "Project Files" button in Site Engineer site detail

---

### 5. SITE ENGINEER - PHOTO ENFORCEMENT ✅

**Backend**:
- Add `upload_time_type` field to work_updates table
- Validate time of day (morning: 6AM-12PM, evening: 4PM-8PM)
- Enforce one morning and one evening photo per day

**Frontend**:
- Update photo upload to specify morning/evening
- Show time validation messages
- Display morning/evening badges on photos

**Files**:
- `django-backend/add_photo_time_type.sql` - Migration
- `django-backend/api/views_site_engineer.py` - Update upload logic
- `otp_phone_auth/lib/screens/site_detail_screen.dart` - Update UI

---

### 6. ACCOUNTANT - EXTRA COST FROM SITE ENGINEER ✅

**Backend**:
- Extend extra_cost system to track `submitted_by_role`
- Update accountant endpoints to include SE extra costs
- Add role field to queries

**Frontend**:
- Display SE extra costs in accountant dashboard
- Show role badge (Supervisor/Site Engineer)
- Include in role-based filter

**Files**:
- `django-backend/add_submitted_by_role.sql` - Migration
- `django-backend/api/views_construction.py` - Update queries
- `otp_phone_auth/lib/screens/accountant_site_detail_screen.dart` - Display SE costs

---

### 7. ARCHITECT - COMPLAINT NOTIFICATIONS ✅

**Backend**:
- Create notifications table
- API: `POST /api/notifications/create`
- API: `GET /api/notifications/user/{user_id}`
- When complaint created → create notification for Site Engineer

**Frontend**:
- Add notification badge in app bar
- Create `notifications_screen.dart`
- Show unread count
- Mark as read functionality

**Files**:
- `django-backend/create_notifications_table.sql` - Migration
- `django-backend/api/views_notifications.py` - New
- `otp_phone_auth/lib/screens/notifications_screen.dart` - New
- Update all dashboards to show notification icon

---

## DATABASE MIGRATIONS NEEDED

```sql
-- 1. Add photo time type
ALTER TABLE work_updates 
ADD COLUMN upload_time_type VARCHAR(10) CHECK (upload_time_type IN ('morning', 'evening'));

-- 2. Add submitted_by_role to track who submitted extra costs
ALTER TABLE labour_entries 
ADD COLUMN submitted_by_role VARCHAR(20) DEFAULT 'Supervisor';

ALTER TABLE material_balances 
ADD COLUMN submitted_by_role VARCHAR(20) DEFAULT 'Supervisor';

-- 3. Create notifications table
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL,
    related_id UUID,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- 4. Ensure sites table has all location fields
ALTER TABLE sites 
ADD COLUMN IF NOT EXISTS town VARCHAR(100),
ADD COLUMN IF NOT EXISTS city VARCHAR(100);
```

---

## API ENDPOINTS TO ADD

1. `POST /api/sites/create` - Create new site (Accountant)
2. `GET /api/sites/{id}/project-files` - Get architect's uploaded files
3. `GET /api/site-engineer/history` - Site Engineer history
4. `POST /api/notifications/create` - Create notification
5. `GET /api/notifications/user/{user_id}` - Get user notifications
6. `PUT /api/notifications/{id}/read` - Mark notification as read

---

## TESTING CHECKLIST

### Accountant - Create Sites
- [ ] Center + button visible in bottom nav
- [ ] Form opens with all fields
- [ ] Validation works
- [ ] Site created successfully
- [ ] Site visible to Supervisor, Site Engineer, Accountant

### Accountant - Role Filter
- [ ] Filter buttons visible in site detail
- [ ] "All" shows all entries
- [ ] "Supervisor" shows only supervisor entries
- [ ] "Site Engineer" shows only SE entries
- [ ] Filter persists during session

### Site Engineer - History
- [ ] History button visible in SE dashboard
- [ ] Photos displayed with timestamps
- [ ] Extra costs shown
- [ ] Notes visible
- [ ] Grouped by date correctly

### Site Engineer - Project Files
- [ ] Project Files button visible
- [ ] Files list loads
- [ ] Download works
- [ ] File types displayed correctly
- [ ] Upload dates shown

### Photo Enforcement
- [ ] Morning upload (6AM-12PM) works
- [ ] Evening upload (4PM-8PM) works
- [ ] Outside time range shows error
- [ ] One photo per time slot enforced
- [ ] Badges show morning/evening

### SE Extra Costs
- [ ] SE can submit extra costs
- [ ] Accountant receives SE extra costs
- [ ] Role badge shows correctly
- [ ] Included in role filter

### Notifications
- [ ] Notification created on complaint
- [ ] Site Engineer receives notification
- [ ] Unread count shows
- [ ] Mark as read works
- [ ] Notification list displays correctly

---

## ESTIMATED COMPLETION TIME

- Phase 1 (Backend): 2-3 hours
- Phase 2 (High Priority): 3-4 hours
- Phase 3 (Medium Priority): 2-3 hours

**Total: 7-10 hours of development**

---

## NEXT STEPS

1. Run database migrations
2. Implement backend endpoints
3. Create frontend screens
4. Test each feature
5. Deploy and verify

Let's begin implementation! 🚀
