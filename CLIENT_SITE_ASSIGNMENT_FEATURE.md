# Client Site Assignment Feature

## Overview
When admin creates a user with "Client" role, they must select which site(s) the client can access. When the client logs in, they automatically see only their assigned site details.

## How It Works

### 1. Admin Creates Client Role
1. Login as Admin
2. Click "Create Role"
3. Enter "Client"
4. Click Create

### 2. Admin Creates Client User with Site Assignment

**UI Flow:**
1. Login as Admin
2. Click "Create User"
3. Fill in user details (name, username, email, phone, password)
4. Select "Client" from Role dropdown
5. **Site selection appears automatically!**
6. Select one or more sites from the list
7. Click "Create"

**What Happens:**
- User is created with Client role
- Selected sites are linked to the client in `client_sites` table
- Client can only access assigned sites

### 3. Client Logs In

**What Client Sees:**
- Automatically redirected to their assigned site(s)
- Can only view data for assigned sites
- No access to other sites

## Database Schema

### client_sites table
```sql
CREATE TABLE client_sites (
    id UUID PRIMARY KEY,
    client_id UUID REFERENCES users(id) ON DELETE CASCADE,
    site_id UUID REFERENCES sites(id) ON DELETE CASCADE,
    assigned_by UUID REFERENCES users(id),
    assigned_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    UNIQUE(client_id, site_id)
);
```

## API Endpoints

### 1. Create User with Site Assignment
- **Endpoint**: `POST /api/admin/create-user/`
- **Auth**: Admin only
- **Body**:
```json
{
  "full_name": "John Doe",
  "username": "johndoe",
  "email": "john@example.com",
  "phone": "1234567890",
  "password": "password123",
  "role": "Client",
  "site_ids": ["uuid1", "uuid2"]
}
```
- **Response**:
```json
{
  "message": "User 'johndoe' created successfully with 2 site(s) assigned",
  "user_id": "uuid"
}
```

### 2. Get Client's Assigned Sites
- **Endpoint**: `GET /api/client/sites/`
- **Auth**: Client only
- **Response**:
```json
{
  "success": true,
  "sites": [
    {
      "id": "uuid",
      "site_name": "Site A",
      "customer_name": "Customer X",
      "display_name": "Customer X Site A",
      "area": "Area 1",
      "street": "Street 1",
      "status": "ACTIVE",
      "assigned_date": "2026-03-27"
    }
  ],
  "count": 1
}
```

## UI Components

### Create User Dialog (Client Role Selected)

```
┌─────────────────────────────────────┐
│  Create User                        │
│                                     │
│  👤 Full Name: [John Doe]           │
│  @ Username: [johndoe]              │
│  ✉ Email: [john@example.com]       │
│  📱 Phone: [1234567890]             │
│  🔒 Password: [••••••]              │
│  🎭 Role: [Client ▼]                │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  🏗️ Assign Site(s)                  │
│  Client will only see assigned sites│
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ☑ Customer A Site 1         │   │
│  │ ☐ Customer B Site 2         │   │
│  │ ☑ Customer C Site 3         │   │
│  │ ☐ Customer D Site 4         │   │
│  └─────────────────────────────┘   │
│                                     │
│  ⚠️ Please select at least one site │
│                                     │
│  [Cancel]  [Create]                 │
└─────────────────────────────────────┘
```

## Features

### Dynamic Site Selection
- Site list appears only when "Client" role is selected
- Sites are loaded from the database
- Multiple sites can be selected
- Validation ensures at least one site is selected

### Client Dashboard
- Client sees only assigned sites
- No access to other sites
- Can view site details, progress, photos, etc.
- Restricted to read-only access (configurable)

### Admin Management
- Admin can assign/unassign sites later
- Admin can see which clients are assigned to which sites
- Admin can create multiple clients for the same site

## Validation Rules

1. **Client Role Requires Sites**
   - Error if no sites selected for Client role
   - Warning message: "Please select at least one site"

2. **Unique Client-Site Pairs**
   - Same site cannot be assigned twice to same client
   - Database constraint: `UNIQUE(client_id, site_id)`

3. **Site Existence**
   - Only existing sites can be assigned
   - Foreign key constraint ensures data integrity

## Security

- ✅ Only Admin can create clients
- ✅ Only Admin can assign sites
- ✅ Clients can only access their assigned sites
- ✅ API validates user role before returning data
- ✅ Database constraints prevent invalid assignments

## Testing Steps

### Test 1: Create Client Role
1. Login as Admin
2. Click "Create Role"
3. Enter "Client"
4. ✅ Role created successfully

### Test 2: Create Client with Site Assignment
1. Click "Create User"
2. Fill in details
3. Select "Client" role
4. ✅ Site selection appears
5. Select 2 sites
6. Click Create
7. ✅ Success message shows "with 2 site(s) assigned"

### Test 3: Client Login
1. Logout from Admin
2. Login as client
3. ✅ Client sees only assigned sites
4. ✅ Cannot access other sites

### Test 4: Validation
1. Try creating client without selecting sites
2. ✅ Error: "Please select at least one site"

## Files Modified

### Frontend:
- `lib/screens/admin_dashboard.dart`
  - Updated `_showCreateUserDialog()` to show site selection for Client role
  - Added site loading and selection logic
  - Added validation for site selection

### Backend:
- `api/views_auth.py`
  - Updated `admin_create_user()` to handle site assignments
  - Added `get_client_sites()` endpoint for clients

- `api/urls.py`
  - Added `path('client/sites/', ...)`

### Database:
- `create_client_sites_table.sql`
  - New table for client-site relationships

## Next Steps

### Optional Enhancements:
1. **Client Dashboard** - Create dedicated dashboard for clients
2. **Site Details View** - Show site progress, photos, reports
3. **Multi-Site Selector** - Allow client to switch between assigned sites
4. **Site Permissions** - Configure what clients can see (photos, reports, etc.)
5. **Admin Site Management** - UI to reassign sites to clients

## Summary

✅ **Feature Fully Implemented!**

- Admin can create Client role
- Admin selects sites when creating client users
- Sites are automatically assigned in database
- Client API endpoint ready to fetch assigned sites
- Validation ensures at least one site is selected
- Ready to build client dashboard!
