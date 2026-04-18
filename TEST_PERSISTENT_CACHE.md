# How to Test Persistent Cache

**Quick guide to verify persistent caching is working**

---

## 🧪 Test 1: Notifications Persistent Cache

### Steps:
1. Open the app
2. Login as Admin
3. Click on **Notifications** tab
4. Wait for notifications to load (1-2 seconds)
5. You should see: "✅ [NOTIFICATIONS] Loaded X notifications and saved to cache" in console
6. **Close the app completely** (swipe away from recent apps)
7. **Reopen the app**
8. Login as Admin
9. Click on **Notifications** tab
10. **Result:** Notifications should appear INSTANTLY (0ms)
11. Check console: "✅ [NOTIFICATIONS] Loaded X from persistent cache"
12. Wait 30 seconds
13. **Result:** New data loads silently in background (no spinner)

### Expected Behavior:
- ✅ First open: 1-2 second load
- ✅ App restart: Instant display (0ms)
- ✅ Background refresh: Silent update every 30s
- ✅ No loading spinner on reopen

---

## 🧪 Test 2: Client Issues Persistent Cache

### Steps:
1. Open the app
2. Login as Admin
3. Click on **Issues** tab
4. Wait for issues to load (1-2 seconds)
5. You should see: "✅ [ADMIN] Loaded X complaints and saved to cache" in console
6. **Close the app completely**
7. **Reopen the app**
8. Login as Admin
9. Click on **Issues** tab
10. **Result:** Issues should appear INSTANTLY (0ms)
11. Check console: "✅ [ADMIN] Loaded X complaints from persistent cache"

### Expected Behavior:
- ✅ First open: 1-2 second load
- ✅ App restart: Instant display (0ms)
- ✅ Background refresh: Silent update every 60s

---

## 🧪 Test 3: Budget Persistent Cache

### Steps:
1. Open the app
2. Login as Admin
3. Click on **Sites** tab
4. Select an area and street
5. Click on a site's **Budget Management**
6. Wait for budget data to load (1-2 seconds)
7. You should see: "✅ [BUDGET] Loaded allocation from API and saved to cache" in console
8. Click on **Utilization** tab
9. Wait for utilization to load
10. **Close the app completely**
11. **Reopen the app**
12. Navigate back to the same site's Budget Management
13. **Result:** Budget data should appear INSTANTLY (0ms)
14. Check console: "✅ [BUDGET] Loaded allocation from persistent cache"

### Expected Behavior:
- ✅ First open: 1-2 second load
- ✅ App restart: Instant display (0ms)
- ✅ Background refresh: Silent update every 90s

---

## 🧪 Test 4: Offline Mode

### Steps:
1. Open the app with internet connection
2. Login as Admin
3. Load Notifications, Issues, and Budget data
4. **Turn off WiFi/Mobile data**
5. **Close the app completely**
6. **Reopen the app** (still offline)
7. Login as Admin
8. Navigate to Notifications, Issues, Budget
9. **Result:** Should see all cached data even without internet

### Expected Behavior:
- ✅ Cached data displays offline
- ✅ No error messages
- ✅ Smooth navigation
- ✅ Data from last online session

---

## 🧪 Test 5: Background Refresh

### Steps:
1. Open the app
2. Login as Admin
3. Go to **Notifications** tab
4. Wait for data to load
5. **Keep the app open**
6. **Stay on Notifications tab**
7. **Wait 30 seconds**
8. **Result:** Console shows background refresh
9. If there's new data, it appears without spinner

### Expected Behavior:
- ✅ Timer triggers every 30s
- ✅ No loading spinner
- ✅ Data updates silently
- ✅ UI updates smoothly

---

## 🧪 Test 6: Cache Expiry

### Steps:
1. Open the app
2. Load some data
3. **Wait 24 hours** (or modify cache expiry in code for testing)
4. Reopen the app
5. **Result:** Cache expired, loads from API

### Expected Behavior:
- ✅ Old cache auto-deleted
- ✅ Fresh data loaded from API
- ✅ New cache created

---

## 🧪 Test 7: Multiple Tab Switches

### Steps:
1. Open the app
2. Login as Admin
3. Click **Notifications** → Wait for load
4. Click **Sites** → Instant
5. Click **Issues** → Wait for load
6. Click **Notifications** → Instant (from memory cache)
7. **Close app**
8. **Reopen app**
9. Click **Notifications** → Instant (from persistent cache)
10. Click **Issues** → Instant (from persistent cache)

### Expected Behavior:
- ✅ First visit: Loads from API
- ✅ Revisit (same session): Instant from memory
- ✅ After restart: Instant from persistent cache

---

## 📊 Console Messages to Look For

### On First Load:
```
🔍 [NOTIFICATIONS] Loading notifications from API...
✅ [NOTIFICATIONS] Loaded 5 notifications and saved to cache
```

### On App Restart:
```
✅ [NOTIFICATIONS] Loaded 5 from persistent cache
🔍 [NOTIFICATIONS] Loading notifications from API...
✅ [NOTIFICATIONS] Loaded 6 notifications and saved to cache
```

### On Background Refresh:
```
🔍 [NOTIFICATIONS] Loading notifications from API...
✅ [NOTIFICATIONS] Loaded 7 notifications and saved to cache
```

---

## ✅ Success Criteria

### All tests should show:
- ✅ Instant display on app restart (0ms)
- ✅ No loading spinner on cached data
- ✅ Background refresh works silently
- ✅ Offline mode shows cached data
- ✅ Console logs confirm cache usage
- ✅ UI updates smoothly

---

## 🐛 Troubleshooting

### If cache doesn't work:

1. **Check console logs** - Should see cache messages
2. **Clear app data** - Reset and try again
3. **Check internet** - First load needs internet
4. **Wait for load** - Must complete first load to cache
5. **Check device storage** - Ensure space available

### Common Issues:

**Issue:** Data not showing on restart  
**Solution:** Ensure first load completed successfully

**Issue:** Background refresh not working  
**Solution:** Stay on the tab, timer only runs when active

**Issue:** Cache not clearing  
**Solution:** 24-hour expiry is automatic, or clear manually

---

## 🎯 Quick Verification

### Fastest way to test:

1. Open app → Load Notifications
2. Close app completely
3. Reopen app → Go to Notifications
4. **Should be INSTANT** ✅

If instant = Cache working! 🎉

---

## 📝 Notes

- Cache survives app restarts
- Cache expires after 24 hours
- Background refresh updates cache
- Works offline with cached data
- Separate cache per user
- Separate cache per filter/status

---

**Happy Testing!** 🚀
