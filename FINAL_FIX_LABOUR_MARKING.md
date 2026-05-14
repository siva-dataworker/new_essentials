# Final Fix - Labour Button Not Marking as Done

## Issue
After submitting labour data, the labour button in quick actions is not showing as "done" (no checkmark).

## Root Cause Analysis

The issue is in the data flow:

1. Labour submitted → `onSuccess` callback fires
2. `_loadTodayEntries()` is called
3. Quick actions reopens with `_showQuickActions()`
4. But `_showQuickActions()` reads `_todayEntries` which might not be updated yet
5. Or `_todayEntries['labour_entries']` is not in the expected format

## Debug Steps

Add these print statements to trace the issue:

```dart
void _showQuickActions() {
  print('🔍 [DEBUG] _todayEntries: $_todayEntries');
  
  final labourEntries = List<Map<String, dynamic>>.from(
    _todayEntries?['labour_entries'] ?? [],
  );
  print('🔍 [DEBUG] labourEntries count: ${labourEntries.length}');
  print('🔍 [DEBUG] labourEntries: $labourEntries');
  
  final photoCount = (_todayEntries?['photo_count'] as num?)?.toInt() ?? 0;
  print('🔍 [DEBUG] photoCount: $photoCount');
  
  final hasLabourData = labourEntries.isNotEmpty;
  final hasPhotoData = photoCount > 0;
  
  print('🔍 [DEBUG] hasLabourData: $hasLabourData');
  print('🔍 [DEBUG] hasPhotoData: $hasPhotoData');
  
  // ... rest of the code
}
```

## Expected Output

After labour submission, you should see:
```
🔍 [DEBUG] _todayEntries: {labour_entries: [{...}], photo_count: 0, ...}
🔍 [DEBUG] labourEntries count: 1
🔍 [DEBUG] labourEntries: [{labour_type: Mason, labour_count: 5, ...}]
🔍 [DEBUG] photoCount: 0
🔍 [DEBUG] hasLabourData: true
🔍 [DEBUG] hasPhotoData: false
```

## Possible Issues

### Issue 1: Data Not Loaded Yet
If you see:
```
🔍 [DEBUG] _todayEntries: null
🔍 [DEBUG] labourEntries count: 0
```

**Solution:** Wait for data to load before reopening quick actions.

### Issue 2: Wrong Data Format
If you see:
```
🔍 [DEBUG] _todayEntries: {labour_entries: null, ...}
```

**Solution:** Check API response format.

### Issue 3: Data Loaded But Empty
If you see:
```
🔍 [DEBUG] _todayEntries: {labour_entries: [], ...}
🔍 [DEBUG] labourEntries count: 0
```

**Solution:** Check if API is returning the correct data for today's date.

## Complete Fix

Replace the `_showLabourEntry` method with this version that ensures data is loaded:

```dart
void _showLabourEntry({bool startAtEvening = false}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.3),
    enableDrag: true,
    isDismissible: true,
    builder: (context) => _LabourEntrySheet(
      siteId: widget.site['id'],
      defaultToEvening: startAtEvening,
      onSuccess: () async {
        print('✅ [LABOUR_SUCCESS] Labour submitted, reloading data...');
        
        // Mark session complete
        _entrySession.markComplete('labour');
        
        // Invalidate cache and reload data
        _invalidateCache();
        
        // Wait for data to load
        await _loadTodayEntries();
        
        print('✅ [LABOUR_SUCCESS] Data reloaded, checking entries...');
        print('🔍 [LABOUR_SUCCESS] _todayEntries: $_todayEntries');
        
        final labourEntries = List<Map<String, dynamic>>.from(
          _todayEntries?['labour_entries'] ?? [],
        );
        print('🔍 [LABOUR_SUCCESS] Labour entries count: ${labourEntries.length}');
        
        // Reopen quick actions if session is active
        if (_entrySession.isActive && mounted) {
          print('✅ [LABOUR_SUCCESS] Reopening quick actions...');
          _showQuickActions();
        }
        
        SupervisorHistoryScreen.invalidateCache(widget.site['id']);
      },
    ),
  );
}
```

## Alternative Solution

If the above doesn't work, the issue might be that the quick actions sheet needs to be closed first before reopening. Try this:

```dart
onSuccess: () async {
  print('✅ [LABOUR_SUCCESS] Labour submitted');
  
  // Mark session complete
  _entrySession.markComplete('labour');
  
  // Invalidate cache and reload data
  _invalidateCache();
  await _loadTodayEntries();
  
  // Close quick actions if open
  if (Navigator.canPop(context)) {
    Navigator.pop(context);
  }
  
  // Wait a bit for sheet to close
  await Future.delayed(const Duration(milliseconds: 300));
  
  // Reopen quick actions with fresh data
  if (_entrySession.isActive && mounted) {
    _showQuickActions();
  }
  
  SupervisorHistoryScreen.invalidateCache(widget.site['id']);
},
```

## Testing Steps

1. Clear app data
2. Open supervisor screen
3. Click + icon
4. Click "Labour Count"
5. Enter labour data
6. Submit
7. Check console logs for debug output
8. Verify labour button shows checkmark

## Expected Behavior

After labour submission:
- ✅ Labour button shows green checkmark
- ✅ Subtitle changes to "Tap to add evening update"
- ✅ Sheet remains locked (photo not uploaded yet)
- ✅ Can reopen quick actions and see labour as done

---

**Status:** Needs debugging to identify exact issue
**Next Step:** Add debug logs and check console output
