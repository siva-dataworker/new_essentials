# Client Role Setup Guide

## Overview
The Client role has been implemented as a basic role in the system. Users can register and login as Client, but no dashboard/UI is implemented yet.

## What's Implemented

### 1. Flutter (Frontend)
- ✅ `UserRole.client` added to user model enum
- ✅ Client role displays as "Client" in the app
- ✅ Registration screen will show Client role option (loaded from backend)
- ✅ Login screen handles Client role (shows message that dashboard is not implemented)
- ✅ No dashboard/UI created (intentionally)

### 2. Backend (Django)
- ✅ Client role endpoints already exist in `views_client.py`:
  - `get_client_site_details` - Get site details for client
  - `get_client_labour_summary` - Get labour summary
  - `get_client_photos` - Get site photos
  - `get_client_documents` - Get documents
- ✅ URL routes configured in `urls.py`

### 3. Database
- ⚠️ Client role needs to be added to the `roles` table

## Setup Instructions

### Step 1: Check if Client Role Exists
```bash
cd essential/construction_flutter/django-backend
python check_client_role.py
```

### Step 2: Create Client Role (if it doesn't exist)
```bash
python create_client_role.py
```

This will:
- Create a new role with name "Client" in the `roles` table
- Generate a UUID for the role ID
- Set the created_at timestamp

### Step 3: Verify in Database
You can verify the role was created by checking the database:
```sql
SELECT * FROM roles WHERE role_name = 'Client';
```

### Step 4: Test Registration
1. Open the Flutter app
2. Go to Registration screen
3. The "Client" role should now appear in the role dropdown
4. Register a new user with Client role
5. Admin needs to approve the user

### Step 5: Test Login
1. After approval, login with Client credentials
2. You'll see a message: "Client dashboard is not yet implemented"
3. User stays on login screen (no navigation happens)

## Current Behavior

### Registration
- Client role appears in the dropdown
- Users can register as Client
- Registration follows normal approval flow

### Login
- Client users can login successfully
- JWT token is generated
- Instead of navigating to a dashboard, a SnackBar message is shown
- User remains on login screen

### Backend API
- All client endpoints are functional
- Endpoints require JWT authentication
- Only users with "Client" role can access client endpoints

## Next Steps (When Ready to Build Client Dashboard)

1. Create `client_dashboard.dart` screen
2. Import it in `login_screen.dart` and `main.dart`
3. Update the `case 'client':` sections to navigate to the dashboard
4. Implement UI to call existing backend endpoints:
   - Site details
   - Labour summary
   - Photos
   - Documents

## Files Modified

### Flutter
- `lib/models/user_model.dart` - Added Client to UserRole enum
- `lib/screens/login_screen.dart` - Added Client case with message
- `lib/main.dart` - Added Client case with login redirect

### Backend Scripts (New)
- `check_client_role.py` - Check if Client role exists
- `create_client_role.py` - Create Client role in database

### Backend (Existing - No Changes Needed)
- `api/views_client.py` - Client endpoints already exist
- `api/urls.py` - Client routes already configured

## Testing Checklist

- [ ] Run `check_client_role.py` to verify role status
- [ ] Run `create_client_role.py` if role doesn't exist
- [ ] Verify role in database
- [ ] Test registration with Client role
- [ ] Admin approves Client user
- [ ] Test login with Client credentials
- [ ] Verify message appears and no navigation happens
- [ ] Check backend logs for Client role detection

## Notes

- Client role is fully functional at the authentication level
- Backend API endpoints are ready to use
- Only the UI/dashboard is missing (intentionally)
- This allows Client users to be created and managed in the system
- When ready to build the dashboard, all backend infrastructure is in place
