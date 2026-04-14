# Admin Client Complaints Feature

## Overview
Added a "Client Complaints" button to the admin dashboard that shows ALL client complaints across all sites with client name, site name, and issue details.

## Implementation Status: ✅ COMPLETE

### Features Added

#### 1. Client Complaints Button in Admin Dashboard
**Location**: Site Management tab, below Labour Rates card

**Design**:
- Red gradient background (red.shade600 to red.shade400)
- Report problem icon
- Title: "Client Complaints"
- Subtitle: "View all client issues across sites"
- Chevron right arrow

#### 2. Admin Client Complaints Screen
**File**: `lib/screens/admin_client_complaints_screen.dart`

**Features**:
- Shows ALL client complaints across ALL sites (admin privilege)
- No site filtering - admin sees everything
- Status filter dropdown (All, Open, In Progress, Resolved, Closed)
- Pull-to-refresh functionality
- Empty state when no complaints

**Complaint Card Shows**:
- Title with priority badge (HIGH/MEDIUM/LOW/URGENT)
- Client name (who reported it)
- Site name (where the issue is)
- Customer name (site owner)
- Description (truncated to 2 lines)
- Status badge (colored)
- Message count
- Reported date

### UI Design

#### Client Complaints Button:
- Red gradient background
- White icon and text
- Positioned between Labour Rates and Site Budget Management
- Tappable card with chevron indicator

#### Complaints List Screen:
- AppBar: Deep navy with white text
- Filter icon in top right
- Pull-to-refresh enabled
- White complaint cards with shadow
- Priority badges: HIGH=red, MEDIUM=orange, LOW=blue, URGENT=red
- Status badges: OPEN=blue, IN_PROGRESS=orange, RESOLVED=green, CLOSED=grey

#### Complaint Card Layout:
```
┌─────────────────────────────────────┐
│ Title                    [PRIORITY] │ ← Header (light navy bg)
├─────────────────────────────────────┤
│ 👤 Client: Client Name              │
│ 🏢 Site: Site Name                  │
│ 🏪 Customer: Customer Name          │
│                                     │
│ Description text here...            │
│                                     │
│ [STATUS]          💬 0 messages     │
│ 📅 Reported: Jan 11, 2026          │
└─────────────────────────────────────┘
```

### API Integration

**Endpoint Used**: `GET /api/construction/client-complaints/`

**Query Parameters**:
- `status` (optional): Filter by status
- `site_id` (optional): NOT used for admin - admin sees all

**Service Method**: `getClientComplaintsForArchitect()`
- When called without `siteId`, returns ALL complaints
- Admin role allows access to all complaints

### User Flow

#### For Admin:
1. Login as admin
2. Go to "Sites" tab (bottom navigation)
3. See "Client Complaints" button (red card)
4. Tap "Client Complaints"
5. See list of ALL client complaints from ALL sites
6. Can filter by status using top-right filter icon
7. Can pull down to refresh
8. Each card shows:
   - Which client reported it
   - Which site it's for
   - What the issue is
   - Current status
   - How many messages

### Comparison: Admin vs Architect

| Feature | Admin | Architect |
|---------|-------|-----------|
| Access | All complaints across all sites | Only complaints for selected site |
| Site Filter | No (sees everything) | Yes (must select site first) |
| Button Location | Site Management tab | After site selection |
| Use Case | Overview of all issues | Site-specific issue management |

### Code Changes

#### Files Modified:
1. `lib/screens/admin_dashboard.dart`
   - Added import for `admin_client_complaints_screen.dart`
   - Added Client Complaints button card in Site Management tab

#### Files Created:
2. `lib/screens/admin_client_complaints_screen.dart`
   - NEW screen showing all client complaints
   - Reuses existing API endpoint
   - Similar UI to architect complaints screen but shows all sites

### Testing Instructions

1. **Login as Admin**:
   - Use admin credentials

2. **Navigate to Client Complaints**:
   - Tap "Sites" tab in bottom navigation
   - Scroll to see "Client Complaints" button (red card)
   - Tap the button

3. **Verify Complaints Display**:
   - Should see ALL client complaints from ALL sites
   - Check client names are shown
   - Check site names are shown
   - Check descriptions are visible

4. **Test Filters**:
   - Tap filter icon (top right)
   - Select "Open" → should show only OPEN complaints
   - Select "All Status" → should show all complaints

5. **Test Refresh**:
   - Pull down to refresh
   - Should reload complaints

6. **Test Empty State**:
   - If no complaints exist, should show empty state message

### Current Test Data

Based on database check:
```
Total Client Complaints: 3

1. Water Leakage in Bathroom
   Site: Test Construction Site
   Client: sivu
   Status: OPEN
   Priority: HIGH

2. pipe not working
   Site: 6 22 Ibrahim
   Client: Sivaaaa (clientanwar)
   Status: OPEN
   Priority: HIGH

3. bdnskaksjwns
   Site: 10 25 Karim
   Client: Sivaaaa (clientanwar)
   Status: OPEN
   Priority: URGENT
```

Admin should see all 3 complaints in the list.

### Key Features

✅ Admin sees ALL complaints (no site filter)
✅ Client name displayed
✅ Site name displayed
✅ Customer name displayed
✅ Issue description
✅ Priority badges (colored)
✅ Status badges (colored)
✅ Message count
✅ Reported date
✅ Status filtering
✅ Pull-to-refresh
✅ Empty state handling
✅ Clean, modern UI

### Benefits for Admin

1. **Overview**: See all client issues at a glance
2. **Monitoring**: Track complaint status across all sites
3. **Priority**: Identify high-priority issues quickly
4. **Response**: See which complaints need attention
5. **Accountability**: Monitor which sites have more issues

### Future Enhancements

1. Search functionality (by client, site, or keyword)
2. Sort options (by date, priority, status)
3. Export complaints to CSV/PDF
4. Complaint analytics dashboard
5. Assign complaints to specific architects
6. Bulk status updates
7. Complaint resolution workflow
8. Email notifications for new complaints

### Notes

- Admin privilege allows viewing all complaints
- No site selection required (unlike architect)
- Same backend API used for both admin and architect
- API automatically handles role-based filtering
- Complaints are read-only (no chat functionality)
- Status changes must be done via other means

---
**Status**: Complete and ready to test
**Date**: 2026-04-03
**Feature**: Admin client complaints overview
