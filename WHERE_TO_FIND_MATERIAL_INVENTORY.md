# 📍 Where to Find Material Inventory Features

## FOR SITE ENGINEER

### **Step-by-Step Navigation:**

1. **Login** as Site Engineer
2. You'll see the **Dashboard** (first tab at bottom)
3. **Scroll down** past the "Today's Overview" cards
4. Look for **"Quick Actions"** section
5. You'll see **3 buttons:**
   - View Sites
   - Notifications
   - **Material Inventory** ← THIS ONE!

### **Visual Guide:**
```
┌─────────────────────────────────────┐
│  Site Engineer Dashboard            │
├─────────────────────────────────────┤
│                                     │
│  Welcome, Engineer                  │
│  Site Engineer Dashboard            │
│                                     │
│  Today's Overview                   │
│  [Total Sites] [Morning Photos]    │
│  [Evening Photos] [Pending]         │
│                                     │
│  Quick Actions                      │
│  ┌──────────┐ ┌──────────┐         │
│  │View Sites│ │Notificat.│         │
│  └──────────┘ └──────────┘         │
│  ┌─────────────────────────┐       │
│  │  Material Inventory     │ ← TAP │
│  └─────────────────────────┘       │
│                                     │
└─────────────────────────────────────┘
```

### **What Happens When You Tap:**
- If you have **1 site**: Opens Material Inventory directly
- If you have **multiple sites**: Shows site selection dialog
- If you have **no sites**: Shows error message

---

## FOR SUPERVISOR

### **Step-by-Step Navigation:**

1. **Login** as Supervisor
2. **Select Area** from dropdown
3. **Select Street** from dropdown
4. You'll see **site cards** appear
5. On each site card, look for **3 buttons at the bottom:**
   - [View Details] (white button)
   - [📜] (history icon)
   - [📦] (material icon) ← THIS ONE!

### **Visual Guide:**
```
┌─────────────────────────────────────┐
│  Supervisor Dashboard               │
├─────────────────────────────────────┤
│                                     │
│  Area: [Madipakkam ▼]               │
│  Street: [5th Street ▼]             │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 🏗️ Rahman Site              │   │
│  │ Madipakkam, 5th Street      │   │
│  │                             │   │
│  │ [View Details] [📜] [📦]    │   │
│  │                      ↑   ↑  │   │
│  │                  History │  │   │
│  │                  Material  │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

### **What Happens When You Tap 📦:**
- Opens **Material Usage Dialog**
- Shows list of available materials
- Displays current balance
- Allows recording usage

---

## BUTTON APPEARANCE

### **Site Engineer - Material Inventory Button:**
```
┌─────────────────────────────┐
│  📦 Material Inventory      │
└─────────────────────────────┘
```
- **Color:** White background
- **Border:** Navy blue border
- **Icon:** Inventory icon
- **Text:** "Material Inventory"
- **Size:** Full width button

### **Supervisor - Material Icon Button:**
```
┌────┐
│ 📦 │
└────┘
```
- **Color:** Semi-transparent white
- **Icon:** Inventory/box icon
- **Size:** Small square button
- **Position:** Third button (after View Details and History)

---

## SCREENSHOTS REFERENCE

### **Site Engineer Dashboard - Quick Actions:**
```
╔═══════════════════════════════════╗
║  Quick Actions                    ║
╠═══════════════════════════════════╣
║  ┌──────────┐ ┌──────────┐       ║
║  │📍 View   │ │🔔 Notif. │       ║
║  │  Sites   │ │  ications│       ║
║  └──────────┘ └──────────┘       ║
║  ┌─────────────────────────┐     ║
║  │ 📦 Material Inventory   │     ║
║  └─────────────────────────┘     ║
╚═══════════════════════════════════╝
```

### **Supervisor Site Card - Buttons:**
```
╔═══════════════════════════════════╗
║  🏗️ Rahman Site                   ║
║  📍 Madipakkam, 5th Street        ║
║                                   ║
║  ┌──────────┐ ┌───┐ ┌───┐       ║
║  │View      │ │📜 │ │📦 │       ║
║  │Details   │ │   │ │   │       ║
║  └──────────┘ └───┘ └───┘       ║
╚═══════════════════════════════════╝
```

---

## COMMON QUESTIONS

### **Q: I don't see the Material Inventory button**
**A:** Make sure you're:
- Logged in as **Site Engineer** (not Supervisor)
- On the **Dashboard tab** (first tab at bottom)
- **Scrolled down** past the overview cards
- Looking in the **Quick Actions** section

### **Q: I don't see the 📦 icon on site card**
**A:** Make sure you're:
- Logged in as **Supervisor** (not Site Engineer)
- Have **selected Area and Street**
- Looking at the **bottom of the site card**
- Looking for the **third button** (after View Details and History)

### **Q: The button is there but nothing happens**
**A:** 
- Make sure backend is running
- Check your network connection
- Try rebuilding the app
- Check console for error messages

---

## QUICK REFERENCE

| Role | Location | Button | Action |
|------|----------|--------|--------|
| Site Engineer | Dashboard → Quick Actions | "Material Inventory" | Opens material management screen |
| Supervisor | Site Card → Bottom buttons | 📦 icon | Opens material usage dialog |

---

## TESTING TIPS

1. **Test as Site Engineer first:**
   - Add some materials
   - Verify they appear in the list

2. **Then test as Supervisor:**
   - Record usage
   - Verify success message

3. **Go back to Site Engineer:**
   - Refresh the screen
   - Verify balance updated
   - Check "Used Today" shows correct amount

---

## VISUAL MARKERS TO LOOK FOR

### **Site Engineer:**
- ✅ "Quick Actions" heading
- ✅ White button with navy border
- ✅ Inventory icon (📦)
- ✅ Text: "Material Inventory"

### **Supervisor:**
- ✅ Site card with gradient header
- ✅ Row of 3 buttons at bottom
- ✅ Third button has inventory icon (📦)
- ✅ Semi-transparent white background

---

**If you still can't find it, rebuild the app:**
```bash
cd otp_phone_auth
flutter clean
flutter pub get
flutter run
```

**The buttons are definitely there!** 🎯
