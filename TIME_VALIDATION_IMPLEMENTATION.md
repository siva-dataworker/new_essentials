# Time Validation Implementation for Supervisor Entries

## Overview
Implemented time-based validation for supervisor entries with automatic admin notifications for late submissions. All times are based on Indian Standard Time (IST).

## Time Windows

### Labour Entry
- **Allowed Time**: Before 12:00 PM IST
- **Validation**: Entry submitted after 12:00 PM triggers admin notification

### Material Balance
- **Allowed Time**: 4:00 PM - 7:00 PM IST
- **Validation**: Entry submitted outside this window triggers admin notification

### Morning Photos
- **Allowed Time**: Before 11:00 AM IST
- **Validation**: Upload after 11:00 AM triggers admin notification

### Evening Photos
- **Allowed Time**: 4:00 PM - 7:30 PM IST
- **Validation**: Upload outside this window triggers admin notification

## Implementation Details

### New Files Created

1. **`lib/services/notification_service.dart`**
   - Service for sending late entry notifications to admin
   - API endpoint: `/api/notifications/late-entry/`
   - Sends notification with entry type, message, and actual submission time

2. **`lib/utils/time_validator.dart`**
   - Utility class for time validation and IST time handling
   - Functions:
     - `getISTTime()`: Returns current time in IST (UTC + 5:30)
     - `formatISTTime()`: Formats time for display
     - `isLabourEntryOnTime()`: Validates labour entry time
     - `isMaterialEntryOnTime()`: Validates material entry time
     - `isMorningPhotoOnTime()`: Validates morning photo upload time
     - `isEveningPhotoOnTime()`: Validates evening photo upload time
     - Various message generators for late entries

### Modified Files

1. **`lib/screens/site_detail_screen.dart`**
   - Added imports for `NotificationService` and `TimeValidator`
   - Updated `_submit()` method in `_LabourEntrySheetState`:
     - Checks if entry is on time
     - Sends notification to admin if late
     - Shows warning message in snackbar
   - Updated `_submit()` method in `_MaterialEntrySheetState`:
     - Checks if entry is on time
     - Sends notification to admin if late
     - Shows warning message in snackbar
   - Added IST time display in "Today's Entries" section
   - Added time window indicators in labour and material entry sheets
     - Green indicator when within allowed time
     - Orange warning when outside allowed time

2. **`lib/screens/supervisor_photo_upload_screen.dart`**
   - Added imports for `NotificationService` and `TimeValidator`
   - Updated `_uploadPhotos()` method:
     - Checks if upload is on time (morning or evening)
     - Sends notification to admin if late
     - Shows warning message in snackbar

## User Experience

### Visual Indicators

1. **Site Detail Screen**
   - Current IST time displayed at the top of "Today's Entries"
   - Format: "IST: HH:MM AM/PM"

2. **Labour Entry Sheet**
   - Green indicator: "Labour entries must be submitted before 12:00 PM IST • Current: HH:MM AM/PM"
   - Orange warning: "⚠️ Late Entry! Labour entries must be submitted before 12:00 PM IST"

3. **Material Entry Sheet**
   - Green indicator: "Material entries must be submitted between 4:00 PM - 7:00 PM IST • Current: HH:MM AM/PM"
   - Orange warning: "⚠️ Outside Time Window! Material entries must be submitted between 4:00 PM - 7:00 PM IST"

### Feedback Messages

1. **On-Time Submission**
   - Labour: "X labour types submitted successfully!"
   - Material: "✅ Materials updated!"
   - Photos: "✅ Photos uploaded successfully!"

2. **Late Submission**
   - Labour: "⚠️ X labour types submitted (Late entry - Admin notified)"
   - Material: "⚠️ Materials updated (Late entry - Admin notified)"
   - Photos: "⚠️ Photos uploaded (Late upload - Admin notified)"

## Backend Requirements

The backend needs to implement the following API endpoint:

### POST `/api/notifications/late-entry/`

**Request Body:**
```json
{
  "site_id": "string",
  "entry_type": "labour|material|morning_photo|evening_photo",
  "message": "string",
  "actual_time": "ISO 8601 datetime string"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "notification_id": "string",
    "sent_to": ["admin_user_ids"]
  }
}
```

**Functionality:**
- Create a notification record in the database
- Send push notification/email to admin users
- Include site name, supervisor name, entry type, and timestamp
- Mark notification as unread for admin dashboard

## Testing Checklist

- [ ] Labour entry before 12:00 PM - no notification
- [ ] Labour entry after 12:00 PM - admin receives notification
- [ ] Material entry between 4:00-7:00 PM - no notification
- [ ] Material entry outside 4:00-7:00 PM - admin receives notification
- [ ] Morning photo before 11:00 AM - no notification
- [ ] Morning photo after 11:00 AM - admin receives notification
- [ ] Evening photo between 4:00-7:30 PM - no notification
- [ ] Evening photo outside 4:00-7:30 PM - admin receives notification
- [ ] IST time displays correctly
- [ ] Time window indicators show correct status
- [ ] Snackbar messages display appropriate warnings

## Dependencies

- **intl**: ^0.19.0 (already in pubspec.yaml)
  - Used for date/time formatting

## Notes

- All time calculations use IST (UTC + 5:30)
- Notifications are sent asynchronously and don't block the submission
- Even if notification fails, the entry is still saved
- Time window indicators update in real-time based on current IST time
