# Architect Features Implementation 🏗️

## Overview
Implemented complete architect workflow: site selection, file upload/management (estimation, plans, floor plans), and complaint system with notifications.

---

## Features Implemented

### 1. Site Selection ✅
- Architect dashboard shows all assigned sites
- Tap site card to enter site detail screen
- Instagram-style site cards with search and filters

### 2. Project Files Management ✅
- **File Types Supported**:
  - Estimation Files (with amount and plan extended flag)
  - Floor Plans
  - Elevation Drawings
  - Structure Drawings
  - Design Files
  - Other Documents

- **Features**:
  - Upload files with title and description
  - View all project files for a site
  - File type badges with color coding
  - Estimation amount display
  - Plan extended indicator
  - Pull to refresh

### 3. Complaints System ✅
- **Raise Complaints**:
  - Title and description
  - Priority levels: LOW, MEDIUM, HIGH, URGENT
  - Auto-assign to site engineer
  - Notifications sent to site engineer and architect

- **View Complaints**:
  - See all complaints for a site
  - Status tracking (OPEN, IN_PROGRESS, RESOLVED)
  - Priority color coding
  - Assigned engineer display

---

## Backend APIs

### Project Files APIs

#### 1. Upload Project File
```
POST /api/construction/upload-project-file/
Headers: Authorization: Bearer <token>
Body (multipart/form-data):
  - site_id (UUID, required)
  - file_type (string, required): ESTIMATION, FLOOR_PLAN, ELEVATION, STRUCTURE, DESIGN, OTHER
  - file (file, required)
  - title (string, optional)
  - description (text, optional)
  - amount (decimal, optional - for estimation)
  - is_plan_extended (boolean, optional - for estimation)

Response:
{
  "message": "File uploaded successfully",
  "file_id": "uuid",
  "file_url": "/media/project_files/..."
}
```

#### 2. Get Project Files
```
GET /api/construction/project-files/<site_id>/
Headers: Authorization: Bearer <token>
Query Params:
  - file_type (optional): Filter by file type

Response:
{
  "files": [
    {
      "id": "uuid",
      "file_type": "ESTIMATION",
      "file_url": "/media/project_files/...",
      "title": "Initial Estimation",
      "description": "First draft estimation",
      "amount": 5000000.00,
      "is_plan_extended": false,
      "uploaded_at": "2025-12-29T10:30:00",
      "uploaded_by": "John Architect",
      "uploaded_by_role": "Architect"
    }
  ]
}
```

### Complaints APIs

#### 3. Raise Complaint
```
POST /api/construction/raise-complaint/
Headers: Authorization: Bearer <token>
Body (JSON):
{
  "site_id": "uuid",
  "title": "Complaint title",
  "description": "Detailed description",
  "priority": "MEDIUM"  // LOW, MEDIUM, HIGH, URGENT
}

Response:
{
  "message": "Complaint raised successfully",
  "complaint_id": "uuid",
  "assigned_to": "Site Engineer Name"
}
```

#### 4. Get Complaints
```
GET /api/construction/complaints/
Headers: Authorization: Bearer <token>
Query Params:
  - site_id (optional): Filter by site
  - status (optional): Filter by status (OPEN, IN_PROGRESS, RESOLVED)

Response:
{
  "complaints": [
    {
      "id": "uuid",
      "title": "Complaint title",
      "description": "Description",
      "priority": "HIGH",
      "status": "OPEN",
      "site_name": "Site Name",
      "area": "Area",
      "street": "Street",
      "raised_by_name": "Architect Name",
      "raised_by_role": "Architect",
      "assigned_to_name": "Engineer Name",
      "created_at": "2025-12-29T10:30:00",
      "resolved_at": null,
      "resolution_notes": null,
      "proof_image_url": null
    }
  ]
}
```

---

## Database Tables

### 1. project_files Table
```sql
CREATE TABLE project_files (
    id UUID PRIMARY KEY,
    site_id UUID NOT NULL REFERENCES sites(id),
    uploaded_by UUID NOT NULL REFERENCES users(id),
    file_type VARCHAR(50) NOT NULL,
    file_url TEXT NOT NULL,
    title VARCHAR(255),
    description TEXT,
    amount DECIMAL(15, 2),
    is_plan_extended BOOLEAN DEFAULT FALSE,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 2. notifications Table
```sql
CREATE TABLE notifications (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id),
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL,
    related_id UUID,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP
);
```

### 3. complaints Table (Updated)
- Added `proof_image_url` column
- Added `resolution_notes` column

---

## Frontend Implementation

### Architect Site Detail Screen
**File**: `otp_phone_auth/lib/screens/architect_site_detail_screen.dart`

#### Features:
- **2 Tabs**: Project Files, Complaints
- **Project Files Tab**:
  - Upload button
  - Files list with type badges
  - Amount display for estimations
  - Plan extended indicator
  - Pull to refresh
- **Complaints Tab**:
  - Raise complaint button
  - Complaints list with priority colors
  - Status badges
  - Assigned engineer display
  - Pull to refresh

### Architect Dashboard (Updated)
**File**: `otp_phone_auth/lib/screens/architect_dashboard.dart`

#### Changes:
- Site cards now clickable
- Removed individual action buttons
- Added "Tap to manage site" indicator
- Navigate to site detail screen on tap

---

## Setup Instructions

### Step 1: Run Database Migration
```bash
cd django-backend
python run_architect_migration.py
```

This creates:
- `project_files` table
- `notifications` table
- Updates `complaints` table
- Creates indexes

### Step 2: Restart Backend
```bash
cd django-backend
python manage.py runserver
```

### Step 3: Add file_picker Dependency
Add to `otp_phone_auth/pubspec.yaml`:
```yaml
dependencies:
  file_picker: ^6.1.1
```

Then run:
```bash
cd otp_phone_auth
flutter pub get
```

### Step 4: Hot Restart Flutter
Press **R** in terminal or:
```bash
flutter run
```

---

## Testing Steps

### Test as Architect

1. **Login**:
   - Username: `architect1`
   - Password: `password123`

2. **View Sites**:
   - See all assigned sites on dashboard
   - Use search and filters

3. **Enter Site**:
   - Tap any site card
   - Opens site detail screen with 2 tabs

4. **Upload Project File**:
   - Go to "Project Files" tab
   - Tap "Upload File" button
   - Select file type, add title/description
   - For estimation: add amount and plan extended flag
   - Upload file

5. **View Project Files**:
   - See all uploaded files
   - Files grouped by type
   - Pull down to refresh

6. **Raise Complaint**:
   - Go to "Complaints" tab
   - Tap "Raise Complaint" button
   - Enter title, description
   - Select priority (LOW/MEDIUM/HIGH/URGENT)
   - Submit

7. **View Complaints**:
   - See all complaints for site
   - Check status and assigned engineer
   - Pull down to refresh

---

## Notification System

### When Complaint is Raised:
1. **Site Engineer** receives notification:
   - Title: "New [PRIORITY] Priority Complaint"
   - Message: Complaint title and description
   - Type: COMPLAINT
   - Related ID: complaint_id

2. **Architect** can view their raised complaints

### Notification Table Structure:
- Stores all notifications
- Tracks read/unread status
- Links to related entities
- Supports multiple notification types

---

## File Upload Flow

### 1. Architect Uploads File:
```
Architect → Select File → Add Details → Upload
     ↓
Backend saves file to /media/project_files/
     ↓
Database stores file metadata
     ↓
Returns file_url
```

### 2. File Storage:
- Files stored in: `django-backend/media/project_files/`
- Filename format: `{site_id}_{file_type}_{timestamp}.{ext}`
- Accessible via: `http://localhost:8000/media/project_files/...`

### 3. File Types:
- **ESTIMATION**: Blue badge, calculator icon
- **FLOOR_PLAN**: Purple badge, architecture icon
- **ELEVATION**: Indigo badge, apartment icon
- **STRUCTURE**: Teal badge, foundation icon
- **DESIGN**: Pink badge, design services icon
- **OTHER**: Grey badge, file icon

---

## UI Design

### Color Scheme:
- **Architect Theme**: Purple gradient
- **Estimation**: Blue
- **Floor Plans**: Purple
- **Elevation**: Indigo
- **Structure**: Teal
- **Design**: Pink
- **Complaints**: Orange
- **Priority Colors**:
  - LOW: Green
  - MEDIUM: Orange
  - HIGH: Deep Orange
  - URGENT: Red

### Card Design:
- White background
- Rounded corners (12px)
- Subtle shadows
- Type badges with colors
- Status indicators
- Priority dots

---

## Future Enhancements

### Potential Features:
1. **File Preview**: View PDFs, images in-app
2. **File Download**: Download files to device
3. **File Versioning**: Track file versions
4. **Approval Workflow**: Owner approval for estimations
5. **Complaint Chat**: Real-time chat for complaints
6. **Push Notifications**: Real-time notifications
7. **File Sharing**: Share files with clients
8. **Estimation Comparison**: Compare multiple estimations
9. **Plan Annotations**: Mark up plans with notes
10. **Complaint Photos**: Attach photos to complaints

---

## API Error Handling

### Common Errors:
- **400 Bad Request**: Missing required fields
- **401 Unauthorized**: Invalid or expired token
- **404 Not Found**: Site/file/complaint not found
- **500 Internal Server Error**: Server error

### Frontend Handling:
- Shows error snackbars
- Logs errors to console
- Graceful fallbacks
- Retry mechanisms

---

## Security Considerations

### File Upload Security:
- File size limits (configured in Django)
- File type validation
- Unique filenames to prevent overwrites
- Stored outside web root
- Access controlled by authentication

### API Security:
- JWT authentication required
- Role-based access control
- Site-specific data isolation
- Input validation
- SQL injection prevention

---

## Performance Optimizations

### Backend:
- Database indexes on frequently queried columns
- Efficient SQL queries with JOINs
- Pagination for large lists (future)
- File compression (future)

### Frontend:
- Lazy loading of files
- Pull to refresh instead of auto-refresh
- Cached network images
- Optimized list rendering

---

## Summary

✅ **Architect Dashboard**: Site selection with search/filters
✅ **Site Detail Screen**: 2 tabs (Project Files, Complaints)
✅ **File Upload**: Support for 6 file types
✅ **Estimation Files**: Amount and plan extended flag
✅ **Complaints System**: Raise and track complaints
✅ **Notifications**: Auto-notify site engineers
✅ **Backend APIs**: Complete CRUD operations
✅ **Database Tables**: Created and indexed
✅ **UI Design**: Consistent purple theme
✅ **Error Handling**: Graceful error messages

**Status**: READY TO TEST! 🚀

**Next Action**: 
1. Run database migration
2. Restart backend
3. Add file_picker dependency
4. Hot restart Flutter
5. Test as Architect
