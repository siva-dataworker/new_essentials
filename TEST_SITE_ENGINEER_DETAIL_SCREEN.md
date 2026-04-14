# Test Site Engineer Detail Screen

## Quick Test Guide

### 1. Hot Restart
```
Press R in Flutter terminal
```

### 2. Login
- Username: `siteengineer1`
- Password: `password123`

### 3. Test Flow

#### Step 1: Dashboard
- ✅ See site cards
- ✅ Each card shows:
  - Site name
  - Location
  - Morning status (🌅)
  - Evening status (🌆)
  - "Tap to enter site" text

#### Step 2: Tap Card
- ✅ Tap any site card
- ✅ Opens site detail screen
- ✅ See 4 tabs at bottom:
  - 📸 Photos
  - ⚠️ Complaints
  - 📁 Project Files
  - 💰 Extra Cost

#### Step 3: Photos Tab (Default)
- ✅ See site info card
- ✅ "Upload Photo" button (blue)
- ✅ "View Gallery" button (outlined)
- ✅ Guidelines card with:
  - 🌅 Morning instructions
  - 🌆 Evening instructions
  - 📸 Quality tips

#### Step 4: Upload Photo
1. Tap "Upload Photo"
2. Select Morning or Evening
3. Choose camera/gallery
4. Add description
5. Upload
6. Return to detail screen

#### Step 5: View Gallery
1. Tap "View Gallery"
2. See all photos
3. Filter by type
4. Tap for full screen
5. Swipe between photos
6. Pinch to zoom

#### Step 6: Other Tabs
1. Tap "Complaints" tab
   - See "Coming Soon" message
2. Tap "Project Files" tab
   - See "Coming Soon" message
3. Tap "Extra Cost" tab
   - See "Coming Soon" message

#### Step 7: Navigation
- ✅ Switch between tabs
- ✅ Back button returns to dashboard
- ✅ Status updates on dashboard

## Expected UI

### Dashboard Card
```
┌──────────────────────┐
│  [Gradient Header]   │
│  [Camera Icon]       │
│  [Active Badge]      │
├──────────────────────┤
│ Sumaya 1 18 Sasikumar│
│ 📍 Area, Street      │
│                      │
│ 🌅 Morning  🌆 Evening│
│ [✅/⏳]     [✅/⏳]   │
│                      │
│ ┌──────────────────┐ │
│ │Tap to enter site→│ │
│ └──────────────────┘ │
└──────────────────────┘
```

### Detail Screen - Photos Tab
```
┌──────────────────────┐
│ ← Sumaya 1 18 Sasikumar│
├──────────────────────┤
│ ┌──────────────────┐ │
│ │ 🏗️ Site Info     │ │
│ │ Name + Location  │ │
│ └──────────────────┘ │
│                      │
│ ┌──────────────────┐ │
│ │ 📸 Upload Photo  │ │
│ └──────────────────┘ │
│                      │
│ ┌──────────────────┐ │
│ │ 📷 View Gallery  │ │
│ └──────────────────┘ │
│                      │
│ ┌──────────────────┐ │
│ │ ℹ️ Guidelines    │ │
│ │ • Morning        │ │
│ │ • Evening        │ │
│ │ • Quality        │ │
│ └──────────────────┘ │
├──────────────────────┤
│ 📸  ⚠️  📁  💰      │
│ Photos Complaints    │
│        Files  Cost   │
└──────────────────────┘
```

### Detail Screen - Other Tabs
```
┌──────────────────────┐
│ ← Site Name          │
├──────────────────────┤
│                      │
│      [Icon]          │
│                      │
│   Tab Name           │
│   Description        │
│                      │
│  ┌────────────────┐  │
│  │  Coming Soon   │  │
│  └────────────────┘  │
│                      │
├──────────────────────┤
│ 📸  ⚠️  📁  💰      │
└──────────────────────┘
```

## Success Criteria

- ✅ Dashboard shows clickable cards
- ✅ Tap card opens detail screen
- ✅ 4 tabs visible in bottom navigation
- ✅ Photos tab fully functional
- ✅ Upload photo works
- ✅ View gallery works
- ✅ Other tabs show coming soon
- ✅ Navigation between tabs smooth
- ✅ Back button works
- ✅ Status updates on dashboard

## Troubleshooting

### Card Not Clickable
- Hot restart app (Press R)
- Check GestureDetector added

### Detail Screen Not Opening
- Check import statement
- Verify navigation code
- Check console for errors

### Bottom Navigation Not Showing
- Check IndexedStack
- Verify BottomNavigationBar
- Check tab count matches

### Photos Not Working
- Backend must be running
- Check image URL fix applied
- Verify token valid

---

**Status:** Ready for testing
**Action:** Hot restart and test
**Time:** 5-10 minutes for full test
