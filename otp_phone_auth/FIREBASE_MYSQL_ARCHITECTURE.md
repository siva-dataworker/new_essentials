# 🏗️ Firebase + MySQL Architecture

## Overview

Your Essential Homes app now uses a **hybrid architecture**:

- **Firebase Authentication** → Google Sign-In only
- **MySQL Database** → All user data & business data

---

## 🔄 Complete Flow

```
1. User clicks "Sign in with Google"
    ↓
2. Firebase handles Google OAuth
    ↓
3. User authenticated, get email & name
    ↓
4. Check MySQL database:
   - If user exists → Load profile
   - If new user → Create record
    ↓
5. Navigate to Dashboard with user data
```

---

## 📊 Data Storage Strategy

### **Firebase Authentication (Google Cloud)**
✅ Stores:
- Google OAuth tokens
- User email (from Google)
- Session management
- Authentication state

❌ Does NOT store:
- User profiles
- Passwords
- Business data
- Any custom data

### **MySQL Database (Your Server)**
✅ Stores:
- User profiles (name, phone, role)
- Encrypted passwords
- Sites & projects
- Materials & labor data
- Daily entries
- All business logic

---

## 🔐 Security Features

### **Password Storage:**
- Passwords hashed with SHA-256
- Never stored in plain text
- Stored only in MySQL
- Firebase never sees passwords

### **Authentication:**
- Google OAuth handled by Firebase
- Secure token management
- Auto token refresh
- Session persistence

### **Database:**
- MySQL user authentication
- Encrypted connections (SSL)
- Prepared statements (SQL injection protection)
- Role-based access control

---

## 💾 Database Schema

### **Users Table:**
```sql
CREATE TABLE users (
  id VARCHAR(255) PRIMARY KEY,           -- Firebase UID
  email VARCHAR(255) UNIQUE NOT NULL,    -- From Google
  name VARCHAR(255),                     -- User's name
  phone_number VARCHAR(50),              -- Optional
  password_hash VARCHAR(255),            -- SHA-256 hashed
  role VARCHAR(50) NOT NULL,             -- supervisor, admin, etc.
  is_profile_complete BOOLEAN,           -- Profile status
  created_at TIMESTAMP,                  -- Account creation
  updated_at TIMESTAMP                   -- Last update
);
```

---

## 🚀 Setup Steps

### 1. Firebase Setup (Already Done)
- ✅ Firebase project created
- ✅ Google Sign-In enabled
- ✅ SHA-1 fingerprint added
- ✅ google-services.json configured

### 2. MySQL Setup (Required)
1. Install MySQL server
2. Create database: `essential_homes`
3. Update credentials in `lib/services/mysql_service.dart`
4. Run app (tables auto-created)

See `MYSQL_SETUP.md` for detailed instructions.

---

## 📱 App Features

### **Google Sign-In:**
- One-click authentication
- No password needed for login
- Secure OAuth flow
- Auto profile creation

### **Password Management:**
- Optional password in profile
- Strong password requirements:
  - Minimum 8 characters
  - 1 uppercase letter
  - 1 lowercase letter
  - 1 number
  - 1 special character
- Stored encrypted in MySQL

### **Profile Management:**
- Edit name
- Set/change password
- View role
- Phone number (read-only from Google)

---

## 🔧 Configuration

### **MySQL Connection:**
File: `lib/services/mysql_service.dart`

```dart
final ConnectionSettings _settings = ConnectionSettings(
  host: 'localhost',        // Change for production
  port: 3306,
  user: 'your_username',    // Your MySQL user
  password: 'your_password', // Your MySQL password
  db: 'essential_homes',
);
```

### **Firebase Config:**
File: `android/app/google-services.json`
- Already configured with your Client ID
- SHA-1 fingerprint added

---

## 🌐 Production Deployment

### **Firebase:**
- Already hosted on Google Cloud
- No additional setup needed
- Scales automatically

### **MySQL:**
Choose one:

1. **Cloud MySQL (Recommended):**
   - AWS RDS
   - Google Cloud SQL
   - DigitalOcean Managed Database

2. **Self-Hosted:**
   - VPS (DigitalOcean, Linode)
   - Configure firewall
   - Enable SSL
   - Setup backups

---

## 💰 Cost Comparison

### **Firebase Authentication:**
- Free tier: 10,000 authentications/month
- After: $0.01 per authentication
- Your usage: ~100 users = FREE

### **MySQL:**
- **Cloud:** $15-50/month (managed)
- **Self-hosted:** $5-20/month (VPS)
- **Local:** FREE (development)

**Total monthly cost:** $0-50 depending on hosting choice

---

## 🔄 Sync Logic

### **On Google Sign-In:**
```dart
1. Firebase authenticates user
2. Get user email from Firebase
3. Query MySQL: SELECT * FROM users WHERE email = ?
4. If found:
   - Load existing profile
   - Return user data
5. If not found:
   - Create new record in MySQL
   - Set default role (supervisor)
   - Return new user data
6. Navigate to dashboard
```

### **On Profile Update:**
```dart
1. User edits profile
2. Validate password (if changed)
3. Hash password with SHA-256
4. UPDATE users SET ... WHERE id = ?
5. Show success message
```

---

## 🧪 Testing

### **Test Google Sign-In:**
1. Run app
2. Click "Sign in with Google"
3. Select Google account
4. Check MySQL: `SELECT * FROM users;`
5. Verify user created

### **Test Password:**
1. Go to Profile
2. Set password
3. Check MySQL: `SELECT password_hash FROM users WHERE email = ?;`
4. Verify hash stored

---

## 📚 Key Files

### **Authentication:**
- `lib/screens/google_signin_screen.dart` - Google Sign-In UI
- `lib/services/mysql_service.dart` - MySQL operations

### **Profile:**
- `lib/screens/supervisor_profile_screen.dart` - Profile edit
- `lib/models/user_model.dart` - User data structure

### **Configuration:**
- `lib/main.dart` - App initialization
- `android/app/google-services.json` - Firebase config
- `MYSQL_SETUP.md` - Database setup guide

---

## ✅ Benefits of This Architecture

1. **Best of Both Worlds:**
   - Easy authentication (Firebase)
   - Full data control (MySQL)

2. **Cost Effective:**
   - Firebase free tier sufficient
   - MySQL cheaper than Firestore

3. **Flexible:**
   - Can switch MySQL providers
   - Can add more databases
   - Not locked into Firebase ecosystem

4. **Secure:**
   - Google handles OAuth
   - Passwords encrypted
   - SQL injection protected

5. **Scalable:**
   - Firebase scales automatically
   - MySQL can be upgraded
   - Can add caching layer

---

## 🆘 Troubleshooting

### **Google Sign-In fails:**
- Check SHA-1 fingerprint in Firebase
- Verify Client ID matches
- Check internet connection

### **MySQL connection fails:**
- Verify MySQL is running
- Check credentials
- Test connection with MySQL Workbench

### **User not created in MySQL:**
- Check MySQL connection
- View app logs for errors
- Verify table exists: `SHOW TABLES;`

---

## 📞 Support

For issues:
1. Check `MYSQL_SETUP.md`
2. View app logs
3. Test MySQL connection
4. Check Firebase console

---

**Your app is now ready with Firebase + MySQL!** 🎉
