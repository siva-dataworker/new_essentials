# Firestore Database Setup Guide

## 🔥 Enable Cloud Firestore

### Step 1: Open Firestore in Firebase Console

1. Go to: https://console.firebase.google.com/project/constructionsite-8d964/firestore

2. Click **"Create database"** button

### Step 2: Choose Security Rules

Select **"Start in test mode"** for development:
- Allows read/write access for 30 days
- Good for development and testing
- You'll update rules later for production

Or select **"Start in production mode"**:
- Denies all reads/writes by default
- More secure but requires immediate rule setup

**Recommendation:** Start in test mode for easier development

### Step 3: Select Location

Choose a location close to your users:
- **us-central** (Iowa) - Good for US
- **asia-south1** (Mumbai) - Good for India
- **europe-west** - Good for Europe

**Note:** Location cannot be changed later!

### Step 4: Click "Enable"

Wait for Firestore to be created (takes ~30 seconds)

---

## 🔐 Security Rules (Important!)

### Development Rules (Test Mode)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.time < timestamp.date(2025, 2, 15);
    }
  }
}
```

### Production Rules (Recommended)

Update rules before going live:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      // Users can read their own data
      allow read: if request.auth != null && request.auth.uid == userId;
      
      // Users can create their own document
      allow create: if request.auth != null && request.auth.uid == userId;
      
      // Users can update their own data
      allow update: if request.auth != null && request.auth.uid == userId;
      
      // Users can delete their own data
      allow delete: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### How to Update Rules

1. Go to: https://console.firebase.google.com/project/constructionsite-8d964/firestore/rules

2. Replace the rules with production rules above

3. Click **"Publish"**

---

## 📊 Database Structure

Your app will create this structure:

```
firestore
└── users (collection)
    └── {userId} (document)
        ├── uid: string
        ├── phoneNumber: string
        ├── name: string
        ├── age: number
        ├── email: string (optional)
        ├── address: string (optional)
        ├── createdAt: string (ISO 8601)
        └── isProfileComplete: boolean
```

### Example Document

```json
{
  "uid": "abc123xyz",
  "phoneNumber": "+1234567890",
  "name": "John Doe",
  "age": 25,
  "email": "john@example.com",
  "address": "123 Main St, City",
  "createdAt": "2025-01-15T10:30:00.000Z",
  "isProfileComplete": true
}
```

---

## 🧪 Testing Firestore

### View Data in Console

1. Go to: https://console.firebase.google.com/project/constructionsite-8d964/firestore/data

2. You'll see the `users` collection after first user signs up

3. Click on documents to view/edit data

### Test Queries

In Firebase Console, you can run queries:
- Filter by phone number
- Sort by creation date
- Search by name

---

## 💰 Pricing

### Free Tier (Spark Plan)
- **Stored data:** 1 GB
- **Document reads:** 50,000/day
- **Document writes:** 20,000/day
- **Document deletes:** 20,000/day

### Blaze Plan (Pay-as-you-go)
After free tier:
- **Stored data:** $0.18/GB/month
- **Document reads:** $0.06 per 100,000
- **Document writes:** $0.18 per 100,000
- **Document deletes:** $0.02 per 100,000

**Example Costs:**
- 1,000 users with profiles = ~1 MB = FREE
- 10,000 users = ~10 MB = FREE
- 100,000 users = ~100 MB = FREE
- 1 million users = ~1 GB = FREE (storage only)

---

## 🔍 Indexes

Firestore automatically creates indexes for simple queries. For complex queries, you may need composite indexes.

### When You Need Indexes

If you see this error:
```
The query requires an index
```

Click the link in the error message to auto-create the index in Firebase Console.

---

## 🚀 App Flow with Firestore

### New User Flow

1. User enters phone number
2. User verifies OTP
3. **App checks if user exists in Firestore**
4. **If new:** Create user document → Show profile form
5. **If existing:** Load user data → Show home screen

### Returning User Flow

1. User enters phone number
2. User verifies OTP
3. **App loads user data from Firestore**
4. **If profile incomplete:** Show profile form
5. **If profile complete:** Show home screen with data

---

## 📱 Features Enabled

With Firestore, your app now has:

✅ **User Profile Storage**
- Name, age, email, address
- Phone number
- Creation date
- Profile completion status

✅ **Profile Management**
- Create profile after first login
- Edit profile anytime
- View profile information

✅ **Persistent Data**
- Data survives app restarts
- Syncs across devices
- Accessible from anywhere

✅ **Welcome Message**
- Personalized greeting with user's name
- Shows profile information
- Edit profile option

---

## 🔧 Troubleshooting

### Error: "Missing or insufficient permissions"
**Solution:** Update Firestore security rules (see Production Rules above)

### Error: "Firestore is not enabled"
**Solution:** Enable Firestore in Firebase Console (Step 1)

### Data not showing
**Solution:** 
1. Check Firestore console for data
2. Verify security rules allow read access
3. Check app logs for errors

### Slow queries
**Solution:**
1. Create indexes for complex queries
2. Limit query results
3. Use pagination

---

## 📚 Next Steps

1. ✅ Enable Firestore in Firebase Console
2. ✅ Set security rules (test mode for now)
3. ✅ Run your app
4. ✅ Sign up and complete profile
5. ✅ View data in Firestore console
6. ⏳ Update to production rules before launch

---

## 🔗 Useful Links

- **Firestore Console:** https://console.firebase.google.com/project/constructionsite-8d964/firestore
- **Security Rules:** https://console.firebase.google.com/project/constructionsite-8d964/firestore/rules
- **Firestore Docs:** https://firebase.google.com/docs/firestore
- **Pricing:** https://firebase.google.com/pricing

---

**Ready to enable Firestore?** Follow Step 1 above! 🚀
