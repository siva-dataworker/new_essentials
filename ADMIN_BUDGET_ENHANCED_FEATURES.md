# Admin Budget Management - Enhanced Features ✅

## Overview

The budget management system has been enhanced to provide comprehensive project quote management, detailed cost tracking, financial timeline, and mismatch alerts as per your requirements.

## Enhanced Features

### 1. Project Quote Management 💰

#### Initial Quote Setting
- Admin sets initial quoted amount for each project
- Example: Initial Quote = 60 Lakhs
- Automatically tracked in financial timeline

#### Extra Cost Management
- **Request Workflow**: Accountants/Site Engineers can request extra costs
- **Admin Approval**: Admin reviews and approves/rejects requests
- **Automatic Updates**: Approved costs added to total budget
- Example: Extra Bill Added = 5 Lakhs → Total Updated = 65 Lakhs

### 2. Detailed Cost Breakdown 📊

#### Three Separate Cost Categories

**Labour Cost**
- Tracks all labour-related expenses
- Automatically calculated from labour entries
- Real-time updates

**Material Cost**
- Tracks all material purchases
- Calculated from uploaded bills
- Itemized tracking

**Extra Cost**
- Tracks additional approved expenses
- Separate from initial quote
- Full audit trail

#### Budget Calculation
```
Total Allocated = Initial Quote + Extra Cost Approved
Total Utilized = Labour Cost + Material Cost + Extra Cost
Remaining = Total Allocated - Total Utilized
```

### 3. Financial History Timeline 📅

Complete chronological history of all financial events:

- **INITIAL_QUOTE**: Project quote set
- **EXTRA_COST_ADDED**: Additional cost approved
- **LABOUR_COST_UPDATED**: Labour expenses updated
- **MATERIAL_COST_UPDATED**: Material expenses updated
- **BUDGET_ADJUSTED**: Budget modifications
- **PROJECT_COMPLETED**: Project completion

Each entry includes:
- Event description
- Amount changed
- Previous total
- New total
- Who performed the action
- Timestamp

### 4. Budget Mismatch Alerts 🚨

#### Alert Types

**OVER_BUDGET** (Critical)
- Triggered when expenses exceed allocated budget
- Severity: CRITICAL
- Immediate admin notification

**NEAR_LIMIT** (High)
- Triggered at 90% budget utilization
- Severity: HIGH
- Warning notification

**COST_SPIKE** (Medium)
- Triggered by sudden cost increases
- Severity: MEDIUM
- Investigation recommended

**UNAUTHORIZED_EXPENSE** (High)
- Triggered by expenses without approval
- Severity: HIGH
- Requires immediate action

#### Alert Management
- Real-time notifications to admin
- Acknowledgment workflow
- Alert history tracking
- Severity-based prioritization

### 5. Extra Cost Request Workflow 📝

#### Request Process
1. **Accountant/Engineer** submits extra cost request
   - Amount
   - Reason
   - Category (Labour/Material/Equipment/Other)

2. **Admin** receives notification
   - Reviews request details
   - Checks budget impact
   - Makes decision

3. **Approval/Rejection**
   - If approved: Amount added to budget
   - If rejected: Reason provided
   - Notification sent to requester

4. **Timeline Update**
   - Event recorded in financial timeline
   - Audit trail created
   - Budget recalculated

## Database Schema

### Enhanced site_budgets Table
```sql
- budget_id (UUID)
- site_id (UUID)
- initial_quote (DECIMAL)           -- Initial quoted amount
- extra_cost_approved (DECIMAL)     -- Approved extra costs
- allocated_amount (DECIMAL)        -- Auto: initial + extra
- labour_cost (DECIMAL)             -- Total labour expenses
- material_cost (DECIMAL)           -- Total material expenses
- extra_cost (DECIMAL)              -- Other expenses
- utilized_amount (DECIMAL)         -- Auto: sum of costs
- remaining_amount (DECIMAL)        -- Auto: allocated - utilized
- project_status (VARCHAR)          -- ACTIVE/COMPLETED/ON_HOLD/CANCELLED
- notes (TEXT)
```

### New Tables

**extra_cost_requests**
```sql
- request_id (UUID)
- site_id (UUID)
- budget_id (UUID)
- requested_amount (DECIMAL)
- reason (TEXT)
- category (VARCHAR)                -- LABOUR/MATERIAL/EQUIPMENT/OTHER
- requested_by (UUID)
- requested_at (TIMESTAMP)
- status (VARCHAR)                  -- PENDING/APPROVED/REJECTED
- reviewed_by (UUID)
- reviewed_at (TIMESTAMP)
- review_notes (TEXT)
```

**financial_timeline**
```sql
- timeline_id (UUID)
- site_id (UUID)
- budget_id (UUID)
- event_type (VARCHAR)
- event_description (TEXT)
- amount (DECIMAL)
- previous_total (DECIMAL)
- new_total (DECIMAL)
- performed_by (UUID)
- performed_at (TIMESTAMP)
- metadata (JSONB)
```

**budget_mismatch_alerts**
```sql
- alert_id (UUID)
- site_id (UUID)
- budget_id (UUID)
- alert_type (VARCHAR)
- severity (VARCHAR)                -- LOW/MEDIUM/HIGH/CRITICAL
- message (TEXT)
- current_amount (DECIMAL)
- threshold_amount (DECIMAL)
- difference_amount (DECIMAL)
- is_acknowledged (BOOLEAN)
- acknowledged_by (UUID)
- acknowledged_at (TIMESTAMP)
- created_at (TIMESTAMP)
```

## Automatic Features

### Triggers

**1. Auto Budget Calculation**
- Automatically calculates allocated_amount
- Automatically calculates utilized_amount
- Automatically calculates remaining_amount
- Updates on any cost change

**2. Financial Timeline Creation**
- Automatically creates timeline entries
- Tracks all budget modifications
- Records who made changes
- Timestamps all events

**3. Budget Mismatch Detection**
- Automatically checks for over-budget
- Automatically checks for near-limit (90%)
- Creates alerts automatically
- Notifies admin in real-time

### View

**v_site_cost_breakdown**
- Pre-calculated cost breakdown for all sites
- Includes utilization percentage
- Optimized for quick queries
- Used in dashboard displays

## API Endpoints (To Be Created)

### Project Quote Management
```
POST   /api/admin/sites/quote/set/
POST   /api/admin/extra-cost/request/
POST   /api/admin/extra-cost/approve/
POST   /api/admin/extra-cost/reject/
GET    /api/admin/extra-cost/pending/
```

### Cost Breakdown
```
GET    /api/admin/sites/<site_id>/cost-breakdown/
GET    /api/admin/sites/cost-breakdown/all/
```

### Financial Timeline
```
GET    /api/admin/sites/<site_id>/financial-timeline/
```

### Budget Alerts
```
GET    /api/admin/budget-alerts/
GET    /api/admin/budget-alerts/<site_id>/
POST   /api/admin/budget-alerts/<alert_id>/acknowledge/
```

## Example Usage Scenarios

### Scenario 1: Setting Initial Quote
```
Admin Action:
1. Select site: "Downtown Construction"
2. Set initial quote: ₹60,00,000 (60 Lakhs)
3. Add notes: "Initial project estimate"

System Response:
✓ Budget created
✓ Timeline entry: "Initial project quote set"
✓ Status: ACTIVE
✓ Remaining: ₹60,00,000
```

### Scenario 2: Extra Cost Request & Approval
```
Accountant Action:
1. Request extra cost: ₹5,00,000 (5 Lakhs)
2. Reason: "Additional foundation work required"
3. Category: MATERIAL

Admin Notification:
🔔 New extra cost request
   Site: Downtown Construction
   Amount: ₹5,00,000
   Reason: Additional foundation work

Admin Action:
1. Review request
2. Approve with note: "Approved for foundation reinforcement"

System Response:
✓ Extra cost approved
✓ Total budget updated: ₹60L → ₹65L
✓ Timeline entry: "Extra cost approved and added"
✓ Notification sent to accountant
```

### Scenario 3: Budget Alert
```
System Detection:
- Labour cost: ₹30L
- Material cost: ₹28L
- Extra cost: ₹2L
- Total utilized: ₹60L
- Total allocated: ₹65L
- Utilization: 92%

System Action:
🚨 Alert created
   Type: NEAR_LIMIT
   Severity: HIGH
   Message: "Project at 92% of allocated budget"

Admin Notification:
⚠️ Budget Alert
   Site: Downtown Construction
   Status: 92% utilized
   Remaining: ₹5L
   Action: Review and monitor
```

### Scenario 4: Financial Timeline View
```
Admin Views Timeline:

📅 Feb 26, 2026 10:30 AM
   Initial Quote Set
   Amount: ₹60,00,000
   By: Admin User

📅 Feb 20, 2026 02:15 PM
   Extra Cost Added
   Amount: +₹5,00,000
   Total: ₹60L → ₹65L
   By: Admin User

📅 Feb 15, 2026 09:00 AM
   Labour Cost Updated
   Amount: +₹15,00,000
   Total Utilized: ₹45L → ₹60L
   By: System (Auto)

📅 Feb 10, 2026 03:30 PM
   Material Cost Updated
   Amount: +₹10,00,000
   Total Utilized: ₹35L → ₹45L
   By: System (Auto)
```

## Migration Steps

### Step 1: Run Enhanced Schema Migration
```bash
cd django-backend
python run_enhanced_budget_migration.py
```

This will:
- Add new columns to site_budgets
- Create 3 new tables
- Create automatic triggers
- Create cost breakdown view
- Verify all changes

### Step 2: Update Existing Budgets (Optional)
```sql
-- Set initial_quote for existing budgets
UPDATE site_budgets 
SET initial_quote = allocated_amount
WHERE initial_quote IS NULL;
```

### Step 3: Create API Endpoints
- Implement views for enhanced features
- Add URL routing
- Test endpoints

### Step 4: Update Flutter UI
- Add extra cost request screen
- Add financial timeline view
- Add budget alerts display
- Update cost breakdown display

## Benefits

### For Admin
✅ Complete financial visibility
✅ Separate cost tracking
✅ Automatic alerts for issues
✅ Full audit trail
✅ Extra cost approval workflow
✅ Historical timeline

### For Accountants
✅ Request extra costs easily
✅ Track approval status
✅ View cost breakdown
✅ Real-time updates

### For System
✅ Automatic calculations
✅ Automatic alerts
✅ Automatic timeline
✅ Data integrity maintained
✅ Performance optimized

## Status

**Schema Enhancement**: ✅ COMPLETE
**Migration Script**: ✅ COMPLETE
**Backend Services**: ✅ COMPLETE
**API Endpoints**: ⏳ PENDING
**Flutter UI**: ⏳ PENDING
**Testing**: ⏳ PENDING

## Next Steps

1. ✅ Run migration: `python run_enhanced_budget_migration.py`
2. ⏳ Create API endpoints (views_budget_enhanced.py)
3. ⏳ Update Flutter UI components
4. ⏳ Test complete workflow
5. ⏳ User acceptance testing

---

**Last Updated**: February 26, 2026
**Status**: Schema & Services Ready - API & UI Pending
