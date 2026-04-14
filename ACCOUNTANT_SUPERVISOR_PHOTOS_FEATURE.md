# Accountant Supervisor Photos Feature

## ✅ Implementation Complete

Added a "Photos" tab to the Accountant's Supervisor view with Morning/Evening sub-tabs to view supervisor-uploaded photos.

---

## Features Implemented

### 1. UI Changes (Flutter)

**File:** `otp_phone_auth/lib/screens/accountant_entry_screen.dart`

#### Added Photos Tab
- Added "Photos" as the 4th tab in Supervisor view (after Labour, Materials, Requests)
- Tab order: Labour | Materials | Requests | **Photos**

#### Morning/Evening Sub-tabs
- When Photos tab is selected, shows two sub-tabs:
  - **Morning** (with sun icon ☀️)
  - **Evening** (with moon icon 🌙)
- Filters photos by time_of_day

#### Photo Grid Display
- 2-column grid layout
- Each photo card shows:
  - Photo image (with loading and error states)
  - Supervisor name
  - Upload date
  - Description (if available)
- Tap on photo to view full-screen with details

#### Empty States
- "No Photos Found" when no photos exist
- "No Morning/Evening Photos" when filtered list is empty
- Refresh button to reload photos

### 2. Backend API

**File:** `django-backend/api/views_construction.py`

#### New Endpoint
```
GET /api/construction/supervisor-photos-for-accountant/?site_id=<uuid>
```

**Access:** Accountant and Admin roles only

**Response:**
```json
{
  "success": true,
  "photos": [
    {
      "id": "uuid",
      "site_id": "uuid",
      "image_url": "/media/supervisor_photos/...",
      "upload_date": "2026-03-27",
      "time_of_day": "morning",
      "description": "Morning photo",
      "supervisor_name": "John Doe"
    }
  ],
  "count": 1
}
```

**Features:**
- Fetches ALL supervisor photos for a site (not just current user's)
- Includes supervisor name via JOIN with users table
- Ordered by upload_date DESC, time_of_day DESC
- Role-based access control (Accountant/Admin only)

### 3. URL Routing

**File:** `django-backend/api/urls.py`

Added route:
```python
path('construction/supervisor-photos-for-accountant/', 
     views_construction.get_supervisor_photos_for_accountant, 
     name='get-supervisor-photos-for-accountant'),
```

---

## How It Works

### User Flow

1. **Accountant logs in** and navigates to Entries tab
2. **Selects Area → Street → Site** from dropdowns
3. **Clicks "Supervisor" role tab** at the top
4. **Clicks "Photos" tab** (new tab added)
5. **Sees Morning/Evening sub-tabs**
6. **Views photos in grid** (2 columns)
7. **Taps photo** to view full-screen with details

### Data Flow

```
Flutter App
    ↓
GET /api/construction/supervisor-photos-for-accountant/?site_id=xxx
    ↓
Django Backend (views_construction.py)
    ↓
Query site_photos table with JOIN to users
    ↓
Return photos with supervisor names
    ↓
Flutter displays in grid with Morning/Evening filter
```

---

## Database Schema

Uses existing `site_photos` table:

```sql
site_photos (
    id UUID PRIMARY KEY,
    site_id UUID REFERENCES sites(id),
    uploaded_by UUID REFERENCES users(id),  -- Supervisor ID
    image_url TEXT,
    upload_date DATE,
    time_of_day VARCHAR,  -- 'morning' or 'evening'
    description TEXT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
```

---

## Testing

### Test the API

```bash
cd django-backend

# Create test script
cat > test_supervisor_photos_api.py << 'EOF'
import requests
import json

BASE_URL = 'http://192.168.1.11:8000/api'

# Login as accountant
login_response = requests.post(
    f'{BASE_URL}/auth/login/',
    json={'username': 'accountant', 'password': 'your_password'}
)

token = login_response.json()['access_token']
headers = {'Authorization': f'Bearer {token}'}

# Get photos for a site
site_id = 'your-site-id-here'
response = requests.get(
    f'{BASE_URL}/construction/supervisor-photos-for-accountant/',
    params={'site_id': site_id},
    headers=headers
)

print(f"Status: {response.status_code}")
print(f"Response:\n{json.dumps(response.json(), indent=2)}")
EOF

python test_supervisor_photos_api.py
```

### Test in Flutter App

1. Login as accountant
2. Go to Entries tab
3. Select a site that has supervisor photos
4. Click Supervisor tab
5. Click Photos tab (should be 4th tab)
6. Should see Morning/Evening sub-tabs
7. Photos should display in grid
8. Tap photo to view full-screen

---

## UI Screenshots Reference

### Tab Structure
```
┌─────────────────────────────────────────┐
│  Supervisor | Site Engineer | Architect │  ← Role tabs
├─────────────────────────────────────────┤
│  Labour | Materials | Requests | Photos │  ← Supervisor sub-tabs
├─────────────────────────────────────────┤
│  Morning | Evening                      │  ← Photos time filter
├─────────────────────────────────────────┤
│  [Photo Grid - 2 columns]               │
│  ┌────────┐  ┌────────┐                │
│  │ Photo1 │  │ Photo2 │                │
│  │ Name   │  │ Name   │                │
│  │ Date   │  │ Date   │                │
│  └────────┘  └────────┘                │
└─────────────────────────────────────────┘
```

---

## Code Changes Summary

### Flutter Files Modified
1. `accountant_entry_screen.dart`
   - Added `_selectedPhotoTimeOfDay` state variable
   - Updated supervisor tabs list to include 'Photos'
   - Added `_buildSupervisorPhotosTab()` method
   - Added `_loadSupervisorPhotos()` API call method
   - Added `_buildSupervisorPhotoCard()` widget
   - Added `_showPhotoDialog()` for full-screen view
   - Added imports: `dart:convert`, `package:http/http.dart`

### Backend Files Modified
1. `api/views_construction.py`
   - Added `get_supervisor_photos_for_accountant()` function
   - Role-based access control (Accountant/Admin)
   - Fetches all supervisor photos for a site

2. `api/urls.py`
   - Added route for new endpoint

---

## Security

- ✅ JWT Authentication required
- ✅ Role-based access (Accountant and Admin only)
- ✅ Site-specific data (requires site_id parameter)
- ✅ No modification allowed (GET only)

---

## Performance

- Photos loaded on-demand when Photos tab is selected
- Grid layout with lazy loading
- Image caching handled by Flutter
- Efficient database query with JOIN

---

## Future Enhancements

Possible improvements:
1. Add date range filter
2. Add download all photos button
3. Add photo comparison (morning vs evening)
4. Add photo annotations/comments
5. Add photo approval workflow

---

**Status:** ✅ Complete and Ready to Test
**Created:** Current session
**Django Server:** Auto-reloaded with new endpoint
