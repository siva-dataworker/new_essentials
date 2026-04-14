# Admin Enhanced Features - Integration Guide

## Quick Start

### 1. Run Database Migration
```bash
cd django-backend
psql -U postgres -d construction_db -f admin_features_migration.sql
```

### 2. Update Existing Admin Dashboard

Add a button to access specialized login in `admin_dashboard.dart`:

```dart
// In the admin dashboard, add this to the Reports tab or as a new action
ElevatedButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminSpecializedLoginScreen(),
      ),
    );
  },
  icon: const Icon(Icons.admin_panel_settings),
  label: const Text('Specialized Access'),
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.safetyOrange,
  ),
)
```

### 3. Add Import Statements

Add these imports to your admin dashboard file:

```dart
import 'screens/admin_specialized_login_screen.dart';
import 'screens/admin_labour_count_screen.dart';
import 'screens/admin_bills_view_screen.dart';
import 'screens/admin_profit_loss_screen.dart';
import 'screens/admin_site_comparison_screen.dart';
import 'screens/admin_material_purchases_screen.dart';
import 'screens/admin_site_documents_screen.dart';
```

## Feature Access Points

### From Login Screen
Add a "Specialized Access" button on the main login screen:

```dart
TextButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminSpecializedLoginScreen(),
      ),
    );
  },
  child: const Text('Specialized Access →'),
)
```

### From Admin Dashboard
Add these options to the admin dashboard menu:

```dart
// In the Reports tab or as separate menu items
ListTile(
  leading: const Icon(Icons.people),
  title: const Text('Labour Count View'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminLabourCountScreen(),
      ),
    );
  },
),
ListTile(
  leading: const Icon(Icons.receipt_long),
  title: const Text('Bills Viewing'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminBillsViewScreen(),
      ),
    );
  },
),
ListTile(
  leading: const Icon(Icons.account_balance),
  title: const Text('Complete Accounts'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminProfitLossScreen(),
      ),
    );
  },
),
```

## Creating Test Users

### SQL Commands:
```sql
-- Create specialized access users
INSERT INTO users (username, password, full_name, email, phone, role_id, access_type, is_active, status)
VALUES 
    -- Labour Count Viewer
    ('labour_view', 'password123', 'Labour Viewer', 'labour@site.com', '9876543210',
     (SELECT role_id FROM roles WHERE role_name = 'Admin'), 'LABOUR_COUNT', TRUE, 'APPROVED'),
    
    -- Bills Viewer
    ('bills_view', 'password123', 'Bills Viewer', 'bills@site.com', '9876543211',
     (SELECT role_id FROM roles WHERE role_name = 'Admin'), 'BILLS_VIEW', TRUE, 'APPROVED'),
    
    -- Chief Accountant (Full Access)
    ('chief_acc', 'password123', 'Chief Accountant', 'chief@site.com', '9876543212',
     (SELECT role_id FROM roles WHERE role_name = 'Admin'), 'FULL_ACCOUNTS', TRUE, 'APPROVED');
```

## Testing Workflow

### Test Labour Count View:
1. Open app
2. Tap "Specialized Access"
3. Select "Labour Count View"
4. Login with: `labour_view` / `password123`
5. Select a site from dropdown
6. Verify labour count data displays

### Test Bills View:
1. Open app
2. Tap "Specialized Access"
3. Select "Bills Viewing"
4. Login with: `bills_view` / `password123`
5. Select a site from dropdown
6. Verify bills display with verification status

### Test Complete Accounts:
1. Open app
2. Tap "Specialized Access"
3. Select "Complete Accounts"
4. Login with: `chief_acc` / `password123`
5. Select a site from dropdown
6. Verify P/L metrics display
7. Tap "View Material Purchases"
8. Tap "View Site Documents"
9. Tap compare icon to compare sites

## API Testing with Postman/cURL

### Get All Sites:
```bash
curl -X GET http://localhost:8000/api/admin/sites/ \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Specialized Login:
```bash
curl -X POST http://localhost:8000/api/admin/specialized-login/ \
  -H "Content-Type: application/json" \
  -d '{
    "username": "labour_view",
    "password": "password123",
    "access_type": "LABOUR_COUNT"
  }'
```

### Get Labour Count:
```bash
curl -X GET http://localhost:8000/api/admin/sites/1/labour-count/ \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Get Bills:
```bash
curl -X GET http://localhost:8000/api/admin/sites/1/bills/ \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Get P/L Data:
```bash
curl -X GET http://localhost:8000/api/admin/sites/1/profit-loss/ \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Compare Sites:
```bash
curl -X POST http://localhost:8000/api/admin/sites/compare/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "site1_id": 1,
    "site2_id": 2
  }'
```

### Get Material Purchases:
```bash
curl -X GET http://localhost:8000/api/admin/sites/1/material-purchases/ \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Get Site Documents:
```bash
curl -X GET http://localhost:8000/api/admin/sites/1/documents/ \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## Sample Data Setup

### Add Site Metrics:
```sql
INSERT INTO site_metrics (site_id, built_up_area, project_value, total_cost, profit_loss)
VALUES 
    (1, 5000.00, 50000000.00, 45000000.00, 5000000.00),
    (2, 3500.00, 35000000.00, 32000000.00, 3000000.00);
```

### Add Sample Documents:
```sql
INSERT INTO site_documents (site_id, document_type, document_name, file_path, uploaded_by)
VALUES 
    (1, 'PLAN', 'Ground Floor Plan', '/uploads/plans/ground_floor.pdf', 1),
    (1, 'ELEVATION', 'Front Elevation', '/uploads/elevations/front.pdf', 1),
    (1, 'STRUCTURE', 'Foundation Drawing', '/uploads/structure/foundation.pdf', 1),
    (1, 'FINAL_OUTPUT', 'Completed Building', '/uploads/final/building.jpg', 1);
```

### Create Work Notifications:
```sql
INSERT INTO work_notifications (site_id, report_id, notification_type, message, sent_to, is_read)
VALUES 
    (1, 1, 'WORK_NOT_DONE', 'Labour count not entered for 2025-02-18', 
     (SELECT user_id FROM users WHERE username = 'chief_acc'), FALSE),
    (1, 2, 'MISSING_DATA', 'Material balance missing for 2025-02-18', 
     (SELECT user_id FROM users WHERE username = 'chief_acc'), FALSE);
```

## Troubleshooting

### Issue: Sites not loading
**Solution**: Check if sites table has data
```sql
SELECT * FROM sites;
```

### Issue: Access denied on specialized login
**Solution**: Verify user has correct access_type
```sql
SELECT username, access_type FROM users WHERE username = 'labour_view';
```

### Issue: No data showing in screens
**Solution**: Check if site has reports and entries
```sql
SELECT * FROM daily_site_report WHERE site_id = 1;
SELECT * FROM daily_labour_summary WHERE report_id IN (SELECT report_id FROM daily_site_report WHERE site_id = 1);
```

### Issue: Comparison not working
**Solution**: Ensure both sites have metrics
```sql
SELECT * FROM site_metrics WHERE site_id IN (1, 2);
```

## Performance Optimization

### Add Indexes:
```sql
CREATE INDEX IF NOT EXISTS idx_admin_access_log_user ON admin_access_log(user_id);
CREATE INDEX IF NOT EXISTS idx_work_notifications_sent_to ON work_notifications(sent_to);
CREATE INDEX IF NOT EXISTS idx_work_notifications_read ON work_notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_site_documents_site ON site_documents(site_id);
CREATE INDEX IF NOT EXISTS idx_site_documents_type ON site_documents(document_type);
```

## Security Checklist

- [ ] All API endpoints require authentication
- [ ] Access type validated on backend
- [ ] Passwords hashed (not plain text)
- [ ] SQL injection prevented (parameterized queries)
- [ ] File upload paths validated
- [ ] Access logs maintained
- [ ] Token expiration implemented

## Next Steps

1. **Implement Notifications Badge**: Show unread count in app bar
2. **Add Document Upload**: Allow uploading from mobile
3. **Export Reports**: PDF/Excel export functionality
4. **Charts & Graphs**: Visual analytics for P/L trends
5. **WhatsApp Integration**: Send notifications via WhatsApp
6. **Push Notifications**: Real-time alerts using FCM

## Support

For issues:
1. Check Django logs: `python manage.py runserver`
2. Check Flutter console for errors
3. Verify database tables exist
4. Test API endpoints with Postman
5. Check authentication token validity
