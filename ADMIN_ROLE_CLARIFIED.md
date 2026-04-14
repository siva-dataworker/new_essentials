# 🔐 ADMIN ROLE - CLARIFIED

## ✅ WHAT ADMIN CAN DO

### 1. User Management (ONLY)
Admin's PRIMARY job is to manage user registrations:

#### When User Registers:
1. User fills registration form in mobile app
2. User data appears in Supabase `users` table with `status = 'PENDING'`
3. Admin sees:
   - Username
   - Email
   - Phone
   - Full Name
   - **Role** (Supervisor, Site Engineer, Accountant, Architect, Owner)
   - Registration date

#### Admin Actions:
1. **Review** the user details
2. **Change status** from `PENDING` to `APPROVED`
3. **Click Save/Confirm**
4. User can now login

---

## ❌ WHAT ADMIN CANNOT DO

### Admin CANNOT Modify:
- ❌ Labour counts (entered by Supervisor)
- ❌ Material balances (entered by Supervisor)
- ❌ Work updates (entered by Site Engineer)
- ❌ Bills (uploaded by Accountant)
- ❌ Complaints (raised by Architect)

### Admin CAN ONLY VIEW (Read-Only):
- ✅ View all labour entries
- ✅ View all material balances
- ✅ View all work updates
- ✅ View all bills
- ✅ View all complaints
- ✅ Export data for reports

**Admin is READ-ONLY for all operational data!**

---

## 📊 ADMIN WORKFLOW

### Step 1: User Registers in Mobile App
```
User fills form:
- Username: john_doe
- Email: john@example.com
- Phone: 9876543210
- Password: ********
- Full Name: John Doe
- Role: Supervisor  ← This is important!
```

### Step 2: Data Appears in Supabase
Admin goes to Supabase → Table Editor → `users` table

Sees new row:
| username | email | phone | full_name | role_id | status |
|----------|-------|-------|-----------|---------|--------|
| john_doe | john@example.com | 9876543210 | John Doe | 2 | PENDING |

**Role ID Mapping:**
- 1 = Admin
- 2 = Supervisor ← User selected this
- 3 = Site Engineer
- 4 = Accountant
- 5 = Architect
- 6 = Owner

### Step 3: Admin Reviews
Admin checks:
- ✅ Is this person authorized?
- ✅ Is the role correct?
- ✅ Are the details valid?

### Step 4: Admin Approves
1. Click on the `status` cell
2. Change from `PENDING` to `APPROVED`
3. Press Enter or click Save
4. Done!

### Step 5: User Can Login
- User tries to login
- System checks: status = APPROVED ✅
- User gets access to Supervisor Dashboard

---

## 🖥️ HOW TO APPROVE USERS IN SUPABASE

### Method 1: Table Editor (Visual)
1. Go to: https://supabase.com/dashboard
2. Select project: `ctwthgjuccioxivnzifb`
3. Click: **Table Editor** (left sidebar)
4. Click: **users** table
5. Find row with `status = 'PENDING'`
6. Click on `status` cell
7. Type: `APPROVED`
8. Press: Enter
9. Done! ✅

### Method 2: SQL Editor (Bulk)
1. Go to: **SQL Editor** (left sidebar)
2. Click: **New query**
3. Paste this:

```sql
-- View all pending users with their roles
SELECT 
    u.username,
    u.email,
    u.phone,
    u.full_name,
    r.role_name,  -- Shows "Supervisor", "Site Engineer", etc.
    u.status,
    u.created_at
FROM users u
LEFT JOIN roles r ON u.role_id = r.id
WHERE u.status = 'PENDING'
ORDER BY u.created_at DESC;
```

4. Click: **Run**
5. See all pending users with their selected roles

6. To approve a specific user:
```sql
UPDATE users 
SET status = 'APPROVED', approved_at = NOW()
WHERE username = 'john_doe';
```

7. To approve ALL pending users at once:
```sql
UPDATE users 
SET status = 'APPROVED', approved_at = NOW()
WHERE status = 'PENDING';
```

---

## 📋 ADMIN DASHBOARD VIEW

### What Admin Sees in Supabase:

#### Users Table:
| Column | Description | Admin Can Edit? |
|--------|-------------|-----------------|
| username | User's login name | ❌ No |
| email | User's email | ❌ No |
| phone | User's phone | ❌ No |
| full_name | User's full name | ❌ No |
| role_id | User's role (1-6) | ⚠️ Only if needed |
| **status** | PENDING/APPROVED/REJECTED | ✅ **YES - Main job!** |
| is_active | Active/Inactive | ✅ Yes (to suspend) |
| created_at | Registration date | ❌ No |

#### Labour Entries Table (READ-ONLY):
| Column | Description | Admin Can Edit? |
|--------|-------------|-----------------|
| entry_date | Date of entry | ❌ No |
| site_id | Which site | ❌ No |
| supervisor_id | Who entered | ❌ No |
| labour_count | Number of workers | ❌ **NO - Read only!** |
| labour_type | Type of labour | ❌ No |
| is_modified | Was it changed? | ❌ No |
| modified_by | Who changed it | ❌ No |

**Admin can ONLY VIEW, not modify!**

#### Material Balances Table (READ-ONLY):
| Column | Description | Admin Can Edit? |
|--------|-------------|-----------------|
| entry_date | Date of entry | ❌ No |
| site_id | Which site | ❌ No |
| supervisor_id | Who entered | ❌ No |
| material_type | Type of material | ❌ **NO - Read only!** |
| quantity | Amount | ❌ **NO - Read only!** |
| unit | Unit of measure | ❌ No |

**Admin can ONLY VIEW, not modify!**

---

## 🎯 ADMIN'S ONLY JOB

### Primary Responsibility:
**Approve or Reject user registrations**

### Secondary Responsibilities:
- View all data (read-only)
- Export reports
- Suspend users (set is_active = false)
- Monitor system activity

### NOT Admin's Job:
- ❌ Modify labour counts
- ❌ Modify material balances
- ❌ Enter any operational data
- ❌ Change work updates
- ❌ Modify bills or payments

---

## 📱 EXAMPLE SCENARIO

### Scenario: New Supervisor Registers

**Step 1: User Action (Mobile App)**
```
Ravi Kumar registers:
- Username: ravi_kumar
- Email: ravi@example.com
- Phone: 9876543210
- Password: SecurePass123
- Full Name: Ravi Kumar
- Role: Supervisor  ← Selected from dropdown
```

**Step 2: System Action**
```
Database creates record:
- status = 'PENDING'
- role_id = 2 (Supervisor)
- User sees: "Waiting for admin approval"
```

**Step 3: Admin Action (Supabase)**
```
Admin logs into Supabase
Goes to users table
Sees: ravi_kumar | ravi@example.com | 9876543210 | Ravi Kumar | Supervisor | PENDING
Clicks on status cell
Changes to: APPROVED
Saves
```

**Step 4: User Can Login**
```
Ravi tries to login
System checks: status = APPROVED ✅
Ravi gets access to Supervisor Dashboard
Ravi can now:
- Select sites
- Enter labour counts
- Enter material balances
```

**Step 5: Admin Monitors (Read-Only)**
```
Admin can view:
- Ravi's labour entries (cannot modify)
- Ravi's material balances (cannot modify)
- Export data for reports
```

---

## ✅ SUMMARY

### Admin's Role:
1. **Approve/Reject** user registrations
2. **View** all data (read-only)
3. **Export** reports
4. **Suspend** users if needed

### Admin CANNOT:
- Modify labour counts
- Modify material balances
- Modify any operational data

### Admin Uses:
- ✅ Supabase Dashboard (admin panel)
- ❌ Mobile App (not for admin)

---

**Admin = Gatekeeper + Monitor, NOT Data Entry!**
