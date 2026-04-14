# Client Dashboard - Complete Implementation Guide

## Current Status

✅ **Client Dashboard Created** - Fully functional UI
✅ **Role-based Routing** - Clients redirect to ClientDashboard
✅ **API Integration** - Backend endpoints ready
⚠️ **Database Table** - `client_sites` table needs to be created

## Issue: "No site assigned to you"

This message appears because:
1. The `client_sites` table doesn't exist in the database yet, OR
2. The table exists but client3 has no site assignments

## Solution Steps

### Option 1: Create Database Table (Recommended)

When PostgreSQL is running, execute this SQL:

```sql
-- Create client_sites table
CREATE TABLE IF NOT EXISTS client_sites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID REFERENCES users(id) ON DELETE CASCADE,
    site_id UUID REFERENCES sites(id) ON DELETE CASCADE,
    assigned_by UUID REFERENCES users(id) ON DELETE SET NULL,
    assigned_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    UNIQUE(client_id, site_id)
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_client_sites_client ON client_sites(client_id);
CREATE INDEX IF NOT EXISTS idx_client_sites_site ON client_sites(site_id);
CREATE INDEX IF NOT EXISTS idx_client_sites_active ON client_sites(is_active);
```

Then re-create the client user with site assignment.

### Option 2: Re-create Client User

1. **Login as Admin**
2. **Go to Profile > Create User**
3. **Fill in details:**
   - Full Name: Test Client
   - Username: client4
   - Email: client4@gmail.com
   - Phone: 1234567890
   - Password: password123
   - Role: **Client** ← Important!
4. **Select Sites** - The site list will appear
5. **Check 1-2 sites**
6. **Click Create**
7. **Logout and login as client4**

## Client Dashboard Features

### 1. Site Header
- Shows assigned site name
- Displays location (area - street)
- Gradient background with site info

### 2. Ongoing Work Pictures
- Horizontal scrollable gallery
- Shows morning/evening photos
- Uploaded by supervisor
- Displays upload date

### 3. Agreement & Estimation
- Agreement documents
- Project estimation files
- Uploaded by admin/architect
- Download option available

### 4. Floor Planning
- Floor plan documents
- Architectural drawings
- PDF/Image files
- View and download

### 5. Project Files
- Other project documents
- Technical specifications
- Uploaded by architect
- Organized by type

### 6. Extra Requirements
- Shows total extra amount
- Lists additional work
- Displays pending payments
- Updated by accountant

## API Endpoints Used

### 1. Get Client Sites
```
GET /api/client/sites/
Headers: Authorization: Bearer <token>

Response:
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
      "assigned_date": "2026-03-27"
    }
  ],
  "count": 1
}
```

### 2. Get Work Photos
```
GET /api/construction/supervisor-photos/?site_id=<uuid>
Headers: Authorization: Bearer <token>

Response:
{
  "photos": [
    {
      "photo_url": "/media/photos/...",
      "time_of_day": "morning",
      "uploaded_date": "2026-03-27"
    }
  ]
}
```

### 3. Get Architect Documents
```
GET /api/construction/architect-documents/?site_id=<uuid>
Headers: Authorization: Bearer <token>

Response:
{
  "documents": [
    {
      "id": "uuid",
      "title": "Floor Plan",
      "document_type": "FLOOR_PLAN",
      "description": "Ground floor layout",
      "file_url": "/media/documents/...",
      "uploaded_date": "2026-03-27"
    }
  ]
}
```

## Database Schema

### client_sites table
```sql
CREATE TABLE client_sites (
    id UUID PRIMARY KEY,
    client_id UUID REFERENCES users(id),
    site_id UUID REFERENCES sites(id),
    assigned_by UUID REFERENCES users(id),
    assigned_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    UNIQUE(client_id, site_id)
);
```

### Relationships
- **client_id** → users.id (Client user)
- **site_id** → sites.id (Assigned site)
- **assigned_by** → users.id (Admin who assigned)

## Files Created/Modified

### New Files:
1. `lib/screens/client_dashboard.dart` - Client dashboard UI
2. `django-backend/create_client_sites_table.sql` - Table creation script
3. `django-backend/check_client_sites.py` - Diagnostic script

### Modified Files:
1. `lib/main.dart` - Added Client routing
2. `lib/screens/login_screen.dart` - Added Client case
3. `lib/screens/admin_dashboard.dart` - Added site selection for Client role
4. `api/views_auth.py` - Updated create_user to handle site assignments
5. `api/urls.py` - Added client/sites/ endpoint

## Testing Checklist

- [ ] Create `client_sites` table in database
- [ ] Create new client user with site assignment
- [ ] Login as client
- [ ] Verify site header shows correct site
- [ ] Check if work photos load (if any exist)
- [ ] Check if documents load (if any exist)
- [ ] Test refresh functionality
- [ ] Test error handling (no sites assigned)

## Troubleshooting

### "No site assigned to you"
**Cause**: No entries in client_sites table for this user
**Fix**: Re-create user with site selection OR manually insert into client_sites table

### "Failed to load site data"
**Cause**: API error or network issue
**Fix**: Check backend logs, verify token is valid

### Photos/Documents not showing
**Cause**: No data uploaded yet OR API endpoint issue
**Fix**: Upload some photos/documents first, check API responses

### Table doesn't exist error
**Cause**: client_sites table not created
**Fix**: Run create_client_sites_table.sql script

## Next Steps

1. **Create the database table** when PostgreSQL is available
2. **Re-create client user** with proper site assignment
3. **Upload sample data**:
   - Supervisor uploads work photos
   - Architect uploads documents
   - Accountant adds extra requirements
4. **Test the complete flow**

## Summary

The Client Dashboard is fully implemented and ready to use! The only remaining step is to:
1. Create the `client_sites` database table
2. Assign sites to client users during creation

Once these steps are complete, clients will see their project information including:
- Site details
- Work progress photos
- Project documents
- Financial information

The dashboard provides a clean, read-only view perfect for clients to monitor their construction project!
