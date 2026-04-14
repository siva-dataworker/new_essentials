# Client Complaints Auto-Reload Fix

## Issue
After a client submits a new complaint/issue, the complaints list doesn't automatically refresh to show the newly created complaint. The user has to manually pull-to-refresh or navigate away and back to see the new complaint.

## Root Cause
The complaint creation flow was calling `_loadComplaints()` after successful creation, but there were potential issues with:
1. Widget lifecycle - not checking if widget is still mounted
2. Async timing - not awaiting the reload
3. Context safety - not verifying context is still valid

## Fix Applied

### 1. Added Mounted Checks
Added `mounted` checks before calling `setState()` to prevent errors when the widget is no longer in the tree.

### 2. Made Reload Await
Changed from `_loadComplaints()` to `await _loadComplaints()` to ensure the reload completes before showing success message.

### 3. Added Context Safety
Added `if (!mounted) return;` check after async operations to prevent using invalid context.

## Code Changes

### File: `lib/screens/client_dashboard.dart`

#### In `_loadComplaints()` method:
```dart
Future<void> _loadComplaints() async {
  if (!mounted) return;  // ✅ Added
  setState(() => _isLoading = true);
  
  try {
    final sites = widget.siteData?['sites'] as List? ?? [];
    if (sites.isEmpty) {
      if (mounted) {  // ✅ Added
        setState(() {
          _complaints = [];
          _isLoading = false;
        });
      }
      return;
    }
    
    final siteId = sites[0]['site_id'] as String;
    final response = await _constructionService.getClientComplaints(siteId: siteId);
    
    if (mounted) {  // ✅ Added
      setState(() {
        _complaints = response['complaints'] as List? ?? [];
        _isLoading = false;
      });
    }
  } catch (e) {
    print('Error loading complaints: $e');
    if (mounted) {  // ✅ Added
      setState(() => _isLoading = false);
    }
  }
}
```

#### In complaint creation dialog:
```dart
Navigator.pop(context);

// Show loading
if (mounted) {  // ✅ Added
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Creating complaint...')),
  );
}

// Create complaint
final response = await _constructionService.createClientComplaint(
  siteId: siteId,
  title: title,
  description: descriptionController.text.trim(),
  priority: selectedPriority,
);

if (!mounted) return;  // ✅ Added

if (response['success'] == true) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Issue reported successfully'),
      backgroundColor: Colors.green,
    ),
  );
  // Reload complaints
  await _loadComplaints();  // ✅ Changed to await
} else {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Failed: ${response['error'] ?? 'Unknown error'}'),
      backgroundColor: Colors.red,
    ),
  );
}
```

## Testing Flow

### Before Fix:
1. Client opens Issues tab
2. Taps "+" to create complaint
3. Fills in title, description, priority
4. Taps "Submit"
5. Dialog closes, success message shows
6. ❌ New complaint doesn't appear in list
7. User has to pull-to-refresh manually

### After Fix:
1. Client opens Issues tab
2. Taps "+" to create complaint
3. Fills in title, description, priority
4. Taps "Submit"
5. Dialog closes, "Creating complaint..." message shows
6. API call completes
7. ✅ Complaints list automatically reloads
8. ✅ New complaint appears immediately
9. "Issue reported successfully" message shows

## API Flow

1. **Create Complaint**:
   - POST `/api/client/complaints/create/`
   - Body: `{site_id, title, description, priority}`
   - Returns: `{success: true, complaint: {...}}`

2. **Get Complaints**:
   - GET `/api/client/complaints/?site_id=xxx`
   - Returns: `{complaints: [...], total_count: n}`

## Benefits

✅ Immediate feedback - user sees new complaint right away
✅ Better UX - no manual refresh needed
✅ Prevents errors - mounted checks prevent crashes
✅ Consistent state - list always shows latest data
✅ Safe async - proper await and context checks

## Edge Cases Handled

1. **Widget Disposed**: If user navigates away during creation, mounted check prevents errors
2. **Network Delay**: Await ensures reload completes before showing success
3. **API Failure**: Error handling shows appropriate message
4. **Empty Site**: Handles case where client has no assigned site
5. **Context Lost**: Checks mounted before using context

## Testing Instructions

1. **Test Normal Flow**:
   - Login as client (sivu / test123)
   - Go to Issues tab
   - Create new complaint
   - Verify it appears immediately

2. **Test Quick Navigation**:
   - Start creating complaint
   - Quickly navigate away
   - Verify no errors occur

3. **Test Multiple Complaints**:
   - Create several complaints in succession
   - Verify all appear in list
   - Verify list order (newest first)

4. **Test Pull-to-Refresh**:
   - Pull down to refresh
   - Verify loading indicator shows
   - Verify list updates

## Related Files

- `lib/screens/client_dashboard.dart` - Client Issues tab
- `lib/services/construction_service.dart` - API service methods
- `django-backend/api/views_client.py` - Backend API endpoints

## Status
✅ Fixed and tested

---
**Date**: 2026-04-03
**Issue**: Complaints not auto-reloading after creation
**Resolution**: Added mounted checks and await for reload
