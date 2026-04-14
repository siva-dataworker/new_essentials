# 🔧 Fix Network Connection Error

## ❌ Current Error
```
Network error: ClientException with SocketException: 
Connection timed out (OS Error: Connection timed out, errno = 110), 
address = 192.168.1.7, port = 38188, 
uri=http://192.168.1.7:8000/api/auth/login/
```

## 🔍 Root Cause
The Flutter app is trying to connect to the Django backend at `192.168.1.7:8000`, but:
1. **Backend is NOT running** (process stopped)
2. Backend needs to be started with `0.0.0.0` to accept connections from phone

## 🚀 Quick Fix

### Step 1: Start Backend with Correct Host
The backend must run on `0.0.0.0` (not `127.0.0.1`) to accept connections from your phone.

```bash
cd django-backend
python manage.py runserver 0.0.0.0:8000
```

**Important**: Use `0.0.0.0:8000` NOT `127.0.0.1:8000`

### Step 2: Check Firewall
Make sure Windows Firewall allows Python:
1. Open **Windows Defender Firewall**
2. Click **Allow an app through firewall**
3. Find **Python** and check both **Private** and **Public**
4. If not listed, click **Allow another app** and add Python

### Step 3: Verify Connection
Once backend is running, test from your phone's browser:
- Open browser on phone
- Go to: `http://192.168.1.7:8000/api/health/`
- Should see: `{"status": "ok"}`

### Step 4: Restart Flutter App
- Close the app completely
- Reopen and try logging in

---

## 🔧 Alternative: Update IP Address

If your computer's IP changed, update it in all files:

### Find Your Current IP
```bash
ipconfig
```
Look for **IPv4 Address** under your WiFi/Ethernet adapter.

### Update IP in Flutter App
Edit these files and replace `192.168.1.7` with your new IP:

1. `otp_phone_auth/lib/services/auth_service.dart`
2. `otp_phone_auth/lib/services/backend_service.dart`
3. `otp_phone_auth/lib/services/construction_service.dart`
4. `otp_phone_auth/lib/services/site_engineer_service.dart`
5. `otp_phone_auth/lib/screens/admin_dashboard.dart`
6. `otp_phone_auth/lib/screens/site_photo_gallery_screen.dart`

Then rebuild the app:
```bash
cd otp_phone_auth
flutter run
```

---

## 📋 Checklist

- [ ] Backend running on `0.0.0.0:8000` (not 127.0.0.1)
- [ ] Windows Firewall allows Python
- [ ] Phone and computer on same WiFi network
- [ ] Can access `http://192.168.1.7:8000/api/health/` from phone browser
- [ ] Flutter app restarted

---

## 🆘 Troubleshooting

### Backend won't start?
**Problem**: Database connection error
**Solution**: Read `FIX_DATABASE_CONNECTION.md` first

### Still can't connect?
**Check**:
1. Phone and computer on same WiFi?
2. Computer IP is `192.168.1.7`? (run `ipconfig`)
3. Backend running on `0.0.0.0:8000`? (not 127.0.0.1)
4. Firewall allows Python?
5. Can ping computer from phone?

### Different IP address?
If your IP changed:
1. Find new IP: `ipconfig`
2. Update all 6 files listed above
3. Rebuild Flutter app: `flutter run`

---

## 🎯 Quick Commands

### Start Backend (Correct Way)
```bash
cd django-backend
python manage.py runserver 0.0.0.0:8000
```

### Check Your IP
```bash
ipconfig | findstr "IPv4"
```

### Test from Phone Browser
```
http://192.168.1.7:8000/api/health/
```

---

## ✅ Success Indicators

When working correctly:
- ✅ Backend shows: `Starting development server at http://0.0.0.0:8000/`
- ✅ Phone browser can access: `http://192.168.1.7:8000/api/health/`
- ✅ App login screen loads without error
- ✅ Can login successfully

---

**Next Step**: Start backend with `python manage.py runserver 0.0.0.0:8000`
