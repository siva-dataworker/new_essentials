# 📅 Day-Based History Feature - Visual Guide

## Current vs New System

### CURRENT (Date-Based)
```
History Screen
├─ 📅 January 27, 2026
│  └─ 5 labour entries
│     ├─ 8:30 AM - Mason (5)
│     ├─ 9:15 AM - Carpenter (3)
│     └─ 10:00 AM - Electrician (2)
│
├─ 📅 January 26, 2026
│  └─ 3 labour entries
│
└─ 📅 January 25, 2026
   └─ 2 labour entries
```

### NEW (Day-Based)
```
History Screen
├─ 📅 Monday
│  └─ 5 labour entries
│     ├─ 8:30 AM - Mason (5)
│     ├─ 9:15 AM - Carpenter (3)
│     └─ 10:00 AM - Electrician (2)
│
├─ 📅 Tuesday
│  └─ 3 labour entries
│
└─ 📅 Wednesday (Today)
   └─ 2 labour entries
```

---

## Time Restriction Feature

### Allowed Time (8 AM - 1 PM IST)
```
┌─────────────────────────────┐
│  ✅ Entry Allowed            │
│                             │
│  Current Time: 10:30 AM IST │
│                             │
│  You can add entries until: │
│  1:00 PM (2 hours 30 min)   │
│                             │
│  [Add Labour Entry]         │
│  [Add Material Entry]       │
└─────────────────────────────┘
```

### Outside Allowed Time (Before 8 AM or After 1 PM)
```
┌─────────────────────────────┐
│  ❌ Entry Not Allowed        │
│                             │
│  Current Time: 3:45 PM IST  │
│                             │
│  Entries only allowed:      │
│  8:00 AM - 1:00 PM IST      │
│                             │
│  Next window opens:         │
│  Tomorrow at 8:00 AM        │
│                             │
│  [View History Only]        │
└─────────────────────────────┘
```

---

## Day Card UI

### Collapsed Day Card
```
┌─────────────────────────────┐
│  📅 Monday, Jan 27           │
│  5 labour entries           │
│  [▼ Tap to expand]          │
└─────────────────────────────┘
```

### Expanded Day Card
```
┌─────────────────────────────┐
│  📅 Monday, Jan 27, 2026     │
│  5 labour entries           │
│  [▲ Tap to collapse]        │
│                             │
│  ┌─────────────────────────┐│
│  │ 8:30 AM                 ││
│  │ Mason                   ││
│  │ Workers: 5              ││
│  │ Notes: Foundation work  ││
│  └─────────────────────────┘│
│                             │
│  ┌─────────────────────────┐│
│  │ 9:15 AM                 ││
│  │ Carpenter               ││
│  │ Workers: 3              ││
│  │ Notes: Door frames      ││
│  └─────────────────────────┘│
│                             │
│  ┌─────────────────────────┐│
│  │ 10:00 AM                ││
│  │ Electrician             ││
│  │ Workers: 2              ││
│  │ Notes: Wiring           ││
│  └─────────────────────────┘│
└─────────────────────────────┘
```

---

## Supervisor Flow

### Monday 9:00 AM (Allowed Time)
```
1. Open app
2. See: ✅ "Entry allowed until 1:00 PM"
3. Add labour entry
4. Entry saved as "Monday"
5. View history → See under "Monday" card
```

### Monday 2:00 PM (Not Allowed)
```
1. Open app
2. See: ❌ "Entry not allowed"
3. Message: "Entries only 8 AM - 1 PM"
4. Can only view history
5. Cannot add new entries
```

### Tuesday 8:00 AM (New Day)
```
1. Open app
2. See: ✅ "Entry allowed until 1:00 PM"
3. Add labour entry
4. Entry saved as "Tuesday"
5. View history → See under "Tuesday" card
```

---

## Accountant View

### Same Day-Based Format
```
Accountant Entry Screen
├─ Select Site (3 dropdowns)
├─ Role Tabs: Supervisor | Engineer | Architect
└─ Supervisor Tab
   ├─ Labour Tab
   │  ├─ 📅 Monday (5 entries)
   │  ├─ 📅 Tuesday (3 entries)
   │  └─ 📅 Wednesday (2 entries)
   │
   └─ Materials Tab
      ├─ 📅 Monday (4 entries)
      ├─ 📅 Tuesday (2 entries)
      └─ 📅 Wednesday (1 entry)
```

---

## Data Storage

### Database Entry
```json
{
  "id": 123,
  "site_id": 1,
  "user_id": 5,
  "labour_type": "Mason",
  "labour_count": 5,
  "entry_date": "2026-01-27",
  "entry_time": "08:30:00",
  "day_of_week": "Monday",  ← NEW FIELD
  "notes": "Foundation work",
  "created_at": "2026-01-27T08:30:00+05:30"
}
```

### History Response
```json
{
  "success": true,
  "labour_by_day": {
    "Monday": [
      {
        "id": 123,
        "labour_type": "Mason",
        "labour_count": 5,
        "entry_time": "08:30:00",
        "notes": "Foundation work"
      },
      {
        "id": 124,
        "labour_type": "Carpenter",
        "labour_count": 3,
        "entry_time": "09:15:00",
        "notes": "Door frames"
      }
    ],
    "Tuesday": [...],
    "Wednesday": [...]
  }
}
```

---

## Key Features

### 1. Time Restriction
- ✅ Check time before showing form
- ✅ Validate on submission
- ✅ Show countdown timer
- ✅ Clear error messages

### 2. Day Storage
- ✅ Store day name with entry
- ✅ Use IST timezone
- ✅ Automatic day calculation

### 3. Day Grouping
- ✅ Group entries by day
- ✅ Show day names (Monday, Tuesday, etc.)
- ✅ Expandable day cards
- ✅ Entry count per day

### 4. Consistent View
- ✅ Supervisor sees day-based history
- ✅ Accountant sees same format
- ✅ Both can expand/collapse days
- ✅ Same UI/UX

---

## Benefits

1. **Compliance**: Enforces work hour regulations
2. **Organization**: Clear day-based structure
3. **Reporting**: Easy to see work by day
4. **Consistency**: Same view for all users
5. **Clarity**: Day names easier than dates

---

**This is what you'll get when the feature is implemented!**
