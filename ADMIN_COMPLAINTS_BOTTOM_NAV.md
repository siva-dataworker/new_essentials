# Admin Client Complaints - Bottom Navigation

## Overview
Moved the Client Complaints feature from a button in Site Management to a dedicated tab in the bottom navigation bar.

## Implementation Status: ✅ COMPLETE

### Changes Made

#### 1. Added "Issues" Tab to Bottom Navigation
**Position**: 4th tab (between Alerts and Profile)

**Icon**: 
- Outline: `report_problem_outlined`
- Filled: `report_problem`

**Label**: "Issues"

**Bottom Navigation Order**:
1. Users (people icon)
2. Sites (location_city icon)
3. Alerts (notifications icon)
4. **Issues (report_problem icon)** ← NEW
5. Profile (person icon)

#### 2. Removed Client Complaints Button
**Removed from**: Site Management tab

**What was removed**:
- Red gradient button card
- "Client Complaints" title
- "View all client issues across sites" subtitle
- Navigation to separate screen

#### 3. Updated AdminClientComplaintsScreen
**Changes**:
- Removed Scaffold wrapper
- Removed AppBar
- Now embedded directly in admin dashboard
- Added filter chips bar at top
- Filter chips: All, Open, In Progress, Resolved, Closed
- Maintains pull-to-refresh functionality

### UI Design

#### Bottom Navigation:
```
┌─────────────────────────────────────┐
│  👥    🏢    🔔    ⚠️    👤         │
│ Users Sites Alerts Issues Profile  │
└─────────────────────────────────────┘
```

#### Issues Tab Layout:
```
┌─────────────────────────────────────┐
│ Client Issues                    ⋮  │ ← AppBar (from dashboard)
├─────────────────────────────────────┤
│ 🔍 Filter: [All][Open][In Progress]│ ← Filter chips
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ Complaint Card 1                │ │
│ │ Client: Name | Site: Site Name  │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ Complaint Card 2                │ │
│ │ Client: Name | Site: Site Name  │ │
│ └─────────────────────────────────┘ │
│                                     │
└─────────────────────────────────────┘
```

### User Flow

#### Before (Old Design):
1. Admin logs in
2. Taps "Sites" tab
3. Scrolls to find red "Client Complaints" button
4. Taps button → navigates to new screen
5. Sees complaints with back button

#### After (New Design):
1. Admin logs in
2. Taps "Issues" tab in bottom navigation
3. Immediately sees all complaints
4. Can filter using chips at top
5. No navigation needed - embedded in dashboard

### Benefits

✅ **Faster Access**: One tap instead of two
✅ **Better Visibility**: Dedicated tab shows importance
✅ **Consistent UX**: Matches other role dashboards (client has Issues tab)
✅ **No Navigation**: Embedded view, no back button needed
✅ **Cleaner Sites Tab**: Removed clutter from Site Management
✅ **Easy Filtering**: Filter chips always visible at top

### Code Changes

#### Files Modified:

1. **admin_dashboard.dart**:
   - Added 5th item to bottom navigation (Issues)
   - Updated `_getAppBarTitle()` to handle index 3 (Client Issues)
   - Updated `_buildBody()` to handle index 3
   - Added `_buildClientComplaintsTab()` method
   - Removed Client Complaints button from `_buildSitesTab()`

2. **admin_client_complaints_screen.dart**:
   - Removed Scaffold wrapper
   - Removed AppBar
   - Replaced PopupMenu with filter chips
   - Added filter chips bar
   - Now returns widget tree directly (no Scaffold)

### Testing Instructions

1. **Login as Admin**:
   - Use admin credentials

2. **Check Bottom Navigation**:
   - Should see 5 tabs: Users, Sites, Alerts, Issues, Profile
   - Issues tab should have warning/report icon

3. **Tap Issues Tab**:
   - Should immediately show complaints list
   - Should see filter chips at top: All, Open, In Progress, Resolved, Closed
   - Should see complaint cards with client name, site name, etc.

4. **Test Filters**:
   - Tap "Open" chip → should show only OPEN complaints
   - Tap "All" chip → should show all complaints
   - Selected chip should be highlighted in navy blue

5. **Test Refresh**:
   - Pull down to refresh
   - Should reload complaints

6. **Check Sites Tab**:
   - Tap "Sites" tab
   - Verify Client Complaints button is REMOVED
   - Should only see Labour Rates and Site Budget Management

### Comparison: Before vs After

| Aspect | Before | After |
|--------|--------|-------|
| Location | Button in Sites tab | Dedicated bottom nav tab |
| Access | 2 taps (Sites → Button) | 1 tap (Issues tab) |
| Navigation | Separate screen | Embedded in dashboard |
| AppBar | Own AppBar with back | Dashboard AppBar |
| Filters | Popup menu | Filter chips (always visible) |
| Visibility | Hidden in Sites tab | Prominent in bottom nav |

### Filter Chips Design

**Appearance**:
- Unselected: White background, navy text
- Selected: Navy background, white text, bold
- Horizontal scrollable row
- Icon: filter_list (funnel icon)

**Options**:
- All (shows all complaints)
- Open (status = OPEN)
- In Progress (status = IN_PROGRESS)
- Resolved (status = RESOLVED)
- Closed (status = CLOSED)

### Navigation Indices

```dart
0 = Users
1 = Sites
2 = Alerts
3 = Issues  ← NEW
4 = Profile
```

### Key Features

✅ Dedicated Issues tab in bottom navigation
✅ Warning icon (report_problem) for visibility
✅ Filter chips for quick status filtering
✅ Embedded view (no separate screen)
✅ Pull-to-refresh enabled
✅ Shows all complaints across all sites
✅ Client name, site name, and issue details
✅ Priority and status badges
✅ Message count display
✅ Reported date

### Notes

- Issues tab is always accessible from bottom navigation
- No need to navigate to Sites tab first
- Filter chips provide quick access to status filtering
- Consistent with client dashboard (which also has Issues tab)
- Admin sees ALL complaints (no site filtering)
- Complaints are read-only (no chat functionality)

---
**Status**: Complete and ready to test
**Date**: 2026-04-03
**Change**: Moved from button to bottom navigation tab
