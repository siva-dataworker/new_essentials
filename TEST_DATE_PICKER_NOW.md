# Test Date Picker Feature - Quick Guide

## How to Test

### 1. Start Backend
```bash
cd django-backend
python manage.py runserver
```

### 2. Run Flutter App
```bash
cd otp_phone_auth
flutter run
```

### 3. Test Steps

1. **Login as Supervisor**
   - Use any supervisor account from ALL_USERS_AND_PASSWORDS.md

2. **Open a Site**
   - From dashboard, click on any site card
   - Click "View Details" button

3. **Test Date Picker**
   - Look for calendar icon (📅) in the app bar
   - Click the calendar icon
   - Date picker dialog will appear

4. **Select Different Dates**
   - Try selecting today → Should show "Today's Entries"
   - Try selecting yesterday → Should show "Entries for [date]"
   - Try selecting a date from last week
   - Try selecting a date with no data → Should show "No entries for this date"

5. **Verify Data Loading**
   - Each date selection should reload the entries
   - Labour and material entries should display correctly
   - Extra costs should be visible if present

## What to Look For

✅ Calendar icon appears in app bar next to history icon
✅ Date picker opens when clicking calendar icon
✅ Selected date displays in header (e.g., "Jan 29" or "Today")
✅ Entries reload when date changes
✅ Empty state shows appropriate message for past dates
✅ Date picker uses navy blue theme matching the app

## Expected Behavior

- **Today**: Shows "Today's Entries" with calendar showing current date
- **Yesterday**: Shows "Yesterday" in date button
- **Other dates**: Shows "Jan 29" format in date button
- **No data**: Shows "No entries for this date" message

## Troubleshooting

If entries don't load:
1. Check backend is running on http://192.168.1.7:8000
2. Check network connectivity
3. Look at Flutter console for API errors
4. Verify date format in API call (should be YYYY-MM-DD)

If date picker doesn't open:
1. Check for any Flutter errors in console
2. Verify calendar icon is visible in app bar
3. Try hot restart: `r` in Flutter console

## Sample Test Data

If you need to add test data for a specific date:
1. Go to site detail screen
2. Select the date you want to test
3. Click the + button to add labour/materials
4. Submit entries
5. They will be saved for that date
6. Navigate away and back to verify they load correctly
