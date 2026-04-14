# Time Picker Testing Guide - Step by Step

## Issue Summary
User wants to add labour and material entries for **January 26, 2026** (Rahman site) but the time picker is not working properly.

## Current Status
- ✅ Backend correctly processes custom datetime
- ✅ Time picker UI exists with proper debug logging
- ✅ History screen displays entries by day + date
- ❌ No entries found for January 26, 2026 (user's test failed)

## Step-by-Step Testing Instructions

### Step 1: Start the Backend
```bash
cd django-backend
python manage.py runserver 0.0.0.0:8000
```

### Step 2: Open Flutter App
1. Open the Flutter app on your device/emulator
2. Login as Supervisor
3. Navigate to Rahman site (or any site)

### Step 3: Open Labour Entry Form
1. Tap the **+ (Plus)** button at the bottom
2. Select **"Labour Count"** from the quick actions menu
3. You should see the labour entry form with time picker at the top

### Step 4: Test Time Picker - Date Selection
1. **Look for the time picker section** (should be near the top of the form)
2. **Tap the LEFT button** (date button) - should show current date like "Jan 27, 2026"
3. **Date picker should open** - navigate to January 2026
4. **Select day 26** (should be Monday)
5. **Tap OK/Confirm**
6. **Check the display** - should now show "Jan 26, 2026"

### Step 5: Test Time Picker - Time Selection  
1. **Tap the RIGHT button** (time button) - should show current time
2. **Time picker should open** 
3. **Select 2:00 PM** (or any desired time)
4. **Tap OK/Confirm**
5. **Check the display** - should now show "2:00 PM"

### Step 6: Verify Selection Display
At the bottom of the time picker section, you should see:
```
Selected: Jan 26, 2026 at 2:00 PM • Tap to change
```

**🚨 CRITICAL: If this text doesn't update, the time picker is not working!**

### Step 7: Check Console Logs
Open Flutter console/logs and look for these messages:
```
🕒 [LABOUR] Initialized with local time: 2026-01-27 13:48:00.000
🕒 [LABOUR] Date changed to: 2026-01-26 13:48:00.000
🕒 [LABOUR] Time changed to: 2026-01-26 14:00:00.000
```

**🚨 If you don't see these logs, the time picker callbacks are not firing!**

### Step 8: Submit Entry
1. **Add some labour counts** (e.g., Mason: 3, Carpenter: 2)
2. **Tap "Submit Labour Count"**
3. **Check console for submission logs:**
```
🕒 [LABOUR] About to submit with selected time: 2026-01-26 14:00:00.000
🔍 [SUBMIT] Custom DateTime: 2026-01-26 14:00:00.000
```

### Step 9: Verify in History
1. **Go to History screen** (tap History button or menu)
2. **Look for "Monday, Jan 26, 2026" section**
3. **Expand the section** - should show your entries
4. **Check the time** - should show "2:00 PM"

### Step 10: Verify in Database
```bash
cd django-backend
python check_jan_26_entries.py
```

Should show:
```
📊 LABOUR ENTRIES FOR JAN 26, 2026: 1
  - Mason: 3 workers
    Date: 2026-01-26, Time: 2026-01-26 14:00:00+05:30
    Day: Monday
```

## Troubleshooting

### Problem 1: Time Picker Buttons Don't Respond
**Symptoms:** Tapping date/time buttons does nothing
**Solution:** 
- Hot restart the app: `flutter hot restart`
- Check for any compilation errors
- Verify the buttons are properly wrapped in InkWell/GestureDetector

### Problem 2: Date/Time Pickers Open But Selection Doesn't Update
**Symptoms:** Pickers open, you select date/time, but display doesn't change
**Solution:**
- Check console logs for "Date changed to" or "Time changed to" messages
- If missing, the setState() calls are not working
- Verify the _selectedDateTime variable is being updated

### Problem 3: Display Updates But Submission Uses Wrong Time
**Symptoms:** UI shows correct date/time but entries are created with current time
**Solution:**
- Check submission logs for "About to submit with selected time"
- Verify customDateTime parameter is being passed to API
- Check backend logs for custom datetime processing

### Problem 4: Entries Created But Don't Appear in History
**Symptoms:** Submission succeeds but history is empty
**Solution:**
- Refresh history screen (pull down to refresh)
- Check if entries are created for different site
- Verify site_id matches between submission and history

## Expected Console Output (Full Flow)

```
🕒 [LABOUR] Initialized with local time: 2026-01-27 13:48:00.000
🕒 [LABOUR] Date changed to: 2026-01-26 13:48:00.000
🕒 [LABOUR] Time changed to: 2026-01-26 14:00:00.000
🕒 [LABOUR] About to submit with selected time: 2026-01-26 14:00:00.000
🔍 [SUBMIT] Submitting labour: Mason = 3
🔍 [SUBMIT] Site ID: [site-id]
🔍 [SUBMIT] Custom DateTime: 2026-01-26 14:00:00.000
```

## Quick Test Commands

**Check recent entries:**
```bash
cd django-backend
python check_recent_entries.py
```

**Check Jan 26 entries:**
```bash
cd django-backend
python check_jan_26_entries.py
```

**Test backend parsing:**
```bash
cd django-backend
python test_jan_26_submission.py
```

## Status: Ready for User Testing

The time picker implementation is complete with comprehensive logging. Follow the step-by-step guide above to test the functionality and identify where the issue occurs.

**If the time picker still doesn't work after following these steps, the issue is likely in the Flutter UI event handling or state management.**