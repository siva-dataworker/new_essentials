# 📄 Document Upload - User Guide

## ✅ Issue Resolved

The document upload system is now working correctly with improved validation and user feedback.

## 📱 How to Upload a Document (Step-by-Step)

### For Site Engineer:

**Step 1: Open Documents Screen**
- Login as Site Engineer
- Navigate to Documents section
- Tap "Upload PDF" button

**Step 2: Fill Upload Form**

The upload dialog has 4 fields:

1. **Document Type** (Dropdown) ✅ Pre-selected
   - Site Plan
   - Floor Design
   - Structural Plan
   - Electrical Plan
   - Plumbing Plan
   - HVAC Plan
   - Other

2. **Title** ⚠️ **REQUIRED - YOU MUST TYPE HERE**
   - This field is REQUIRED
   - Type a descriptive title
   - Examples:
     - "Main Site Layout"
     - "Ground Floor Plan"
     - "Electrical Wiring Diagram"
     - "Foundation Details"
   - The cursor will automatically focus here when dialog opens

3. **Description** (Optional)
   - Add additional details if needed
   - Not required

4. **Select PDF File** ⚠️ **REQUIRED**
   - Tap "Select PDF File *" button
   - Choose a PDF from your device
   - You'll see "PDF Selected" with filename when done

**Step 3: Upload**
- Make sure BOTH Title and PDF file are filled
- Tap "Upload" button
- Wait for success message
- Document will appear in the list

## ⚠️ Common Mistakes

### Mistake 1: Not Entering a Title
**Problem:** Tapping Upload without typing in the Title field
**Error Message:** "⚠️ Please enter a title for the document"
**Solution:** Type a title in the "Title *" field before uploading

### Mistake 2: Not Selecting a File
**Problem:** Tapping Upload without selecting a PDF
**Error Message:** "⚠️ Please select a PDF file"
**Solution:** Tap "Select PDF File *" and choose a PDF

### Mistake 3: Wrong File Type
**Problem:** Trying to upload non-PDF files
**Error Message:** "Only PDF files are allowed"
**Solution:** Only PDF files are supported

## ✅ What You Should See

### Before Upload:
```
Upload Document Dialog:
- Document Type: [Site Plan ▼]
- Title *: [Empty - TYPE HERE] ← MUST FILL THIS
- Description: [Optional]
- [Select PDF File *] ← MUST TAP THIS
```

### After Selecting File:
```
Upload Document Dialog:
- Document Type: [Site Plan ▼]
- Title *: [Main Site Layout] ← FILLED
- Description: [Optional]
- [PDF Selected] ← DONE
- ✅ Symptom Triage and care navigator.pdf
```

### After Upload Success:
```
✅ Document uploaded successfully!
- Document appears in list
- Shows PDF icon
- Shows title and type
- Shows upload date
- Can tap to open
```

## 🔧 Improvements Made

### 1. Better Validation Messages
- **Before:** "Please select a file and enter a title" (generic)
- **After:** 
  - "⚠️ Please enter a title for the document" (specific)
  - "⚠️ Please select a PDF file" (specific)

### 2. Visual Improvements
- Added title icon (📝)
- Added hint text with examples
- Added red helper text "Required - Enter a descriptive title"
- Auto-focus on title field when dialog opens
- Better file selection feedback

### 3. Backend Fixes
- Fixed SQL queries to use `full_name` instead of `name`
- Documents now appear correctly after upload
- Both Site Engineer and Accountant can see documents

## 📊 Upload Flow Diagram

```
1. Tap "Upload PDF"
   ↓
2. Dialog Opens
   ↓
3. Title field auto-focused (cursor blinking)
   ↓
4. TYPE A TITLE ← IMPORTANT!
   ↓
5. Tap "Select PDF File *"
   ↓
6. Choose PDF from device
   ↓
7. See "PDF Selected" with filename
   ↓
8. Tap "Upload" button
   ↓
9. See loading indicator
   ↓
10. Success! ✅
    ↓
11. Document appears in list
```

## 🎯 Quick Checklist

Before tapping Upload, verify:
- [ ] Title field has text (not empty)
- [ ] PDF file is selected (shows filename)
- [ ] Document type is correct
- [ ] Description added (optional)

## 📱 Testing Instructions

### Test 1: Successful Upload
1. Open Documents screen
2. Tap "Upload PDF"
3. Type title: "Test Document"
4. Tap "Select PDF File *"
5. Choose any PDF
6. Tap "Upload"
7. ✅ Should see success message
8. ✅ Document should appear in list

### Test 2: Missing Title
1. Open Documents screen
2. Tap "Upload PDF"
3. DON'T type a title (leave empty)
4. Select a PDF file
5. Tap "Upload"
6. ⚠️ Should see: "Please enter a title for the document"
7. Type a title
8. Tap "Upload" again
9. ✅ Should work now

### Test 3: Missing File
1. Open Documents screen
2. Tap "Upload PDF"
3. Type title: "Test"
4. DON'T select a file
5. Tap "Upload"
6. ⚠️ Should see: "Please select a PDF file"
7. Select a PDF
8. Tap "Upload" again
9. ✅ Should work now

## 🚀 Current Status

✅ Backend: Fixed and running
✅ Frontend: Improved validation
✅ Auto-focus: Title field focused on open
✅ Better error messages
✅ Visual feedback improved
✅ Documents appear after upload
✅ Accountant can see documents

## 📝 Summary

**The main issue was:** Users were not entering a title in the Title field.

**The solution:**
1. Made it more obvious that Title is required
2. Added auto-focus to Title field
3. Added better error messages
4. Added visual hints and examples

**Now:** Users will immediately see the cursor in the Title field and know they need to type something there before uploading.

---

**Updated:** February 14, 2026 - 10:50 AM
**Status:** ✅ Working with improved UX
