# 👷 Site Engineer Photo Upload Feature - Implementation Plan

## Requirements Summary

### Core Features
1. **Instagram-style site cards** on dashboard
2. **Twice-daily photo uploads**:
   - Morning: "Work Started" (before work begins)
   - Evening: "Work Completed" (after work ends)
3. **Photo visibility**: Site Engineer, Supervisor, Architect, Accountant, Owner
4. **Site-specific uploads**: Photos tied to specific site cards

## Current Status

### ✅ Already Implemented
- Site Engineer dashboard exists
- Site cards display (basic)
- Backend API endpoints for photo uploads exist in `views_construction.py`:
  - `upload_work_started()` - Morning photos
  - `upload_work_finished()` - Evening photos
- Database table: `work_updates` stores photos

### ❌ Not Implemented
- Photo upload UI for Site Engineer
- Photo gallery/viewer for all roles
- Time restrictions (morning/evening)
- Photo display in site cards
- Image picker integration
- Image upload to server/cloud storage

## Implementation Steps

### Phase 1: Backend Preparation (30 minutes)

#### 1.1 Update Database Schema
Ensure `work_updates` table has:
```sql
- id (UUID)
- site_id (FK to sites)
- engineer_id (FK to users)
- update_type ('STARTED' or 'FINISHED')
- image_url (TEXT)
- description (TEXT)
- update_date (DATE)
- created_at (TIMESTAMP)
- visible_to_client (BOOLEAN)
```

#### 1.2 Add Photo Retrieval API
**File:** `django-backend/api/views_construction.py`

```python
@api_view(['GET'])
def get_site_photos(request, site_id):
    """Get all photos for a specific site"""
    photos = fetch_all("""
        SELECT 
            w.id,
            w.update_type,
            w.image_url,
            w.description,
            w.update_date,
            w.created_at,
            u.full_name as uploaded_by
        FROM work_updates w
        JOIN users u ON w.engineer_id = u.id
        WHERE w.site_id = %s
        ORDER BY w.created_at DESC
    """, (site_id,))
    
    return Response({'photos': photos})
```

### Phase 2: Image Storage Solution (1 hour)

#### Option A: Local File Storage (Simpler)
- Store images in `django-backend/media/site_photos/`
- Serve via Django static files
- Good for development/testing

#### Option B: Cloud Storage (Production)
- Use AWS S3, Google Cloud Storage, or Cloudinary
- Better for production
- Requires additional setup

**Recommendation:** Start with Option A, migrate to Option B later

#### 2.1 Configure Django Media Files
**File:** `django-backend/backend/settings.py`

```python
MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'media')
```

#### 2.2 Update Upload Endpoint
**File:** `django-backend/api/views_construction.py`

```python
@api_view(['POST'])
def upload_work_photo(request):
    """Upload work photo (started or finished)"""
    site_id = request.data.get('site_id')
    update_type = request.data.get('update_type')  # 'STARTED' or 'FINISHED'
    description = request.data.get('description', '')
    photo = request.FILES.get('photo')
    
    # Save photo to media folder
    # Generate unique filename
    # Store in database
    # Return photo URL
```

### Phase 3: Flutter Frontend (3-4 hours)

#### 3.1 Add Image Picker Dependency
**File:** `otp_phone_auth/pubspec.yaml`

```yaml
dependencies:
  image_picker: ^1.0.7
  http: ^1.2.0
  cached_network_image: ^3.3.1
```

#### 3.2 Create Site Engineer Dashboard
**File:** `otp_phone_auth/lib/screens/site_engineer_dashboard.dart`

Features:
- Instagram-style site cards
- Tap card to open site detail
- Show photo upload status (morning/evening)
- Visual indicators for uploaded photos

#### 3.3 Create Photo Upload Screen
**File:** `otp_phone_auth/lib/screens/site_engineer_photo_upload_screen.dart`

Features:
- Camera/gallery picker
- Morning/Evening mode selection
- Time validation (morning before 1 PM, evening after)
- Description input
- Upload progress indicator
- Preview before upload

#### 3.4 Create Photo Gallery Screen
**File:** `otp_phone_auth/lib/screens/site_photo_gallery_screen.dart`

Features:
- Grid view of all photos for a site
- Filter by date
- Filter by type (Started/Finished)
- Full-screen photo viewer
- Swipe between photos
- Show upload date and time

#### 3.5 Update Site Cards
Add photo indicators to site cards:
- Morning photo uploaded: ✅ 🌅
- Evening photo uploaded: ✅ 🌆
- Missing photos: ⚠️

### Phase 4: Multi-Role Access (2 hours)

#### 4.1 Add Photo Gallery to All Roles
- **Supervisor**: View photos from site detail
- **Architect**: View photos for quality check
- **Accountant**: View photos for verification
- **Owner**: View photos for progress tracking

#### 4.2 Add Photo Tab to Site Detail Screens
Update existing site detail screens:
- `site_detail_screen.dart` (Supervisor)
- `accountant_site_detail_screen.dart` (Accountant)
- Add "Photos" tab alongside Labour/Material tabs

### Phase 5: Time Restrictions (30 minutes)

#### 5.1 Morning Upload Validation
```dart
bool canUploadMorning() {
  final now = DateTime.now();
  return now.hour < 13; // Before 1 PM
}
```

#### 5.2 Evening Upload Validation
```dart
bool canUploadEvening() {
  final now = DateTime.now();
  return now.hour >= 13; // After 1 PM
}
```

#### 5.3 Check Already Uploaded
```dart
Future<bool> hasUploadedToday(String siteId, String type) async {
  // Check if photo already uploaded today
  // Return true if exists, false otherwise
}
```

## UI Design

### Site Engineer Dashboard
```
┌─────────────────────────────────────────┐
│  Site Engineer Dashboard                │
├─────────────────────────────────────────┤
│  ┌───────────────────────────────────┐  │
│  │ 📸 Arjun 12 22 Prakash           │  │
│  │ 📍 Prakash Nagar, Street 22      │  │
│  │                                   │  │
│  │ Morning: ✅ 🌅  Evening: ⚠️ 🌆   │  │
│  │                                   │  │
│  │ [Tap to upload photos]            │  │
│  └───────────────────────────────────┘  │
│                                          │
│  ┌───────────────────────────────────┐  │
│  │ 📸 Site 2                         │  │
│  │ Morning: ⚠️ 🌅  Evening: ✅ 🌆   │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

### Photo Upload Screen
```
┌─────────────────────────────────────────┐
│  ← Upload Photo                         │
├─────────────────────────────────────────┤
│  Site: Arjun 12 22 Prakash              │
│                                          │
│  Upload Type:                            │
│  ⦿ Morning - Work Started               │
│  ○ Evening - Work Completed             │
│                                          │
│  ┌─────────────────────────────────┐   │
│  │                                  │   │
│  │      [Photo Preview]             │   │
│  │                                  │   │
│  └─────────────────────────────────┘   │
│                                          │
│  📷 Take Photo    🖼️ Choose from Gallery│
│                                          │
│  Description (optional):                 │
│  ┌─────────────────────────────────┐   │
│  │ Work started at 8 AM...          │   │
│  └─────────────────────────────────┘   │
│                                          │
│  [Upload Photo]                          │
└─────────────────────────────────────────┘
```

### Photo Gallery
```
┌─────────────────────────────────────────┐
│  ← Site Photos                          │
├─────────────────────────────────────────┤
│  Filter: [All] [Morning] [Evening]      │
├─────────────────────────────────────────┤
│  ┌────┐ ┌────┐ ┌────┐                  │
│  │ 🌅 │ │ 🌆 │ │ 🌅 │                  │
│  │8AM │ │6PM │ │8AM │                  │
│  └────┘ └────┘ └────┘                  │
│                                          │
│  ┌────┐ ┌────┐ ┌────┐                  │
│  │ 🌆 │ │ 🌅 │ │ 🌆 │                  │
│  │6PM │ │8AM │ │6PM │                  │
│  └────┘ └────┘ └────┘                  │
└─────────────────────────────────────────┘
```

## Database Schema

### work_updates Table
```sql
CREATE TABLE work_updates (
    id UUID PRIMARY KEY,
    site_id UUID REFERENCES sites(id),
    engineer_id UUID REFERENCES users(id),
    update_type VARCHAR(20) CHECK (update_type IN ('STARTED', 'FINISHED')),
    image_url TEXT NOT NULL,
    description TEXT,
    update_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    visible_to_client BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_work_updates_site ON work_updates(site_id);
CREATE INDEX idx_work_updates_date ON work_updates(update_date);
```

## API Endpoints

### Backend APIs Needed

1. **Upload Photo**
   ```
   POST /api/construction/upload-work-photo/
   Body: multipart/form-data
   - site_id
   - update_type (STARTED/FINISHED)
   - photo (file)
   - description
   ```

2. **Get Site Photos**
   ```
   GET /api/construction/site-photos/<site_id>/
   Response: List of photos with metadata
   ```

3. **Check Today's Upload Status**
   ```
   GET /api/construction/today-upload-status/<site_id>/
   Response: {
     morning_uploaded: true/false,
     evening_uploaded: true/false
   }
   ```

4. **Delete Photo** (Optional)
   ```
   DELETE /api/construction/delete-photo/<photo_id>/
   ```

## Testing Checklist

### Site Engineer
- [ ] Can see all assigned sites as cards
- [ ] Can upload morning photo (before 1 PM)
- [ ] Can upload evening photo (after 1 PM)
- [ ] Cannot upload same type twice in one day
- [ ] Can add description to photos
- [ ] Can view uploaded photos in gallery
- [ ] Photos show correct timestamp

### Other Roles
- [ ] Supervisor can view photos from site detail
- [ ] Architect can view photos
- [ ] Accountant can view photos
- [ ] Owner can view photos (if exists)
- [ ] Photos are organized by date
- [ ] Can filter by morning/evening

### Edge Cases
- [ ] Handle no internet connection
- [ ] Handle large image files
- [ ] Handle upload failures
- [ ] Show upload progress
- [ ] Validate image format (jpg, png)
- [ ] Compress images before upload

## Estimated Timeline

- **Backend Setup**: 1-2 hours
- **Image Storage**: 1 hour
- **Site Engineer UI**: 3-4 hours
- **Photo Gallery**: 2 hours
- **Multi-Role Access**: 2 hours
- **Testing & Polish**: 2 hours

**Total**: 11-13 hours (1.5-2 days)

## Priority Order

1. **High Priority**:
   - Site Engineer photo upload
   - Photo storage and retrieval
   - Basic photo gallery

2. **Medium Priority**:
   - Time restrictions
   - Multi-role access
   - Photo indicators on cards

3. **Low Priority**:
   - Photo compression
   - Advanced filters
   - Photo editing features

## Next Steps

Would you like me to:
1. Start with backend API implementation?
2. Create the Site Engineer dashboard first?
3. Implement the photo upload screen?
4. Set up image storage solution?

Let me know which part to implement first!
