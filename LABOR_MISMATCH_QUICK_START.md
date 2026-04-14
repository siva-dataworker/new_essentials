# 🚀 Labor Mismatch Detection - Quick Start Guide

## ✅ What's New?

The Accountant dashboard now shows a **warning icon (⚠️)** when there are mismatches between Supervisor and Site Engineer labor entries!

---

## 🎯 How It Works

### Visual Indicator

When you select a site in the Accountant dashboard, the system automatically checks for labor entry mismatches from the last 7 days.

**If mismatches are found:**
```
┌─────────────────────────────────────┐
│  Site Name          ⚠️3  📄  🚪     │  ← Warning icon with count!
│  Accountant View                    │
└─────────────────────────────────────┘
```

**If no mismatches:**
```
┌─────────────────────────────────────┐
│  Site Name              📄  🚪      │  ← No warning icon
│  Accountant View                    │
└─────────────────────────────────────┘
```

---

## 📱 How to Use

### Step 1: Login as Accountant
- Use your accountant credentials

### Step 2: Select a Site
1. Choose Area
2. Choose Street
3. Choose Site

### Step 3: Check for Warnings
- Look at the top-right corner of the screen
- If you see ⚠️ with a number → There are mismatches!
- The number shows how many mismatches were found

### Step 4: View Details
1. **Tap the warning icon (⚠️)**
2. A dialog will open showing all mismatches
3. Each mismatch shows:
   - Labor type (Mason, Carpenter, etc.)
   - Supervisor's count
   - Site Engineer's count
   - The difference
   - Date of entry
   - Names of who submitted

### Step 5: Take Action
- Review the mismatches
- Contact the Supervisor or Site Engineer
- Verify which count is correct
- Request corrections if needed

---

## 🔍 Types of Mismatches

### 1. Count Difference (🟠 Orange)
**What it means:** Both submitted entries but the numbers don't match

**Example:**
- Supervisor: 10 Masons
- Site Engineer: 8 Masons
- **Difference: 2 workers**

---

### 2. Missing Engineer Entry (🔴 Red)
**What it means:** Supervisor submitted but Site Engineer didn't

**Example:**
- Supervisor: 5 Carpenters
- Site Engineer: No entry
- **Missing engineer data**

---

### 3. Missing Supervisor Entry (🔴 Red)
**What it means:** Site Engineer submitted but Supervisor didn't

**Example:**
- Supervisor: No entry
- Site Engineer: 3 Electricians
- **Missing supervisor data**

---

## 💡 Why This Matters

### Data Accuracy
- Ensures both roles are tracking labor correctly
- Catches errors early
- Prevents payroll mistakes

### Accountability
- Both Supervisor and Site Engineer must submit
- Easy to see who's missing entries
- Encourages consistent reporting

### Better Management
- Quick visual check of data quality
- Detailed breakdown when needed
- Helps resolve issues faster

---

## 🎨 What You'll See

### Warning Icon
- **Icon:** ⚠️ (Orange warning triangle)
- **Badge:** Red circle with number (e.g., "3")
- **Location:** Top-right corner, next to Bills icon

### Mismatch Dialog
- **Title:** "Labor Entry Mismatches"
- **Cards:** One card per mismatch
- **Colors:** Orange for count differences, Red for missing entries
- **Info:** All details about each mismatch

---

## 📊 Example Mismatch Card

```
┌─────────────────────────────────────┐
│ ↔️ Count Mismatch          Δ 2     │
│ Mason                               │
├─────────────────────────────────────┤
│ Supervisor        Site Engineer     │
│ 10 workers        8 workers         │
│ John Doe          Jane Smith        │
├─────────────────────────────────────┤
│ 📅 2024-02-14                       │
└─────────────────────────────────────┘
```

---

## 🔄 When Data Updates

The mismatch check runs automatically when you:
- Select a different site
- Switch between role tabs (Supervisor/Site Engineer/Architect)
- Return to the accountant dashboard

---

## ⚙️ Settings

### Time Range
- Currently checks last **7 days**
- Configurable by developers if needed

### Refresh
- Automatic on site selection
- Manual refresh available (pull down on lists)

---

## 🆘 Troubleshooting

### Warning icon not showing?
- Make sure you've selected a site
- Check if there are actually any mismatches
- Try refreshing the data

### Can't see mismatch details?
- Tap directly on the warning icon
- Make sure you have internet connection
- Check if backend is running

### Numbers seem wrong?
- Verify the date range (last 7 days)
- Check if entries were modified
- Contact support if issue persists

---

## 📞 Support

If you encounter issues:
1. Take a screenshot
2. Note the site name and date
3. Contact the development team

---

## 🎉 Benefits

✅ **Instant visibility** of data issues
✅ **Detailed breakdown** of all mismatches
✅ **Easy identification** of problem dates
✅ **Better data quality** for payroll
✅ **Improved accountability** for both roles

---

**Ready to use!** Just login as accountant and select a site to see it in action! 🚀
