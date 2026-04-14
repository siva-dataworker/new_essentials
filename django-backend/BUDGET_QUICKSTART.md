# Budget Management Feature - Quick Start Guide

## Prerequisites

- Django backend is set up and running
- PostgreSQL database is accessible
- Admin user exists in the system
- Python environment is activated

## Quick Setup (5 minutes)

### Step 1: Run the Migration

```bash
cd django-backend
python run_budget_realtime_migration.py
```

Expected output:
```
============================================================
Budget and Real-time Visibility Migration
============================================================

📄 Reading SQL file: add_budget_realtime_schema.sql
🔌 Connecting to database: postgres at your-host
✓ Connected successfully
🚀 Executing migration...
✓ Migration executed successfully

🔍 Verifying tables...
  ✓ site_budgets: exists (rows: 0)
  ✓ realtime_updates: exists (rows: 0)
  ✓ audit_logs_enhanced: exists (rows: 0)

🔍 Checking daily_labour_summary modifications...
  ✓ Added columns: is_modified, modified_at, modified_by, modification_reason

============================================================
✅ Migration completed successfully!
============================================================
```

### Step 2: Restart Django Server

```bash
python manage.py runserver
```

### Step 3: Test the APIs

Update `test_budget_apis.py` with your admin credentials:

```python
login_response = requests.post(f'{BASE_URL}/auth/login/', json={
    'email': 'your-admin@example.com',  # Your admin email
    'password': 'your-password'          # Your admin password
})
```

Then run:

```bash
python test_budget_apis.py
```

## Available API Endpoints

### Budget Management

1. **Set Budget**
   ```
   POST /api/admin/sites/budget/set/
   Body: {"site_id": 1, "budget_amount": 5000000.00}
   ```

2. **Get Budget**
   ```
   GET /api/admin/sites/{site_id}/budget/
   ```

3. **Get Budget Utilization**
   ```
   GET /api/admin/sites/{site_id}/budget/utilization/
   ```

4. **Get All Budgets**
   ```
   GET /api/admin/budgets/all/
   ```

### Real-time Updates

5. **Get Pending Updates**
   ```
   GET /api/admin/realtime-updates/
   Query params: ?last_sync=2024-01-15T10:00:00Z&site_id=1
   ```

### Audit Trail

6. **Get Audit Trail**
   ```
   GET /api/admin/sites/{site_id}/audit-trail/
   Query params: ?page=1&page_size=20&table_name=site_budgets
   ```

## Quick Test with cURL

### 1. Login as Admin

```bash
curl -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@example.com", "password": "admin123"}'
```

Save the token from response.

### 2. Set Budget

```bash
curl -X POST http://localhost:8000/api/admin/sites/budget/set/ \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"site_id": 1, "budget_amount": 5000000.00}'
```

### 3. Get Budget

```bash
curl -X GET http://localhost:8000/api/admin/sites/1/budget/ \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## Common Issues

### Issue: Migration fails with "relation already exists"

**Solution**: Tables already exist. You can either:
- Drop existing tables: `DROP TABLE IF EXISTS site_budgets CASCADE;`
- Or skip migration if tables are correct

### Issue: API returns 403 Forbidden

**Solution**: 
- Verify user has Admin role
- Check JWT token is valid
- Ensure Authorization header format: `Bearer YOUR_TOKEN`

### Issue: No updates returned

**Solution**:
- Ensure data changes have occurred
- Check last_sync timestamp
- Verify user role matches notify_roles

## Database Schema Overview

### site_budgets
- Stores budget allocations
- One active budget per site
- Tracks allocated, utilized, and remaining amounts

### realtime_updates
- Tracks all data changes
- Filtered by user role
- Supports incremental sync

### audit_logs_enhanced
- Complete audit trail
- Tracks who changed what and when
- Includes change reason

## Next Steps

After successful setup:

1. **Integrate with Flutter App**:
   - Use API endpoints in Flutter
   - Implement budget allocation UI
   - Add real-time update polling

2. **Test with Real Data**:
   - Create budgets for multiple sites
   - Submit labour entries
   - Verify real-time updates

3. **Monitor Performance**:
   - Check API response times
   - Monitor database query performance
   - Review audit trail growth

## Support

For detailed documentation, see:
- `PHASE1_BUDGET_IMPLEMENTATION.md` - Complete implementation guide
- `add_budget_realtime_schema.sql` - Database schema details
- `api/services_budget.py` - Service layer documentation
- `api/views_budget.py` - API endpoint details

## Summary

You now have:
- ✅ Budget allocation system
- ✅ Real-time update tracking
- ✅ Comprehensive audit trail
- ✅ Role-based access control
- ✅ RESTful API endpoints

Ready to use in production!
