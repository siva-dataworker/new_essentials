# Next Features Implementation Plan

## Feature 1: Site Engineer Access to Files & Complaints ✅ (Backend Done)

### Current Status:
- ✅ Backend APIs already support Site Engineer viewing files and complaints
- ✅ `get_project_files()` - Returns all files for a site
- ✅ `get_complaints()` - Filters by role, Site Engineer sees assigned complaints
- ❌ Frontend UI not yet implemented for Site Engineer

### Implementation Needed:
1. Add "Project Files" tab to Site Engineer site detail screen
2. Add "Complaints" tab to Site Engineer site detail screen (already exists as placeholder)
3. Site Engineer can view files uploaded by Architect
4. Site Engineer can view and respond to complaints assigned to them

---

## Feature 2: Accountant Can Create Sites

### Requirements:
- Accountant should have option to create new sites
- New sites should be visible to all roles immediately
- Site creation form should include:
  - Site name
  - Customer name
  - Area
  - Street
  - Optional: Address, description

### Implementation Needed:

#### Backend:
1. Create API: `POST /api/construction/create-site/`
2. Permissions: Only Accountant and Admin can create sites
3. Returns: Created site with ID

#### Frontend:
1. Add "Create Site" button to Accountant dashboard
2. Create site creation dialog/screen
3. Form fields: site_name, customer_name, area, street
4. After creation, refresh site list for all users

---

## Implementation Order:

### Step 1: Site Engineer UI (Quick)
- Add Project Files view to Site Engineer detail screen
- Update Complaints tab to show real data
- Reuse existing components from Architect

### Step 2: Create Site API (Backend)
- Add `create_site()` function to views_construction.py
- Add URL route
- Test with Postman/curl

### Step 3: Accountant Create Site UI (Frontend)
- Add "Create Site" button to Accountant dashboard
- Create dialog with form
- Call API and refresh list

---

## Files to Modify:

### Backend:
- `django-backend/api/views_construction.py` - Add create_site API
- `django-backend/api/urls.py` - Add route

### Frontend:
- `otp_phone_auth/lib/screens/site_engineer_site_detail_screen.dart` - Add Project Files tab
- `otp_phone_auth/lib/screens/accountant_dashboard.dart` - Add Create Site button
- Create new file: `otp_phone_auth/lib/screens/create_site_screen.dart`

---

## Expected Behavior:

### Site Engineer:
1. Login as Site Engineer
2. Tap site card → Opens detail screen
3. See tabs: Photos, **Project Files**, Complaints, Extra Cost
4. **Project Files tab**: View all files uploaded by Architect
5. **Complaints tab**: View complaints assigned to them, can mark as resolved

### Accountant:
1. Login as Accountant
2. See "Create Site" button on dashboard
3. Tap button → Opens create site form
4. Fill in: Site name, Customer name, Area, Street
5. Submit → Site created
6. New site appears in all users' dashboards immediately

---

## API Specifications:

### Create Site API
```
POST /api/construction/create-site/
Headers: Authorization: Bearer <token>
Body (JSON):
{
  "site_name": "Villa 123",
  "customer_name": "John Doe",
  "area": "Whitefield",
  "street": "Main Road",
  "address": "Full address (optional)",
  "description": "Description (optional)"
}

Response:
{
  "message": "Site created successfully",
  "site_id": "uuid",
  "site": {
    "id": "uuid",
    "site_name": "Villa 123",
    "customer_name": "John Doe",
    "display_name": "John Doe Villa 123",
    "area": "Whitefield",
    "street": "Main Road"
  }
}
```

---

## Testing Steps:

### Test Site Engineer Access:
1. Login as Architect
2. Upload a file to a site
3. Raise a complaint for a site
4. Logout, login as Site Engineer
5. Open same site
6. Verify: Can see uploaded file
7. Verify: Can see complaint assigned to them

### Test Accountant Create Site:
1. Login as Accountant
2. Tap "Create Site" button
3. Fill form and submit
4. Verify: Site appears in Accountant's dashboard
5. Logout, login as Supervisor
6. Verify: New site appears in Supervisor's dashboard
7. Repeat for other roles

---

## Priority:
1. **High**: Accountant create sites (needed for testing)
2. **Medium**: Site Engineer view files/complaints (improves workflow)

Let's implement Accountant create sites first, then Site Engineer access.
