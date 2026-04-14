# History System Implementation Plan

## Overview
Implement a complete history tracking system where:
1. Supervisor can view their own entry history
2. Accountant can view all entries with supervisor names
3. All data is stored in the database with timestamps

## Database Structure (Already Exists)

### labour_entries table
```sql
- id (primary key)
- site_id (foreign key)
- supervisor_id (foreign key to users)
- labour_type (Carpenter, Mason, etc.)
- labour_count (integer)
- entry_date (date)
- created_at (timestamp)
- notes (text)
```

### material_balance table
```sql
- id (primary key)
- site_id (foreign key)
- supervisor_id (foreign key to users)
- material_type (Bricks, Cement, etc.)
- quantity (decimal)
- unit (nos, bags, kg, etc.)
- entry_date (date)
- created_at (timestamp)
```

## Implementation Tasks

### 1. Backend APIs (Django)

#### New Endpoints Needed:
- `GET /api/construction/supervisor/history/` - Get supervisor's own entries
- `GET /api/construction/accountant/all-entries/` - Get all entries with supervisor names

### 2. Flutter - Supervisor History Screen

#### Features:
- Tab view: Labour History | Material History
- Filter by date range
- Group by site
- Show entry details with timestamps
- Pull to refresh

#### Design:
- Instagram-style cards
- Timeline view with dates
- Site name headers
- Entry type badges
- Count/quantity displays

### 3. Flutter - Accountant Dashboard Update

#### Features:
- View all labour entries
- View all material entries
- Show supervisor name for each entry
- Filter by date, site, supervisor
- Export functionality

#### Design:
- Table/card view
- Supervisor avatar and name
- Site information
- Entry details
- Verification status

## File Structure

```
otp_phone_auth/lib/screens/
├── supervisor_history_screen.dart (NEW)
└── accountant_entries_screen.dart (NEW)

otp_phone_auth/lib/services/
└── construction_service.dart (UPDATE - add history methods)

django-backend/api/
└── views_construction.py (UPDATE - add history endpoints)
```

## Implementation Steps

### Step 1: Backend - Add History Endpoints
1. Add supervisor history endpoint
2. Add accountant all-entries endpoint
3. Include supervisor names in responses
4. Add date filtering

### Step 2: Flutter Service - Add History Methods
1. `getSupervisorHistory()` method
2. `getAccountantEntries()` method
3. Date range filtering

### Step 3: Supervisor History Screen
1. Create screen with tabs
2. Fetch and display labour history
3. Fetch and display material history
4. Add date filters
5. Group by site

### Step 4: Accountant Entries Screen
1. Create screen with tabs
2. Fetch all labour entries
3. Fetch all material entries
4. Show supervisor names
5. Add filters

### Step 5: Navigation
1. Add History tab to supervisor bottom nav
2. Add Entries tab to accountant dashboard
3. Update navigation logic

## Data Flow

### Supervisor History
```
Supervisor History Screen
    ↓
ConstructionService.getSupervisorHistory()
    ↓
Django API: /api/construction/supervisor/history/
    ↓
Database Query (filter by supervisor_id)
    ↓
Return entries with site names
    ↓
Display in Flutter UI
```

### Accountant View
```
Accountant Entries Screen
    ↓
ConstructionService.getAccountantEntries()
    ↓
Django API: /api/construction/accountant/all-entries/
    ↓
Database Query with JOIN to get supervisor names
    ↓
Return entries with supervisor names and site names
    ↓
Display in Flutter UI
```

## UI Mockups

### Supervisor History Screen
```
┌─────────────────────────────┐
│  My History                 │
├─────────────────────────────┤
│ [Labour] [Materials]        │
├─────────────────────────────┤
│ Today - Dec 24, 2024        │
│ ┌─────────────────────────┐ │
│ │ Site A - Kasakudy       │ │
│ │ Carpenter: 5            │ │
│ │ Mason: 3                │ │
│ │ 10:30 AM                │ │
│ └─────────────────────────┘ │
│ ┌─────────────────────────┐ │
│ │ Site B - Karaikal       │ │
│ │ Electrician: 2          │ │
│ │ 2:15 PM                 │ │
│ └─────────────────────────┘ │
└─────────────────────────────┘
```

### Accountant Entries Screen
```
┌─────────────────────────────┐
│  All Entries                │
├─────────────────────────────┤
│ [Labour] [Materials]        │
├─────────────────────────────┤
│ Dec 24, 2024                │
│ ┌─────────────────────────┐ │
│ │ 👤 Supervisor: John     │ │
│ │ 📍 Site A - Kasakudy    │ │
│ │ Carpenter: 5            │ │
│ │ Mason: 3                │ │
│ │ ⏰ 10:30 AM             │ │
│ └─────────────────────────┘ │
│ ┌─────────────────────────┐ │
│ │ 👤 Supervisor: Mike     │ │
│ │ 📍 Site B - Karaikal    │ │
│ │ Bricks: 5000 nos        │ │
│ │ ⏰ 2:15 PM              │ │
│ └─────────────────────────┘ │
└─────────────────────────────┘
```

## Benefits

1. **Transparency**: All entries tracked with supervisor names
2. **Accountability**: Supervisors can review their own entries
3. **Verification**: Accountants can verify entries
4. **Audit Trail**: Complete history with timestamps
5. **Reporting**: Data ready for reports and analytics

## Next Steps

1. Implement backend endpoints
2. Update construction service
3. Create supervisor history screen
4. Create accountant entries screen
5. Update navigation
6. Test end-to-end

---

**Status**: Planning Complete
**Ready to Implement**: Yes
**Estimated Time**: 2-3 hours
