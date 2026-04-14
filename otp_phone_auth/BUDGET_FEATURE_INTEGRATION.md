# Budget Management Feature - Integration Guide

Quick guide to integrate the budget management feature into your Flutter app.

## Files Created

```
lib/
├── services/
│   └── budget_service.dart              ✅ API service
├── models/
│   └── budget_model.dart                ✅ Data models
├── screens/
│   └── admin_budget_management_screen.dart  ✅ Main screen
└── widgets/
    ├── realtime_updates_widget.dart     ✅ Updates widget
    └── budget_overview_card.dart        ✅ Budget card
```

## Step 1: Update Base URL

Edit `lib/services/budget_service.dart`:

```dart
// Line 10: Update to your backend IP
static const String baseUrl = 'http://192.168.1.2:8000/api';
```

Replace `192.168.1.2` with your computer's IP address.

## Step 2: Add to Admin Dashboard

Edit `lib/screens/admin_dashboard.dart`:

### Import the screen:
```dart
import 'admin_budget_management_screen.dart';
```

### Add navigation option:

Find the drawer or navigation menu and add:

```dart
ListTile(
  leading: const Icon(Icons.account_balance_wallet),
  title: const Text('Budget Management'),
  subtitle: const Text('Allocate and track budgets'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminBudgetManagementScreen(),
      ),
    );
  },
),
```

Or add as a card in the dashboard:

```dart
Card(
  child: InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AdminBudgetManagementScreen(),
        ),
      );
    },
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(Icons.account_balance_wallet, size: 48, color: Colors.blue),
          const SizedBox(height: 8),
          const Text(
            'Budget Management',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  ),
)
```

## Step 3: Test the Feature

### Run the app:
```bash
flutter run
```

### Test flow:
1. Login as Admin
2. Navigate to Budget Management
3. Select a site
4. Enter budget amount (e.g., 5000000)
5. Tap "Set Budget"
6. Verify success message
7. Check Updates tab
8. Check All Sites tab

## Step 4: Optional - Add Budget Overview to Site Details

If you have a site detail screen, add budget overview:

```dart
import '../widgets/budget_overview_card.dart';

// In your site detail screen
BudgetOverviewCard(
  siteId: site.id,
  siteName: site.name,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminBudgetManagementScreen(),
      ),
    );
  },
)
```

## Step 5: Optional - Add Real-time Updates Widget

Add to any screen where you want to show updates:

```dart
import '../widgets/realtime_updates_widget.dart';

// In your screen
Container(
  height: 400,
  child: const RealTimeUpdatesWidget(
    autoRefresh: true,
    refreshInterval: Duration(seconds: 30),
  ),
)
```

## API Endpoints Used

The feature uses these backend endpoints:

```
POST   /api/admin/sites/budget/set/
GET    /api/admin/sites/{site_id}/budget/
GET    /api/admin/sites/{site_id}/budget/utilization/
GET    /api/admin/budgets/all/
GET    /api/admin/realtime-updates/
GET    /api/admin/sites/{site_id}/audit-trail/
```

All endpoints require JWT authentication (handled automatically by AuthService).

## Troubleshooting

### Issue: "No token found"
**Solution**: Ensure user is logged in and AuthService has valid token.

### Issue: "Failed to load sites"
**Solution**: 
1. Check backend URL is correct
2. Verify backend is running
3. Check network connectivity
4. Verify JWT token is valid

### Issue: "Failed to set budget"
**Solution**:
1. Verify user has Admin role
2. Check budget amount is positive
3. Verify site ID is valid
4. Check backend logs for errors

### Issue: Updates not showing
**Solution**:
1. Verify backend has real-time updates
2. Check auto-refresh is enabled
3. Try manual refresh
4. Check network connectivity

## Features Overview

### Budget Management Screen

**Tab 1: Budget**
- Select site from dropdown
- View current budget (if exists)
- Set or update budget
- See allocated, utilized, remaining amounts
- Visual progress bar

**Tab 2: Updates**
- Recent real-time updates
- Auto-refresh every 30 seconds
- Pull to refresh
- Tap for details
- Color-coded by type

**Tab 3: All Sites**
- List of all sites
- Budget status for each
- Utilization percentage
- Tap to navigate

### Real-time Updates Widget

- Auto-refresh capability
- Manual refresh button
- Site filtering
- Update details dialog
- Empty state handling

### Budget Overview Card

- Compact budget display
- Visual progress indicator
- Color-coded utilization
- No budget state
- Tap callback

## Customization

### Change Colors

Edit the color scheme in the screens/widgets:

```dart
// Primary color
backgroundColor: AppColors.primary

// Status colors
Colors.green  // Good status
Colors.orange // Warning
Colors.red    // Critical
```

### Change Refresh Interval

In `realtime_updates_widget.dart`:

```dart
refreshInterval: Duration(seconds: 30),  // Change to desired interval
```

### Change Currency Format

In `budget_model.dart`, modify `_formatCurrency()` method:

```dart
String _formatCurrency(double amount) {
  // Customize formatting here
}
```

## Next Steps

1. ✅ Update base URL
2. ✅ Add to admin dashboard
3. ✅ Test with backend
4. ✅ Verify authentication
5. ⏳ Deploy to production

## Support

For issues or questions:
1. Check backend is running
2. Verify API endpoints are accessible
3. Check Flutter console for errors
4. Review backend logs
5. Test API with cURL/Postman

---

**Quick Start**: Update base URL → Add to dashboard → Test!

**Status**: ✅ Ready for Integration
