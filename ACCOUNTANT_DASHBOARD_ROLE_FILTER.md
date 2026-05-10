# Accountant Dashboard Role Filter Added

## Requirement
After Supervisor and Site Engineer enter data, the accountant should be able to **select which role's data** to view in the dashboard. The dashboard should only show data from the selected role.

## Previous Behavior
- Dashboard automatically showed ALL data from both Supervisor and Site Engineer
- No way to filter by role
- Total salary included entries from both roles

## New Behavior
- Dashboard shows role filter chips at the top: **All**, **Supervisor**, **Site Engineer**
- Accountant must select which role's data to view
- Dashboard calculations (entries, workers, salary) are filtered by selected role
- Default selection is "All" (shows data from both roles)

## Implementation

### Role Filter Chips
Added at the top of the dashboard:
```dart
// Role Filter Chips
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: [
      _buildRoleChip('All', _selectedLabourRole == null, ...),
      _buildRoleChip('Supervisor', _selectedLabourRole == 'Supervisor', ...),
      _buildRoleChip('Site Engineer', _selectedLabourRole == 'Site Engineer', ...),
    ],
  ),
)
```

### Filtered Calculations
All dashboard metrics now use filtered data:
```dart
// Filter labour entries by selected role
final filteredLabourEntries = _selectedLabourRole == null
    ? _labourEntries  // Show all
    : _labourEntries.where((e) {
        final role = e['submitted_by_role'];
        return role == _selectedLabourRole;
      }).toList();

// Calculate from filtered data
final totalLabourEntries = filteredLabourEntries.length;
final totalWorkers = filteredLabourEntries.fold(...);
final totalSalary = filteredLabourEntries.fold(...);
```

## User Flow

### Step 1: Dashboard Loads
- Shows "All" data by default
- Displays combined data from Supervisor and Site Engineer

### Step 2: Accountant Selects Role
- Taps on "Supervisor" chip
- Dashboard instantly updates to show only Supervisor data
- Total Labour Entries: Only Supervisor entries
- Total Workers: Only workers from Supervisor entries
- Total Labour Salary: Only salary from Supervisor entries

### Step 3: Switch to Site Engineer
- Taps on "Site Engineer" chip
- Dashboard updates to show only Site Engineer data
- All metrics recalculate based on Site Engineer entries only

### Step 4: View All Data
- Taps on "All" chip
- Dashboard shows combined data from both roles

## Example Scenario

### Data in Database:
- Supervisor entries: 4 entries, 6 workers, ₹3,000
- Site Engineer entries: 2 entries, 3 workers, ₹2,000

### Dashboard Display:

**When "All" is selected:**
- Labour Entries: 6
- Total Workers: 9
- Total Labour Salary: ₹5,000

**When "Supervisor" is selected:**
- Labour Entries: 4
- Total Workers: 6
- Total Labour Salary: ₹3,000

**When "Site Engineer" is selected:**
- Labour Entries: 2
- Total Workers: 3
- Total Labour Salary: ₹2,000

## Benefits
1. **Clear Data Separation**: Accountant can see exactly what each role entered
2. **Easy Comparison**: Switch between roles to compare data
3. **Accurate Reporting**: Generate reports based on specific role's data
4. **Mismatch Detection**: Easier to identify discrepancies between roles

## Files Modified
- `otp_phone_auth/lib/screens/accountant_dashboard.dart`
  - Added role filter chips to dashboard
  - Applied role filtering to all calculations
  - Updated `_buildDashboardContent()` method

## Testing
1. Login as Accountant
2. Navigate to Dashboard
3. See role filter chips at top: All, Supervisor, Site Engineer
4. Tap "Supervisor" - should show only Supervisor data
5. Tap "Site Engineer" - should show only Site Engineer data
6. Tap "All" - should show combined data

## Date Implemented
May 9, 2026
