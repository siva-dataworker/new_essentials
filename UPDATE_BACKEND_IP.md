# Update Backend IP Address

## Current Error
```
Network error: Connection timed out
address = 192.168.1.7, port = 41552
url=http://192.168.1.7:8000/api/auth/login/
```

## Solution

### Step 1: Find Your Computer's IP Address

**Windows:**
```cmd
ipconfig
```

Look for "IPv4 Address" under your WiFi or Ethernet adapter.
Example: `192.168.1.5` or `192.168.0.105`

### Step 2: Start Django Backend

```cmd
cd django-backend
python manage.py runserver 0.0.0.0:8000
```

The `0.0.0.0` makes it accessible from your phone/emulator.

### Step 3: Update Flutter App (if IP changed)

If your IP is NOT `192.168.1.7`, you need to update:

**File**: `otp_phone_auth/lib/services/auth_service.dart`

Change line 11 from:
```dart
static const String baseUrl = 'http://192.168.1.7:8000/api';
```

To your actual IP:
```dart
static const String baseUrl = 'http://YOUR_IP_HERE:8000/api';
```

For example, if your IP is `192.168.1.5`:
```dart
static const String baseUrl = 'http://192.168.1.5:8000/api';
```

### Step 4: Hot Restart Flutter

After changing the IP, press **R** (capital R) in the Flutter terminal to hot restart.

---

## Quick Test

### Option 1: Use Localhost (if using emulator)

If you're using Android Emulator (not physical device):

```dart
static const String baseUrl = 'http://10.0.2.2:8000/api';
```

`10.0.2.2` is the special IP that Android Emulator uses to access the host machine's localhost.

### Option 2: Use Your Computer's IP (if using physical device)

Find your IP with `ipconfig` and use that.

---

## Verify Backend is Running

Open browser and visit:
```
http://YOUR_IP:8000/api/health/
```

Should see:
```json
{"status": "healthy"}
```

If you can't access it, check:
1. Backend server is running
2. Firewall allows port 8000
3. Phone and computer are on same WiFi network

---

## Summary

✅ **Find IP**: Run `ipconfig`
✅ **Start Backend**: `python manage.py runserver 0.0.0.0:8000`
✅ **Update Flutter**: Change IP in `auth_service.dart` if needed
✅ **Hot Restart**: Press R in Flutter terminal
✅ **Test**: Try logging in again

The connection timeout means the backend isn't reachable at that IP address.
