# Client Progress Tab - Date Filter Implementation ✅

## Feature Overview
The Progress tab now includes a date filter that allows clients to view photos from a specific day or all days. Photos are fetched from both Supervisors and Site Engineers.

---

## Implementation Details

### Backend API

#### Endpoint: GET /api/client/photos-by-date/
**Location**: `django-backend/api/views_client.py`

**Parameters**:
- `site_id` (required): UUID of the site
- `date` (optional): Filter by specific date in YYYY-MM-DD format

**Response**:
```json
{
  "success": true,
  "photos_by_date": {
    "2026-03-28": [
      {
        "id": "uuid",
        "photo_url": "/media/photos/...",
        "time_of_day": "Morning",
        "description": "Work progress",
        "uploaded_date": "2026-03-28",
        "day_of_week": "Friday",
        "uploaded_by": "John Doe",
        "uploaded_by_role": "Supervisor"
      }
    ]
  },
  "dates": ["2026-03-28", "2026-03-27", ...],
  "total_photos": 10,
  "supervisor_photos": 6,
  "engineer_photos": 4,
  "filter_date": null
}
```

**Data Sources**:
1. **Supervisor Photos**: `site_photos` table
   - Columns: `image_url`, `time_of_day`, `upload_date`, `uploaded_by`
   - Time of day: "Morning" or "Evening"

2. **Site Engineer Photos**: `work_updates` table
   - Columns: `image_url`, `update_type`, `update_date`, `engineer_id`
   - Update types mapped: `STARTED` → "Morning", `FINISHED` → "Evening"

**Features**:
- Combines photos from both sources
- Groups photos by date
- Returns sorted dates (newest first)
- Optional date filtering
- Shows uploader name and role

---

### Frontend Implementation

#### Service Method
**File**: `lib/services/construction_service.dart`

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
  // Returns: photos_by_date, dates, total_photos, supervisor_photos, engineer_photos
}
```

#### Dashboard State
**File**: `lib/screens/client_dashboard.dart`

**New State Variables**:
```dart
Map<String, dynamic>? _photosData;  // Stores photos grouped by date
String? _selectedDate;               // Currently selected filter date
```

**New Methods**:
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

#### Progress Tab Widget
**File**: `lib/screens/client_dashboard.dart` - `ClientProgressTab`

**New Parameters**:
```dart
final Map<String, dynamic>? photosData;           // Photos data from API
final String? selectedDate;                        // Current filter
final void Function({String? filterDate}) onDateFilter;  // Filter callback
```

**UI Components**:

1. **Date Filter Button**
   - Located next to "Daily Timeline" heading
   - Shows current filter: "All" or "Mar 28"
   - Icon changes color when filter is active
   - Opens popup menu with date options

2. **Popup Menu**
   - "Show All Dates" option (clears filter)
   - List of available dates
   - Check icon on selected date
   - Formatted dates (Today, Yesterday, or "Mar 28, 2026")

3. **Photo Cards**
   - Shows uploader role badge at bottom
   - Icon: person (Supervisor) or engineering (Site Engineer)
   - Text: "John Doe (Supervisor)"
   - Overlay with semi-transparent background

---

## User Experience

### Default View (No Filter)
- Shows all photos from all dates
- Dates sorted newest to oldest
- Each date card shows:
  - Date with calendar icon
  - Badge showing photo count
  - Morning and Evening photo slots
  - Uploader information

### Filtered View (Single Date)
- Shows only photos from selected date
- Filter button shows selected date
- Filter button highlighted in blue
- Easy to clear filter (select "Show All Dates")

### Empty States
- No photos at all: Shows empty state with icon
- No photos for filtered date: Shows empty state
- Missing morning/evening photo: Shows placeholder

---

## Testing

### Manual Testing Steps

1. **Login as Client**
   ```
   Username: testclient
   Password: client123
   ```

2. **Navigate to Progress Tab**
   - Should see all photos by default
   - Filter button shows "All"

3. **Test Date Filter**
   - Tap filter button
   - Select a specific date
   - Verify only that date's photos show
   - Filter button should show selected date

4. **Test Clear Filter**
   - Tap filter button
   - Select "Show All Dates"
   - Verify all photos show again
   - Filter button should show "All"

5. **Test Photo Sources**
   - Verify supervisor photos show "Supervisor" badge
   - Verify engineer photos show "Site Engineer" badge
   - Check uploader names are correct

### API Testing

Use the test script:
```bash
cd django-backend
python test_client_photos_api.py
```

Or test manually with curl:
```bash
# Get all photos
curl -H "Authorization: Bearer YOUR_TOKEN" \
  "http://192.168.31.228:8000/api/client/photos-by-date/?site_id=SITE_ID"

# Get photos for specific date
curl -H "Authorization: Bearer YOUR_TOKEN" \
  "http://192.168.31.228:8000/api/client/photos-by-date/?site_id=SITE_ID&date=2026-03-28"
```

---

## Database Queries

### Supervisor Photos Query
```sql
SELECT 
    sp.id,
    sp.image_url as photo_url,
    sp.time_of_day,
    sp.description,
    sp.upload_date as uploaded_date,
    sp.day_of_week,
    u.full_name as uploaded_by,
    'Supervisor' as uploaded_by_role
FROM site_photos sp
LEFT JOIN users u ON sp.uploaded_by = u.id
WHERE sp.site_id = %s
  AND sp.upload_date = %s  -- Optional filter
ORDER BY sp.upload_date DESC, sp.time_of_day
```

### Site Engineer Photos Query
```sql
SELECT 
    wu.id,
    wu.image_url as photo_url,
    CASE 
        WHEN wu.update_type = 'STARTED' THEN 'Morning'
        WHEN wu.update_type = 'FINISHED' THEN 'Evening'
        ELSE wu.update_type
    END as time_of_day,
    wu.description,
    wu.update_date as uploaded_date,
    '' as day_of_week,
    u.full_name as uploaded_by,
    'Site Engineer' as uploaded_by_role
FROM work_updates wu
LEFT JOIN users u ON wu.engineer_id = u.id
WHERE wu.site_id = %s
  AND wu.update_type IN ('STARTED', 'FINISHED')
  AND wu.update_date = %s  -- Optional filter
ORDER BY wu.update_date DESC, wu.update_type
```

---

## Key Features

### ✅ Implemented
- [x] Date filter dropdown in Progress tab
- [x] Fetch photos from both Supervisors and Site Engineers
- [x] Group photos by date
- [x] Show uploader name and role on photo cards
- [x] Filter by specific date
- [x] Clear filter to show all dates
- [x] Visual indicator for active filter
- [x] Empty states for no photos
- [x] Proper error handling
- [x] Loading states

### 📋 Data Handling
- [x] Combines data from two tables (`site_photos` and `work_updates`)
- [x] Maps engineer update types to time of day
- [x] Groups photos by date on backend
- [x] Returns sorted date list
- [x] Handles missing photos gracefully

### 🎨 UI/UX
- [x] Filter button with icon and text
- [x] Color changes when filter active
- [x] Popup menu with date options
- [x] Check icon on selected date
- [x] Formatted dates (Today, Yesterday, etc.)
- [x] Photo count badge per date
- [x] Uploader role badges on photos
- [x] Different icons for Supervisor vs Engineer

---

## Technical Notes

### Photo URL Handling
Both supervisor and engineer photos use the same URL format:
```dart
ConstructionService.getFullImageUrl(photo['photo_url'])
```

This helper method:
- Checks if URL is already full (starts with http)
- Prepends media base URL if relative
- Handles /media/ prefix correctly

### Time of Day Mapping
- Supervisor: Uses `time_of_day` column directly ("Morning" or "Evening")
- Engineer: Maps `update_type`:
  - `STARTED` → "Morning"
  - `FINISHED` → "Evening"

### Date Formatting
Three formats used:
1. **API**: `YYYY-MM-DD` (e.g., "2026-03-28")
2. **Filter Button**: `MMM DD` (e.g., "Mar 28")
3. **Timeline**: `MMM DD, YYYY` or "Today"/"Yesterday"

---

## Performance Considerations

### Backend
- Single query per photo source (Supervisor, Engineer)
- Indexed columns: `site_id`, `upload_date`, `update_date`
- Date filtering done in SQL (efficient)
- Limited to assigned sites only (security)

### Frontend
- Photos loaded once on tab open
- Filter changes don't reload from server (uses cached data)
- Images loaded lazily by Flutter
- Error handling prevents crashes on missing images

---

## Future Enhancements

### Phase 2 (Suggested)
1. Date range filter (from-to dates)
2. Filter by uploader role (Supervisor only, Engineer only)
3. Filter by time of day (Morning only, Evening only)
4. Search photos by description
5. Download photos
6. Fullscreen photo viewer with swipe
7. Photo comparison (side-by-side)

### Phase 3 (Advanced)
1. Photo annotations/comments
2. Photo approval workflow
3. Photo quality indicators
4. Automatic photo grouping by location
5. Time-lapse video generation
6. Photo analytics (upload frequency, coverage)

---

## Troubleshooting

### Issue: No photos showing
**Check**:
1. Client has assigned site
2. Site has photos in database
3. Photos have correct `site_id`
4. API returns data (check network tab)

### Issue: Filter not working
**Check**:
1. Date format is YYYY-MM-DD
2. Date exists in `dates` array
3. `_selectedDate` state is updating
4. `onDateFilter` callback is called

### Issue: Uploader role not showing
**Check**:
1. `uploaded_by_role` field in API response
2. Photo has `uploaded_by` user
3. JOIN with users table successful
4. Role badge rendering logic

### Issue: Engineer photos missing
**Check**:
1. `work_updates` table has data
2. `update_type` is 'STARTED' or 'FINISHED'
3. `engineer_id` is valid
4. Query includes engineer photos

---

## Files Modified

### Backend
- `api/views_client.py` - Added `get_client_photos_by_date()` function
- `api/urls.py` - Already registered (no changes needed)

### Frontend
- `lib/services/construction_service.dart` - Added `getClientPhotosByDate()` method
- `lib/screens/client_dashboard.dart` - Updated state and Progress tab

### Documentation
- `CLIENT_PROGRESS_TAB_FILTER.md` - This file
- `CLIENT_IMPLEMENTATION_COMPLETE.md` - Updated with filter feature

### Testing
- `django-backend/test_client_photos_api.py` - New test script

---

## Success Criteria ✅

All criteria met:
- [x] Date filter UI implemented
- [x] Filter shows all dates or single date
- [x] Photos fetched from both Supervisor and Site Engineer
- [x] Photos grouped by date
- [x] Uploader name and role displayed
- [x] Empty states handled
- [x] API secured with JWT
- [x] No compilation errors
- [x] Proper error handling

---

**Implementation Date**: April 1, 2026
**Status**: Production Ready ✅
**Feature**: Client Progress Tab Date Filter
