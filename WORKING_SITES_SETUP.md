# Working Sites Feature - Setup & Troubleshooting

## Overview
The Working Sites feature allows accountants to assign sites to ALL supervisors at once. Supervisors can then view their assigned sites in a dropdown.

## How It Works

### For Accountant:
1. Click the "+" icon in the Accountant Dashboard
2. Select sites from the list (with search functionality)
3. Optionally add descriptions for each site
4. Click "Assign X Sites to All Supervisors"
5. Sites are automatically assigned to ALL active supervisors

### For Supervisor:
1. Click "Working Sites" icon in Supervisor Dashboard
2. View all assigned sites
3. Click on any site to navigate to site details

## Recent Fixes Applied

### 1. Fixed Empty Site Names
- **Issue**: First 3 sites showing blank
- **Fix**: Improved display_name generation to handle null/empty values
- **Result**: All sites now show proper names

### 2. Fixed UUID Slicing Error
- **Issue**: "UUID object is not subscriptable"
- **Fix**: Convert UUID to string before slicing: `str(site['id'])[:8]`
- **Result**: Fallback site names work correctly

### 3. Fixed "No Active Supervisors" Error
- **Issue**: Query was too restrictive (required `status = 'APPROVED'` and `is_active = TRUE`)
- **Fix**: Made query more flexible:
  - First tries: `role = 'Supervisor' AND (is_active = TRUE OR is_active IS NULL)`
  - Fallback: Gets ALL supervisors regardless of is_active
- **Result**: Works with any supervisor accounts

### 4. Performance Optimizations
- Added search/filter functionality
- Reduced data transfer (only 3 fields: id, site_name, customer_name)
- Added LIMIT 1000 to prevent excessive loading
- Lazy controller creation
- Better loading indicators

## Troubleshooting

### "No active supervisors found"

**Solution 1**: The backend now automatically handles this by:
1. First looking for active supervisors
2. If none found, gets ALL supervisors
3. If still none, shows helpful error message

**Solution 2**: If you need to create test supervisors, run:
```bash
cd django-backend
python create_test_supervisor.py
```

This will:
- Check for existing supervisors
- Activate them if they exist but are inactive
- Create a test supervisor if none exist

### "No sites available"

**Check**: Make sure sites exist in the database
**Fix**: Create sites using the "Create Site" feature in Accountant Dashboard

### Sites not showing in Supervisor's Working Sites

**Check**: 
1. Accountant has assigned sites
2. Supervisor is logged in with correct role
3. Backend is running

**Debug**: Check backend logs for any errors

## Database Schema

### working_sites table
```sql
CREATE TABLE working_sites (
    id UUID PRIMARY KEY,
    accountant_id UUID REFERENCES users(id),
    supervisor_id UUID REFERENCES users(id),
    site_id UUID REFERENCES sites(id),
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    assigned_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## API Endpoints

### 1. Get All Sites (for assignment)
- **Endpoint**: `GET /api/construction/all-sites/`
- **Auth**: Accountant only
- **Returns**: List of all sites with id, site_name, customer_name, display_name

### 2. Assign Working Sites
- **Endpoint**: `POST /api/construction/assign-working-sites/`
- **Auth**: Accountant only
- **Body**:
```json
{
  "sites": [
    {"site_id": "uuid", "description": "optional"},
    ...
  ]
}
```
- **Action**: Assigns sites to ALL supervisors

### 3. Get Working Sites
- **Endpoint**: `GET /api/construction/working-sites/`
- **Auth**: Supervisor only
- **Returns**: List of sites assigned to the logged-in supervisor

### 4. Get Supervisors List
- **Endpoint**: `GET /api/construction/supervisors-list/`
- **Auth**: Accountant only
- **Returns**: List of all supervisors (for reference)

## Files Modified

### Backend:
- `django-backend/api/views_construction.py`
  - `assign_working_sites()` - Assigns to all supervisors
  - `get_all_sites()` - Optimized query
  - `get_working_sites()` - Supervisor view
  - `get_supervisors_list()` - List supervisors

### Frontend:
- `lib/screens/assign_working_sites_screen.dart` - Accountant UI
- `lib/screens/working_sites_screen.dart` - Supervisor UI
- `lib/services/construction_service.dart` - API calls

## Testing

1. **Login as Accountant**
2. **Click "+" icon** in dashboard
3. **Select 2-3 sites**
4. **Add descriptions** (optional)
5. **Click Assign**
6. **Verify success message**
7. **Login as Supervisor**
8. **Click "Working Sites"**
9. **Verify sites appear**
10. **Click a site** to navigate

## Next Steps

If you still see "No active supervisors found":
1. Run `python create_test_supervisor.py` to create/activate supervisors
2. Or manually update users table: `UPDATE users SET is_active = TRUE WHERE role = 'Supervisor'`
3. Restart the app and try again
