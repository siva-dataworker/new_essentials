# Troubleshooting Guide

## Issue: Profile Form Not Showing After Login

### Symptom
After OTP verification, you see the old "Phone Verified Successfully!" screen instead of the profile form.

### Cause
Firestore database is not enabled in Firebase Console.

### Solution

#### Step 1: Enable Firestore (REQUIRED)

1. **Open Firestore in Firebase Console:**
   https://console.firebase.google.com/project/constructionsite-8d964/firestore

2. **Click "Create database"** button

3. **Select "Start in test mode"**
   - This allows read/write for 30 days
   - Perfect for development

4. **Choose location:**
   - Select **"us-central"** (or closest to you)
   - **Important:** Cannot be changed later!

5. **Click "Enable"**
   - Wait 30-60 seconds for setup

#### Step 2: Verify Firestore is Enabled

1. Go to: https://console.firebase.google.com/project/constructionsite-8d964/firestore/data

2. You should see an empty database (no error message)

3. If you see "Create database" button, Firestore is NOT enabled yet

#### Step 3: Restart Your App

1. Stop the app completely
2. Run again: `flutter run`
3. Test the login flow

#### Step 4: Test the Flow

1. Enter phone: `+918754140702` (or test number)
2. Enter OTP
3. **You should now see the Profile Form!**

---

## Issue: "Permission Denied" Error

### Symptom
Error message: "Missing or insufficient permissions"

### Solution

Update Firestore security rules:

1. Go to: https://console.firebase.google.com/project/constructionsite-8d964/firestore/rules

2. Replace with:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.time < timestamp.date(2025, 3, 1);
    }
  }
}
```

3. Click **"Publish"**

---

## Issue: App Shows Loading Forever

### Symptom
Circular progress indicator never stops

### Solution

1. Check your internet connection
2. Verify Firestore is enabled
3. Check Flutter console for errors:
   ```bash
   flutter logs
   ```

---

## Issue: "Failed to get user" Error

### Symptom
Error dialog appears after OTP verification

### Causes & Solutions

**Cause 1: Firestore not enabled**
→ Enable Firestore (see Step 1 above)

**Cause 2: Wrong security rules**
→ Update rules (see Permission Denied section)

**Cause 3: Network issue**
→ Check internet connection

---

## Issue: Profile Form Doesn't Save

### Symptom
Click "Complete Profile" but nothing happens or error appears

### Solutions

1. **Check required fields:**
   - Name must be filled
   - Age must be filled
   - Age must be 1-120

2. **Check Firestore is enabled:**
   - See Step 1 above

3. **Check security rules:**
   - See Permission Denied section

4. **Check console for errors:**
   ```bash
   flutter logs
   ```

---

## Issue: Data Not Persisting

### Symptom
Profile data disappears after app restart

### Solutions

1. **Verify data is in Firestore:**
   - Go to: https://console.firebase.google.com/project/constructionsite-8d964/firestore/data
   - Check if `users` collection exists
   - Check if your user document exists

2. **Check if profile was saved:**
   - Look for success message
   - Check for errors in console

---

## Issue: Can't Edit Profile

### Symptom
Edit button doesn't work or changes don't save

### Solutions

1. **Check Firestore security rules:**
   - Must allow updates
   - See Permission Denied section

2. **Verify user is authenticated:**
   - Sign out and sign in again

---

## Quick Checklist

Before reporting issues, verify:

- [ ] Firestore is enabled in Firebase Console
- [ ] Security rules are set to test mode
- [ ] Internet connection is working
- [ ] App has been restarted after enabling Firestore
- [ ] No errors in Flutter console (`flutter logs`)
- [ ] Firebase project ID is correct: `constructionsite-8d964`
- [ ] `google-services.json` is in `android/app/`
- [ ] Dependencies are installed: `flutter pub get`

---

## Still Having Issues?

### Check Flutter Console

```bash
flutter logs
```

Look for errors related to:
- Firestore
- Firebase Auth
- Network requests

### Check Firebase Console

1. **Authentication:**
   https://console.firebase.google.com/project/constructionsite-8d964/authentication/users
   - Verify user appears after login

2. **Firestore:**
   https://console.firebase.google.com/project/constructionsite-8d964/firestore/data
   - Check if data is being saved

3. **Usage:**
   https://console.firebase.google.com/project/constructionsite-8d964/usage
   - Check for quota issues

---

## Common Error Messages

### "Firestore is not enabled"
→ Enable Firestore in Firebase Console

### "Missing or insufficient permissions"
→ Update Firestore security rules to test mode

### "Network request failed"
→ Check internet connection

### "User not found"
→ Sign out and sign in again

### "Invalid phone number"
→ Include country code (e.g., +918754140702)

---

## Need More Help?

1. Check the documentation:
   - `FIRESTORE_SETUP.md` - Firestore setup
   - `USER_PROFILE_FEATURE.md` - Feature guide
   - `COMPLETE_SETUP_GUIDE.md` - Complete setup

2. Check Firebase documentation:
   - https://firebase.google.com/docs/firestore

3. Check Flutter Firebase documentation:
   - https://firebase.flutter.dev/docs/firestore/overview
