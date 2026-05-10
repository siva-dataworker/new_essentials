# Cash Entry and Total Salary System

## Overview
Complete system for accountants to select labour entries and track cash payments with automatic salary calculations.

## Database Tables

### 1. `cash_entries` (Already Exists)
Stores accountant-confirmed labour entries for cash management.

**Columns:**
- `id` - UUID primary key
- `site_id` - Reference to site
- `accountant_id` - Reference to accountant user
- `entry_date` - Date of entry
- `source_type` - 'supervisor', 'site_engineer', or 'accountant_created'
- `source_entry_id` - Reference to original labour_entries.id
- `labour_type` - Type of labour (Mason, Helper, etc.)
- `labour_count` - Number of workers
- `daily_rate` - Rate per worker
- `total_cost` - Total cost (labour_count × daily_rate)
- `notes` - Additional notes
- `submitted_by_name` - Name of original submitter
- `created_at`, `updated_at` - Timestamps

**Unique Constraint:** One entry per site per date per labour type

### 2. `total_salary` (NEW - Just Created)
Tracks net salary calculations per site per date.

**Columns:**
- `id` - UUID primary key
- `site_id` - Reference to site
- `entry_date` - Date
- `total_labour_cost` - Total from labour_entries
- `total_cash_paid` - Total from cash_entries
- `net_salary` - total_labour_cost - total_cash_paid
- `total_workers` - Total worker count
- `calculated_at`, `updated_at` - Timestamps

**Unique Constraint:** One entry per site per date

**Calculation:**
```
net_salary = total_labour_cost - total_cash_paid
```

## User Flow

### Step 1: Supervisor and Site Engineer Enter Data
- Supervisor enters labour data → stored in `labour_entries` table
- Site Engineer enters labour data → stored in `labour_entries` table
- Both entries have `submitted_by_role` field ('Supervisor' or 'Site Engineer')

### Step 2: Accountant Views Compare Screen
- Compare screen shows entries from both Supervisor and Site Engineer
- Grouped by date, site, and labour type
- Shows mismatches if counts differ

### Step 3: Accountant Selects Entries
- Accountant reviews entries in Compare screen
- Selects which entries to approve for cash payment
- Can select from Supervisor, Site Engineer, or create custom entry

### Step 4: Store in cash_entries Table
When accountant selects an entry:
```python
# Create cash entry
cash_entry = {
    'site_id': selected_entry['site_id'],
    'accountant_id': accountant_user_id,
    'entry_date': selected_entry['entry_date'],
    'source_type': 'supervisor' or 'site_engineer',
    'source_entry_id': selected_entry['id'],
    'labour_type': selected_entry['labour_type'],
    'labour_count': selected_entry['labour_count'],
    'daily_rate': selected_entry['daily_rate'],
    'total_cost': selected_entry['total_cost'],
    'submitted_by_name': selected_entry['supervisor_name']
}
```

### Step 5: Calculate and Update total_salary
After cash entry is created, automatically calculate:
```python
# Calculate total labour cost for this site and date
total_labour_cost = SUM(labour_entries.total_cost) 
    WHERE site_id = X AND entry_date = Y

# Calculate total cash paid for this site and date
total_cash_paid = SUM(cash_entries.total_cost) 
    WHERE site_id = X AND entry_date = Y

# Calculate net salary
net_salary = total_labour_cost - total_cash_paid

# Update or insert into total_salary table
```

## API Endpoints Needed

### 1. Get Cash Entries
```
GET /api/construction/cash-entries/
Query params:
  - site_id (optional)
  - start_date (optional)
  - end_date (optional)
  - accountant_id (optional)

Response:
{
  "cash_entries": [
    {
      "id": "uuid",
      "site_id": "uuid",
      "site_name": "Site Name",
      "entry_date": "2026-05-09",
      "labour_type": "Mason",
      "labour_count": 2,
      "daily_rate": 800,
      "total_cost": 1600,
      "source_type": "supervisor",
      "submitted_by_name": "John Doe"
    }
  ],
  "total_count": 10
}
```

### 2. Create Cash Entry
```
POST /api/construction/cash-entries/
Body:
{
  "site_id": "uuid",
  "entry_date": "2026-05-09",
  "source_type": "supervisor",
  "source_entry_id": "uuid",
  "labour_type": "Mason",
  "labour_count": 2,
  "daily_rate": 800,
  "total_cost": 1600,
  "notes": "Approved by accountant",
  "submitted_by_name": "John Doe"
}

Response:
{
  "success": true,
  "cash_entry": {...},
  "total_salary_updated": true
}
```

### 3. Get Total Salary
```
GET /api/construction/total-salary/
Query params:
  - site_id (optional)
  - start_date (optional)
  - end_date (optional)

Response:
{
  "total_salary_records": [
    {
      "id": "uuid",
      "site_id": "uuid",
      "site_name": "Site Name",
      "entry_date": "2026-05-09",
      "total_labour_cost": 5000,
      "total_cash_paid": 3000,
      "net_salary": 2000,
      "total_workers": 6
    }
  ],
  "summary": {
    "total_labour_cost": 50000,
    "total_cash_paid": 30000,
    "net_salary": 20000
  }
}
```

### 4. Calculate Total Salary (Manual Trigger)
```
POST /api/construction/calculate-total-salary/
Body:
{
  "site_id": "uuid",
  "entry_date": "2026-05-09"
}

Response:
{
  "success": true,
  "total_salary": {
    "total_labour_cost": 5000,
    "total_cash_paid": 3000,
    "net_salary": 2000
  }
}
```

## Frontend Changes Needed

### 1. Compare Screen Enhancement
- Add "Approve for Cash Payment" button for each entry
- When clicked, create cash_entry record
- Show confirmation dialog
- Update UI to show entry is approved

### 2. New Cash Entries Screen
- Show all cash entries
- Filter by site, date range
- Show total cash paid per site
- Export functionality

### 3. New Total Salary Screen
- Show net salary calculations
- Filter by site, date range
- Visual breakdown: Labour Cost vs Cash Paid vs Net Salary
- Charts and graphs

### 4. Dashboard Updates
- Add "Total Cash Paid" card
- Add "Net Salary" card
- Show pending approvals count

## Example Scenario

### Day 1: May 9, 2026 - Site A

**Supervisor enters:**
- Mason: 2 workers × ₹800 = ₹1,600
- Helper: 1 worker × ₹500 = ₹500
- **Total: ₹2,100**

**Site Engineer enters:**
- Mason: 2 workers × ₹800 = ₹1,600
- Helper: 2 workers × ₹500 = ₹1,000
- **Total: ₹2,600**

**Accountant reviews in Compare Screen:**
- Sees mismatch in Helper count (1 vs 2)
- Decides to approve Supervisor's entry
- Clicks "Approve for Cash Payment"

**System creates cash_entry:**
```
site_id: Site A
entry_date: 2026-05-09
labour_type: Mason
labour_count: 2
total_cost: 1600
source_type: supervisor

labour_type: Helper
labour_count: 1
total_cost: 500
source_type: supervisor
```

**System calculates total_salary:**
```
total_labour_cost: ₹2,100 (from labour_entries - Supervisor)
total_cash_paid: ₹2,100 (from cash_entries - Approved)
net_salary: ₹0 (fully paid)
```

### Day 2: Partial Payment

**Accountant approves only Mason:**
```
total_labour_cost: ₹2,100
total_cash_paid: ₹1,600 (only Mason approved)
net_salary: ₹500 (Helper not yet paid)
```

## Benefits

1. **Clear Audit Trail**: Every cash payment is tracked
2. **Mismatch Resolution**: Accountant decides which entry to approve
3. **Outstanding Balance**: Net salary shows what's still owed
4. **Financial Control**: Accountant has full control over payments
5. **Reporting**: Easy to generate payment reports

## Next Steps

1. Create API endpoints in `views_construction.py`
2. Update Compare screen to add "Approve" functionality
3. Create Cash Entries management screen
4. Create Total Salary report screen
5. Update Dashboard with new metrics

## Date Created
May 9, 2026
