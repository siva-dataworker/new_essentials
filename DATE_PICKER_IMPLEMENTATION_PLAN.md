# 📅 Date Picker for Site Detail Screen - Implementation Plan

## Problem
Site detail screen shows "0 Workers, 0 Materials" because it only loads TODAY's entries. Historical data exists but can't be viewed.

## Solution
Add a date picker to allow supervisors to select any date and view entries from that specific day.

## Implementation Steps

### 1. Update Site Detail Screen UI

Add date selector bar below the site header with:
- **Previous Day** button (←)
- **Current Date** display (tap to open calendar)
- **Next Day** button (→)
- **Today** quick button

### 2. Update Backend API

Modify `/api/construction/today-entries/` to accept optional date parameter:
- If no date provided → return today's entries (current behavior)
- If date provided → return entries for that specific date

### 3. Update Flutter Service

Add date parameter to `getTodayEntries()` method in `construction_service.dart`

### 4. Update State Management

Add selected date to site detail screen state and reload data when date changes

## UI Design

```
┌─────────────────────────────────────────┐
│  Site Name - History                    │
│  Area • Street                          │
├─────────────────────────────────────────┤
│  ← │  Dec 28, 2025  │ →  │ [Today]     │
├─────────────────────────────────────────┤
│  Today's Entries (or Selected Date)     │
│  ┌───────────────────────────────────┐  │
│  │ 👷 Mason - 5 workers              │  │
│  │ 📦 Cement - 50 bags               │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

## Features

✅ Navigate between dates with arrow buttons
✅ Tap date to open calendar picker
✅ "Today" button to quickly return to current date
✅ Show selected date in header
✅ Load and display entries for selected date
✅ Empty state shows "No entries for [date]"

## Benefits

- View historical data easily
- Compare entries across different dates
- Verify past submissions
- Check what was done on specific days
- Better data transparency

## Next Steps

Would you like me to implement this feature now? It will involve:
1. Adding date picker UI to site detail screen
2. Updating the backend API endpoint
3. Modifying the service layer
4. Testing with different dates

This is a valuable feature that will make the app much more useful for supervisors!
