# Site Engineer Budget View Added ✅

## Feature Request
Add a "Budget" button for Site Engineer that:
1. Shows all sites when clicked
2. Allows Site Engineer to select a site
3. Displays the total budget allocated by Admin (read-only)

## Implementation

### 1. Added "Budget" Button to Quick Actions
```dart
Row(
  children: [
    Expanded(
      child: _buildQuickActionButton(
        'Documents',
        Icons.description,
        _openDocuments,
      ),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: _buildQuickActionButton(
        'Budget',  // ✅ NEW
        Icons.account_balance_wallet,
        _openBudget,
      ),
    ),
  ],
),
```

### 2. Created `_openBudget()` Method
Shows site selection dialog for Site Engineer to choose which site's budget to view.

```dart
void _openBudget() {
  final sites = context.read<ConstructionProvider>().sites;
  
  if (sites.isEmpty) {
    // Show error message
    return;
  }

  // Show site selection dialog
  _showSiteSelectionDialog(
    title: 'Select Site to View Budget',
    onSiteSelected: (site) {
      _showBudgetDetails(site);
    },
  );
}
```

### 3. Created `_showBudgetDetails()` Method
Fetches budget data from backend and displays it in a dialog.

```dart
Future<void> _showBudgetDetails(Map<String, dynamic> site) async {
  // 1. Show loading indicator
  // 2. Fetch budget from API
  // 3. Display budget details in dialog
  // 4. Show error if no budget allocated
}
```

### 4. Added Budget Details Dialog
Beautiful dialog showing:
- Total Project Budget (large, prominent)
- Allocated By (who set the budget)
- Date (when budget was allocated)
- Status (ACTIVE/COMPLETED)
- Notes (optional admin notes)

### 5. Added Helper Methods
- `_buildBudgetDetailRow()` - Formats label-value pairs
- `_formatCurrency()` - Formats amounts (₹87.00 L, ₹8.50 Cr, etc.)

## User Flow

### Step 1: Click Budget Button
```
Site Engineer Dashboard
↓
Quick Actions Section
↓
Click "Budget" button
```

### Step 2: Select Site
```
Dialog appears: "Select Site to View Budget"
↓
List of all assigned sites
↓
Click on a site
```

### Step 3: View Budget
```
Loading indicator appears
↓
Budget fetched from backend
↓
Budget details dialog shows:
  - Total Budget: ₹87.00 L
  - Allocated By: Essential Homes
  - Date: 2026-05-08
  - Status: ACTIVE
  - Notes: (if any)
```

## UI Design

### Budget Button
```
┌─────────────────────────────────────┐
│  📄 Documents    💰 Budget          │
└─────────────────────────────────────┘
```

### Site Selection Dialog
```
┌─────────────────────────────────────┐
│  Select Site to View Budget         │
├─────────────────────────────────────┤
│  🏗️ Anwar 6 22 Ibrahim             │
│  🏗️ Site 2                          │
│  🏗️ Site 3                          │
└─────────────────────────────────────┘
```

### Budget Details Dialog
```
┌─────────────────────────────────────┐
│  💰 Anwar 6 22 Ibrahim              │
├─────────────────────────────────────┤
│  ┌───────────────────────────────┐  │
│  │ Total Project Budget          │  │
│  │ ₹87.00 L                      │  │
│  └───────────────────────────────┘  │
│                                     │
│  Budget Details                     │
│  Allocated By: Essential Homes      │
│  Date: 2026-05-08                   │
│  Status: ACTIVE                     │
│                                     │
│  Notes:                             │
│  (admin notes if any)               │
│                                     │
│  [Close]                            │
└─────────────────────────────────────┘
```

## Features

### Read-Only Access
- Site Engineer can **view** budget only
- Cannot modify or update budget
- Cannot see budget breakdown (material/labour/other)
- Only sees total project budget

### Multi-Site Support
- Works with multiple assigned sites
- Site selection dialog for easy navigation
- Each site has its own budget

### Error Handling
- Shows error if no sites assigned
- Shows error if no budget allocated
- Loading indicator while fetching data
- Graceful error messages

### Currency Formatting
- ₹87.00 L (Lakhs)
- ₹8.50 Cr (Crores)
- ₹950.00 K (Thousands)
- ₹500 (Rupees)

## Backend Integration

### API Endpoint Used
```
GET /api/budget/allocation/{site_id}/
```

### Response Format
```json
{
  "budget": {
    "id": "uuid",
    "total_budget": 8700000,
    "material_budget": null,
    "labour_budget": null,
    "other_budget": null,
    "status": "ACTIVE",
    "notes": "Budget for Q2 2026",
    "allocated_by": "Essential Homes",
    "allocated_date": "2026-05-08T10:30:00Z"
  }
}
```

### Service Used
```dart
final budgetService = BudgetManagementService();
final budget = await budgetService.getBudgetAllocation(siteId);
```

## Permissions

### Site Engineer Can:
- ✅ View total project budget
- ✅ See who allocated the budget
- ✅ See when budget was allocated
- ✅ See budget status
- ✅ Read admin notes

### Site Engineer Cannot:
- ❌ Modify budget
- ❌ Allocate new budget
- ❌ See budget breakdown (material/labour/other)
- ❌ See budget utilization
- ❌ See phase payments
- ❌ Add costs

## Files Modified
- `essential/essential/construction_flutter/otp_phone_auth/lib/screens/site_engineer_dashboard.dart`
  - Added "Budget" button to Quick Actions
  - Added `_openBudget()` method
  - Added `_showBudgetDetails()` method
  - Added `_buildBudgetDetailRow()` helper
  - Added `_formatCurrency()` helper

## Testing Instructions

1. **Login as Site Engineer**
2. Navigate to Dashboard
3. Scroll to "Quick Actions" section
4. **Expected:** See "Budget" button next to "Documents"
5. Click "Budget" button
6. **Expected:** See "Select Site to View Budget" dialog
7. Click on a site
8. **Expected:** See loading indicator
9. **Expected:** See budget details dialog with:
   - Total Budget (large, prominent)
   - Allocated By
   - Date
   - Status
   - Notes (if any)
10. Click "Close"
11. **Expected:** Dialog closes

### Test Cases

#### Test 1: No Sites Assigned
- **Action:** Click Budget button with no sites
- **Expected:** Error message "No sites available"

#### Test 2: No Budget Allocated
- **Action:** Select site with no budget
- **Expected:** Error message "No budget allocated for this site yet"

#### Test 3: View Budget
- **Action:** Select site with budget
- **Expected:** See budget details dialog

#### Test 4: Multiple Sites
- **Action:** Click Budget with multiple sites
- **Expected:** See site selection dialog

## Benefits for Site Engineer

### 1. Budget Awareness
- Know the total project budget
- Understand project scale
- Plan work accordingly

### 2. Transparency
- See who allocated the budget
- Know when budget was set
- Read admin notes/instructions

### 3. Quick Access
- One-click access from dashboard
- No need to ask admin for budget info
- Available for all assigned sites

### 4. Professional Information
- Makes Site Engineer feel trusted
- Provides context for project decisions
- Helps with material planning

## Future Enhancements (Optional)

### 1. Budget Utilization View
- Show how much budget is spent
- Show remaining budget
- Show budget breakdown

### 2. Budget History
- See budget changes over time
- Track budget updates
- View previous budgets

### 3. Budget Alerts
- Notify when budget is low
- Alert when budget is updated
- Warn when approaching budget limit

### 4. Export Budget
- Download budget as PDF
- Share budget with team
- Print budget details

## Status: ✅ READY FOR TESTING
Site Engineer can now view project budgets for all assigned sites!
