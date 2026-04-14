# ⚠️ BACKEND RUNNING ON WRONG ADDRESS!

## What's Wrong
```
❌ Backend is on: 127.0.0.1:8000 (localhost only)
✅ Needs to be on: 0.0.0.0:8000 (network accessible)
```

Your phone can't connect to `127.0.0.1` - that's only for your computer!

---

## 🔧 Fix in 30 Seconds

### 1. Stop Backend
In the terminal where backend is running:
- Press `Ctrl+C`

### 2. Restart with Correct Address
```bash
python manage.py runserver 0.0.0.0:8000
```

### 3. Look for This Message
```
Starting development server at http://0.0.0.0:8000/
Quit the server with CTRL-BREAK.
```

If you see `http://127.0.0.1:8000/` instead, you did it wrong!

---

## ✅ Test It Works

### From Your Phone Browser
Open: `http://192.168.1.7:8000/api/health/`

Should see: `{"status": "ok"}`

### Then Restart Your App
- Close app completely
- Reopen
- Try login: `1111111111` / `test123`

---

## 🎯 The Difference

### Wrong Way (Current)
```bash
python manage.py runserver
# Runs on 127.0.0.1:8000 - phone can't connect ❌
```

### Right Way (What You Need)
```bash
python manage.py runserver 0.0.0.0:8000
# Runs on 0.0.0.0:8000 - phone CAN connect ✅
```

---

## 🆘 Still Not Working?

### Can't access from phone browser?
1. Check Windows Firewall allows Python
2. Make sure phone and computer on same WiFi
3. Verify backend shows `0.0.0.0:8000` not `127.0.0.1:8000`

### Backend won't start?
- Database connection error? Fix credentials in `.env` first
- See `FIX_DATABASE_CONNECTION.md`

---

**DO THIS NOW**: 
1. Press `Ctrl+C` to stop backend
2. Run: `python manage.py runserver 0.0.0.0:8000`
3. Test from phone browser
4. Restart app
