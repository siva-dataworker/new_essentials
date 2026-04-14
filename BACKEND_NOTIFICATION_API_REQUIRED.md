# Backend Notification API Implementation Required

## Issue
Material balance was updated at 11:59 AM (outside the allowed 4:00 PM - 7:00 PM window), but the admin notification is not being sent.

## Root Cause
The Flutter app is correctly detecting the late entry and attempting to send a notification, but the backend API endpoint `/api/notifications/late-entry/` likely doesn't exist or is not working properly.

## Required Backend Implementation

### API Endpoint
**POST** `/api/notifications/late-entry/`

### Request Headers
```
Content-Type: application/json
Authorization: Bearer <token>
```

### Request Body
```json
{
  "site_id": "uuid-string",
  "entry_type": "material|labour|morning_photo|evening_photo",
  "message": "Material entry submitted at 11:59 AM. Should be submitted between 4:00 PM - 7:00 PM IST.",
  "actual_time": "2026-03-31T11:59:00.000Z"
}
```

### Expected Response (Success)
```json
{
  "success": true,
  "notification_id": "uuid",
  "sent_to": ["admin_user_id_1", "admin_user_id_2"]
}
```

### Expected Response (Error)
```json
{
  "error": "Error message here"
}
```

## Frontend Changes Made

1. **Improved IST Time Calculation** - Now correctly handles system timezone
2. **Enhanced Debug Logging** - Added detailed logs to track notification flow
3. **Better Error Handling** - Logs notification errors for debugging

## Testing the Fix

After implementing the backend endpoint, test by:
1. Submitting material balance outside 4:00 PM - 7:00 PM
2. Check console logs for notification attempt
3. Verify admin receives notification
4. Check snackbar shows "⚠️ Materials updated (Late entry - Admin notified)"

## Console Logs to Watch
```
🕒 [MATERIAL] Current IST time: ...
🕒 [MATERIAL] Is on time: false
📧 [MATERIAL] Sending late entry notification to admin...
📧 [MATERIAL] Notification result: true/false
```
