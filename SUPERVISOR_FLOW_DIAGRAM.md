# Supervisor Entry Flow - Visual Diagram

## Complete Workflow with Locking System

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         SUPERVISOR DASHBOARD                             │
│                                                                          │
│  Site: ABC Construction                                                 │
│  Date: May 14, 2026                                                     │
│                                                                          │
│  ┌────────────────────────────────────────────────────────────────┐    │
│  │  Status Banner:                                                 │    │
│  │  🔵 No entries yet — Tap + to start daily entry               │    │
│  └────────────────────────────────────────────────────────────────┘    │
│                                                                          │
│                            [  +  ]  ← Orange FAB                        │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ Click +
                                    ▼
                    ┌───────────────────────────┐
                    │  Check Entry Lock API     │
                    │  GET /check-entry-lock/   │
                    └───────────────────────────┘
                                    │
                    ┌───────────────┴───────────────┐
                    │                               │
                    ▼                               ▼
            ┌───────────────┐              ┌────────────────┐
            │  UNLOCKED     │              │   LOCKED       │
            │  (Available)  │              │  (By Other)    │
            └───────────────┘              └────────────────┘
                    │                               │
                    │                               ▼
                    │                    ┌──────────────────────┐
                    │                    │  Lock Dialog         │
                    │                    │  🔒 Entry Locked     │
                    │                    │                      │
                    │                    │  Entered by:         │
                    │                    │  John Doe            │
                    │                    │  at 09:30 AM         │
                    │                    │                      │
                    │                    │  Data:               │
                    │                    │  • Mason: 5          │
                    │                    │  • Helper: 3         │
                    │                    │                      │
                    │                    │  [OK] [View History] │
                    │                    └──────────────────────┘
                    │                               │
                    │                               ▼
                    │                    ┌──────────────────────┐
                    │                    │  FAB → Grey Lock 🔒  │
                    │                    │  Cannot enter data   │
                    │                    └──────────────────────┘
                    │
                    ▼
    ┌───────────────────────────────────────────────────┐
    │         QUICK ACTIONS SHEET (LOCKED)              │
    │                                                    │
    │  🔒 Complete Labour & Photo to go back            │
    │                                                    │
    │  ┌──────────────────────────────────────────┐    │
    │  │ 👥 Labour Count                          │    │
    │  │    Add workers by type                   │    │
    │  │                                    [TAP] │    │
    │  └──────────────────────────────────────────┘    │
    │                                                    │
    │  ┌──────────────────────────────────────────┐    │
    │  │ 📦 Material Balance                      │    │
    │  │    Update materials — once per day       │    │
    │  │                                    [TAP] │    │
    │  └──────────────────────────────────────────┘    │
    │                                                    │
    │  ┌──────────────────────────────────────────┐    │
    │  │ 📷 Add Photo                             │    │
    │  │    Upload site progress pictures         │    │
    │  │                                    [TAP] │    │
    │  └──────────────────────────────────────────┘    │
    │                                                    │
    │  ┌──────────────────────────────────────────┐    │
    │  │ 🛒 Material Requirement                  │    │
    │  │    Request materials needed              │    │
    │  │                                    [TAP] │    │
    │  └──────────────────────────────────────────┘    │
    │                                                    │
    │  [🔒 Complete Labour & Photo to go back]         │
    │                                                    │
    └───────────────────────────────────────────────────┘
                        │
                        │ Tap Labour Count
                        ▼
    ┌───────────────────────────────────────────────────┐
    │         LABOUR ENTRY SHEET                        │
    │                                                    │
    │  Morning Entry                                    │
    │                                                    │
    │  Mason:        [  -  ]  5  [  +  ]               │
    │  Helper:       [  -  ]  3  [  +  ]               │
    │  Carpenter:    [  -  ]  2  [  +  ]               │
    │                                                    │
    │  Total Workers: 10                                │
    │                                                    │
    │  [Submit Labour Count]                            │
    │                                                    │
    └───────────────────────────────────────────────────┘
                        │
                        │ Submit
                        ▼
    ┌───────────────────────────────────────────────────┐
    │  POST /api/construction/labour/                   │
    │                                                    │
    │  ✅ Success → Entry saved                         │
    │  ❌ 423 LOCKED → Another supervisor entered       │
    │  ❌ 409 CONFLICT → Duplicate entry                │
    └───────────────────────────────────────────────────┘
                        │
                        │ Success
                        ▼
    ┌───────────────────────────────────────────────────┐
    │         QUICK ACTIONS SHEET (UPDATED)             │
    │                                                    │
    │  🔒 Complete Labour & Photo to go back            │
    │                                                    │
    │  ┌──────────────────────────────────────────┐    │
    │  │ ✅ Labour Count                          │    │
    │  │    Already submitted — locked            │    │
    │  │                              [LOCKED 🔒] │    │
    │  └──────────────────────────────────────────┘    │
    │                                                    │
    │  ┌──────────────────────────────────────────┐    │
    │  │ 📦 Material Balance                      │    │
    │  │    Update materials — once per day       │    │
    │  │                                    [TAP] │    │
    │  └──────────────────────────────────────────┘    │
    │                                                    │
    │  ┌──────────────────────────────────────────┐    │
    │  │ 📷 Add Photo                             │    │
    │  │    Upload site progress pictures         │    │
    │  │                                    [TAP] │    │
    │  └──────────────────────────────────────────┘    │
    │                                                    │
    │  [🔒 Complete Labour & Photo to go back]         │
    │                                                    │
    └───────────────────────────────────────────────────┘
                        │
                        │ Tap Add Photo
                        ▼
    ┌───────────────────────────────────────────────────┐
    │         PHOTO UPLOAD SCREEN                       │
    │                                                    │
    │  [📷 Take Photo]  [🖼️ Choose from Gallery]       │
    │                                                    │
    │  ┌─────────┐  ┌─────────┐  ┌─────────┐          │
    │  │ Photo 1 │  │ Photo 2 │  │ Photo 3 │          │
    │  └─────────┘  └─────────┘  └─────────┘          │
    │                                                    │
    │  [Upload Photos]                                  │
    │                                                    │
    └───────────────────────────────────────────────────┘
                        │
                        │ Upload Success
                        ▼
    ┌───────────────────────────────────────────────────┐
    │         QUICK ACTIONS SHEET (UNLOCKED)            │
    │                                                    │
    │  ✅ Labour & Photo done — you can go back anytime │
    │                                                    │
    │  ┌──────────────────────────────────────────┐    │
    │  │ ✅ Labour Count                          │    │
    │  │    Already submitted — locked            │    │
    │  │                              [LOCKED 🔒] │    │
    │  └──────────────────────────────────────────┘    │
    │                                                    │
    │  ┌──────────────────────────────────────────┐    │
    │  │ 📦 Material Balance                      │    │
    │  │    Update materials — once per day       │    │
    │  │                                    [TAP] │    │
    │  └──────────────────────────────────────────┘    │
    │                                                    │
    │  ┌──────────────────────────────────────────┐    │
    │  │ ✅ Add Photo                             │    │
    │  │    Already submitted — locked            │    │
    │  │                              [LOCKED 🔒] │    │
    │  └──────────────────────────────────────────┘    │
    │                                                    │
    │  [✅ Done]  ← NOW ENABLED                         │
    │                                                    │
    └───────────────────────────────────────────────────┘
                        │
                        │ Tap Done
                        ▼
    ┌───────────────────────────────────────────────────┐
    │         SUPERVISOR DASHBOARD (UPDATED)            │
    │                                                    │
    │  Site: ABC Construction                           │
    │  Date: May 14, 2026                               │
    │                                                    │
    │  ┌────────────────────────────────────────────┐  │
    │  │  Status Banner:                             │  │
    │  │  ✅ Day complete — Labour & Photo ✓        │  │
    │  └────────────────────────────────────────────┘  │
    │                                                    │
    │  Labour Entries:                                  │
    │  • Mason: 5 workers                               │
    │  • Helper: 3 workers                              │
    │  • Carpenter: 2 workers                           │
    │                                                    │
    │  Photos: 3 uploaded                               │
    │                                                    │
    │                        [  ✓  ]  ← Green FAB       │
    │                                                    │
    └───────────────────────────────────────────────────┘
                        │
                        │ Click Green FAB
                        ▼
    ┌───────────────────────────────────────────────────┐
    │         LABOUR ENTRY SHEET (EVENING TAB)          │
    │                                                    │
    │  [Morning] [Evening] ← Evening tab selected       │
    │                                                    │
    │  Evening Update                                   │
    │                                                    │
    │  Total Wage Amount:  ₹ [______]                   │
    │  OT Amount:          ₹ [______]                   │
    │  Extra Expense:      ₹ [______]                   │
    │                                                    │
    │  Evening Photos:                                  │
    │  [📷 Add Photos]                                  │
    │                                                    │
    │  [Submit Evening Update]                          │
    │                                                    │
    └───────────────────────────────────────────────────┘
```

---

## State Transitions

### FAB Icon States

```
┌─────────────────────────────────────────────────────────────┐
│                      FAB STATES                              │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  1. 🟠 Orange + (No entries)                                │
│     → Click: Check lock → Open quick actions                │
│                                                              │
│  2. 🔒 Grey Lock (Locked by other)                          │
│     → Click: Show lock dialog                               │
│                                                              │
│  3. 🟢 Green ✓ (Morning complete)                           │
│     → Click: Open evening update directly                   │
│                                                              │
│  4. 🟡 Orange + (Partial entry)                             │
│     → Click: Open quick actions (still locked)              │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Quick Actions Sheet States

```
┌─────────────────────────────────────────────────────────────┐
│              QUICK ACTIONS SHEET STATES                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  1. LOCKED (Labour or Photo incomplete)                     │
│     • Cannot dismiss by back button                         │
│     • Cannot dismiss by swipe down                          │
│     • Shows lock icon in header                             │
│     • Done button disabled                                  │
│                                                              │
│  2. UNLOCKED (Labour + Photo complete)                      │
│     • Can dismiss by back button                            │
│     • Can dismiss by swipe down                             │
│     • Shows no lock icon                                    │
│     • Done button enabled                                   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Labour Entry Button States

```
┌─────────────────────────────────────────────────────────────┐
│            LABOUR ENTRY BUTTON STATES                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  1. 🔵 Active (Not submitted)                               │
│     • Blue color                                            │
│     • Tappable                                              │
│     • Shows "Add workers by type"                           │
│                                                              │
│  2. ✅ Locked (Already submitted)                           │
│     • Green color                                           │
│     • Not tappable                                          │
│     • Shows "Already submitted — locked"                    │
│     • Lock icon displayed                                   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## Multi-Supervisor Scenarios

### Scenario A: Supervisor 1 Enters First

```
Time: 09:00 AM
Supervisor: John Doe

[John's Phone]
  ↓
Click + → Check Lock → UNLOCKED
  ↓
Open Quick Actions
  ↓
Enter Labour (Mason: 5, Helper: 3)
  ↓
Submit → ✅ Success
  ↓
Upload Photos
  ↓
FAB → Green ✓
```

### Scenario B: Supervisor 2 Tries to Enter (Locked)

```
Time: 09:30 AM
Supervisor: Jane Smith

[Jane's Phone]
  ↓
Click + → Check Lock → LOCKED
  ↓
Show Lock Dialog:
  "Entry already submitted by John Doe at 09:00 AM"
  Data: Mason: 5, Helper: 3
  ↓
[OK] → Close Dialog
  ↓
FAB → Grey Lock 🔒
```

### Scenario C: Supervisor 1 Continues to Evening

```
Time: 05:00 PM
Supervisor: John Doe

[John's Phone]
  ↓
Click Green ✓ → Open Evening Update
  ↓
Enter Evening Data:
  - Total Wage: ₹8000
  - OT Amount: ₹500
  - Extra Expense: ₹200
  ↓
Upload Evening Photos
  ↓
Submit → ✅ Success
  ↓
FAB → Green ✓ (Fully Complete)
```

---

## Error Handling

### Network Error

```
Click + → Check Lock → ❌ Network Error
  ↓
Show Error Message:
  "Failed to check entry status: Network error"
  ↓
[Retry] or [Cancel]
```

### Lock Detected During Submission

```
Enter Labour → Submit → ❌ 423 LOCKED
  ↓
Show Error Dialog:
  "Mason data already entered by John Doe at 09:30 AM"
  ↓
[OK] → Close Sheet
  ↓
Reload Data → FAB → Grey Lock 🔒
```

### Duplicate Entry

```
Enter Labour → Submit → ❌ 409 CONFLICT
  ↓
Show Error Message:
  "You have already submitted Mason count for 2026-05-14"
  ↓
[OK] → Close Sheet
  ↓
Reload Data
```

---

**Last Updated:** May 14, 2026
**Status:** ✅ COMPLETE VISUAL GUIDE
