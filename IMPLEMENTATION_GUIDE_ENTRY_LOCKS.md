# 🔒 PRODUCTION-SAFE IMPLEMENTATION GUIDE
## Supervisor Entry Lock System

**Version:** 1.0  
**Date:** 2026-05-12  
**Status:** Ready for Implementation

---

## 📋 TABLE OF CONTENTS

1. [Feature 1: Single Daily Entry Lock](#feature-1-single-daily-entry-lock)
2. [Feature 2: Entry Screen Lock Flow](#feature-2-entry-screen-lock-flow)
3. [Database Changes](#database-changes)
4. [Backend Implementation](#backend-implementation)
5. [Flutter Implementation](#flutter-implementation)
6. [Edge Cases & Solutions](#edge-cases--solutions)
7. [Testing Strategy](#testing-strategy)
8. [Rollback Plan](#rollback-plan)

---

## 🎯 FEATURE 1: SINGLE DAILY ENTRY LOCK

### Current System Analysis

**Existing Table:** `labour_entries`
```sql
-- Current structure (from code analysis)
CREATE TABLE labour_entries (
    id UUID PRIMARY KEY,
    site_id UUID NOT NULL,
    supervisor_id UUID NOT NULL,
    labour_count INTEGER NOT NULL,
    labour_type VARCHAR(50) NOT NULL,
    entry_date DATE NOT NULL,
    entry_time TIME NOT NULL,
    day_of_week VARCHAR(10),
    notes TEXT,
    extra_cost DECIMAL(10,2),
    extra_cost_notes TEXT,
    submitted_by_role VARCHAR(50)
);
```

### Problem Identified
- ❌ No constraint preventing multiple supervisors from entering data for same site/date/time
- ❌ Current check in `views_construction.py` only prevents duplicate labour_type, not duplicate supervisors
- ❌ Race condition possible if 2 supervisors submit simultaneously

---

### ✅ SOLUTION 1: DATABASE CONSTRAINTS

#### Step 1: Add Unique Constraint (SAFE - Non-Breaking)

```sql
-- Migration Script: 001_add_entry_lock_constraint.sql
-- Run this during low-traffic period

-- Step 1: Add entry_type column (morning/evening)
ALTER TABLE labour_entries 
ADD COLUMN IF NOT EXISTS entry_type VARCHAR(10) DEFAULT 'morning';

-- Step 2: Update existing data based on entry_time
UPDATE labour_entries 
SET entry_type = CASE 
    WHEN EXTRACT(HOUR FROM entry_time) < 12 THEN 'morning'
    ELSE 'evening'
END
WHERE entry_type IS NULL OR entry_type = 'morning';

-- Step 3: Add composite unique constraint
-- This prevents multiple supervisors from entering same site/date/type
CREATE UNIQUE INDEX CONCURRENTLY IF NOT EXISTS 
    idx_labour_entry_lock 
ON labour_entries(site_id, entry_date, entry_type, labour_type);

-- Step 4: Add check constraint for entry_type
ALTER TABLE labour_entries 
ADD CONSTRAINT chk_entry_type 
CHECK (entry_type IN ('morning', 'evening'));

-- Step 5: Make entry_type NOT NULL
ALTER TABLE labour_entries 
ALTER COLUMN entry_type SET NOT NULL;
```

**Why This Works:**
- ✅ Database-level enforcement (strongest guarantee)
- ✅ Prevents race conditions
- ✅ Works even if API validation fails
- ✅ `CONCURRENTLY` ensures no downtime
- ✅ Existing data preserved

---

### ✅ SOLUTION 2: BACKEND API VALIDATION

#### File: `django-backend/api/views_construction.py`

**Current Code Location:** Line ~307 (submitLabourCount method)

```python
# BEFORE (Current Code)
existing_entry = fetch_one("""
    SELECT id FROM labour_entries 
    WHERE site_id = %s AND entry_date = %s AND labour_type = %s
""", (site_id, entry_date, labour_type))

if existing_entry:
    return Response({
        'error': f'{labour_type} labour count already submitted...'
    }, status=status.HTTP_400_BAD_REQUEST)
```

```python
# AFTER (Enhanced Code)
from django.db import transaction
from django.utils import timezone

@transaction.atomic
def submitLabourCount(self, request):
    """Submit labour count with entry lock validation"""
    
    # ... existing validation code ...
    
    # Determine entry type based on time
    entry_hour = entry_time.hour if entry_time else timezone.now().hour
    entry_type = 'morning' if entry_hour < 12 else 'evening'
    
    # CRITICAL: Check if ANY supervisor has already entered for this site/date/type
    existing_entry = fetch_one("""
        SELECT 
            le.id,
            le.supervisor_id,
            u.full_name as supervisor_name,
            le.entry_time,
            le.labour_type
        FROM labour_entries le
        LEFT JOIN users u ON le.supervisor_id = u.user_id
        WHERE le.site_id = %s 
          AND le.entry_date = %s 
          AND le.entry_type = %s
          AND le.labour_type = %s
        LIMIT 1
    """, (site_id, entry_date, entry_type, labour_type))
    
    if existing_entry:
        # Check if it's the same supervisor (allow updates)
        if str(existing_entry['supervisor_id']) == str(user_id):
            return Response({
                'error': f'You have already submitted {labour_type} count for {entry_type}.',
                'can_edit': True,
                'existing_entry_id': existing_entry['id']
            }, status=status.HTTP_409_CONFLICT)
        else:
            # Different supervisor - BLOCK
            return Response({
                'error': f'{entry_type.capitalize()} data already entered by {existing_entry["supervisor_name"]} at {existing_entry["entry_time"].strftime("%I:%M %p")}',
                'locked_by': existing_entry['supervisor_name'],
                'locked_at': existing_entry['entry_time'].strftime("%I:%M %p"),
                'entry_type': entry_type,
                'can_edit': False
            }, status=status.HTTP_423_LOCKED)
    
    # Check for duplicate labour_type from SAME supervisor
    duplicate_check = fetch_one("""
        SELECT id FROM labour_entries 
        WHERE site_id = %s 
          AND entry_date = %s 
          AND entry_type = %s
          AND labour_type = %s
          AND supervisor_id = %s
    """, (site_id, entry_date, entry_type, labour_type, user_id))
    
    if duplicate_check:
        return Response({
            'error': f'You have already submitted {labour_type} for {entry_type}. Each labour type can only be submitted once per session.'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    # Proceed with insertion
    entry_id = str(uuid.uuid4())
    
    try:
        execute_query("""
            INSERT INTO labour_entries
            (id, site_id, supervisor_id, labour_count, labour_type, 
             entry_date, entry_time, entry_type, day_of_week, notes, 
             extra_cost, extra_cost_notes, submitted_by_role)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (entry_id, site_id, user_id, labour_count, labour_type, 
              entry_date, entry_time, entry_type, day_of_week, notes, 
              extra_cost, extra_cost_notes, user_role))
        
        # ... rest of existing code ...
        
        return Response({
            'success': True,
            'message': f'{labour_type} count submitted successfully',
            'entry_id': entry_id,
            'entry_type': entry_type
        }, status=status.HTTP_201_CREATED)
        
    except IntegrityError as e:
        # Database constraint violation
        if 'idx_labour_entry_lock' in str(e):
            return Response({
                'error': 'Entry already exists. Another supervisor may have submitted simultaneously.',
                'retry': True
            }, status=status.HTTP_409_CONFLICT)
        raise
```

**HTTP Status Codes:**
- `423 LOCKED` - Entry locked by another supervisor
- `409 CONFLICT` - Duplicate entry attempt
- `400 BAD REQUEST` - Invalid data
- `201 CREATED` - Success

---

### ✅ SOLUTION 3: FLUTTER UI HANDLING

#### File: `lib/services/construction_service.dart`

```dart
// Add to ConstructionService class

Future<Map<String, dynamic>> checkEntryLock({
  required String siteId,
  required String entryDate,
  required String entryType, // 'morning' or 'evening'
}) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/construction/check-entry-lock/'),
      headers: await _getHeaders(),
    ).timeout(const Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'success': true,
        'is_locked': data['is_locked'] ?? false,
        'locked_by': data['locked_by'],
        'locked_at': data['locked_at'],
        'can_view': data['can_view'] ?? false,
        'entries': data['entries'] ?? [],
      };
    }
    
    return {'success': false, 'error': 'Failed to check entry lock'};
  } catch (e) {
    return {'success': false, 'error': e.toString()};
  }
}

// Enhanced submitLabourCount with lock handling
Future<Map<String, dynamic>> submitLabourCount({
  required String siteId,
  required int labourCount,
  required String labourType,
  String? notes,
  double? extraCost,
  String? extraCostNotes,
  DateTime? customDateTime,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/construction/submit-labour-count/'),
      headers: await _getHeaders(),
      body: json.encode({
        'site_id': siteId,
        'labour_count': labourCount,
        'labour_type': labourType,
        'notes': notes,
        'extra_cost': extraCost,
        'extra_cost_notes': extraCostNotes,
        'custom_date_time': customDateTime?.toIso8601String(),
      }),
    ).timeout(const Duration(seconds: 15));
    
    final data = json.decode(response.body);
    
    // Handle different status codes
    if (response.statusCode == 201) {
      return {'success': true, ...data};
    } else if (response.statusCode == 423) {
      // Entry locked by another supervisor
      return {
        'success': false,
        'locked': true,
        'error': data['error'],
        'locked_by': data['locked_by'],
        'locked_at': data['locked_at'],
        'entry_type': data['entry_type'],
      };
    } else if (response.statusCode == 409) {
      // Conflict - duplicate entry
      return {
        'success': false,
        'conflict': true,
        'error': data['error'],
        'can_edit': data['can_edit'] ?? false,
      };
    }
    
    return {'success': false, 'error': data['error'] ?? 'Submission failed'};
  } catch (e) {
    return {'success': false, 'error': e.toString()};
  }
}
```

#### File: `lib/screens/site_detail_screen.dart`

```dart
// Add to _SiteDetailScreenState class

Future<void> _checkEntryLockBeforeOpening() async {
  final now = DateTime.now();
  final entryType = now.hour < 12 ? 'morning' : 'evening';
  
  final result = await _constructionService.checkEntryLock(
    siteId: widget.site['id'],
    entryDate: DateFormat('yyyy-MM-dd').format(now),
    entryType: entryType,
  );
  
  if (result['success'] && result['is_locked']) {
    // Show lock dialog
    _showEntryLockedDialog(
      lockedBy: result['locked_by'],
      lockedAt: result['locked_at'],
      entryType: entryType,
      entries: result['entries'],
    );
    return;
  }
  
  // Proceed to open entry sheet
  _showLabourEntry();
}

void _showEntryLockedDialog({
  required String lockedBy,
  required String lockedAt,
  required String entryType,
  required List entries,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(Icons.lock, color: Colors.orange.shade700, size: 28),
          const SizedBox(width: 12),
          const Text('Entry Locked'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${entryType.capitalize()} data has already been entered by:',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.person, size: 18, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Text(
                      lockedBy,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 18, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'at $lockedAt',
                      style: TextStyle(color: Colors.orange.shade700),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'You can view the entered data below:',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          ...entries.map((entry) => _buildReadOnlyEntryRow(entry)).toList(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

Widget _buildReadOnlyEntryRow(Map<String, dynamic> entry) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          entry['labour_type'] ?? '',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        Text(
          '${entry['labour_count']} workers',
          style: TextStyle(color: Colors.grey.shade700),
        ),
      ],
    ),
  );
}

// Update FAB tap handler
void _onFABTap() {
  _checkEntryLockBeforeOpening(); // Check lock first
}
```

---

## 🔒 FEATURE 2: ENTRY SCREEN LOCK FLOW

### Current Implementation Status
✅ **ALREADY IMPLEMENTED** in previous update!

The WillPopScope with strict blocking is already in place:
- Labour Entry Sheet: Lines 1920-1950
- Material Entry Sheet: Lines 3495-3525

### Enhancement: Add Entry Session State Management

```dart
// Add to _SiteDetailScreenState

class EntrySession {
  bool isActive = false;
  String? sessionId;
  DateTime? startTime;
  List<String> completedSteps = [];
  
  bool get isLabourComplete => completedSteps.contains('labour');
  bool get isMaterialComplete => completedSteps.contains('material');
  bool get isPhotoComplete => completedSteps.contains('photo');
  
  bool get canExit => isLabourComplete && isMaterialComplete;
  
  void start() {
    isActive = true;
    sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    startTime = DateTime.now();
    completedSteps.clear();
  }
  
  void markComplete(String step) {
    if (!completedSteps.contains(step)) {
      completedSteps.add(step);
    }
  }
  
  void end() {
    isActive = false;
    sessionId = null;
    startTime = null;
    completedSteps.clear();
  }
}

// Add to state
final EntrySession _entrySession = EntrySession();

// Wrap SiteDetailScreen with WillPopScope
@override
Widget build(BuildContext context) {
  return WillPopScope(
    onWillPop: () async {
      if (_entrySession.isActive && !_entrySession.canExit) {
        _showSessionLockWarning();
        return false; // Block navigation
      }
      return true; // Allow navigation
    },
    child: Scaffold(
      // ... existing code
    ),
  );
}

void _showSessionLockWarning() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning, color: Colors.red.shade600, size: 28),
          const SizedBox(width: 12),
          const Text('Entry In Progress'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'You have started the daily entry process. Please complete:',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          _buildRequirementRow(
            'Labour Count',
            _entrySession.isLabourComplete,
          ),
          _buildRequirementRow(
            'Material Updates',
            _entrySession.isMaterialComplete,
          ),
          _buildRequirementRow(
            'Photos (Optional)',
            _entrySession.isPhotoComplete,
            optional: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Continue Entry'),
        ),
      ],
    ),
  );
}

Widget _buildRequirementRow(String title, bool isComplete, {bool optional = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Icon(
          isComplete ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isComplete ? Colors.green : (optional ? Colors.grey : Colors.orange),
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: isComplete ? FontWeight.bold : FontWeight.normal,
              color: isComplete ? Colors.green.shade700 : Colors.black87,
            ),
          ),
        ),
        if (optional)
          Text(
            'Optional',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
      ],
    ),
  );
}

// Update FAB handler
void _onFABTap() {
  _entrySession.start(); // Start session
  _checkEntryLockBeforeOpening();
}

// Update submit handlers
Future<void> _submitLabour() async {
  // ... existing submit code ...
  
  if (result['success']) {
    _entrySession.markComplete('labour');
    // Check if can exit
    if (_entrySession.canExit) {
      _showCompletionDialog();
    } else {
      _promptNextStep();
    }
  }
}

void _promptNextStep() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Labour Submitted ✓'),
      content: const Text('Please proceed to update material balances.'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            _showMaterialEntry();
          },
          child: const Text('Continue'),
        ),
      ],
    ),
  );
}

void _showCompletionDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade600, size: 28),
          const SizedBox(width: 12),
          const Text('Entry Complete!'),
        ],
      ),
      content: const Text('All required entries have been submitted successfully.'),
      actions: [
        TextButton(
          onPressed: () {
            _entrySession.end(); // End session
            Navigator.pop(context);
            Navigator.pop(context); // Exit to dashboard
          },
          child: const Text('Done'),
        ),
      ],
    ),
  );
}
```

---

## 🗄️ DATABASE CHANGES SUMMARY

### Migration Checklist

```sql
-- ✅ STEP 1: Backup current data
pg_dump -U postgres -d construction_db -t labour_entries > backup_labour_entries_$(date +%Y%m%d).sql

-- ✅ STEP 2: Add entry_type column
ALTER TABLE labour_entries ADD COLUMN IF NOT EXISTS entry_type VARCHAR(10);

-- ✅ STEP 3: Populate entry_type from entry_time
UPDATE labour_entries 
SET entry_type = CASE 
    WHEN EXTRACT(HOUR FROM entry_time) < 12 THEN 'morning'
    ELSE 'evening'
END;

-- ✅ STEP 4: Create unique index (prevents duplicates)
CREATE UNIQUE INDEX CONCURRENTLY idx_labour_entry_lock 
ON labour_entries(site_id, entry_date, entry_type, labour_type);

-- ✅ STEP 5: Add constraints
ALTER TABLE labour_entries 
ADD CONSTRAINT chk_entry_type CHECK (entry_type IN ('morning', 'evening'));

ALTER TABLE labour_entries ALTER COLUMN entry_type SET NOT NULL;

-- ✅ STEP 6: Verify
SELECT site_id, entry_date, entry_type, labour_type, COUNT(*) as count
FROM labour_entries
GROUP BY site_id, entry_date, entry_type, labour_type
HAVING COUNT(*) > 1;
-- Should return 0 rows
```

---

## 🧪 TESTING STRATEGY

### Test Cases

#### Test 1: Single Supervisor Lock
```
1. Supervisor A logs in
2. Opens Site X
3. Submits morning labour entry
4. Supervisor B logs in
5. Opens Site X
6. Attempts morning labour entry
Expected: ❌ Blocked with message showing Supervisor A's name
```

#### Test 2: Different Time Slots
```
1. Supervisor A submits morning entry
2. Supervisor A submits evening entry
Expected: ✅ Both succeed
```

#### Test 3: Race Condition
```
1. Supervisor A and B both open entry form
2. Both submit simultaneously
Expected: One succeeds, other gets 409 CONFLICT
```

#### Test 4: Entry Session Lock
```
1. Supervisor opens entry form
2. Enters labour data
3. Presses back button
Expected: ❌ Blocked with warning
4. Submits labour
5. Presses back button
Expected: ❌ Still blocked (material pending)
6. Submits material
7. Presses back button
Expected: ✅ Allowed
```

---

## 🚨 EDGE CASES & SOLUTIONS

### Edge Case 1: App Crash During Entry
**Problem:** Session remains active, user can't exit
**Solution:** 
```dart
// Add session timeout
class EntrySession {
  static const Duration timeout = Duration(hours: 2);
  
  bool get isExpired {
    if (startTime == null) return false;
    return DateTime.now().difference(startTime!) > timeout;
  }
  
  bool get canExit => isLabourComplete && isMaterialComplete || isExpired;
}
```

### Edge Case 2: Network Failure During Submit
**Problem:** Data lost, session stuck
**Solution:**
```dart
// Add local draft storage
Future<void> _saveDraft() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('entry_draft_${widget.site['id']}', json.encode({
    'labour_counts': _labourCounts,
    'material_quantities': _materialQuantities,
    'timestamp': DateTime.now().toIso8601String(),
  }));
}

Future<void> _loadDraft() async {
  final prefs = await SharedPreferences.getInstance();
  final draft = prefs.getString('entry_draft_${widget.site['id']}');
  if (draft != null) {
    // Show recovery dialog
    _showDraftRecoveryDialog(json.decode(draft));
  }
}
```

### Edge Case 3: Force Close
**Problem:** Session not cleaned up
**Solution:**
```dart
@override
void dispose() {
  // Auto-save draft on dispose
  if (_entrySession.isActive && !_entrySession.canExit) {
    _saveDraft();
  }
  super.dispose();
}
```

---

## 📊 WORKFLOW DIAGRAM

```
┌─────────────────────────────────────────────────────────────┐
│                    SUPERVISOR OPENS SITE                     │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
              ┌────────────────┐
              │  Check Entry   │
              │  Lock Status   │
              └────────┬───────┘
                       │
         ┌─────────────┴─────────────┐
         │                           │
         ▼                           ▼
    ┌─────────┐              ┌──────────────┐
    │ LOCKED  │              │  AVAILABLE   │
    │ by Other│              │              │
    └────┬────┘              └──────┬───────┘
         │                          │
         ▼                          ▼
  ┌──────────────┐          ┌──────────────┐
  │ Show Lock    │          │ Start Entry  │
  │ Dialog with  │          │ Session      │
  │ Read-Only    │          └──────┬───────┘
  │ Data         │                 │
  └──────────────┘                 ▼
                           ┌───────────────┐
                           │ Labour Entry  │
                           │ Form Opens    │
                           └───────┬───────┘
                                   │
                           ┌───────▼───────┐
                           │ Back Button?  │
                           └───┬───────┬───┘
                               │       │
                          YES  │       │  NO
                               │       │
                               ▼       ▼
                        ┌──────────┐  Continue
                        │ BLOCKED  │  Entry
                        │ Warning  │
                        └──────────┘
                                   │
                                   ▼
                           ┌───────────────┐
                           │ Submit Labour │
                           └───────┬───────┘
                                   │
                                   ▼
                           ┌───────────────┐
                           │ Material Form │
                           └───────┬───────┘
                                   │
                                   ▼
                           ┌───────────────┐
                           │Submit Material│
                           └───────┬───────┘
                                   │
                                   ▼
                           ┌───────────────┐
                           │ Session End   │
                           │ Exit Allowed  │
                           └───────────────┘
```

---

## 🔄 ROLLBACK PLAN

### If Issues Occur

```sql
-- ROLLBACK STEP 1: Remove constraints
DROP INDEX IF EXISTS idx_labour_entry_lock;
ALTER TABLE labour_entries DROP CONSTRAINT IF EXISTS chk_entry_type;

-- ROLLBACK STEP 2: Remove column (optional)
ALTER TABLE labour_entries DROP COLUMN IF EXISTS entry_type;

-- ROLLBACK STEP 3: Restore from backup
psql -U postgres -d construction_db < backup_labour_entries_YYYYMMDD.sql
```

### Flutter Rollback
```dart
// Simply comment out or remove:
// - _checkEntryLockBeforeOpening() call
// - _entrySession logic
// - WillPopScope wrapper on SiteDetailScreen

// Existing UI will work as before
```

---

## ✅ IMPLEMENTATION CHECKLIST

### Backend
- [ ] Run database migration script
- [ ] Update `views_construction.py` with new validation
- [ ] Add new API endpoint `/check-entry-lock/`
- [ ] Test with Postman/curl
- [ ] Deploy to staging
- [ ] Run integration tests

### Flutter
- [ ] Update `construction_service.dart`
- [ ] Add `EntrySession` class
- [ ] Update `site_detail_screen.dart`
- [ ] Add lock check dialogs
- [ ] Test on Android
- [ ] Test on iOS
- [ ] Build and deploy

### Testing
- [ ] Unit tests for backend validation
- [ ] Integration tests for API
- [ ] UI tests for Flutter
- [ ] Manual testing with 2 devices
- [ ] Load testing for race conditions

---

## 📝 NOTES

1. **Database Migration:** Run during low-traffic hours (2-4 AM)
2. **Backward Compatibility:** Old app versions will still work (no breaking changes)
3. **Performance:** Index creation is `CONCURRENTLY` - no downtime
4. **Monitoring:** Add logging for lock violations to track usage patterns

---

## 🎯 SUCCESS CRITERIA

- ✅ No duplicate entries possible
- ✅ Clear error messages for users
- ✅ No race conditions
- ✅ Entry workflow enforced
- ✅ Graceful handling of edge cases
- ✅ Zero downtime deployment
- ✅ Backward compatible

---

**END OF IMPLEMENTATION GUIDE**
