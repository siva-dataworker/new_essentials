# Quick Start - Cash Entries System

## 🚀 Get Started in 3 Steps

### Step 1: Create the Database Table (1 minute)
```bash
cd essential/essential/construction_flutter/django-backend
python create_cash_entries_table.py
```

✅ You should see: "cash_entries table created successfully!"

### Step 2: Start the Servers (1 minute)
```bash
# Terminal 1 - Backend
cd django-backend
python manage.py runserver

# Terminal 2 - Flutter
cd otp_phone_auth
flutter run
```

### Step 3: Test the Feature (5 minutes)

#### A. Test Confirm Entry
1. **Login as Supervisor**
   - Submit labour entries for today
   - Example: Mason (5), Helper (3)

2. **Login as Accountant**
   - Tap "Compare" tab (bottom navigation)
   - Today's date should be selected
   - You'll see supervisor entries in green cards
   - Tap checkbox on the entry
   - Tap "Confirm Selection" button at bottom
   - ✅ Success message appears

3. **Login as Admin**
   - Go to Budget Management → Budget Utilization
   - Select the site
   - ✅ Labour costs now appear in the breakdown

#### B. Test Custom Entry
1. **Login as Accountant**
   - Tap "Compare" tab
   - Tap "+" button (top right)
   - Fill the form:
     - Select site
     - Select date
     - Select labour type (e.g., "Electrician")
     - Enter count (e.g., 2)
     - Daily rate auto-fills (e.g., ₹750)
     - Add notes (optional)
   - Tap "Create"
   - ✅ Success message appears

2. **Login as Admin**
   - Check Budget Utilization
   - ✅ Custom entry appears in labour costs

## 📊 What You'll See

### Accountant Compare Screen
```
┌─────────────────────────────────────┐
│  Compare Entries          📅 🔄 ➕  │
├─────────────────────────────────────┤
│  📅 Friday, May 8, 2026             │
│  📍 Site: [All Sites ▼]             │
├─────────────────────────────────────┤
│  Supervisor Entries (2)             │
│  ┌───────────────────────────────┐  │
│  │ ☑ Customer Name Site Name     │  │
│  │   By: John Doe                │  │
│  │   ▼ Labour Details            │  │
│  │     • Mason: 5                │  │
│  │     • Helper: 3               │  │
│  └───────────────────────────────┘  │
│                                     │
│  Site Engineer Entries (1)          │
│  ┌───────────────────────────────┐  │
│  │ ☐ Another Site                │  │
│  │   By: Jane Smith              │  │
│  └───────────────────────────────┘  │
├─────────────────────────────────────┤
│  [Confirm Selection]                │
└─────────────────────────────────────┘
```

### Admin Budget Utilization
```
┌─────────────────────────────────────┐
│  Budget Utilization                 │
├─────────────────────────────────────┤
│  Total Budget: ₹500,000             │
│  Total Spent: ₹45,000               │
│  Remaining: ₹455,000                │
├─────────────────────────────────────┤
│  Labour Breakdown                   │
│  • Mason: ₹4,000 (5 × ₹800)        │
│  • Helper: ₹1,500 (3 × ₹500)       │
│  • Electrician: ₹1,500 (2 × ₹750)  │
└─────────────────────────────────────┘
```

## 🔍 Verify It's Working

### Check Database
```bash
python show_cash_entries.py
```

You should see:
- Table structure
- Number of entries
- Sample data

### Check Backend Logs
Look for these messages:
```
🔍 [CASH ENTRY] Confirming entry - site: xxx, date: 2026-05-08
✅ [CASH ENTRY] Created 2 cash entries
```

### Check Flutter Logs
Look for these messages:
```
📊 [COMPARE] Supervisor data: 1 sites
✅ [SERVICE] Parsed 1 items
```

## ❌ Troubleshooting

### "Cash entry already exists"
- This is expected! Only one entry per site per day
- Solution: Choose a different date or delete existing entry

### "No entries found"
- Make sure supervisor/engineer submitted entries for selected date
- Check backend logs for SQL errors
- Verify `submitted_by_role` column exists in labour_entries table

### Budget utilization shows no labour costs
- Verify cash_entries table has data: `python show_cash_entries.py`
- Check that site_id matches between tables
- Restart backend server

### Cannot create table
- Make sure PostgreSQL is running
- Check DATABASE_URL in .env file
- Verify you have CREATE TABLE permissions

## 📚 More Information

- **Complete Guide:** See `CASH_ENTRIES_COMPLETE.md`
- **Setup Details:** See `django-backend/SETUP_CASH_ENTRIES.md`
- **Implementation:** See `IMPLEMENTATION_SUMMARY.md`

## ✅ Success Criteria

You'll know it's working when:
1. ✅ Accountant can see supervisor/engineer entries
2. ✅ Accountant can select and confirm entries
3. ✅ Accountant can create custom entries
4. ✅ Admin sees labour costs in budget utilization
5. ✅ Duplicate entries are prevented

## 🎉 You're Done!

The cash entries system is now fully functional. Accountants can confirm labour entries, and admins can see the actual cash expenditure in budget utilization.

**Next:** Test with real data and deploy to production!
