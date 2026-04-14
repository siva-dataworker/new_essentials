# Supervisor Statistics Page Enhancement

## Overview
Enhanced the supervisor statistics page with comprehensive data display including total counts and expandable dropdowns for today's working sites and sites with entered data.

## Features Implemented

### 1. Summary Cards (Already Existed, Enhanced)
- **Total Areas**: Count of all areas
- **Total Streets**: Count of all streets  
- **Total Sites**: Count of all sites

### 2. Today's Working Sites Dropdown (NEW)
**Purpose**: Shows all sites assigned to the supervisor for today

**Features**:
- Expandable card with site count
- Refresh button to reload data
- List of assigned sites with:
  - Site name
  - Customer name
  - Area and street location
  - Tap to navigate to site detail

**Display**:
```
📋 Today's Working Sites
   5 sites
   [Refresh] [Expand]
   
   When expanded:
   - Site Name 1
     Area • Street
   - Site Name 2
     Area • Street
```

### 3. Today's Entered Data Dropdown (NEW)
**Purpose**: Shows sites where supervisor has entered data today

**Features**:
- Expandable card with site count
- Refresh button to reload data
- List of sites with data indicators:
  - Labour entry (blue chip)
  - Material entry (brown chip)
  - Photos uploaded (purple chip)
- Tap to navigate to site detail

**Display**:
```
📝 Today's Entered Data
   3 sites
   [Refresh] [Expand]
   
   When expanded:
   ✓ Site Name 1
     Area • Street
     [Labour] [Material] [Photos]
   
   ✓ Site Name 2
     Area • Street
     [Labour] [Material]
```

## Implementation Details

### Flutter Side

#### State Variables Added
```dart
List<Map<String, dynamic>> _todaySitesWithData = [];
bool _isLoadingTodaySites = false;
```

#### Methods Added
```dart
Future<void> _loadTodaySitesWithData()
Widget _buildExpandableSection()
Widget _buildSiteListItem()
Widget _buildSiteDataListItem()
Widget _buildDataChip()
```

#### UI Components
- **ExpansionTile**: For collapsible sections
- **ListTile**: For site items
- **Chips**: For data type indicators
- **CircleAvatar**: For icons
- **Refresh Button**: To reload data

### Backend Side

#### New API Endpoint
```python
GET /api/construction/today-sites-with-data/
```

**Response**:
```json
{
  "success": true,
  "sites": [
    {
      "id": "uuid",
      "site_name": "Site Name",
      "customer_name": "Customer",
      "area": "Area Name",
      "street": "Street Name",
      "has_labour": true,
      "has_material": true,
      "has_photos": false
    }
  ],
  "count": 3,
  "date": "2026-03-31"
}
```

**Logic**:
1. Query labour_entries for today's entries by supervisor
2. Query material_usage for today's entries by supervisor
3. Query work_updates for today's photos by supervisor
4. Merge results by site_id
5. Return unique sites with flags for each data type

### Service Layer

#### Construction Service Method
```dart
Future<Map<String, dynamic>> getTodaySitesWithEntries()
```

Calls the backend API and returns formatted data.

## Data Flow

### Today's Working Sites
```
1. Supervisor opens Statistics tab
2. App calls getWorkingSites()
3. Backend queries working_sites table
4. Returns assigned sites for supervisor
5. Display in expandable list
```

### Today's Entered Data
```
1. Supervisor opens Statistics tab
2. App calls getTodaySitesWithEntries()
3. Backend queries:
   - labour_entries (today)
   - material_usage (today)
   - work_updates (today)
4. Merges by site_id with flags
5. Display with data type chips
```

## Visual Design

### Summary Cards
```
┌─────────────────────────┐
│ 🏢  Total Areas         │
│     3                   │
└─────────────────────────┘

┌─────────────────────────┐
│ 🛣️  Total Streets       │
│     2                   │
└─────────────────────────┘

┌─────────────────────────┐
│ 🏗️  Total Sites         │
│     0                   │
└─────────────────────────┘
```

### Expandable Sections
```
┌─────────────────────────────────┐
│ 💼 Today's Working Sites        │
│    5 sites              [↻] [▼] │
├─────────────────────────────────┤
│ 📍 Site Name 1                  │
│    Area • Street            →   │
│                                 │
│ 📍 Site Name 2                  │
│    Area • Street            →   │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│ 📝 Today's Entered Data         │
│    3 sites              [↻] [▼] │
├─────────────────────────────────┤
│ ✓ Site Name 1                   │
│   Area • Street             →   │
│   [👥 Labour] [📦 Material]     │
│                                 │
│ ✓ Site Name 2                   │
│   Area • Street             →   │
│   [👥 Labour] [📷 Photos]       │
└─────────────────────────────────┘
```

## Use Cases

### 1. Check Today's Assignments
Supervisor can quickly see which sites they need to work on today.

### 2. Track Data Entry Progress
Supervisor can see which sites they've already entered data for and which are pending.

### 3. Navigate to Sites
Tap any site to open the site detail screen for data entry.

### 4. Verify Completeness
Check if all required data (labour, material, photos) has been entered for each site.

## Testing

### Test Scenario 1: View Working Sites
1. Login as supervisor
2. Navigate to Statistics tab
3. Tap "Today's Working Sites"
4. Verify assigned sites are listed
5. Tap a site to navigate to detail

### Test Scenario 2: View Entered Data
1. Enter labour data for Site A
2. Enter material data for Site B
3. Upload photos for Site A
4. Navigate to Statistics tab
5. Tap "Today's Entered Data"
6. Verify:
   - Site A shows Labour + Photos chips
   - Site B shows Material chip

### Test Scenario 3: Refresh Data
1. Open Statistics tab
2. Enter data for a new site
3. Return to Statistics tab
4. Tap refresh button
5. Verify new site appears in "Today's Entered Data"

### Test Scenario 4: Empty States
1. Login as new supervisor with no assignments
2. Navigate to Statistics tab
3. Verify "No working sites for today" message
4. Verify "No data entered today" message

## Files Modified

### Flutter
- `lib/screens/supervisor_dashboard_feed.dart`
  - Added state variables for today's sites
  - Added `_loadTodaySitesWithData()` method
  - Enhanced `_buildStatsScreen()` with dropdowns
  - Added helper widgets for expandable sections

- `lib/services/construction_service.dart`
  - Added `getTodaySitesWithEntries()` method

### Backend
- `api/views_construction.py`
  - Added `get_today_sites_with_data()` endpoint

- `api/urls.py`
  - Added route for `today-sites-with-data/`

## Benefits

1. **Quick Overview**: Supervisor sees all relevant statistics at a glance
2. **Progress Tracking**: Easy to see which sites have data entered
3. **Task Management**: Clear view of today's assignments
4. **Navigation**: Quick access to site details
5. **Completeness Check**: Visual indicators for data types entered

## Future Enhancements

- Add filter for date range (not just today)
- Show percentage of completion for each site
- Add notifications for pending sites
- Export statistics as report
- Add charts/graphs for visual representation
- Show historical trends

## Success Criteria

- [x] Total areas, streets, sites displayed
- [x] Today's working sites dropdown implemented
- [x] Today's entered data dropdown implemented
- [x] Refresh functionality works
- [x] Navigation to site detail works
- [x] Data type chips display correctly
- [x] Empty states handled gracefully
- [x] Backend API returns correct data
