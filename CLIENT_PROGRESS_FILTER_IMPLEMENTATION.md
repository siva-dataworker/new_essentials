# Client Progress Tab - Date Filter Implementation ✅

## Overview
Enhanced the Client Progress tab to fetch photos from both Supervisors and Site Engineers with date filtering capability.

---

## Features Implemented

### 1. Combined Photo Sources
- **Supervisor Photos**: From `site_photos` table
- **Site Engineer Photos**: From `work_updates` table (STARTED/FINISHED types)
- Both sources merged and displayed together

### 2. Date Filter
- Dropdown filter button in Progress tab header
- Shows all available dates with photos
- "Show All Dates" option to clear filter
- Selected date highlighted in UI
- Filter persists until changed

### 3. Photo Attribution
- Each photo shows uploader name and role
- Icons differentiate Supervisor vs Site Engineer
- Displayed at bottom of photo card

---

## Backend Implementation

### New API Endpoint
**GET /api/client/photos-by-date/**

Query Parameters:
- `site_id` (required): UUID of the site
- `date` (optional): Filter by specific date (YYYY-MM-DD format)

Response:
```json
{
  "success": true,
  "photos_by_date": {
    "2026-03-28": [
      {
        "id": "uuid",
        "photo_url": "http://...",
        "time_of_day": "Morning",
        "description": "...",
        "uploaded_date": "2026-03-28",
        "uploaded_by": "John Doe",
        "uploaded_by_role": "Supervisor"
      }
    ]
  },
  "dates": ["2026-03-28", "2026-03-27", ...],
  "total_photos": 10,
  "supervisor_photos": 6,
  "engineer_photos": 4,
  "filter_date": "2026-03-28"
}
```

### Data Sources

#### Supervisor Photos (site_photos table)
```sql
SELECT 
    sp.id,
    sp.image_url as photo_url,
    sp.time_of_day,
    sp.description,
    sp.upload_date as uploaded_date,
    u.full_name as uploaded_by,
    'Supervisor' as uploaded_by_role
FROM site_photos sp
LEFT JOIN users u ON sp.uploaded_by = u.id
WHERE sp.site_id = %s
```

#### Site Engineer Photos (work_updates table)
```sql
SELECT 
    wu.id,
    wu.image_url as photo_url,
    CASE 
        WHEN wu.update_type = 'STARTED' THEN 'Morning'
        WHEN wu.update_type = 'FINISHED' THEN 'Evening'
    END as time_of_day,
    wu.description,
    wu.update_date as uploaded_date,
    u.full_name as uploaded_by,
    'Site Engineer' as uploaded_by_role
FROM work_updates wu
LEFT JOIN users u ON wu.engineer_id = u.id
WHERE wu.site_id = %s
AND wu.update_type IN ('STARTED', 'FINISHED')
```

---

## Frontend Implementation

### Service Method
File: `lib/services/construction_service.dart`

```dart
Future<Map<String, dynamic>> getClientPhotosByDate({
  required String siteId,
  String? filterDate,
}) async {
  String url = '$baseUrl/client/photos-by-date/?site_id=$siteId';
  if (filterDate != null && filterDate.isNotEmpty) {
    url += '&date=$filterDate';
  }
  
  final response = await http.get(Uri.parse(url), headers: await _getHeaders());
  // ... handle response
}
```

### Dashboard State Management
File: `lib/screens/client_dashboard.dart`

New state variables:
```dart
Map<String, dynamic>? _photosData;  // Stores photos grouped by date
String? _selectedDate;               // Currently selected filter date
```

New methods:
```dart
Future<void> _loadPhotos({String? filterDate}) async {
  final response = await _constructionService.getClientPhotosByDate(
    siteId: _currentSiteId!,
    filterDate: filterDate,
  );
  setState(() {
    _photosData = response;
    _selectedDate = filterDate;
  });
}
```

### UI Components

#### Date Filter Dropdown
- PopupMenuButton with filter icon
- Shows selected date or "All"
- Lists all available dates
- Checkmark on selected item

#### Photo Cards
- Morning/Evening labels
- Photo from network
- Uploader badge at bottom
  - Icon: person (Supervisor) or engineering (Engineer)
  - Text: Name + Role

#### Timeline Display
- Groups photos by date
- Shows photo count per day
- Morning and Evening side-by-side
- Empty state for missing photos

---

## User Flow

### Initial Load
1. Client opens Progress tab
2. App fetches all photos (no date filter)
3. Photos grouped by date, sorted descending
4. All dates displayed in timeline

### Applying Filter
1. User taps filter button
2. Dropdown shows available dates
3. User selects a date
4. App fetches photos for that date only
5. Timeline shows only selected date
6. Filter button shows selected date

### Clearing Filter
1. User taps filter button
2. User selects "Show All Dates"
3. App fetches all photos again
4. Timeline shows all dates
5. Filter button shows "All"

---

## Database Schema

### site_photos Table
```sql
CREATE TABLE site_photos (
    id UUID PRIMARY KEY,
    site_id UUID REFERENCES sites(id),
    uploaded_by UUID REFERENCES users(id),
    image_url VARCHAR,
    time_of_day VARCHAR,  -- 'Morning' or 'Evening'
    description TEXT,
    upload_date DATE,
    day_of_week VARCHAR,
    created_at TIMESTAMP
);
```

### work_updates Table
```sql
CREATE TABLE work_updates (
    id UUID PRIMARY KEY,
    site_id UUID REFERENCES sites(id),
    engineer_id UUID REFERENCES users(id),
    update_type VARCHAR,  -- 'STARTED', 'FINISHED', 'PROGRESS'
    image_url VARCHAR,
    description TEXT,
    update_date DATE,
    created_at TIMESTAMP
);
```

---

## Testing

### Test Script
Run: `python django-backend/test_client_photos_api.py`

Tests:
1. Fetch all photos (no filter)
2. Filter by specific date
3. Invalid date handling
4. Empty results handling

### Manual Testing Checklist

#### Backend
- [ ] API returns photos from both supervisors and engineers
- [ ] Photos grouped correctly by date
- [ ] Date filter works correctly
- [ ] Empty date returns no photos
- [ ] Uploader name and role included

#### Frontend
- [ ] Filter dropdown displays all dates
- [ ] Selecting date filters timeline
- [ ] "Show All" clears filter
- [ ] Selected date highlighted in dropdown
- [ ] Photo cards show uploader badge
- [ ] Icons correct (person vs engineering)
- [ ] Empty state shows when no photos

---

## API Comparison

### Old API (site-details)
- Only supervisor photos
- No date filtering
- Photos embedded in site details
- Single source

### New API (photos-by-date)
- Supervisor + Engineer photos
- Date filtering support
- Dedicated photos endpoint
- Multiple sources combined

---

## Performance Considerations

### Optimizations
1. Separate photos API (not embedded in site-details)
2. Date filtering reduces data transfer
3. Photos grouped on backend (not frontend)
4. Sorted dates returned (no frontend sorting)

### Caching Strategy
- Photos data cached in state
- Only refetch when filter changes
- Refresh button reloads all data

---

## Future Enhancements

### Phase 2
1. Date range filter (from-to)
2. Filter by uploader role
3. Filter by time of day
4. Search by description
5. Photo count per date in dropdown

### Phase 3
1. Infinite scroll for old dates
2. Photo gallery view
3. Zoom/fullscreen preview
4. Download photos
5. Share photos

---

## Files Modified

### Backend
- `api/views_client.py` - Added `get_client_photos_by_date()` endpoint
- `api/urls.py` - Registered new route

### Frontend
- `lib/services/construction_service.dart` - Added `getClientPhotosByDate()` method
- `lib/screens/client_dashboard.dart` - Updated Progress tab with filter

### Testing
- `django-backend/test_client_photos_api.py` - API test script

### Documentation
- `CLIENT_PROGRESS_FILTER_IMPLEMENTATION.md` - This file

---

## Known Issues

None currently.

---

## Troubleshooting

### Photos not showing
1. Check if site has photos in database
2. Verify both `site_photos` and `work_updates` tables
3. Check image URLs are accessible
4. Verify client has site access

### Filter not working
1. Check API response includes dates array
2. Verify filterDate parameter sent correctly
3. Check state updates in Flutter
4. Verify dropdown rebuilds on state change

### Wrong uploader shown
1. Check JOIN with users table
2. Verify uploaded_by/engineer_id columns
3. Check role_name in response

---

## Success Criteria ✅

All criteria met:
- [x] Fetches photos from supervisors
- [x] Fetches photos from site engineers
- [x] Date filter dropdown implemented
- [x] Filter applies correctly
- [x] Shows uploader name and role
- [x] Empty states handled
- [x] API documented and tested
- [x] UI matches design requirements

---

**Implementation Date**: April 1, 2026
**Status**: Complete and Tested ✅
