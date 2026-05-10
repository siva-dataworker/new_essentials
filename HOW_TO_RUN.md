# How to Run the Application

## 🚀 Quick Start (Easiest Way)

### Option 1: Run Everything at Once
Double-click this file:
```
SETUP_AND_RUN.bat
```

This will:
1. ✅ Create cash_entries table
2. ✅ Verify database setup
3. ✅ Start Django backend
4. ✅ Start Flutter app

**Two windows will open automatically!**

---

## 📋 Manual Start (Step by Step)

### Step 1: Create Database Table (First Time Only)
```bash
cd essential/essential/construction_flutter/django-backend
python create_cash_entries_table.py
```

Expected output:
```
🔧 Creating cash_entries table...
✅ cash_entries table created successfully!
✅ Table verified in database
```

### Step 2: Start Django Backend
**Option A: Use Script**
```bash
Double-click: RUN_DJANGO.bat
```

**Option B: Manual Command**
```bash
cd essential/essential/construction_flutter/django-backend
python manage.py runserver
```

You should see:
```
Starting development server at http://127.0.0.1:8000/
```

### Step 3: Start Flutter App
**Option A: Use Script**
```bash
Double-click: RUN_FLUTTER.bat
```

**Option B: Manual Command**
```bash
cd essential/essential/construction_flutter/otp_phone_auth
flutter run
```

---

## 🔍 Verify Everything is Working

### Check Django Backend
Open browser: http://localhost:8000/admin/
- You should see Django admin page

### Check Flutter App
- App should open automatically
- Login screen should appear

### Check Database
```bash
cd django-backend
python verify_cash_entries_table.py
```

---

## ❌ Troubleshooting

### Django Won't Start

**Error: "No module named 'django'"**
```bash
pip install -r requirements.txt
```

**Error: "Database connection failed"**
1. Check PostgreSQL is running:
   ```bash
   # Windows
   net start postgresql-x64-14
   ```

2. Check `.env` file in `django-backend/`:
   ```
   DATABASE_URL=postgresql://username:password@localhost:5432/dbname
   ```

3. Test connection:
   ```bash
   python -c "from api.database import fetch_one; print('Connected!')"
   ```

### Flutter Won't Start

**Error: "Flutter not found"**
- Install Flutter: https://flutter.dev/docs/get-started/install
- Add to PATH

**Error: "No devices found"**
- Connect Android device via USB
- Or start Android emulator
- Or use Chrome: `flutter run -d chrome`

**Error: "Pub get failed"**
```bash
cd otp_phone_auth
flutter clean
flutter pub get
```

### App Shows ₹0 in Budget Utilization

This is normal! You need to add data:

1. **Login as Supervisor**
2. **Submit labour entries**
3. **Login as Accountant**
4. **Go to Compare tab**
5. **Select and confirm entry**
6. **Login as Admin**
7. **Check Budget Utilization** - should show labour costs now

---

## 📱 Test the Cash Entries Feature

### Complete Test Flow

1. **Start Both Servers**
   ```bash
   Double-click: SETUP_AND_RUN.bat
   ```

2. **Login as Supervisor**
   - Phone: (your supervisor phone)
   - Submit labour entries for today
   - Example: Mason (5), Helper (3)

3. **Login as Accountant**
   - Phone: (your accountant phone)
   - Tap "Compare" tab (bottom navigation)
   - Today's date should be selected
   - You'll see supervisor entries
   - Tap checkbox on entry
   - Tap "Confirm Selection" button
   - ✅ Success message

4. **Login as Admin**
   - Phone: (your admin phone)
   - Go to Budget Management → Budget Utilization
   - Select the site
   - ✅ Labour costs now appear!

---

## 🛑 Stop the Servers

### Stop Django
- Press `Ctrl+C` in Django terminal
- Or close the terminal window

### Stop Flutter
- Press `q` in Flutter terminal
- Or close the terminal window

---

## 📊 Check Data

### View Cash Entries
```bash
cd django-backend
python show_cash_entries.py
```

### View All Data
```bash
python check_utilization_data.py
```

---

## 🔄 Restart After Changes

### After Backend Code Changes
1. Stop Django (`Ctrl+C`)
2. Restart: `python manage.py runserver`

### After Flutter Code Changes
1. Press `r` in Flutter terminal (hot reload)
2. Or press `R` (hot restart)
3. Or stop and restart: `flutter run`

### After Database Changes
1. Run migration script
2. Restart Django
3. Restart Flutter (press `R`)

---

## 📝 Quick Reference

### Important URLs
- Django Backend: http://localhost:8000
- Django Admin: http://localhost:8000/admin/
- API Docs: http://localhost:8000/api/

### Important Scripts
- `SETUP_AND_RUN.bat` - Run everything
- `RUN_DJANGO.bat` - Run Django only
- `RUN_FLUTTER.bat` - Run Flutter only
- `create_cash_entries_table.py` - Create table
- `verify_cash_entries_table.py` - Check table
- `show_cash_entries.py` - View data

### Important Folders
- `django-backend/` - Backend code
- `otp_phone_auth/` - Flutter app code
- `django-backend/api/` - API endpoints

---

## ✅ Success Checklist

- [ ] PostgreSQL is running
- [ ] Django backend starts without errors
- [ ] Flutter app opens
- [ ] Can login to app
- [ ] cash_entries table exists
- [ ] Can submit labour entries (Supervisor)
- [ ] Can confirm entries (Accountant)
- [ ] Budget utilization shows labour costs (Admin)

---

## 🆘 Need Help?

1. Check error messages in terminal
2. Check Django logs
3. Check Flutter logs
4. Review troubleshooting section above
5. Check documentation files:
   - `QUICK_START_CASH_ENTRIES.md`
   - `CASH_ENTRIES_COMPLETE.md`
   - `TASK_COMPLETE_STATUS.md`
