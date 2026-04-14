# Notifications System Setup Guide

## Overview
This guide will help you set up the late-entry notifications system for the construction management app.

## Files Created
1. `create_notifications_system.sql` - Database schema
2. `api/views_notifications.py` - API endpoints
3. `run_notifications_migration.py` - Migration script
4. Updated `api/urls.py` - Added notification routes

## Setup Steps

### Step 1: Run Database Migration
```bash
cd django-backend
python run_notifications_migration.py
```

This will create the `notifications` table with the following structure:
- id (UUID, primary key)
- site_id (UUID, foreign key to sites)
- entry_type (varchar: 'labour', 'material', 'morning_photo', 'evening_photo')
- message (text)
- actual_time (timestamp)
- created_at (timestamp)
- is_read (boolean)
- read_at (timestamp)
- supervisor_id (UUID)
- supervisor_name (varchar)
- site_name (varchar)

### Step 2: Restart Django Server
```bash
python manage.py runserver 0.0.0.0:8000
```

### Step 3: Test the API

#### Create Late Entry Notification
```bash
curl -X POST http://192.168.31.228:8000/api/notifications/late-entry/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "site_id": "site-uuid",
    "entry_type": "material",
    "message": "Material entry submitted at 11:59 AM. Should be submitted between 4:00 PM - 7:00 PM IST.",
    "actual_time": "2026-03-31T11:59:00.000Z"
  }'
```

#### Get All Notifications (Admin Only)
```bash
curl -X GET http://192.168.31.228:8000/api/notifications/ \
  -H "Authorization: Bearer ADMIN_TOKEN"
```

#### Get Unread Notifications
```bash
curl -X GET "http://192.168.31.228:8000/api/notifications/?is_read=false" \
  -H "Authorization: Bearer ADMIN_TOKEN"
```

#### Mark Notification as Read
```bash
curl -X POST http://192.168.31.228:8000/api/notifications/NOTIFICATION_ID/read/ \
  -H "Authorization: Bearer ADMIN_TOKEN"
```

#### Mark All Notifications as Read
```bash
curl -X POST http://192.168.31.228:8000/api/notifications/mark-all-read/ \
  -H "Authorization: Bearer ADMIN_TOKEN"
```

## API Endpoints

### POST /api/notifications/late-entry/
Create a new late entry notification (called by supervisors automatically)

**Request:**
```json
{
  "site_id": "uuid",
  "entry_type": "material|labour|morning_photo|evening_photo",
  "message": "Descriptive message",
  "actual_time": "ISO 8601 timestamp"
}
```

**Response:**
```json
{
  "success": true,
  "notification_id": "uuid",
  "created_at": "ISO 8601 timestamp",
  "sent_to": ["admin_id_1", "admin_id_2"]
}
```

### GET /api/notifications/
Get all notifications (admin only)

**Query Parameters:**
- `is_read` (optional): "true" or "false"
- `limit` (optional): number, default 50
- `offset` (optional): number, default 0

**Response:**
```json
{
  "success": true,
  "notifications": [
    {
      "id": "uuid",
      "site_id": "uuid",
      "entry_type": "material",
      "message": "Late entry message",
      "actual_time": "ISO 8601",
      "created_at": "ISO 8601",
      "is_read": false,
      "read_at": null,
      "supervisor_id": "uuid",
      "supervisor_name": "John Doe",
      "site_name": "Site Name"
    }
  ],
  "total_count": 10,
  "unread_count": 5
}
```

### POST /api/notifications/{notification_id}/read/
Mark a specific notification as read (admin only)

### POST /api/notifications/mark-all-read/
Mark all notifications as read (admin only)

## Frontend Integration

The Flutter app is already configured to send notifications. Once the backend is set up:

1. Supervisor submits material balance outside allowed time (4-7 PM)
2. Flutter app detects late entry
3. Sends POST request to `/api/notifications/late-entry/`
4. Admin sees notification in their dashboard
5. Admin can mark as read

## Troubleshooting

### Migration Fails
- Check database connection in `.env` file
- Ensure PostgreSQL is running
- Verify user has CREATE TABLE permissions

### Notifications Not Appearing
- Check Django server logs for errors
- Verify token authentication is working
- Check if notifications table exists: `SELECT * FROM notifications;`

### 403 Forbidden Error
- Ensure user has 'admin' role
- Check token is valid and not expired

## Testing Checklist

- [ ] Database migration runs successfully
- [ ] Django server starts without errors
- [ ] Can create notification via API
- [ ] Admin can retrieve notifications
- [ ] Can mark notification as read
- [ ] Can mark all notifications as read
- [ ] Flutter app sends notification on late entry
- [ ] Admin dashboard shows notifications

## Next Steps

After setup, you may want to:
1. Add push notifications (Firebase Cloud Messaging)
2. Add email notifications
3. Add notification preferences for admins
4. Add notification filtering by site/type
5. Add notification statistics dashboard
