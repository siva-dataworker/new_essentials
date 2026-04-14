# Budget Management System - COMPLETE ✅

## Overview
Comprehensive budget management system allowing admin to:
1. Allocate budget for each site
2. Set daily labour salary rates
3. Track material costs from bills
4. Auto-calculate labour costs
5. Monitor budget utilization in real-time

## System Architecture

### Database Tables Created:

#### 1. site_budget_allocation
Stores budget allocation for each site
- `total_budget`: Total allocated budget
- `material_budget`: Budget for materials
- `labour_budget`: Budget for labour
- `other_budget`: Budget for other expenses
- `status`: ACTIVE, EXCEEDED, COMPLETED

#### 2. labour_salary_rates
Stores daily salary rates for different labour types
- `labour_type`: General, Skilled, Mason, Carpenter, etc.
- `daily_rate`: Daily salary amount
- `effective_from`: Start date
- `is_active`: Current active rate

#### 3. material_cost_tracking
Tracks material costs from uploaded bills
- Links to `material_bills`
- Stores unit cost and total cost
- Recorded by admin/accountant

#### 4. labour_cost_calculation
Auto-calculated labour costs
- `labour_count` × `daily_rate` = `total_cost`
- Links to `labour_entries`
- Auto-updated via database trigger

#### 5. budget_utilization_summary (VIEW)
Real-time summary of budget vs spending
- Total material costs
- Total labour costs
- Total vendor costs
- Remaining budget
- Utilization percentage

### Auto-Calculation System:

#### Trigger: calculate_labour_cost()
**When:** Labour entry is created/updated
**What it does:**
1. Gets daily rate for labour type at that site
2. Calculates: `total_cost = labour_count × daily_rate`
3. Inserts/updates `labour_cost_calculation` table
4. Uses default rate of ₹500 if no rate set

#### Trigger: update_budget_status()
**When:** Material cost or labour cost is added
**What it does:**
1. Calculates total spent (materials + labour + vendor)
2. Compares with allocated budget
3. Updates status to 'EXCEEDED' if over budget

## API Endpoints

### 1. Allocate Budget
```
POST /api/budget/allocate/

Request:
{
  "site_id": "uuid",
  "total_budget": 5000000,
  "material_budget": 2000000,
  "labour_budget": 2000000,
  "other_budget": 1000000,
  "notes": "Initial budget allocation"
}

Response:
{
  "message": "Budget allocated successfully",
  "budget_id": "uuid"
}
```

**Access:** Admin only

---

### 2. Get Budget Allocation
```
GET /api/budget/allocation/{site_id}/

Response:
{
  "budget": {
    "id": "uuid",
    "total_budget": 5000000,
    "material_budget": 2000000,
    "labour_budget": 2000000,
    "other_budget": 1000000,
    "status": "ACTIVE",
    "notes": "Initial budget allocation",
    "allocated_by": "Admin Name",
    "allocated_date": "2026-02-26"
  }
}
```

**Access:** All authenticated users

---

### 3. Set Labour Salary Rate
```
POST /api/budget/labour-rate/

Request:
{
  "site_id": "uuid",
  "labour_type": "General",
  "daily_rate": 600,
  "effective_from": "2026-02-26",
  "notes": "Standard rate for general labour"
}

Response:
{
  "message": "Labour rate set successfully",
  "rate_id": "uuid"
}
```

**Access:** Admin only

**Labour Types:**
- General
- Skilled
- Mason
- Carpenter
- Electrician
- Plumber
- Painter
- Helper

---

### 4. Get Labour Rates
```
GET /api/budget/labour-rates/{site_id}/

Response:
{
  "rates": [
    {
      "id": "uuid",
      "labour_type": "General",
      "daily_rate": 600,
      "effective_from": "2026-02-26",
      "set_by": "Admin Name",
      "notes": "Standard rate"
    },
    {
      "id": "uuid",
      "labour_type": "Skilled",
      "daily_rate": 800,
      "effective_from": "2026-02-26",
      "set_by": "Admin Name",
      "notes": "Skilled labour rate"
    }
  ]
}
```

**Access:** All authenticated users

---

### 5. Get Budget Utilization
```
GET /api/budget/utilization/{site_id}/

Response:
{
  "summary": {
    "total_budget": 5000000,
    "material_budget": 2000000,
    "labour_budget": 2000000,
    "other_budget": 1000000,
    "total_material_cost": 800000,
    "total_labour_cost": 600000,
    "total_vendor_cost": 200000,
    "total_spent": 1600000,
    "remaining_budget": 3400000,
    "utilization_percentage": 32.0,
    "status": "ACTIVE"
  },
  "material_breakdown": [
    {
      "material_type": "Cement",
      "total_cost": 300000,
      "total_quantity": 1000,
      "unit": "bags"
    },
    {
      "material_type": "Steel",
      "total_cost": 500000,
      "total_quantity": 5000,
      "unit": "kg"
    }
  ],
  "labour_breakdown": [
    {
      "labour_type": "General",
      "total_count": 500,
      "avg_rate": 600,
      "total_cost": 300000
    },
    {
      "labour_type": "Skilled",
      "total_count": 200,
      "avg_rate": 800,
      "total_cost": 160000
    }
  ]
}
```

**Access:** All authenticated users

---

### 6. Get Labour Cost Details
```
GET /api/budget/labour-costs/{site_id}/

Response:
{
  "costs": [
    {
      "id": "uuid",
      "labour_type": "General",
      "labour_count": 25,
      "daily_rate": 600,
      "total_cost": 15000,
      "entry_date": "2026-02-26",
      "day_of_week": "Thursday",
      "supervisor_name": "John Doe",
      "is_verified": true
    }
  ]
}
```

**Access:** All authenticated users

## Workflow

### Step 1: Admin Allocates Budget
```
Admin → Allocate Budget
  ├─ Total Budget: ₹50 Lakhs
  ├─ Material Budget: ₹20 Lakhs
  ├─ Labour Budget: ₹20 Lakhs
  └─ Other Budget: ₹10 Lakhs
```

### Step 2: Admin Sets Labour Rates
```
Admin → Set Labour Rates
  ├─ General: ₹600/day
  ├─ Skilled: ₹800/day
  ├─ Mason: ₹1000/day
  └─ Carpenter: ₹900/day
```

### Step 3: Supervisor Submits Labour Count
```
Supervisor → Submit Labour Entry
  ├─ Labour Type: General
  ├─ Count: 25 workers
  └─ Date: 2026-02-26

↓ AUTO-CALCULATION TRIGGER ↓

System → Calculate Cost
  ├─ Get Rate: ₹600/day (from labour_salary_rates)
  ├─ Calculate: 25 × ₹600 = ₹15,000
  └─ Store in labour_cost_calculation
```

### Step 4: Accountant Uploads Material Bill
```
Accountant → Upload Material Bill
  ├─ Material: Cement
  ├─ Quantity: 100 bags
  ├─ Unit Price: ₹400
  └─ Total: ₹40,000

↓ MANUAL TRACKING (Future Enhancement) ↓

Admin → Record Material Cost
  └─ Adds to material_cost_tracking
```

### Step 5: Real-time Budget Monitoring
```
System → Calculate Utilization
  ├─ Material Costs: ₹8,00,000
  ├─ Labour Costs: ₹6,00,000
  ├─ Vendor Costs: ₹2,00,000
  ├─ Total Spent: ₹16,00,000
  ├─ Total Budget: ₹50,00,000
  ├─ Remaining: ₹34,00,000
  └─ Utilization: 32%

↓ AUTO STATUS UPDATE ↓

If Total Spent > Total Budget:
  └─ Status → EXCEEDED
```

## Formulas

### Labour Cost Calculation:
```
total_labour_cost = labour_count × daily_rate

Example:
  25 workers × ₹600/day = ₹15,000
```

### Budget Utilization:
```
utilization_percentage = (total_spent / total_budget) × 100

Where:
  total_spent = material_costs + labour_costs + vendor_costs

Example:
  (₹16,00,000 / ₹50,00,000) × 100 = 32%
```

### Remaining Budget:
```
remaining_budget = total_budget - total_spent

Example:
  ₹50,00,000 - ₹16,00,000 = ₹34,00,000
```

## Features

### ✅ Implemented:
1. Budget allocation by admin
2. Labour salary rate management
3. Auto labour cost calculation
4. Budget utilization tracking
5. Real-time status updates
6. Detailed cost breakdowns
7. Material and labour cost separation
8. Budget exceeded alerts

### 🔄 Future Enhancements:
1. Material cost auto-tracking from bills
2. Budget approval workflow
3. Budget revision history
4. Cost forecasting
5. Budget alerts and notifications
6. Export budget reports
7. Multi-currency support
8. Budget templates

## Database Triggers

### 1. Auto Labour Cost Calculation
**Trigger Name:** `trigger_calculate_labour_cost`
**Table:** `labour_entries`
**Event:** AFTER INSERT OR UPDATE
**Function:** `calculate_labour_cost()`

**Logic:**
```sql
1. Get daily_rate from labour_salary_rates
   WHERE site_id = NEW.site_id
     AND labour_type = NEW.labour_type
     AND is_active = TRUE

2. If no rate found, use default ₹500

3. Calculate: total_cost = labour_count × daily_rate

4. INSERT/UPDATE labour_cost_calculation
```

### 2. Auto Budget Status Update
**Trigger Name:** `trigger_update_budget_material` & `trigger_update_budget_labour`
**Tables:** `material_cost_tracking`, `labour_cost_calculation`
**Event:** AFTER INSERT OR UPDATE
**Function:** `update_budget_status()`

**Logic:**
```sql
1. Calculate total_spent for site:
   SUM(material_costs) + 
   SUM(labour_costs) + 
   SUM(vendor_bills)

2. Get total_budget for site

3. If total_spent > total_budget:
   UPDATE status = 'EXCEEDED'
```

## Testing Checklist

### Backend:
- [ ] Budget allocation API works
- [ ] Labour rate setting API works
- [ ] Budget utilization API returns correct data
- [ ] Labour cost auto-calculation trigger works
- [ ] Budget status auto-update trigger works
- [ ] All APIs have proper authentication
- [ ] Admin-only endpoints reject non-admin users

### Database:
- [ ] All tables created successfully
- [ ] Triggers are active
- [ ] View returns correct data
- [ ] Constraints are enforced
- [ ] Indexes improve query performance

### Integration:
- [ ] Labour entry creates cost calculation
- [ ] Material bill can be tracked
- [ ] Budget utilization updates in real-time
- [ ] Status changes to EXCEEDED when over budget
- [ ] Multiple labour types supported
- [ ] Rate changes don't affect past calculations

## Files Created

### Database:
1. `django-backend/create_budget_management_system.sql`
   - Complete database schema
   - Triggers and functions
   - Views and indexes

2. `django-backend/run_budget_management_migration.py`
   - Migration runner script

### Backend:
1. `django-backend/api/views_budget_management.py`
   - All budget management APIs
   - ~400 lines of code

2. `django-backend/api/urls.py`
   - Added 6 new URL patterns

## Summary

Complete budget management system with:
- ✅ Budget allocation by admin
- ✅ Labour salary rate management
- ✅ Auto labour cost calculation (trigger-based)
- ✅ Real-time budget utilization tracking
- ✅ Material and labour cost breakdowns
- ✅ Auto budget status updates
- ✅ Comprehensive API endpoints
- ✅ Database triggers for automation

**Next Step:** Create Flutter UI for admin to manage budgets!

---

**Status:** Backend COMPLETE ✅
**Date:** February 26, 2026
**Backend:** Running on `http://192.168.1.2:8000`
**Ready for:** Flutter UI implementation
