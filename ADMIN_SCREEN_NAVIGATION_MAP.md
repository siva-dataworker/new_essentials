# Admin Screen Navigation Map

## 🗺️ How to Find and Test Each Migrated Screen

---

## Starting Point: Admin Dashboard

After logging in as Admin, you land on the **Admin Dashboard**. From here, you can access all the migrated screens.

---

## 📱 Navigation Paths

### 1. Bills View Screen ✅ MIGRATED
```
Admin Dashboard
    └─→ Look for "Bills" button/tab
        └─→ Click it
            └─→ Bills View Screen opens
                ├─→ Select site from dropdown
                ├─→ View bills for that site
                ├─→ Pull down to refresh
                └─→ Click 🔄 to refresh
```

**Alternative paths:**
- Admin Dashboard → Sites Tab → Select Site → View Bills
- Admin Dashboard → Bottom navigation → Bills section

---

### 2. Labour Count Screen ✅ MIGRATED
```
Admin Dashboard
    └─→ Look for "Labour Count" button/tab
        └─→ Click it
            └─→ Labour Count Screen opens
                ├─→ Select site from dropdown
                ├─→ View labour data
                ├─→ Pull down to refresh
                └─→ Click 🔄 to refresh
```

**What you'll see:**
- Dropdown to select site
- List of labour entries with:
  - Date
  - Worker count
  - Entered by (username)

---

### 3. Material Purchases Screen ✅ MIGRATED
```
Admin Dashboard
    └─→ Navigate to specific site
        └─→ Look for "Material Purchases" or "Materials" tab
            └─→ Click it
                └─→ Material Purchases Screen opens
                    ├─→ View material purchases for that site
                    ├─→ Pull down to refresh
                    └─→ Click 🔄 to refresh
```

**Note:** This screen requires a siteId, so you usually access it from within a site's view.

---

### 4. Site Documents Screen ✅ MIGRATED
```
Admin Dashboard
    └─→ Sites Tab/Section
        └─→ Select a site
            └─→ Click "View Details" or "Full View"
                └─→ Look for "Documents" tab
                    └─→ Site Documents Screen opens
                        ├─→ Click tabs: Plans, Elevations, Structure, Final Output
                        ├─→ View documents in each category
                        ├─→ Pull down to refresh
                        └─→ Click 🔄 to refresh
```

**What you'll see:**
- 4 tabs at the top (Plans, Elevations, Structure, Final Output)
- Document count badges on tabs
- List of documents with:
  - Document name
  - Uploaded by
  - Upload date
  - View button (👁️)

---

### 5. Site Comparison Screen ✅ MIGRATED
```
Admin Dashboard
    └─→ Look for "Compare Sites" or "Site Comparison" button
        └─→ Click it
            └─→ Site Comparison Screen opens
                ├─→ Select Site 1 from left dropdown
                ├─→ Select Site 2 from right dropdown
                ├─→ Click "Compare" button
                ├─→ View comparison results
                ├─→ Pull down to refresh
                └─→ Click 🔄 to refresh
```

**What you'll see:**
- Two dropdowns side by side
- Compare button (orange)
- Comparison results showing:
  - Built-up Area (both sites)
  - Project Value (both sites)
  - Total Cost (both sites)
  - Profit/Loss (both sites)
  - Total Labour (both sites)
  - Material Cost (both sites)

---

### 6. Sites Test Screen ✅ MIGRATED
```
Admin Dashboard
    └─→ Sites Tab
        └─→ Look for "Sites Test" or "Test View" button
            └─→ Click it
                └─→ Sites Test Screen opens
                    ├─→ View all sites
                    ├─→ Pull down to refresh
                    └─→ Click 🔄 to refresh
```

**What you'll see:**
- Simple list of all sites
- Site names and basic info

---

## 🎯 Quick Access Tips

### If you can't find a screen:

1. **Check the Admin Dashboard tabs:**
   - Users Tab
   - Sites Tab
   - Reports Tab
   - Settings Tab

2. **Look for these buttons/links:**
   - "Bills View"
   - "Labour Count"
   - "Material Purchases"
   - "Site Documents"
   - "Compare Sites"
   - "Sites Test"

3. **Check the bottom navigation bar** (if present)

4. **Look in the drawer menu** (hamburger icon ☰)

---

## 🔍 Visual Indicators

### Look for these UI elements:

**Refresh Button:**
- Location: Top-right corner of AppBar
- Icon: 🔄 (circular arrow)
- Color: Usually white or dark

**Pull-to-Refresh:**
- Action: Pull down the list from the top
- Indicator: Circular loading spinner appears
- Release to trigger refresh

**Dropdowns:**
- Site selectors with down arrow (▼)
- Click to see list of sites
- Select a site to load data

---

## 📊 Screen Layouts

### Bills View Screen Layout:
```
┌─────────────────────────────────┐
│ ← Bills Viewing            🔄   │ ← AppBar with refresh
├─────────────────────────────────┤
│ Select Site                     │
│ [Choose a site ▼]               │ ← Site dropdown
├─────────────────────────────────┤
│ ┌─────────────────────────────┐ │
│ │ 📄 Material Name            │ │
│ │ Date: 2024-01-15            │ │
│ │ Amount: ₹5,000  [Verified]  │ │
│ └─────────────────────────────┘ │ ← Bill cards
│ ┌─────────────────────────────┐ │
│ │ 📄 Another Material         │ │
│ │ Date: 2024-01-14            │ │
│ │ Amount: ₹3,500  [Pending]   │ │
│ └─────────────────────────────┘ │
└─────────────────────────────────┘
```

### Labour Count Screen Layout:
```
┌─────────────────────────────────┐
│ ← Labour Count View        🔄   │
├─────────────────────────────────┤
│ Select Site                     │
│ [Choose a site ▼]               │
├─────────────────────────────────┤
│ ┌─────────────────────────────┐ │
│ │ 👥 2024-01-15               │ │
│ │ Entered by: John            │ │
│ │                [25 Workers] │ │
│ └─────────────────────────────┘ │
│ ┌─────────────────────────────┐ │
│ │ 👥 2024-01-14               │ │
│ │ Entered by: Jane            │ │
│ │                [30 Workers] │ │
│ └─────────────────────────────┘ │
└─────────────────────────────────┘
```

### Site Comparison Screen Layout:
```
┌─────────────────────────────────┐
│ ← Site Comparison          🔄   │
├─────────────────────────────────┤
│ Site 1          ⇄      Site 2   │
│ [Select ▼]           [Select ▼] │
│        [Compare Button]          │
├─────────────────────────────────┤
│ 📐 Built-up Area                │
│ 1000 sq ft      |    1200 sq ft │
├─────────────────────────────────┤
│ 💰 Project Value                │
│ ₹50L            |    ₹60L       │
├─────────────────────────────────┤
│ 📊 Total Cost                   │
│ ₹45L            |    ₹55L       │
└─────────────────────────────────┘
```

---

## 🎮 Testing Workflow

### Recommended testing order:

1. **Start Simple:** Sites Test Screen
   - Just a list, easy to verify

2. **Test Dropdowns:** Bills View Screen
   - Tests site selection + data loading

3. **Test Similar:** Labour Count Screen
   - Similar to Bills View

4. **Test Tabs:** Site Documents Screen
   - Tests tab switching + multiple data types

5. **Test Complex:** Site Comparison Screen
   - Tests multiple selections + comparison logic

6. **Test Specific:** Material Purchases Screen
   - Tests site-specific data

---

## 💡 Pro Tips

1. **Open Chrome DevTools (F12)** to see:
   - Console logs
   - Network requests
   - Any errors

2. **Test caching:**
   - Visit a screen
   - Go back
   - Visit again (should be instant!)

3. **Test refresh:**
   - Pull down (pull-to-refresh)
   - Click 🔄 (refresh button)
   - Both should reload data

4. **Test edge cases:**
   - Empty lists
   - No sites selected
   - Same site comparison (should error)

---

## 📞 Need Help Finding a Screen?

If you can't locate a screen:

1. Take a screenshot of your Admin Dashboard
2. Share it with me
3. I'll point you to the exact location

Or describe what you see on the Admin Dashboard, and I'll guide you!

---

**Happy Testing!** 🚀

