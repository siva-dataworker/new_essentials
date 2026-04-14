# 🔴 CRITICAL: Backend Running on Wrong Address!

## The Problem
Your backend is running on `127.0.0.1:8000` (localhost only).
Your phone **CANNOT** connect to localhost - it needs `0.0.0.0:8000`.

## Current Status
```
TCP    127.0.0.1:8000    LISTENING  ❌ Wrong! Phone can't access this
```

## What You Need
```
TCP    0.0.0.0:8000      LISTENING  ✅ Correct! Phone can access this
```

---

## 🚀 Fix Now (2 Steps)

### Step 1: Stop Current Backend
Press `Ctrl+C` in the terminal where backend is running.

### Step 2: Start Backend Correctly
```bash
cd django-backend
python manage.py runserver 0.0.0.0:8000
```

**IMPORTANT**: Must include `0.0.0.0:8000` - don't just run `python manage.py runserver`!

---

## ✅ Verify It's Working

After starting, you should see:
```
Starting development server at http://0.0.0.0:8000/
```

NOT:
```
Starting development server at http://127.0.0.1:8000/  ❌ Wrong!
```

---

## 🧪 Test from Phone

1. Open browser on your phone
2. Go to: `http://192.168.1.7:8000/api/health/`
3. Should see: `{"status": "ok"}`

If you can't access it, check:
- [ ] Backend running on `0.0.0.0:8000`?
- [ ] Windows Firewall allows Python?
- [ ] Phone and computer on same WiFi?

---

## 📋 Quick Commands

### Stop Backend
Press `Ctrl+C` in terminal

### Start Backend Correctly
```bash
cd django-backend
python manage.py runserver 0.0.0.0:8000
```

### Or Use Batch File
```bash
cd django-backend
run_for_phone.bat
```

---

**Next**: Stop backend → Restart with `0.0.0.0:8000` → Test from phone browser → Restart app
