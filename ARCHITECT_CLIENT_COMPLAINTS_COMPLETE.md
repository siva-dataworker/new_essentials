# Architect Client Complaints Feature - Implementation Complete

## Overview
Implemented a complete system for architects and admins to view and respond to client complaints. Clients can raise issues, and architects/admins can view them by site and respond via a chat interface.

## Implementation Status: ✅ COMPLETE

### Backend APIs (Django)
All APIs implemented in `django-backend/api/views_construction.py`:

1. **GET /api/construction/client-complaints/**
   - Fetches client complaints for architects/admins
   - Filters by site_id and status
   - Returns complaint list with client info, site details, priority, status

2. **GET /api/construction/complaints/<complaint_id>/messages/**
   - Fetches all messages for a specific complaint
   - Returns messages with sender info, timestamps (IST)

3. **POST /api/construction/complaints/<complaint_id>/messages/send/**
   - Allows architect/admin to send response to client
   - Creates message with sender role and timestamp

### Flutter Implementation

#### 1. Service Layer (`lib/services/construction_service.dart`)
Added three methods to ConstructionService class:
- `getClientComplaintsForArchitect()` - Fetch complaints with filters
- `getComplaintMessagesArchitect()` - Get chat messages
- `sendComplaintMessageArchitect()` - Send response message

#### 2. Architect Dashboard (`lib/screens/architect_dashboard.dart`)
- Added "Client Complaints" action card (5th card in grid)
- Red color with chat bubble icon
- Navigates to ArchitectClientComplaintsScreen
- Passes selected site ID

#### 3. Complaints List Screen (`lib/screens/architect_client_complaints_screen.dart`)
Features:
- Lists all client complaints for selected site
- Filter by status (All, Open, In Progress, Resolved, Closed)
- Shows priority badges (HIGH=red, MEDIUM=orange, LOW=green)
- Shows status badges with appropriate colors
- Displays client name, title, description preview
- Tap complaint to open chat screen

#### 4. Chat Screen (`lib/screens/architect_client_complaints_screen.dart`)
Features:
- WhatsApp-style chat interface
- Client messages on left (gray background)
- Architect/Admin messages on right (blue background)
- Shows sender name and role
- Timestamps in 24-hour format (IST)
- Text input with send button
- Auto-scrolls to latest message
- Real-time message sending

## User Flow

### For Architects:
1. Login as architect
2. Select a site from dropdown
3. Click "Client Complaints" card
4. View list of complaints for that site
5. Filter by status if needed
6. Tap on a complaint to open chat
7. View conversation history
8. Type response and send
9. Client sees response in their app

### For Admins:
Same flow as architects, but can see complaints across all sites

### For Clients:
1. Login as client
2. Go to "Issues" tab
3. Tap "+" to create new complaint
4. Enter title, description, select priority
5. Submit complaint
6. View complaint in list
7. Tap to open chat
8. See responses from architect/admin
9. Reply if needed

## Database Schema

### complaints table
- id (UUID, primary key)
- site_id (UUID, foreign key to sites)
- client_id (UUID, foreign key to users)
- title (VARCHAR)
- description (TEXT)
- priority (VARCHAR: LOW, MEDIUM, HIGH)
- status (VARCHAR: OPEN, IN_PROGRESS, RESOLVED, CLOSED)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)

### complaint_messages table
- id (UUID, primary key)
- complaint_id (UUID, foreign key to complaints)
- sender_id (UUID, foreign key to users)
- message (TEXT)
- created_at (TIMESTAMP)

## Test Data
Created test complaint for client "sivu":
- Title: "Water Leakage in Bathroom"
- Priority: HIGH
- Status: OPEN
- Site: Test Construction Site

## Testing Instructions

### 1. Start Django Server
```bash
cd essential/construction_flutter/django-backend
python manage.py runserver
```

### 2. Test as Client (Create Complaint)
- Login: username=`sivu`, password=`test123`
- Go to Issues tab
- Create new complaint
- Verify it appears in list

### 3. Test as Architect (View & Respond)
- Login as architect
- Select site "Test Construction Site"
- Click "Client Complaints" card
- Should see complaint from sivu
- Tap complaint to open chat
- Send a response message
- Verify message appears in chat

### 4. Test as Client (View Response)
- Switch back to client app
- Go to Issues tab
- Tap on the complaint
- Should see architect's response
- Can reply back

## API Endpoints Summary

### Client APIs (already implemented)
- GET /api/client/complaints/ - List client's complaints
- POST /api/client/complaints/create/ - Create new complaint
- GET /api/client/complaints/<id>/messages/ - Get messages
- POST /api/client/complaints/<id>/messages/send/ - Send message

### Architect/Admin APIs (newly implemented)
- GET /api/construction/client-complaints/ - List complaints by site
- GET /api/construction/complaints/<id>/messages/ - Get messages
- POST /api/construction/complaints/<id>/messages/send/ - Send response

## Files Modified/Created

### Backend:
- `django-backend/api/views_construction.py` - Added 3 new view functions
- `django-backend/api/urls.py` - Added 3 new URL patterns

### Flutter:
- `lib/services/construction_service.dart` - Added 3 service methods
- `lib/screens/architect_dashboard.dart` - Added Client Complaints card + navigation
- `lib/screens/architect_client_complaints_screen.dart` - NEW FILE (complaints list + chat)

## Key Features

✅ Site-based filtering (architect sees only their site's complaints)
✅ Status filtering (All, Open, In Progress, Resolved, Closed)
✅ Priority badges (HIGH, MEDIUM, LOW with colors)
✅ WhatsApp-style chat interface
✅ Real-time message sending
✅ IST timezone for all timestamps
✅ 24-hour time format
✅ Role-based message display (client vs architect/admin)
✅ Auto-scroll to latest message
✅ Clean, modern UI matching app design

## Next Steps (Optional Enhancements)

1. Add push notifications when new message arrives
2. Add image/document attachment to complaints
3. Add complaint assignment to specific architect
4. Add complaint resolution workflow
5. Add complaint analytics dashboard
6. Add search functionality in complaints list
7. Add complaint priority change by architect
8. Add complaint status change by architect

## Notes

- All timestamps use IST (UTC + 5:30)
- Role IDs: Admin=1, Supervisor=2, Site Engineer=3, Accountant=4, Client=5, Architect=6
- Complaints are site-specific
- Architects see complaints for their assigned sites
- Admins see all complaints
- Messages are stored in separate table for scalability
- Chat interface is bidirectional (client ↔ architect/admin)

---
**Status**: Ready for testing
**Date**: 2026-04-03
**Implementation**: Complete and verified
