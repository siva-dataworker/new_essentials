# ✅ Accountant Bottom Navigation Updated

## What Changed

### Removed "Requests" Tab from Bottom Navigation

**Before:**
```
┌─────────────────────────────────────────────────────────┐
│ Entries | Requests | Dashboard | Reports | Export      │
└─────────────────────────────────────────────────────────┘
```

**After:**
```
┌──────────────────────────────────────────────┐
│ Entries | Dashboard | Reports | Export       │
└──────────────────────────────────────────────┘
```

## Changes Made

### File: `otp_phone_auth/lib/screens/accountant_dashboard.dart`

1. **Removed "Requests" tab** from bottom navigation
2. **Updated tab indices**:
   - 0: Entries (Site Cards)
   - 1: Dashboard (Center - Default)
   - 2: Reports
   - 3: Export
3. **Changed default index** from 2 to 1 (Dashboard)
4. **Removed case 1** (Change Requests) from switch statement

## Where to Access Requests Now

### ✅ Site-Specific Requests
Accountant can now access change requests from within each site card:

```
1. Open site card from Entries tab
2. See 3 tabs: Labour | Material | Requests
3. "Requests" tab shows pending requests for THAT SITE
4. Badge shows count (e.g., "Requests (2)")
5. Handle requests directly from site context
```

## Benefits

✅ **Cleaner Navigation**: Only 4 tabs instead of 5
✅ **Site Context**: Requests are viewed in context of the site
✅ **Better Organization**: No global requests list cluttering the nav
✅ **Focused Workflow**: Handle requests when reviewing site details
✅ **Less Confusion**: Clear separation between global and site-specific views

## Bottom Navigation Structure

### Accountant Dashboard (4 Tabs)
1. **Entries** (Grid Icon)
   - View all site cards
   - Instagram-style layout
   - Tap to open site details

2. **Dashboard** (Dashboard Icon - Center, Default)
   - Overview with summary cards
   - Total sites, labour entries, material entries
   - Extra cost summary
   - Quick actions

3. **Reports** (Chart Icon)
   - Generate reports
   - View historical data
   - Analytics

4. **Export** (Download Icon)
   - Export to Excel
   - Download data
   - File management

## User Flow

### To Handle Change Requests:
```
Accountant Dashboard
  ↓
Entries Tab
  ↓
Click Site Card
  ↓
Site Detail Screen (3 tabs)
  ↓
Requests Tab (shows badge if pending)
  ↓
Handle Request
```

## Testing

1. **Hot Restart Flutter App**
   ```
   Press R (capital R) in terminal
   ```

2. **Login as Accountant**
   - See 4 tabs in bottom navigation
   - Default tab: Dashboard (center)

3. **Navigate to Entries**
   - See all site cards

4. **Open a Site Card**
   - See 3 tabs: Labour, Material, Requests
   - Requests tab shows badge if pending

5. **Handle Requests**
   - Click Requests tab
   - See site-specific requests
   - Handle each request

## Status

✅ **Bottom Navigation**: Reduced from 5 to 4 tabs
✅ **Requests Access**: Moved to site detail screen
✅ **Default Tab**: Dashboard (center position)
✅ **Clean UI**: Simplified navigation structure

---

**Ready to test!** The accountant bottom navigation is now cleaner with requests accessible from within site cards.
