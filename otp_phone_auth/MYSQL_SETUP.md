# MySQL Database Setup Guide

## 📋 Overview

Your Essential Homes app now uses:
- **Firebase Authentication** - Google Sign-In only
- **MySQL Database** - All user data and business data

---

## 🔧 MySQL Installation

### Windows:
1. Download MySQL from: https://dev.mysql.com/downloads/installer/
2. Run installer and select "MySQL Server"
3. Set root password during installation
4. Start MySQL service

### Mac:
```bash
brew install mysql
brew services start mysql
```

### Linux:
```bash
sudo apt-get install mysql-server
sudo systemctl start mysql
```

---

## 🗄️ Database Setup

### 1. Create Database

```sql
CREATE DATABASE essential_homes;
USE essential_homes;
```

### 2. Create User (Optional - for security)

```sql
CREATE USER 'essential_user'@'localhost' IDENTIFIED BY 'your_secure_password';
GRANT ALL PRIVILEGES ON essential_homes.* TO 'essential_user'@'localhost';
FLUSH PRIVILEGES;
```

### 3. Users Table (Auto-created by app)

The app automatically creates this table on first run:

```sql
CREATE TABLE users (
  id VARCHAR(255) PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(255),
  phone_number VARCHAR(50),
  password_hash VARCHAR(255),
  role VARCHAR(50) NOT NULL,
  is_profile_complete BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_email (email),
  INDEX idx_role (role)
);
```

---

## ⚙️ Configure App Connection

### Update MySQL credentials in:
`lib/services/mysql_service.dart`

```dart
final ConnectionSettings _settings = ConnectionSettings(
  host: 'localhost',        // Your MySQL server IP
  port: 3306,               // MySQL port (default 3306)
  user: 'essential_user',   // Your MySQL username
  password: 'your_password', // Your MySQL password
  db: 'essential_homes',    // Database name
);
```

---

## 🔐 Security Best Practices

### 1. Never commit credentials to Git

Add to `.gitignore`:
```
lib/services/mysql_service.dart
```

### 2. Use environment variables (Production)

```dart
final ConnectionSettings _settings = ConnectionSettings(
  host: Platform.environment['MYSQL_HOST'] ?? 'localhost',
  port: int.parse(Platform.environment['MYSQL_PORT'] ?? '3306'),
  user: Platform.environment['MYSQL_USER'] ?? 'root',
  password: Platform.environment['MYSQL_PASSWORD'] ?? '',
  db: Platform.environment['MYSQL_DB'] ?? 'essential_homes',
);
```

### 3. Use SSL for remote connections

```dart
final ConnectionSettings _settings = ConnectionSettings(
  host: 'your-server.com',
  port: 3306,
  user: 'essential_user',
  password: 'your_password',
  db: 'essential_homes',
  useSSL: true,
);
```

---

## 📊 Data Flow

```
[User Signs in with Google]
    ↓
[Firebase Authentication] ← Validates Google OAuth
    ↓
[MySQL Database] ← Checks if user exists
    ↓
If NEW user:
  - Create record in MySQL
  - Store: email, name, role
    ↓
If EXISTING user:
  - Load profile from MySQL
  - Return user data
    ↓
[Navigate to Dashboard]
```

---

## 🧪 Testing MySQL Connection

### Test in MySQL Workbench or CLI:

```sql
-- Check if database exists
SHOW DATABASES LIKE 'essential_homes';

-- Check if users table exists
USE essential_homes;
SHOW TABLES;

-- View table structure
DESCRIBE users;

-- Check users
SELECT * FROM users;
```

---

## 🚀 Production Deployment

### Option 1: Cloud MySQL (Recommended)

**AWS RDS:**
- Managed MySQL service
- Automatic backups
- High availability

**Google Cloud SQL:**
- Integrated with Firebase
- Automatic scaling

**DigitalOcean Managed Database:**
- Simple setup
- Affordable pricing

### Option 2: Self-Hosted

- Use VPS (DigitalOcean, Linode, AWS EC2)
- Install MySQL
- Configure firewall (allow port 3306)
- Use SSL certificates

---

## 📝 Common Issues

### Issue 1: Connection Refused
```
Error: Connection refused
```
**Solution:**
- Check if MySQL is running: `sudo systemctl status mysql`
- Check firewall allows port 3306
- Verify host/port in connection settings

### Issue 2: Access Denied
```
Error: Access denied for user
```
**Solution:**
- Verify username and password
- Check user has privileges: `SHOW GRANTS FOR 'user'@'localhost';`
- Grant privileges if needed

### Issue 3: Database Not Found
```
Error: Unknown database 'essential_homes'
```
**Solution:**
- Create database: `CREATE DATABASE essential_homes;`
- Verify database name in connection settings

---

## 🔄 Migration from Firebase Firestore

If you were using Firestore before:

```dart
// Export Firestore data
final users = await FirebaseFirestore.instance.collection('users').get();

// Import to MySQL
for (var doc in users.docs) {
  final data = doc.data();
  await MySQLService.instance.createUser(
    UserModel.fromMap(data),
  );
}
```

---

## 📚 Additional Resources

- MySQL Documentation: https://dev.mysql.com/doc/
- mysql1 Package: https://pub.dev/packages/mysql1
- Database Security: https://dev.mysql.com/doc/refman/8.0/en/security.html

---

## ✅ Checklist

- [ ] MySQL installed and running
- [ ] Database `essential_homes` created
- [ ] User credentials configured
- [ ] Connection settings updated in app
- [ ] App tested with MySQL connection
- [ ] Firewall configured (if remote)
- [ ] SSL enabled (if production)
- [ ] Backups configured

---

**Need help?** Check the troubleshooting section or contact support.
