# Mismatch Notification Feature Added

## Overview
Added labor entry mismatch detection and notification to both the Accountant Entry Screen and Accountant Dashboard. The feature detects discrepancies between Supervisor and Site Engineer labor entries and displays them with a warning icon and badge.

## Features Added

### 1. Mismatch Detection Service
**File**: `lib/services/labor_mismatch_service.dart`

- Detects 3 types of mismatches:
  - **COUNT_DIFFERENCE**: Same labor type, different counts
  - **MISSING_ENGINEER_ENTRY**: Supervisor entered but Site Engineer didn't
  - **MISSING_SUPERVISOR_ENTRY**: Site Engineer entered but Supervisor didn't
- Configurable date range (default: 7 days)
- Can filter by specific site or check all sites
- Returns detailed mismatch data and summary by site

### 2. Backend API Endpoint
**File**: `django-backend/api/views_labor_mismatch.py`

```python
GET /api/construction/labor-mismatches/
Query params:
  - site_id (optional): Filter by specific site
  - days (optional): Number of days to check (default: 7)
```

**Response**:
```json
{
  "mismatches": [
    {
      "site_id": "uuid",
      "site_name": "Site Name",
      "entry_date": "2026-05-08",
      "labour_type": "General",
      "mismatch_type": "COUNT_DIFFERENCE",
      "supervisor_count": 5,
      "engineer_count": 3,
      "difference": 2,
      "supervisor_name": "John Doe",
      "engineer_name": "Jane Smith"
    }
  ],
  "summary": [
    {
      "site_id": "uuid",
      "site_name": "Site Name",
      "total_mismatches": 4,
      "dates_with_mismatches": ["2026-05-08", "2026-05-07"],
      "has_critical_mismatches": true
    }
  ],
  "total_mismatches": 4,
  "date_range": {
    "start_date": "2026-05-02",
    "end_date": "2026-05-09",
    "days": 7
  }
}
```

### 3. Accountant Entry Screen (Site View)
**File**: `lib/screens/accountant_entry_screen.dart`

**Features**:
- Orange warning icon with red badge showing mismatch count
- Appears in AppBar when viewing a specific site
- Badge shows number of mismatches for that site only
- Click to open detailed mismatch dialog

**UI Elements**:
```dart
// Warning icon with badge
IconButton(
  icon: Icon(Icons.warning_amber_rounded, color: Colors.orange),
  onPressed: () => _showMismatchDialog(),
)

// Red badge with count
Container(
  decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
  child: Text('$_totalMismatches'),
)
```

**Dialog Shows**:
- List of all mismatches for the site
- Date, labor type, counts from both roles
- Difference amount
- Supervisor and Site Engineer names
- Color-coded by mismatch type

### 4. Accountant Dashboard
**File**: `lib/screens/accountant_dashboard.dart`

**Features**:
- Same orange warning icon with red badge
- Shows total mismatches across ALL sites
- Appears in Dashboard AppBar
- Click to open summary dialog

**Dialog Shows**:
- Summary grouped by site
- Site name with total mismatches
- Number of days with mismatches
- Quick overview of problem areas

## How It Works

### Data Flow

1. **On Screen Load**:
   ```dart
   // Entry Screen (specific site)
   _loadMismatchData() // Called when site is selected
   
   // Dashboard (all sites)
   _loadMismatchData() // Called on dashboard load
   ```

2. **API Call**:
   ```dart
   final result = await _mismatchService.detectLaborMismatches(
     siteId: siteId, // Optional - omit for all sites
     days: 7,
   );
   ```

3. **Update UI**:
   ```dart
   setState(() {
     _mismatchData = result;
     _totalMismatches = result['total_mismatches'] ?? 0;
   });
   ```

4. **Show Badge**:
   ```dart
   if (_totalMismatches > 0)
     // Show warning icon with badge
   ```

### Mismatch Detection Logic

The backend compares entries by creating a key: `{site_id}_{date}_{labour_type}`

**Example**:
- Supervisor: `site1_2026-05-08_General` → 5 workers
- Engineer: `site1_2026-05-08_General` → 3 workers
- **Result**: COUNT_DIFFERENCE mismatch (difference: 2)

**Missing Entry**:
- Supervisor: `site1_2026-05-08_Mason` → 2 workers
- Engineer: No entry
- **Result**: MISSING_ENGINEER_ENTRY mismatch

## UI/UX Improvements

### Fixed Click Issue
**Problem**: Red badge was blocking clicks on the warning icon

**Solution**:
```dart
Positioned(
  child: IgnorePointer( // Badge ignores pointer events
    child: Container(...), // Red badge
  ),
)
```

Now clicks pass through the badge to the IconButton underneath.

### Visual Design
- **Orange warning icon**: Indicates attention needed
- **Red badge**: Shows urgency and count
- **Badge size**: 18x18px minimum, auto-expands for larger numbers
- **Position**: Top-right corner of icon
- **Font**: 10px, bold, white text

## Debug Logging

Added comprehensive logging for troubleshooting:

```dart
// Service level
print('🔍 [MISMATCH SERVICE] Calling API: $url');
print('✅ [MISMATCH SERVICE] Success! Total mismatches: $count');

// Screen level
print('🔍 [MISMATCH] Fetching mismatches for site: $siteId');
print('✅ [MISMATCH] Loaded $count mismatches');

// Dialog level
print('🔍 [MISMATCH DIALOG] _showMismatchDialog called');
print('🔍 [MISMATCH DIALOG] mismatches count: $count');
```

## Testing

### Test Scenarios

1. **No Mismatches**:
   - Badge should not appear
   - No warning icon shown

2. **Single Site Mismatch** (Entry Screen):
   - Badge shows count for that site only
   - Dialog shows detailed list

3. **Multiple Site Mismatches** (Dashboard):
   - Badge shows total across all sites
   - Dialog shows summary by site

4. **Click Functionality**:
   - Click orange icon (not badge)
   - Dialog opens immediately
   - Shows correct data

### Manual Testing Steps

1. **Create Test Data**:
   ```sql
   -- Supervisor entry
   INSERT INTO labour_entries (site_id, labour_type, labour_count, entry_date, submitted_by_role)
   VALUES ('site-uuid', 'General', 5, '2026-05-08', 'Supervisor');
   
   -- Site Engineer entry (different count)
   INSERT INTO labour_entries (site_id, labour_type, labour_count, entry_date, submitted_by_role)
   VALUES ('site-uuid', 'General', 3, '2026-05-08', 'Site Engineer');
   ```

2. **Login as Accountant**

3. **Check Dashboard**:
   - Should see orange warning icon with red "1" badge
   - Click icon → Dialog shows 1 mismatch

4. **Navigate to Site**:
   - Go to Entries tab
   - Select the site with mismatch
   - Should see warning icon with badge
   - Click icon → Dialog shows detailed mismatch

## Files Modified

### Frontend
- `lib/services/labor_mismatch_service.dart` - Service for API calls
- `lib/screens/accountant_entry_screen.dart` - Added mismatch button to site view
- `lib/screens/accountant_dashboard.dart` - Added mismatch button to dashboard

### Backend
- `django-backend/api/views_labor_mismatch.py` - Mismatch detection endpoint
- `django-backend/api/urls.py` - Route for mismatch endpoint (already existed)

## Future Enhancements

1. **Auto-refresh**: Refresh mismatch count every 60 seconds
2. **Notifications**: Push notification when new mismatches detected
3. **Resolution**: Allow accountant to mark mismatches as resolved
4. **History**: Track mismatch resolution history
5. **Filters**: Filter by mismatch type, date range, severity
6. **Export**: Export mismatch report to PDF/Excel
7. **Threshold**: Configure acceptable difference threshold (e.g., ±1 worker)

## Notes

- Mismatches are calculated in real-time (not cached)
- Only checks last 7 days by default (configurable)
- Only Accountant role can access mismatch data
- Badge color (red) indicates urgency
- Icon color (orange) indicates warning level
- Dialog is scrollable for many mismatches
- Summary view groups by site for quick overview
