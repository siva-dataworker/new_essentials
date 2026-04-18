# How to Test Migrated Admin Screens

**Date:** April 15, 2026  
**Status:** 6 screens migrated and ready to test

---

## 🚀 Quick Start

### 1. Access the App

The Flutter app is already running in Chrome. If you need the URL:
- **Local URL:** http://localhost:PORT (check Flutter terminal for exact port)
- **Backend:** http://192.168.1.11:8000

### 2. Login as Admin

1. Open the app in Chrome
2. Login with admin credentials
3. You'll land on the Admin Dashboard

---

## 📱 Migrated Screens to Test

### Screen 1: Sites Test Screen ✅
**Path:** Admin Dashboard → Sites Tab → "Sites Test" button (if available)

**What to test:**
- Sites list loads automatically from provider
- Pull down to refresh
- Click refresh button in AppBar
- Check if data loads without errors

**Expected behavior:**
- Sites load from AdminProvider cache
- No duplicate API calls
- Smooth refresh experience

---

### Screen 2: Bills View Screen ✅
**Path:** Admin Dashboard → Navigate to Bills View

**What to test:**
1. Select a site from dropdown
2. Bills should load automatically
3. Pull down to refresh bills
4. Click refresh button in AppBar
5. Switch between different sites

**Expected behavior:**
- Site dropdown populated from provider
- Bills load when site selected
- Cached data shows instantly on revisit
- Pull-to-refresh works smoothly

---

### Screen 3: Material Purchases Screen ✅
**Path:** Admin Dashboard → Navigate to Material Purchases (pass siteId)

**What to test:**
1. Screen loads with material purchases for the site
2. Pull down to refresh
3. Click refresh button in AppBar

**Expected behavior:**
- Material purchases load from provider
- Cached data available
- Refresh updates data

---

### Screen 4: Labour Count Screen ✅
**Path:** Admin Dashboard → Navigate to Labour Count

**What to test:**
1. Select a site from dropdown
2. Labour count data loads
3. Pull down to refresh
4. Click refresh button in AppBar
5. Switch between sites

**Expected behavior:**
- Sites dropdown works
- Labour data loads per site
- Cached data shows on revisit
- Smooth refresh

---

### Screen 5: Site Documents Screen ✅
**Path:** Admin Dashboard → Site Full View → Documents Tab
OR Navigate directly with siteId and siteName

**What to test:**
1. Screen loads with document tabs (Plans, Elevations, Structure, Final Output)
2. Click different document type tabs
3. Pull down to refresh documents
4. Click refresh button in AppBar

**Expected behavior:**
- All document types load from provider
- Tab switching is instant (cached)
- Refresh updates all document types
- Document counts show correctly

---

### Screen 6: Site Comparison Screen ✅
**Path:** Admin Dashboard → Navigate to Site Comparison

**What to test:**
1. Select Site 1 from dropdown
2. Select Site 2 from dropdown
3. Click "Compare" button
4. View comparison results
5. Pull down to refresh comparison
6. Click refresh button in AppBar
7. Try comparing different sites

**Expected behavior:**
- Both dropdowns populated from provider
- Comparison loads on button click
- Results show side-by-side metrics
- Refresh updates comparison
- Can't compare same site with itself

---

## 🔍 What to Look For

### ✅ Good Signs:
- No console errors
- Data loads quickly
- Pull-to-refresh works smoothly
- Refresh button updates data
- Switching between screens is fast (cached data)
- No duplicate API calls in network tab

### ❌ Issues to Report:
- Console errors
- Data not loading
- Refresh not working
- Slow performance
- Duplicate API calls
- UI glitches

---

## 🛠️ Testing Checklist

For each screen, verify:

- [ ] Screen loads without errors
- [ ] Data displays correctly
- [ ] Pull-to-refresh works
- [ ] Refresh button works
- [ ] Loading indicators show/hide properly
- [ ] Empty states show when no data
- [ ] Provider caching works (fast on revisit)
- [ ] No console errors
- [ ] UI looks good

---

## 📊 Provider Benefits to Observe

### 1. Smart Caching
- First visit: Data loads from API
- Second visit: Data shows instantly from cache
- Manual refresh: Updates cache with fresh data

### 2. Reduced API Calls
- Open Network tab in Chrome DevTools
- Navigate between screens
- Should see fewer API calls than before

### 3. Consistent State
- Data synced across screens
- Changes in one screen reflect in others

---

## 🐛 Debugging

### If screens don't load:

1. **Check Backend:**
   ```bash
   # Backend should be running on http://192.168.1.11:8000
   # Check terminal ID 2
   ```

2. **Check Flutter:**
   ```bash
   # Flutter should be running in Chrome
   # Check terminal ID 11
   ```

3. **Check Console:**
   - Open Chrome DevTools (F12)
   - Look for errors in Console tab
   - Check Network tab for failed requests

4. **Check IP Address:**
   - All services should use 192.168.1.11:8000
   - If you see 192.168.1.9, that's the old IP

---

## 📝 Navigation Flow

```
Login Screen
    ↓
Admin Dashboard
    ↓
    ├─→ Sites Tab → Sites Test Screen ✅
    ├─→ Bills View Screen ✅
    ├─→ Material Purchases Screen ✅
    ├─→ Labour Count Screen ✅
    ├─→ Site Documents Screen ✅
    └─→ Site Comparison Screen ✅
```

---

## 🎯 Key Features to Test

### Pull-to-Refresh
1. Scroll to top of list
2. Pull down
3. Release
4. Watch loading indicator
5. Data should refresh

### Refresh Button
1. Look for refresh icon in AppBar (top right)
2. Click it
3. Data should reload

### Provider Caching
1. Visit a screen (loads from API)
2. Go back
3. Visit same screen again (loads from cache - instant)
4. Pull to refresh (updates cache)

---

## 💡 Tips

1. **Open Chrome DevTools** to see console logs and network requests
2. **Test with real data** - make sure backend has some test data
3. **Try edge cases** - empty lists, no sites, etc.
4. **Test refresh multiple times** to verify caching works
5. **Switch between screens** to see provider state management

---

## 📞 Need Help?

If you encounter issues:
1. Check console for errors
2. Verify backend is running (http://192.168.1.11:8000)
3. Verify Flutter is running in Chrome
4. Check network tab for failed API calls
5. Report specific error messages

---

## ✅ Success Criteria

All 6 migrated screens should:
- Load without errors
- Display data correctly
- Support pull-to-refresh
- Have working refresh buttons
- Use provider caching
- Show proper loading states
- Handle empty states gracefully

---

**Last Updated:** April 15, 2026  
**Migrated Screens:** 6 of 13 (46%)  
**Status:** Ready for testing

