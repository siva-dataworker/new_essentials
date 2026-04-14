# 📅 Time-Restricted Day-Based History System

## Requirements

### 1. Time Restriction (8 AM - 1 PM IST)
- Supervisor can only add/update entries between 8:00 AM and 1:00 PM IST
- Outside this window, show error message
- Prevent form submission outside allowed hours

### 2. Day-Based Storage
- Store entries with day name (Monday, Tuesday, Wednesday, etc.)
- Use IST timezone for day calculation
- Each entry tagged with day of week

### 3. History Display
- Show expandable day cards (Monday, Tuesday, etc.)
- Click day card to expand and see entries
- Click again to collapse
- Show entry count per day

### 4. Accountant View
- Same day-based format as supervisor
- Labour and Materials tabs
- Expandable day cards
- Read-only view

---

## Implementation Plan

### Phase 1: Backend Changes

#### 1.1 Add Day Column to Tables
```sql
ALTER TABLE labour_entries ADD COLUMN day_of_week VARCHAR(10);
ALTER TABLE material_entries ADD COLUMN day_of_week VARCHAR(10);
```

#### 1.2 Update Django Models
Add `day_of_week` field to models:
- `LabourEntry` model
- `MaterialEntry` model

#### 1.3 Create Time Validation Endpoint
```python
# New endpoint: /api/construction/validate-entry-time/
# Returns: { "allowed": true/false, "message": "..." }
```

#### 1.4 Update Entry Creation
- Calculate day of week in IST
- Store day name with entry
- Validate time before saving

#### 1.5 Update History Endpoints
- Group by day_of_week instead of date
- Return entries organized by day
- Include day name in response

---

### Phase 2: Flutter Frontend Changes

#### 2.1 Time Validation Service
Create `TimeValidationService`:
```dart
class TimeValidationService {
  // Check if current time is between 8 AM - 1 PM IST
  bool isWithinAllowedHours();
  
  // Get IST time
  DateTime getISTTime();
  
  // Get day of week in IST
  String getDayOfWeek();
  
  // Show error dialog
  void showTimeRestrictionError(BuildContext context);
}
```

#### 2.2 Update Supervisor Entry Forms
- Check time before showing form
- Validate time before submission
- Show countdown/timer showing remaining time
- Display error if outside hours

#### 2.3 Update History Display
**Current**: Groups by date (2026-01-27)
**New**: Groups by day (Monday, Tuesday, etc.)

Changes needed:
- `supervisor_history_screen.dart`
- `accountant_entry_screen.dart`
- Group entries by `day_of_week`
- Show day names instead of dates
- Keep expandable card UI

#### 2.4 Update Construction Provider
```dart
// Add methods:
- loadHistoryByDay()
- groupEntriesByDay()
- validateEntryTime()
```

---

### Phase 3: UI/UX Design

#### 3.1 Time Restriction UI
```
┌─────────────────────────────┐
│  ⏰ Entry Time Restriction  │
│                             │
│  Entries allowed:           │
│  8:00 AM - 1:00 PM IST      │
│                             │
│  Current time: 2:30 PM IST  │
│                             │
│  ❌ Outside allowed hours   │
│                             │
│  Next window opens:         │
│  Tomorrow at 8:00 AM        │
└─────────────────────────────┘
```

#### 3.2 Day-Based History UI
```
┌─────────────────────────────┐
│  📅 Monday                   │
│  5 labour entries           │
│  [Tap to expand]            │
├─────────────────────────────┤
│  📅 Tuesday                  │
│  3 labour entries           │
│  [Tap to expand]            │
├─────────────────────────────┤
│  📅 Wednesday (Today)        │
│  2 labour entries           │
│  [Tap to expand]            │
└─────────────────────────────┘
```

#### 3.3 Expanded Day Card
```
┌─────────────────────────────┐
│  📅 Monday, Jan 27, 2026     │
│  5 labour entries           │
│  [Tap to collapse]          │
│                             │
│  ├─ 8:30 AM - Mason         │
│  │  Workers: 5              │
│  │                          │
│  ├─ 9:15 AM - Carpenter     │
│  │  Workers: 3              │
│  │                          │
│  └─ 10:00 AM - Electrician  │
│     Workers: 2              │
└─────────────────────────────┘
```

---

## Database Schema Changes

### labour_entries Table
```sql
CREATE TABLE labour_entries (
  id SERIAL PRIMARY KEY,
  site_id INTEGER,
  user_id INTEGER,
  labour_type VARCHAR(100),
  labour_count INTEGER,
  entry_date DATE,
  entry_time TIMESTAMP,
  day_of_week VARCHAR(10),  -- NEW: Monday, Tuesday, etc.
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### material_entries Table
```sql
CREATE TABLE material_entries (
  id SERIAL PRIMARY KEY,
  site_id INTEGER,
  user_id INTEGER,
  material_type VARCHAR(100),
  quantity DECIMAL(10,2),
  unit VARCHAR(50),
  timestamp TIMESTAMP,
  day_of_week VARCHAR(10),  -- NEW: Monday, Tuesday, etc.
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## API Changes

### 1. Validate Entry Time
```
POST /api/construction/validate-entry-time/
Response: {
  "allowed": true,
  "current_time_ist": "2026-01-27T10:30:00+05:30",
  "message": "Entry allowed"
}
```

### 2. Create Entry (Updated)
```
POST /api/construction/labour-entry/
Body: {
  "site_id": 1,
  "labour_type": "Mason",
  "labour_count": 5,
  "notes": "Foundation work"
}
Response: {
  "success": true,
  "entry": {
    "id": 123,
    "day_of_week": "Monday",
    "entry_date": "2026-01-27",
    "entry_time": "10:30:00"
  }
}
```

### 3. Get History by Day
```
GET /api/construction/history-by-day/?site_id=1
Response: {
  "success": true,
  "labour_by_day": {
    "Monday": [...],
    "Tuesday": [...],
    "Wednesday": [...]
  },
  "material_by_day": {
    "Monday": [...],
    "Tuesday": [...],
    "Wednesday": [...]
  }
}
```

---

## Implementation Steps

### Step 1: Database Migration
1. Add `day_of_week` column to tables
2. Populate existing entries with day names
3. Test migration

### Step 2: Backend Implementation
1. Update Django models
2. Create time validation function
3. Update entry creation to store day
4. Create history-by-day endpoint
5. Test all endpoints

### Step 3: Flutter Time Validation
1. Create `TimeValidationService`
2. Add IST timezone handling
3. Implement time check UI
4. Test time restrictions

### Step 4: Flutter History Update
1. Update history display to group by day
2. Modify expandable cards for days
3. Update accountant view
4. Test UI/UX

### Step 5: Testing
1. Test time restrictions (8 AM - 1 PM)
2. Test day-based grouping
3. Test across timezone changes
4. Test accountant view matches supervisor

---

## Edge Cases to Handle

1. **Timezone Issues**: Always use IST, not device timezone
2. **Midnight Boundary**: Entry at 11:59 PM vs 12:01 AM
3. **Week Transitions**: Sunday to Monday
4. **Empty Days**: Days with no entries
5. **Multiple Entries Same Day**: Group properly
6. **Historical Data**: Migrate old entries
7. **Time Validation Failure**: Network issues during check

---

## Testing Scenarios

### Time Restriction Tests
- [ ] Entry at 7:59 AM - Should fail
- [ ] Entry at 8:00 AM - Should succeed
- [ ] Entry at 12:59 PM - Should succeed
- [ ] Entry at 1:00 PM - Should succeed
- [ ] Entry at 1:01 PM - Should fail
- [ ] Entry at 2:00 PM - Should fail

### Day Grouping Tests
- [ ] Monday entries show under Monday
- [ ] Tuesday entries show under Tuesday
- [ ] Multiple entries same day group correctly
- [ ] Empty days don't show
- [ ] Week transitions work correctly

### UI Tests
- [ ] Day cards expand/collapse
- [ ] Entry count shows correctly
- [ ] Today's day highlighted
- [ ] Accountant sees same format
- [ ] Refresh updates properly

---

## Timeline Estimate

- **Backend Changes**: 4-6 hours
- **Flutter Time Validation**: 2-3 hours
- **Flutter History Update**: 3-4 hours
- **Testing & Bug Fixes**: 2-3 hours
- **Total**: 11-16 hours

---

## Priority

🔴 **HIGH PRIORITY** - Core business requirement

This feature is critical for:
- Compliance with work hour regulations
- Accurate day-based reporting
- Consistent data organization
- Accountant verification workflow

---

**Next Step**: Start with backend database migration and model updates
