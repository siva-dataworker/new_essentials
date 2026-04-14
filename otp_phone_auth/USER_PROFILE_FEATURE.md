# User Profile Feature - Complete Guide

## 🎉 What's New

Your app now includes a complete user profile system with Firestore database integration!

## ✨ New Features

### 1. **User Profile Storage**
- Stores user data in Firebase Firestore
- Persistent across app restarts
- Syncs across devices

### 2. **Profile Form Screen**
- Welcome message with phone number
- Required fields: Name, Age
- Optional fields: Email, Address
- Form validation
- Loading states

### 3. **Enhanced Home Screen**
- Personalized welcome message
- Profile information card
- Edit profile button
- Member since date
- Sign out functionality

### 4. **Smart Flow Logic**
- New users → Profile form
- Returning users → Home screen
- Incomplete profiles → Profile form
- Complete profiles → Home screen

---

## 📱 User Flow

### First Time User

```
1. Enter Phone Number
   ↓
2. Verify OTP
   ↓
3. Create User in Firestore
   ↓
4. Show Profile Form
   "Welcome! 👋"
   "Phone: +1234567890"
   "Please complete your profile"
   ↓
5. User Fills Form
   - Name (required)
   - Age (required)
   - Email (optional)
   - Address (optional)
   ↓
6. Save to Firestore
   ↓
7. Redirect to Home Screen
   "Welcome, John! 👋"
   [Profile Card with all info]
```

### Returning User

```
1. Enter Phone Number
   ↓
2. Verify OTP
   ↓
3. Load User from Firestore
   ↓
4. Check Profile Status
   ↓
5. If Complete → Home Screen
   "Welcome back, John! 👋"
   [Shows saved profile]
   ↓
6. If Incomplete → Profile Form
   "Please complete your profile"
```

---

## 🗂️ New Files Created

### Models
- `lib/models/user_model.dart` - User data model

### Services
- `lib/services/firestore_service.dart` - Database operations

### Screens
- `lib/screens/profile_form_screen.dart` - Profile form UI
- `lib/screens/home_screen.dart` - Updated with profile display

### Documentation
- `FIRESTORE_SETUP.md` - Firestore setup guide
- `USER_PROFILE_FEATURE.md` - This file

---

## 🔧 Setup Required

### Step 1: Enable Firestore

1. Go to: https://console.firebase.google.com/project/constructionsite-8d964/firestore

2. Click **"Create database"**

3. Select **"Start in test mode"** (for development)

4. Choose location: **us-central** (or closest to you)

5. Click **"Enable"**

### Step 2: Install Dependencies

```bash
cd otp_phone_auth
flutter pub get
```

### Step 3: Run the App

```bash
flutter run
```

### Step 4: Test the Flow

1. Enter phone: `+1 650 555 1234`
2. Enter OTP: `123456`
3. Fill profile form:
   - Name: Your Name
   - Age: 25
   - Email: your@email.com (optional)
   - Address: Your address (optional)
4. Click "Complete Profile"
5. See home screen with your info!

---

## 📊 Database Structure

### Firestore Collection: `users`

```javascript
users/
  └── {userId}/
      ├── uid: "abc123"
      ├── phoneNumber: "+1234567890"
      ├── name: "John Doe"
      ├── age: 25
      ├── email: "john@example.com"
      ├── address: "123 Main St"
      ├── createdAt: "2025-01-15T10:30:00Z"
      └── isProfileComplete: true
```

---

## 🎨 UI Screenshots (Text Description)

### Profile Form Screen
```
┌─────────────────────────────────┐
│  Complete Your Profile     [X]  │
├─────────────────────────────────┤
│                                 │
│         👤 (Person Icon)        │
│                                 │
│        Welcome! 👋              │
│    Phone: +1234567890           │
│  Please complete your profile   │
│                                 │
│  ┌───────────────────────────┐  │
│  │ Full Name *              │  │
│  └───────────────────────────┘  │
│                                 │
│  ┌───────────────────────────┐  │
│  │ Age *                    │  │
│  └───────────────────────────┘  │
│                                 │
│  ┌───────────────────────────┐  │
│  │ Email (Optional)         │  │
│  └───────────────────────────┘  │
│                                 │
│  ┌───────────────────────────┐  │
│  │ Address (Optional)       │  │
│  │                          │  │
│  └───────────────────────────┘  │
│                                 │
│  ┌───────────────────────────┐  │
│  │   Complete Profile       │  │
│  └───────────────────────────┘  │
│                                 │
│      * Required fields          │
└─────────────────────────────────┘
```

### Home Screen
```
┌─────────────────────────────────┐
│  Home                  [Logout] │
├─────────────────────────────────┤
│                                 │
│         ✓ (Check Icon)          │
│                                 │
│     Welcome, John! 👋           │
│                                 │
│  ┌─────────────────────────┐   │
│  │ Profile Information  ✏️ │   │
│  ├─────────────────────────┤   │
│  │ 👤 Name                 │   │
│  │    John Doe             │   │
│  │                         │   │
│  │ 📱 Phone                │   │
│  │    +1234567890          │   │
│  │                         │   │
│  │ 🎂 Age                  │   │
│  │    25                   │   │
│  │                         │   │
│  │ 📧 Email                │   │
│  │    john@example.com     │   │
│  │                         │   │
│  │ 📍 Address              │   │
│  │    123 Main St          │   │
│  │                         │   │
│  │ 📅 Member Since         │   │
│  │    15/1/2025            │   │
│  └─────────────────────────┘   │
│                                 │
│  ┌───────────────────────────┐  │
│  │  ✏️  Edit Profile        │  │
│  └───────────────────────────┘  │
│                                 │
│  ┌───────────────────────────┐  │
│  │  🚪 Sign Out             │  │
│  └───────────────────────────┘  │
└─────────────────────────────────┘
```

---

## 🔐 Security Rules

### Development (Test Mode)
```javascript
// Allows all reads/writes for 30 days
allow read, write: if request.time < timestamp.date(2025, 2, 15);
```

### Production (Recommended)
```javascript
// Users can only access their own data
match /users/{userId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}
```

---

## 💡 Features Breakdown

### UserModel Class
```dart
class UserModel {
  final String uid;              // Firebase Auth UID
  final String phoneNumber;      // User's phone
  final String? name;            // User's name
  final int? age;                // User's age
  final String? email;           // Optional email
  final String? address;         // Optional address
  final DateTime createdAt;      // Registration date
  final bool isProfileComplete;  // Profile status
}
```

### FirestoreService Methods
```dart
// Save or update user
FirestoreService.saveUser(UserModel user)

// Get user by UID
FirestoreService.getUser(String uid)

// Check if user exists
FirestoreService.userExists(String uid)

// Update profile
FirestoreService.updateUserProfile(...)

// Delete user
FirestoreService.deleteUser(String uid)
```

---

## 🧪 Testing Checklist

- [ ] Firestore enabled in Firebase Console
- [ ] Dependencies installed (`flutter pub get`)
- [ ] App runs without errors
- [ ] New user flow works:
  - [ ] Phone verification
  - [ ] Profile form appears
  - [ ] Can fill and submit form
  - [ ] Redirects to home screen
- [ ] Returning user flow works:
  - [ ] Phone verification
  - [ ] Loads existing profile
  - [ ] Shows home screen with data
- [ ] Edit profile works:
  - [ ] Can edit existing profile
  - [ ] Changes save to Firestore
  - [ ] Home screen updates
- [ ] Data persists:
  - [ ] Close and reopen app
  - [ ] Data still there
- [ ] Sign out works:
  - [ ] Returns to phone input
  - [ ] Can sign in again

---

## 📈 Next Steps

### Immediate
1. ✅ Enable Firestore (see FIRESTORE_SETUP.md)
2. ✅ Run `flutter pub get`
3. ✅ Test the app

### Future Enhancements
- [ ] Add profile photo upload
- [ ] Add more profile fields
- [ ] Add profile completion percentage
- [ ] Add email verification
- [ ] Add push notifications
- [ ] Add user settings screen
- [ ] Add dark mode toggle
- [ ] Add language selection

---

## 🐛 Troubleshooting

### "Firestore not enabled"
→ Enable Firestore in Firebase Console

### "Permission denied"
→ Update Firestore security rules

### "User data not loading"
→ Check Firestore console for data
→ Verify user UID matches document ID

### Form validation errors
→ Check required fields are filled
→ Verify email format if provided
→ Age must be 1-120

---

## 💰 Cost Impact

### Firestore Usage (per user)
- **Create profile:** 1 write
- **Load profile:** 1 read
- **Update profile:** 1 write
- **Storage:** ~1 KB per user

### Free Tier Limits
- **50,000 reads/day** = 50,000 profile loads
- **20,000 writes/day** = 20,000 profile updates
- **1 GB storage** = ~1 million users

**Conclusion:** Free tier is more than enough for most apps!

---

## 🎉 Summary

You now have a complete user profile system with:
- ✅ Phone authentication
- ✅ User profile storage
- ✅ Profile form with validation
- ✅ Personalized home screen
- ✅ Edit profile functionality
- ✅ Persistent data storage
- ✅ Smart flow logic

**Ready to test?** Enable Firestore and run the app! 🚀
