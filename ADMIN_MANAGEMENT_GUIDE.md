# 🔐 ADMIN MANAGEMENT GUIDE

## 📋 ADMIN ROLE CLARIFICATION

**Admin does NOT use the mobile app.**

Admin manages everything through **Supabase Dashboard** (the admin panel).

---

## 🎯 ADMIN RESPONSIBILITIES

### 1. User Management
- Approve/Reject new user registrations
- Activate/Deactivate users
- Change user roles
- Reset passwords
- View user activity

### 2. Site Management
- Add new sites (Area, Street, Customer, Site details)
- Edit site information
- Activate/Deactivate sites
- Assign sites to supervisors

### 3. Data Management
- View all labour entries
- View all material balances
- View all bills and payments
- View all complaints
- Export data for reports

### 4. System Configuration
- Manage roles and permissions
- Configure notification settings
- Set business rules (e.g., labour entry deadlines)
- Manage material types

---

## 🖥️ HOW ADMIN MANAGES THE SYSTEM

### Access Supabase Dashboard:
1. Go to: **https://supabase.com/dashboard**
2. Login with your Supabase account
3. Select your project: `ctwthgjuccioxivnzifb`

---

## 📊 ADMIN TASKS IN SUPABASE

### Task 1: Approve New Users
**When**: After someone registers in the mobile app

**Steps**:
1. Go to **Table Editor** → **users** table
2. Find users with `status = 'PENDING'`
3. Click on the row to edit
4. Change `status` from `PENDING` to `APPROVED`
5. Save

**Alternative (SQL)**:
```sql
-- View pending users
SELECT username, email, phone, role_id, created_at 
FROM users 
WHERE status = 'PENDING';

-- Approve a user
UPDATE users 
SET status = 'APPROVED', approved_at = NOW()
WHERE username = 'username_here';

-- Reject a user
UPDATE users 
SET status = 'REJECTED'
WHERE username = 'username_here';
```

---

### Task 2: Add New Sites
**When**: New construction site starts

**Steps**:
1. Go to **Table Editor** → **sites** table
2. Click **Insert row**
3. Fill in:
   - `area`: (e.g., Kasakudy)
   - `street`: (e.g., Saudha Garden)
   - `customer_name`: (e.g., Sumaya)
   - `site_name`: (e.g., 1 18 Sasikumar)
4. Click **Save**

**Alternative (SQL)**:
```sql
INSERT INTO sites (area, street, customer_name, site_name)
VALUES ('Kasakudy', 'Saudha Garden', 'Sumaya', '1 18 Sasikumar');
```

---

### Task 3: View Labour Entries
**When**: Daily monitoring of labour attendance

**Steps**:
1. Go to **Table Editor** → **labour_entries** table
2. View all entries
3. Filter by date, site, or supervisor
4. Export to CSV if needed

**SQL Queries**:
```sql
-- Today's labour entries
SELECT 
    l.entry_date,
    s.customer_name,
    s.site_name,
    l.labour_count,
    l.labour_type,
    u.username as supervisor
FROM labour_entries l
JOIN sites s ON l.site_id = s.id
JOIN users u ON l.supervisor_id = u.id
WHERE l.entry_date = CURRENT_DATE
ORDER BY l.entry_time DESC;

-- Labour summary by site
SELECT 
    s.customer_name,
    s.site_name,
    COUNT(*) as total_entries,
    SUM(l.labour_count) as total_labour
FROM labour_entries l
JOIN sites s ON l.site_id = s.id
GROUP BY s.id, s.customer_name, s.site_name
ORDER BY total_labour DESC;
```

---

### Task 4: View Material Balances
**When**: Daily monitoring of material usage

**Steps**:
1. Go to **Table Editor** → **material_balances** table
2. View all entries
3. Filter by date, site, or material type

**SQL Queries**:
```sql
-- Today's material balances
SELECT 
    m.entry_date,
    s.customer_name,
    s.site_name,
    m.material_type,
    m.quantity,
    m.unit
FROM material_balances m
JOIN sites s ON m.site_id = s.id
WHERE m.entry_date = CURRENT_DATE
ORDER BY m.updated_at DESC;

-- Material summary by site
SELECT 
    s.customer_name,
    s.site_name,
    m.material_type,
    SUM(m.quantity) as total_quantity,
    m.unit
FROM material_balances m
JOIN sites s ON m.site_id = s.id
GROUP BY s.id, s.customer_name, s.site_name, m.material_type, m.unit
ORDER BY s.customer_name, m.material_type;
```

---

### Task 5: Manage User Roles
**When**: Need to change someone's role

**Steps**:
1. Go to **Table Editor** → **users** table
2. Find the user
3. Change `role_id`:
   - 1 = Admin
   - 2 = Supervisor
   - 3 = Site Engineer
   - 4 = Accountant
   - 5 = Architect
   - 6 = Owner
4. Save

**SQL**:
```sql
-- View all roles
SELECT * FROM roles;

-- Change user role
UPDATE users 
SET role_id = 2  -- Supervisor
WHERE username = 'username_here';
```

---

### Task 6: Deactivate Users
**When**: Employee leaves or suspended

**Steps**:
1. Go to **Table Editor** → **users** table
2. Find the user
3. Change `is_active` from `true` to `false`
4. Save

**SQL**:
```sql
-- Deactivate user
UPDATE users 
SET is_active = false
WHERE username = 'username_here';

-- Reactivate user
UPDATE users 
SET is_active = true
WHERE username = 'username_here';
```

---

### Task 7: View Audit Logs
**When**: Need to track who modified what

**Steps**:
1. Go to **Table Editor** → **audit_logs** table
2. View all modifications
3. Filter by user, action, or date

**SQL**:
```sql
-- Recent audit logs
SELECT 
    a.action,
    a.table_name,
    a.record_id,
    u.username,
    a.old_value,
    a.new_value,
    a.timestamp
FROM audit_logs a
JOIN users u ON a.performed_by = u.id
ORDER BY a.timestamp DESC
LIMIT 50;

-- Labour count modifications
SELECT 
    a.action,
    u.username as modified_by,
    a.old_value,
    a.new_value,
    a.timestamp
FROM audit_logs a
JOIN users u ON a.performed_by = u.id
WHERE a.table_name = 'labour_entries'
AND a.action = 'UPDATE'
ORDER BY a.timestamp DESC;
```

---

### Task 8: Export Data for Reports
**When**: Need to create reports or backups

**Steps**:
1. Go to **SQL Editor**
2. Run your query
3. Click **Download CSV** button
4. Open in Excel/Google Sheets

**Useful Export Queries**:
```sql
-- Complete labour report
SELECT 
    l.entry_date,
    s.area,
    s.street,
    s.customer_name,
    s.site_name,
    l.labour_type,
    l.labour_count,
    u.username as supervisor,
    l.is_modified,
    l.modified_by_name,
    l.modified_at
FROM labour_entries l
JOIN sites s ON l.site_id = s.id
JOIN users u ON l.supervisor_id = u.id
WHERE l.entry_date >= '2025-01-01'
ORDER BY l.entry_date DESC, s.customer_name;

-- Complete material report
SELECT 
    m.entry_date,
    s.area,
    s.street,
    s.customer_name,
    s.site_name,
    m.material_type,
    m.quantity,
    m.unit,
    u.username as supervisor
FROM material_balances m
JOIN sites s ON m.site_id = s.id
JOIN users u ON m.supervisor_id = u.id
WHERE m.entry_date >= '2025-01-01'
ORDER BY m.entry_date DESC, s.customer_name;
```

---

## 🚫 WHAT ADMIN DOES NOT DO

❌ Admin does NOT login to the mobile app
❌ Admin does NOT enter labour counts or material balances
❌ Admin does NOT upload images or files
❌ Admin does NOT use the field worker features

✅ Admin ONLY manages the system through Supabase Dashboard

---

## 📱 WHO USES THE MOBILE APP

| Role | Uses Mobile App | Purpose |
|------|----------------|---------|
| Admin | ❌ No | Manages via Supabase Dashboard |
| Supervisor | ✅ Yes | Enter labour count, material balance |
| Site Engineer | ✅ Yes | Upload work updates, handle complaints |
| Accountant | ✅ Yes | Verify labour, upload bills |
| Architect | ✅ Yes | Upload plans, raise complaints |
| Owner | ✅ Yes | View reports, analytics |

---

## 🔗 QUICK LINKS FOR ADMIN

- **Supabase Dashboard**: https://supabase.com/dashboard
- **Project ID**: `ctwthgjuccioxivnzifb`
- **Database Host**: `aws-1-ap-northeast-1.pooler.supabase.com`

---

## 💡 ADMIN BEST PRACTICES

1. **Daily Tasks**:
   - Check pending user registrations
   - Review labour entries
   - Monitor material usage
   - Check for missing entries

2. **Weekly Tasks**:
   - Export data for reports
   - Review audit logs
   - Check for inactive users
   - Update site information

3. **Monthly Tasks**:
   - Generate P&L reports
   - Review system performance
   - Backup database
   - Clean up old data

---

## 📞 ADMIN SUPPORT

If you need help with:
- Complex SQL queries
- Data exports
- System configuration
- Custom reports

Just ask and I'll help you create the queries or scripts!

---

**Remember**: Admin = Supabase Dashboard, NOT mobile app!
