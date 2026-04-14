# Site Engineer Labor Entry & Accountant View Implementation Plan

## REQUIREMENTS

### 1. Site Engineer Can Update Labor Entries
**Current:** Only Supervisor can add labor entries
**Required:** Site Engineer should also be able to add labor entries for their sites

### 2. Accountant Can See Labor Entries in Site Engineer Tab
**Current:** Site Engineer tab only shows photos
**Required:** Site Engineer tab should show both photos AND labor entries

---

## IMPLEMENTATION PLAN

### PART 1: Add Labor Entry to Site Engineer Dashboard

#### Changes Needed:
1. Add "Labor Entry" quick action button to Site Engineer dashboard
2. Create labor entry dialog/screen for Site Engineer
3. Use existing `ConstructionService.submitLabourCount()` API

#### Files to Modify:
- `otp_phone_auth/lib/screens/site_engineer_dashboard.dart`
- `otp_phone_auth/lib/screens/site_engineer_site_detail_screen.dart` (if exists)

---

### PART 2: Add Labor Entries to Accountant's Site Engineer Tab

#### Changes Needed:
1. Modify `_buildSiteEngineerContent()` to show tabs: Photos, Labor, Materials
2. Load labor entries for selected site
3. Display labor entries with same format as Supervisor tab

#### Files to Modify:
- `otp_phone_auth/lib/screens/accountant_entry_screen.dart`

---

## DETAILED IMPLEMENTATION

### PART 1: Site Engineer Labor Entry

#### Option A: Add to Dashboard Quick Actions
```dart
Row(
  children: [
    Expanded(
      child: _buildQuickActionButton(
        'Material Inventory',
        Icons.inventory_2,
        _openMaterialInventory,
      ),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: _buildQuickActionButton(
        'Labor Entry',  // ← NEW
        Icons.people,
        _openLaborEntry,
      ),
    ),
  ],
),
```

#### Option B: Add to Site Detail Screen
Add labor entry button to `SiteEngineerSiteDetailScreen` similar to Supervisor's site detail screen.

---

### PART 2: Accountant Site Engineer Tab Enhancement

#### Current Structure:
```
Site Engineer Tab
  └─ Photos only
```

#### New Structure:
```
Site Engineer Tab
  ├─ Photos
  ├─ Labor Entries  ← NEW
  └─ Materials      ← NEW (optional)
```

#### Implementation:
```dart
Widget _buildSiteEngineerContent() {
  return Column(
    children: [
      // Sub-tabs
      TabBar(
        tabs: [
          Tab(text: 'Photos'),
          Tab(text: 'Labor'),      // ← NEW
          Tab(text: 'Materials'),  // ← NEW
        ],
      ),
      Expanded(
        child: TabBarView(
          children: [
            _buildPhotosView(),
            _buildLaborEntriesView(),    // ← NEW
            _buildMaterialEntriesView(), // ← NEW
          ],
        ),
      ),
    ],
  );
}
```

---

## API ENDPOINTS (Already Exist)

### Labor Entry:
```
POST /api/construction/submit-labour/
Body: {
  "site_id": "123",
  "labour_count": 10,
  "labour_type": "Mason",
  "extra_cost": 500,
  "extra_cost_notes": "Transport",
  "custom_date_time": "2024-02-12T10:30:00"
}
```

### Get Labor Entries:
```
GET /api/construction/supervisor-history/{site_id}/
Response: {
  "labour_entries": [...],
  "material_entries": [...]
}
```

---

## USER FLOWS

### Flow 1: Site Engineer Adds Labor
```
Site Engineer Dashboard
  ↓
Tap "Labor Entry" button
  ↓
Select Site (if multiple)
  ↓
Labor Entry Dialog:
  - Carpenter: 5
  - Mason: 10
  - Helper: 3
  - Extra Cost: ₹500
  - Date/Time picker
  ↓
Submit
  ↓
Success message
```

### Flow 2: Accountant Views Site Engineer Labor
```
Accountant Dashboard
  ↓
Select: Area → Street → Site
  ↓
Tap "Site Engineer" tab
  ↓
See sub-tabs: Photos | Labor | Materials
  ↓
Tap "Labor" tab
  ↓
View labor entries:
  - Date: Feb 12, 2024
  - Carpenter: 5 workers
  - Mason: 10 workers
  - Helper: 3 workers
  - Extra Cost: ₹500
```

---

## BENEFITS

### For Site Engineer:
✅ Can add labor entries directly
✅ No need to wait for Supervisor
✅ Better control over site data
✅ Faster data entry

### For Accountant:
✅ See all Site Engineer activities
✅ Labor entries visible alongside photos
✅ Complete view of site operations
✅ Better audit trail

### For System:
✅ Dual entry capability (Supervisor + Site Engineer)
✅ More accurate data
✅ Better accountability
✅ Comprehensive reporting

---

## IMPLEMENTATION STEPS

### Step 1: Add Labor Entry to Site Engineer
1. Add quick action button
2. Create labor entry dialog (reuse Supervisor's dialog)
3. Test labor submission

### Step 2: Enhance Accountant Site Engineer Tab
1. Add TabBar with Photos, Labor, Materials
2. Load labor entries for selected site
3. Display labor entries (reuse Supervisor's list view)
4. Test data loading and display

### Step 3: Testing
1. Site Engineer adds labor entry
2. Verify in database
3. Check Accountant can see it
4. Verify Supervisor can still add labor
5. Test with multiple sites

---

## NOTES

- Both Supervisor and Site Engineer can add labor entries
- No conflict - both entries are stored separately
- Accountant sees all entries from both roles
- Labor entries are site-specific
- Date/time picker allows backdating if needed

---

## STATUS

📋 Planning Complete
⏳ Implementation Pending
🎯 Ready to Code
