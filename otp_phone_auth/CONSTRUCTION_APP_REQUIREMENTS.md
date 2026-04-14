# Construction Site Management App - Requirements

## 🎯 App Overview
A construction site management system for tracking daily work, labor, materials, and site updates.

## 👥 User Roles
1. **Site Engineer** - Daily data entry
2. **Accountant** - Can modify labor counts
3. **Chief Accountant** - Receives all notifications
4. **Owner** - Views all data and receives notifications

## 📱 Core Features

### 1. User Authentication
- ✅ Phone OTP login
- ✅ User profile management
- Profile icon in app bar for editing profile

### 2. Site Selection
- Dropdown to select site name
- User can work on multiple sites
- Site selection required before data entry

### 3. Morning Tasks (Before deadline)
- **Labor Count Entry**
  - Enter number of laborers present
  - Contact all laborers before entry
  - Cannot be modified by site engineer
  - Only accountant can modify after consulting labor head
  - All modifications tracked and notified

### 4. Evening Tasks (Before deadline)
- **Material Balance Update**
  - Update remaining materials
  - Track material usage
  
- **Site Pictures Upload**
  - Upload work progress photos
  - Photos stored for site engineer and owner viewing
  - Organized by date and site

### 5. Notifications System
- **Missing Morning Entry:**
  - If labor count not entered → Notify accountant & owner
  
- **Missing Evening Entry:**
  - If material balance not entered → Notify accountant & owner
  
- **Modification Alerts:**
  - Any labor count modification → Notify chief accountant & owner
  - Include who modified, when, and reason

### 6. Data Management
- Follow Excel sheet format
- All entries timestamped
- Modification history maintained
- Read-only for site engineers (labor count)
- Edit access for accountants

### 7. Viewing & Reports
- Site engineers can view their entries
- Owners can view all sites
- Photo gallery by site and date
- Labor count history
- Material balance trends

## 📊 Database Structure

### Collections:
1. **users** - User profiles and roles
2. **sites** - Site information
3. **daily_entries** - Daily work logs
4. **labor_counts** - Labor attendance records
5. **material_balance** - Material inventory
6. **site_photos** - Work progress images
7. **modifications** - Audit trail
8. **notifications** - Alert system

## 🔔 Notification Rules

### Triggers:
1. Missing labor count by 10 AM → Alert
2. Missing material balance by 6 PM → Alert
3. Any modification → Alert with details

### Recipients:
- Accountant (for missing entries)
- Owner (for all alerts)
- Chief Accountant (for modifications)

## 🎨 UI Flow

```
Login (OTP)
    ↓
Home Dashboard
    ├─ Profile Icon (top right)
    ├─ Site Selector (dropdown)
    ├─ Morning Tasks Card
    │   └─ Labor Count Entry
    ├─ Evening Tasks Card
    │   ├─ Material Balance
    │   └─ Upload Photos
    └─ View History
```

## 📋 Excel Sheet Integration
- Import/Export functionality
- Follow existing Excel format
- Sync with database
- Generate reports in Excel format

## 🔐 Permissions

| Feature | Site Engineer | Accountant | Chief Accountant | Owner |
|---------|--------------|------------|------------------|-------|
| Enter Labor Count | ✅ | ✅ | ✅ | ❌ |
| Modify Labor Count | ❌ | ✅ | ✅ | ❌ |
| Enter Material Balance | ✅ | ✅ | ✅ | ❌ |
| Upload Photos | ✅ | ✅ | ✅ | ❌ |
| View All Sites | ❌ | ✅ | ✅ | ✅ |
| Receive Notifications | ❌ | ✅ | ✅ | ✅ |
| Modify Entries | ❌ | ✅ | ✅ | ❌ |

## 🚀 Implementation Phases

### Phase 1: Foundation (Current)
- ✅ Authentication
- ✅ User profiles
- ⏳ Role management

### Phase 2: Core Features
- Site management
- Daily entry forms
- Labor count tracking
- Material balance

### Phase 3: Media & Notifications
- Photo upload
- Cloud storage
- Push notifications
- Email alerts

### Phase 4: Reports & Analytics
- Dashboard
- Excel export
- Analytics
- History viewing

## 📱 Technology Stack

### Frontend:
- Flutter (Mobile & Web)
- Material Design 3

### Backend:
- Firebase Firestore (Database)
- Firebase Storage (Photos)
- Firebase Cloud Messaging (Notifications)
- Firebase Cloud Functions (Scheduled checks)

### Optional:
- Django backend (for complex logic)
- Excel integration library

## 🎯 Next Steps

1. Enable Firestore database
2. Set up user roles
3. Create site management
4. Build daily entry forms
5. Implement photo upload
6. Set up notifications
7. Create reports

---

**Ready to start building?** Let me know and I'll create the complete implementation!
