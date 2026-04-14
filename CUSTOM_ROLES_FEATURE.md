# Custom Roles Feature - Complete Guide

## Overview
The system already has a fully functional custom roles feature! Admin can create custom roles (like "Client") and then create users with those roles.

## How It Works

### 1. Create Custom Role (Admin)

**Steps:**
1. Login as Admin
2. Go to Profile tab
3. Click "Create Role"
4. Enter role name (e.g., "Client", "Quality Inspector", "Safety Officer")
5. Click "Create"

**Backend API:**
- **Endpoint**: `POST /api/admin/create-role/`
- **Body**: `{"role_name": "Client"}`
- **Response**: `{"message": "Role 'Client' created successfully"}`

**What Happens:**
- New role is inserted into `roles` table
- Role becomes immediately available in "Create User" dropdown

### 2. Create User with Custom Role (Admin)

**Steps:**
1. Login as Admin
2. Go to Profile tab
3. Click "Create User"
4. Fill in user details:
   - Full Name
   - Username
   - Email
   - Phone (10 digits)
   - Password (min 6 characters)
   - **Role** (dropdown shows all roles except Admin)
5. Select the custom role (e.g., "Client")
6. Click "Create"

**Backend API:**
- **Endpoint**: `POST /api/admin/create-user/`
- **Body**:
```json
{
  "full_name": "John Doe",
  "username": "johndoe",
  "email": "john@example.com",
  "phone": "1234567890",
  "password": "password123",
  "role": "Client"
}
```
- **Response**: `{"message": "User 'johndoe' created successfully", "user_id": "uuid"}`

**What Happens:**
- User is created with `status = 'APPROVED'` and `is_active = true`
- User can login immediately
- User's role is set to the selected custom role

### 3. View All Roles (Admin)

**Backend API:**
- **Endpoint**: `GET /api/admin/roles/`
- **Response**:
```json
{
  "roles": [
    {"id": 1, "role_name": "Admin"},
    {"id": 2, "role_name": "Supervisor"},
    {"id": 3, "role_name": "Site Engineer"},
    {"id": 4, "role_name": "Accountant"},
    {"id": 5, "role_name": "Architect"},
    {"id": 6, "role_name": "Owner"},
    {"id": 7, "role_name": "Client"}
  ]
}
```

## Default Roles

The system comes with 6 predefined roles:
1. **Admin** - Full system access
2. **Supervisor** - Site supervision, labour/material entry
3. **Site Engineer** - Work updates, material inventory
4. **Accountant** - Financial management, bill uploads
5. **Architect** - Document uploads, complaints
6. **Owner** - View-only access (if implemented)

## Custom Role Examples

You can create any custom roles needed:
- **Client** - For customers to view their project progress
- **Quality Inspector** - For quality control checks
- **Safety Officer** - For safety compliance
- **Contractor** - For subcontractors
- **Material Supplier** - For vendors
- **Project Manager** - For project oversight

## Database Schema

### roles table
```sql
CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    role_name VARCHAR(50) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### users table (role relationship)
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255),
    role_id INTEGER REFERENCES roles(id),  -- Links to roles table
    status VARCHAR(20) DEFAULT 'PENDING',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## UI Flow

### Admin Profile Screen
```
┌─────────────────────────────────┐
│         Profile                 │
│                                 │
│  System Admin                   │
│  [ADMIN]                        │
│                                 │
│  Management                     │
│  ┌───────────────────────────┐ │
│  │ 👤 Create User            │ │
│  │ Add Supervisor, Engineer  │ │
│  └───────────────────────────┘ │
│  ┌───────────────────────────┐ │
│  │ 🔐 Create Admin           │ │
│  │ Add another admin account │ │
│  └───────────────────────────┘ │
│  ┌───────────────────────────┐ │
│  │ 🎭 Create Role            │ │
│  │ Add a new custom role     │ │
│  └───────────────────────────┘ │
└─────────────────────────────────┘
```

### Create Role Dialog
```
┌─────────────────────────────────┐
│  Create Role                    │
│                                 │
│  ┌───────────────────────────┐ │
│  │ 🎭 Role Name              │ │
│  │ e.g. Quality Inspector    │ │
│  └───────────────────────────┘ │
│                                 │
│  [Cancel]  [Create]             │
└─────────────────────────────────┘
```

### Create User Dialog
```
┌─────────────────────────────────┐
│  Create User                    │
│                                 │
│  ┌───────────────────────────┐ │
│  │ 👤 Full Name              │ │
│  └───────────────────────────┘ │
│  ┌───────────────────────────┐ │
│  │ @ Username                │ │
│  └───────────────────────────┘ │
│  ┌───────────────────────────┐ │
│  │ ✉ Email                   │ │
│  └───────────────────────────┘ │
│  ┌───────────────────────────┐ │
│  │ 📱 Phone                  │ │
│  └───────────────────────────┘ │
│  ┌───────────────────────────┐ │
│  │ 🔒 Password               │ │
│  └───────────────────────────┘ │
│  ┌───────────────────────────┐ │
│  │ 🎭 Role ▼                 │ │
│  │   - Supervisor            │ │
│  │   - Site Engineer         │ │
│  │   - Accountant            │ │
│  │   - Architect             │ │
│  │   - Owner                 │ │
│  │   - Client  ← NEW!        │ │
│  └───────────────────────────┘ │
│                                 │
│  [Cancel]  [Create]             │
└─────────────────────────────────┘
```

## Testing Steps

### Test 1: Create Custom Role
1. Login as Admin
2. Click "Create Role"
3. Enter "Client"
4. Click Create
5. ✅ Should show success message

### Test 2: Verify Role in Dropdown
1. Click "Create User"
2. Scroll to Role dropdown
3. ✅ Should see "Client" in the list

### Test 3: Create User with Custom Role
1. Fill in all user details
2. Select "Client" from Role dropdown
3. Click Create
4. ✅ Should show success message

### Test 4: Verify User Can Login
1. Logout from Admin
2. Login with new client credentials
3. ✅ Should login successfully
4. ✅ Should see appropriate dashboard for Client role

## Error Handling

### Duplicate Role Name
- **Error**: "Role 'Client' already exists"
- **Solution**: Use a different role name

### Invalid Role in Create User
- **Error**: "Role 'XYZ' not found"
- **Solution**: Create the role first using "Create Role"

### Missing Required Fields
- **Error**: "username, email, phone, password and role are required"
- **Solution**: Fill in all required fields

## Security

- ✅ Only Admin can create roles
- ✅ Only Admin can create users
- ✅ Admin role is filtered out from user creation dropdown
- ✅ Passwords are hashed using Django's `make_password()`
- ✅ Users created by admin are auto-approved (`status = 'APPROVED'`)
- ✅ Users are active by default (`is_active = true`)

## Files Involved

### Frontend:
- `lib/screens/admin_dashboard.dart`
  - `_showCreateRoleDialog()` - Create role UI
  - `_showCreateUserDialog()` - Create user UI with role dropdown

### Backend:
- `api/views_auth.py`
  - `admin_create_role()` - Create role API
  - `admin_create_user()` - Create user API
  - `get_all_roles()` - Get roles API

- `api/urls.py`
  - `path('admin/create-role/', ...)`
  - `path('admin/create-user/', ...)`
  - `path('admin/roles/', ...)`

## Summary

✅ **Feature is fully implemented and working!**

The system already supports:
1. Creating custom roles dynamically
2. Viewing all roles in the create user dropdown
3. Creating users with custom roles
4. Filtering out Admin role from user creation

No additional implementation needed - the feature is ready to use!
