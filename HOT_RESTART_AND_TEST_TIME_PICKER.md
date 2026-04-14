# Hot Restart and Test Time Picker - Quick Guide

## Issue
User reported: "Time picker is not working - forgot that add labour entry, material entry on 26 Jan 2026 for Rahman site"

## Quick Fix Steps

### Step 1: Hot Restart Flutter App
```bash
cd otp_phone_auth
flutter hot restart
```

### Step 2: Test Time Picker Immediately

1. **Open the app** and login as Supervisor
2. **Go to Rahman site** (or any site)
3. **Tap + button** → Select "Labour Count"
4. **Look for time picker section** at the top of the form

### Step 3: Change Date to January 26, 2026

**CRITICAL: You must tap the date button and change it!**

1. **Tap the LEFT button** (shows current date like "Jan 27, 2026")
2. **Date picker opens** → Navigate to January 2026
3. **Select day 26** (should be Monday)
4. **Tap OK/Confirm**
5. **Verify button now shows "Jan 26, 2026"**

### Step 4: Verify Selection Display

At the bottom of time picker section, you should see:
```
Selected: Jan 26, 2026 at [time] • Tap to change
```

**🚨 If this text doesn't change from Jan 27 to Jan 26, the time picker is not working!**

### Step 5: Submit Entry

1. **Add labour counts** (e.g., Mason: 3, Carpenter: 2)
2. **Tap "Submit Labour Count"**
3. **Should see success message**

### Step 6: Check History

1. **Go to History screen**
2. **Look for "Monday, Jan 26, 2026" section**
3. **Expand it** → Should show your entries with correct time

### Step 7: Verify in Database

```bash
cd django-backend
python check_jan_26_entries.py
```

Should show entries for January 26, 2026.

## Expected Console Output

Watch Flutter console for these debug messages:

```
🕒 [LABOUR] Initialized with local time: 2026-01-27 13:48:00.000
🕒 [LABOUR] Date changed to: 2026-01-26 13:48:00.000  ← This confirms date picker worked
🕒 [LABOUR] About to submit with selected time: 2026-01-26 14:00:00.000
```

## If Still Not Working

### Problem: Date picker doesn't open
- **Solution**: Hot restart again, check for compilation errors

### Problem: Date picker opens but selection doesn't update
- **Solution**: Check console logs, ensure you're tapping OK/Confirm

### Problem: UI updates but entries still created with wrong date
- **Solution**: Check submission logs, verify customDateTime is being passed

## Quick Test Commands

**Check if entries were created:**
```bash
cd django-backend
python check_jan_26_entries.py
```

**Check recent entries:**
```bash
cd django-backend
python check_recent_entries.py
```

## Status: Ready to Test

The time picker implementation is complete. Follow the steps above to test it properly.

**Key Point**: You MUST change the date using the time picker. The default date is today (Jan 27, 2026). To create entries for Jan 26, 2026, you must actively select that date using the date picker button.