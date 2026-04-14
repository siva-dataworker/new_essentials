# How to See Flutter Logs on Mobile

## Option 1: Check Your Computer Terminal (Easiest)

When you ran the app on your phone, you used a command like:
```bash
flutter run
```

The **terminal/command prompt window** where you ran this command shows all the logs!

**Look for that window on your computer** - it should show:
- App startup messages
- "Launching lib\main.dart on moto g45 5G..."
- And then continuous logs as you use the app

**The logs I added will appear there** with emojis like:
- 🔍 [SUBMIT] Submitting labour...
- 📊 [SUBMIT] Response status: 201
- ✅ [SUBMIT] Labour submitted successfully!

## Option 2: Use Android Studio / VS Code

If you're using an IDE:

### Android Studio:
1. Look at the bottom of the screen
2. Find the "Run" or "Logcat" tab
3. Logs appear there

### VS Code:
1. Look at the "Debug Console" panel at the bottom
2. Logs appear there while app is running

## Option 3: Use ADB Logcat (Advanced)

If you can't find the terminal:
```bash
adb logcat | findstr "flutter"
```

This shows Flutter logs in real-time.

## What to Look For

When you submit labour data, you should see:
```
🔍 [SUBMIT] Submitting labour: Carpenter = 2
🔍 [SUBMIT] Site ID: <some-uuid>
📊 [SUBMIT] Response status: 201
✅ [SUBMIT] Labour submitted successfully!
```

When you check history, you should see:
```
🔍 [HISTORY] Calling supervisor history API...
📊 [HISTORY] Response status: 200
✅ [HISTORY] Labour entries: 1
```

## If You Still Can't See Logs

Let me know and I'll create an on-screen debug panel that shows the information directly in the app!
