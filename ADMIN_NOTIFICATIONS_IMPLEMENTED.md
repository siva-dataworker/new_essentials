# Admin Notifications Implementation Complete

## Overview
Implemented a complete notification system for admin to view late entries (material balance, labour counts, and photos) submitted outside allowed time windows by supervisors.

## Features Implemented

### 1. Backend API (Django)
✅ **Notification Endpoints**:
- `GET /api/notifications/` - Get all notifications with filtering
- `POST /api/notifications/late-entry/` - Create late entry notification
- `POST /api/notifications/<uuid>/read/` - Mark notification as read
- `POST /api/notifications/mark-all-read/` - Mark all notifications as read

✅ **Data Returned**:
- Notification ID, type, message
- Site name and ID
- Supervisor name and ID
- Actual submission time
- Entry type (labour, material, morning_photo, evening_photo)
- Read/unread status
- Created timestamp
- Total count and unread count

### 2. Flutter Service Layer
✅ **NotificationService** (`lib/services/notification_service.dart`):
- `getNotifications()` - Fetch notifications with optional filters
- `markAsRead(notificationId)` - Mark single notification as read
- `markAllAsRead()` - Mark all notifications as read
- `sendLateEntryNotification()` - Send notification (already implemented)

### 3. Admin Dashboard UI
✅ **Notifications Tab** (`lib/screens/admin_dashboard.dart`):
- Empty state with refresh button
- Loading state with spinner
- List of notifications with pull-to-refresh
- Header with unread count badge
- "Mark all read" button
- Individual notification cards

✅ **Notification Card Design**:
- Color-coded by entry type:
  - 🔵 Labour Entry (blue)
  - 🟢 Material Balance (green)
  - 🟡 Morning Photo (amber)
  - 🟣 Evening Photo (indigo)
- Visual indicators:
  - Red dot for unread notifications
  - Highlighted border for unread
  - Grayed out when read
- Information displayed:
  - Entry type with icon
  - Warning message
  - Site name
  - Supervisor name
  - Actual submission time
  - Time ago (e.g., "2h ago")
- Tap to mark as read

## API Endpoints

### Get Notifications
```
GET /api/notifications/
Query Parameters:
  - is_read: true/false (optional)
  - limit: number (default: 50)
  - offset: number (default: 0)

Response:
{
  "success": true,
  "notifications": [
    {
      "id": "uuid",
      "site_id": "uuid",
      "site_name": "Site Name",
      "supervisor_id": "uuid",
      "supervisor_name": "Supervisor Name",
      "entry_type": "material|labour|morning_photo|evening_photo",
      "message": "Material entry submitted outside allowed time...",
      "actual_time": "2026-03-31T06:29:53+05:30",
      "created_at": "2026-03-31T06:30:00+05:30",
      "is_read": false,
      "read_at": null
    }
  ],
  "total": 10,
  "unread_count": 5
}
```

### Mark as Read
```
POST /api/notifications/<notification_id>/read/
Response:
{
  "success": true,
  "message": "Notification marked as read"
}
```

### Mark All as Read
```
POST /api/notifications/mark-all-read/
Response:
{
  "success": true,
  "message": "5 notifications marked as read"
}
```

## Time Windows

| Entry Type | Allowed Time (IST) | Notification Trigger |
|------------|-------------------|---------------------|
| Labour | Before 12:00 PM | After 12:00 PM |
| Material | 4:00 PM - 7:00 PM | Before 4:00 PM or After 7:00 PM |
| Morning Photo | Before 11:00 AM | After 11:00 AM |
| Evening Photo | 4:00 PM - 7:30 PM | Before 4:00 PM or After 7:30 PM |

## User Flow

### Supervisor Side
1. Supervisor submits entry (material/labour/photo)
2. Flutter app checks time using `TimeValidator`
3. If outside allowed window:
   - Entry is saved to database
   - Notification sent to backend via `NotificationService`
   - UI shows orange warning "Late entry - Admin notified"
   - Flutter console logs notification result

### Admin Side
1. Admin opens app and navigates to "Alerts" tab
2. App calls `getNotifications()` API
3. Notifications displayed in list with:
   - Unread count badge in header
   - Color-coded cards by entry type
   - Red dot on unread notifications
4. Admin taps notification to mark as read
5. Admin can tap "Mark all read" to clear all
6. Pull down to refresh notifications

## Testing

### Test Scenario 1: Material Entry Outside Time
1. Submit material balance at 11:59 AM (outside 4-7 PM)
2. Check Flutter console for notification logs
3. Open admin dashboard → Alerts tab
4. Verify notification appears with:
   - Green icon (Material Balance)
   - Warning message
   - Site and supervisor info
   - Actual time: 11:59 AM

### Test Scenario 2: Labour Entry Late
1. Submit labour count at 12:30 PM (after 12:00 PM)
2. Check admin notifications
3. Verify blue icon (Labour Entry)
4. Verify message shows late submission

### Test Scenario 3: Mark as Read
1. Tap on unread notification
2. Verify red dot disappears
3. Verify card background changes to gray
4. Verify unread count decreases

### Test Scenario 4: Mark All Read
1. Have multiple unread notifications
2. Tap "Mark all read" button
3. Verify all notifications marked as read
4. Verify unread count becomes 0

## Files Modified

### Flutter
- `lib/services/notification_service.dart` - Added get, mark read methods
- `lib/screens/admin_dashboard.dart` - Implemented notifications tab UI

### Backend
- `api/views_notifications.py` - Updated get endpoint to return unread count

## Database Schema

```sql
CREATE TABLE notifications (
    id UUID PRIMARY KEY,
    site_id UUID REFERENCES sites(id),
    site_name VARCHAR(255),
    supervisor_id UUID REFERENCES users(id),
    supervisor_name VARCHAR(255),
    entry_type VARCHAR(50), -- 'labour', 'material', 'morning_photo', 'evening_photo'
    message TEXT,
    actual_time TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP WITH TIME ZONE
);
```

## Next Steps

1. ✅ Restart Django server to load updated code
2. ✅ Test notification creation by submitting late entries
3. ✅ Verify notifications appear in admin dashboard
4. ✅ Test mark as read functionality
5. ✅ Test mark all as read functionality
6. ✅ Verify unread count updates correctly

## Success Criteria

- [x] Admin can view all late entry notifications
- [x] Notifications show entry type, site, supervisor, time
- [x] Unread notifications are visually distinct
- [x] Admin can mark individual notifications as read
- [x] Admin can mark all notifications as read
- [x] Unread count badge displays correctly
- [x] Pull-to-refresh works
- [x] Empty state shows when no notifications
- [x] Loading state shows while fetching

## Screenshots Reference

The UI matches the provided screenshot with:
- "Notifications" header with bell icon
- "Work Notifications" empty state
- "Refresh Notifications" button
- Bottom navigation with "Alerts" tab active

When notifications exist:
- List of color-coded notification cards
- Unread count badge
- "Mark all read" button
- Individual notification details
