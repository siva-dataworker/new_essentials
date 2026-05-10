# Total Salary - Role-Based Implementation ✅ COMPLETE

## Overview
Total salary now tracks labour costs **per selected role** (Supervisor or Site Engineer), not as a difference calculation.

## Database Schema Updated

### total_salary Table
```sql
CREATE TABLE total_salary (
    id UUID PRIMARY KEY,
    site_id UUID REFERENCES sites(id),
    entry_date DATE,
    selected_role VARCHAR(50),  ← NEW FIELD
    total_labour_cost DECIMAL(12, 2),
    total_cash_paid DECIMAL(12, 2),
    net_salary DECIMAL(12, 2),
    total_workers INTEGER,
    calculated_at TIMESTAMP,
    updated_at TIMESTAMP,
    UNIQUE(site_id, entry_date, selected_role)  ← Updated constraint
);
```

## How It Works

### Step 1: Supervisor Enters Data
```
Site: ABC Construction
Date: 2026-05-09
Supervisor enters:
  - Mason: 2 × ₹800 = ₹1,600
  - Helper: 1 × ₹500 = ₹500
Total: ₹2,100
```

### Step 2: Site Engineer Enters Data
```
Site: ABC Construction
Date: 2026-05-09
Site Engineer enters:
  - Mason: 2 × ₹800 = ₹1,600
  - Helper: 1 × ₹500 = ₹500
  - Carpenter: 1 × ₹750 = ₹750
Total: ₹2,850
```

### Step 3: Accountant Selects Supervisor
```
Accountant clicks "Approve for Cash Payment" on Supervisor's entry
```

**System stores in cash_entries:**
```
site_id: ABC Construction
entry_date: 2026-05-09
source_type: supervisor
entries: Mason (2, ₹1600), Helper (1, ₹500)
```

**System stores in total_salary:**
```
site_id: ABC Construction
entry_date: 2026-05-09
selected_role: supervisor  ← KEY FIELD
total_labour_cost: ₹2,100  ← From cash_entries (supervisor only)
total_cash_paid: ₹2,100    ← Same as labour cost
net_salary: ₹0             ← Always 0 (tracking approved amounts)
total_workers: 3
```

### Step 4: Dashboard Display

**When Accountant selects "Supervisor" role:**
```
GET /api/construction/total-salary/?selected_role=supervisor

Response:
{
  "total_salary_records": [
    {
      "site_name": "ABC Construction",
      "entry_date": "2026-05-09",
      "selected_role": "supervisor",
      "total_labour_cost": 2100,
      "total_workers": 3
    }
  ],
  "summary": {
    "total_labour_cost": 2100
  }
}
```

**Dashboard shows:** Total Labour Salary: ₹2,100 ✅

**When Accountant selects "Site Engineer" role:**
```
GET /api/construction/total-salary/?selected_role=site_engineer

Response:
{
  "total_salary_records": [],
  "summary": {
    "total_labour_cost": 0
  }
}
```

**Dashboard shows:** Total Labour Salary: ₹0 ✅

**When Accountant selects "All":**
```
GET /api/construction/total-salary/

Response:
{
  "total_salary_records": [
    {
      "site_name": "ABC Construction",
      "selected_role": "supervisor",
      "total_labour_cost": 2100
    }
  ],
  "summary": {
    "total_labour_cost": 2100
  }
}
```

**Dashboard shows:** Total Labour Salary: ₹2,100 ✅

## API Endpoints

### 1. Confirm Cash Entry (Updated)
```
POST /api/construction/confirm-cash-entry/
Body: {
  "site_id": "uuid",
  "entry_date": "2026-05-09",
  "source_type": "supervisor",  ← This becomes selected_role
  "labour_entries": [...]
}
```

**Auto-triggers:** Creates total_salary record with selected_role = source_type

### 2. Get Total Salary (Updated)
```
GET /api/construction/total-salary/?selected_role=supervisor
```

**Query Params:**
- `site_id` (optional)
- `start_date` (optional)
- `end_date` (optional)
- `selected_role` (optional) - "supervisor" or "site_engineer"

### 3. Calculate Total Salary (Updated)
```
POST /api/construction/calculate-total-salary/
Body: {
  "site_id": "uuid",
  "entry_date": "2026-05-09",
  "selected_role": "supervisor"  ← NEW REQUIRED FIELD
}
```

## Dashboard Integration

### Frontend Logic:
```dart
// When accountant selects role filter
String? _selectedRole; // 'Supervisor', 'Site Engineer', or null (All)

// Fetch total salary based on selected role
Future<void> _fetchTotalSalary() async {
  String apiRole = _selectedRole == 'Supervisor' ? 'supervisor' 
                 : _selectedRole == 'Site Engineer' ? 'site_engineer' 
                 : '';
  
  final response = await http.get(
    '/api/construction/total-salary/?selected_role=$apiRole'
  );
  
  // Display total_labour_cost in dashboard
  setState(() {
    _totalLabourSalary = response['summary']['total_labour_cost'];
  });
}
```

### Dashboard Cards:
```
When "Supervisor" selected:
  Total Labour Salary: ₹2,100 (from supervisor entries only)

When "Site Engineer" selected:
  Total Labour Salary: ₹0 (no site engineer entries approved yet)

When "All" selected:
  Total Labour Salary: ₹2,100 (sum of all approved entries)
```

## Key Differences from Previous Implementation

### ❌ OLD (Wrong):
- total_salary = ALL labour entries - cash entries
- Showed "outstanding balance"
- One record per site per date

### ✅ NEW (Correct):
- total_salary = ONLY selected role's approved entries
- Shows "what accountant approved for this role"
- One record per site per date **per role**
- Dashboard filters by selected role

## Example Scenarios

### Scenario 1: Only Supervisor Approved
```
Supervisor approved: ₹2,100
Site Engineer approved: ₹0

Dashboard:
- Supervisor role: ₹2,100 ✅
- Site Engineer role: ₹0 ✅
- All: ₹2,100 ✅
```

### Scenario 2: Both Roles Approved
```
Supervisor approved: ₹2,100
Site Engineer approved: ₹2,850

Dashboard:
- Supervisor role: ₹2,100 ✅
- Site Engineer role: ₹2,850 ✅
- All: ₹4,950 ✅
```

### Scenario 3: Multiple Sites
```
Site A - Supervisor: ₹2,100
Site A - Site Engineer: ₹2,850
Site B - Supervisor: ₹3,000
Site B - Site Engineer: ₹0

Dashboard (Supervisor role):
- Site A: ₹2,100
- Site B: ₹3,000
- Total: ₹5,100 ✅

Dashboard (Site Engineer role):
- Site A: ₹2,850
- Site B: ₹0
- Total: ₹2,850 ✅
```

## Files Modified

1. ✅ `django-backend/update_total_salary_add_role.sql` - Added selected_role column
2. ✅ `django-backend/apply_total_salary_update.py` - Applied schema changes
3. ✅ `django-backend/api/views_cash_and_salary.py` - Updated calculation logic
4. ✅ `django-backend/api/views_construction.py` - Updated confirm_cash_entry

## Testing

### Test 1: Approve Supervisor Entry
```bash
curl -X POST http://localhost:8000/api/construction/confirm-cash-entry/ \
  -H "Authorization: Bearer TOKEN" \
  -d '{
    "site_id": "uuid",
    "entry_date": "2026-05-09",
    "source_type": "supervisor",
    "labour_entries": [{"labour_type": "Mason", "labour_count": 2, "daily_rate": 800}]
  }'
```

### Test 2: Get Total Salary for Supervisor
```bash
curl http://localhost:8000/api/construction/total-salary/?selected_role=supervisor \
  -H "Authorization: Bearer TOKEN"
```

### Test 3: Get Total Salary for All Roles
```bash
curl http://localhost:8000/api/construction/total-salary/ \
  -H "Authorization: Bearer TOKEN"
```

## Date Completed
May 9, 2026

## Status
✅ Backend implementation complete
⏳ Frontend integration pending
