# DATA ISOLATION & MULTI-USER SYSTEM EXPLAINED

## Overview
Your construction management system is designed with **complete data isolation** between users. Each user sees only the data they should see based on their role.

---

## How It Works

### 1. User Authentication & JWT Token

When a user logs in, they receive a JWT token containing their unique information:

```json
{
  "user_id": "5be9eb15-da04-4721-8fa2-ed5baf57a802",
  "username": "nsnwjw",
  "email": "user@example.com",
  "role": "Supervisor"
}
```

This token is sent with **every API request** to identify who is making the request.

---

### 2. Data Storage with User ID

When a supervisor submits labour or material entries, the system automatically stores **their user_id**:

```sql
INSERT INTO labour_entries 
(id, site_id, supervisor_id, labour_count, labour_type, entry_date)
VALUES (
  'entry-uuid',
  'site-uuid',
  '5be9eb15-da04-4721-8fa2-ed5baf57a802',  -- ← Supervisor's user_id from JWT
  10,
  'Mason',
  '2025-12-26'
)
```

---

### 3. Role-Based Data Access

## 🔵 SUPERVISOR Role

**What they can do:**
- Submit labour counts
- Submit material balances
- Upload site images
- View their own history

**What they see:**
```sql
-- Supervisor History Query
SELECT * FROM labour_entries 
WHERE supervisor_id = 'THEIR_USER_ID'
```

**Example:**
- Supervisor `nsnwjw` (ID: 5be9eb15...) sees ONLY entries where `supervisor_id = 5be9eb15...`
- Supervisor `ravi` (ID: abc123...) sees ONLY entries where `supervisor_id = abc123...`
- They **CANNOT** see each other's data

---

## 🟢 ACCOUNTANT Role

**What they can do:**
- View ALL labour and material entries from ALL supervisors
- Modify labour counts (with reason)
- Upload material bills
- Upload extra work bills

**What they see:**
```sql
-- Accountant Query
SELECT l.*, u.full_name as supervisor_name
FROM labour_entries l
JOIN users u ON l.supervisor_id = u.id
ORDER BY l.entry_date DESC
```

**Example:**
Accountant sees:
- 10 Mason by nsnwjw at Site A
- 8 Carpenter by ravi at Site B
- 5 Plumber by kumar at Site C

Each entry shows **which supervisor submitted it**.

---

## 🔴 ADMIN Role

**What they can do:**
- Approve/reject new user registrations
- View all users
- Manage user accounts

**What they see:**
- All users in the system
- User approval status
- User activity

---

## Real-World Example

### Scenario: 3 Supervisors Working on Different Sites

#### Day 1 Morning:

**Supervisor 1: nsnwjw**
- Site: Rajiv Nagar, Plot 12
- Submits: 10 Mason, 5 Carpenter
- Database stores: `supervisor_id = 5be9eb15...`

**Supervisor 2: ravi**
- Site: Gandhi Street, House 5
- Submits: 8 Mason, 3 Plumber
- Database stores: `supervisor_id = abc123...`

**Supervisor 3: kumar**
- Site: MG Road, Villa 8
- Submits: 12 Electrician, 4 Helper
- Database stores: `supervisor_id = xyz789...`

#### When They Check History:

**nsnwjw's History Tab:**
```
Today
  Rajiv Nagar, Plot 12
  • 10 Mason
  • 5 Carpenter
```
❌ Cannot see ravi's or kumar's entries

**ravi's History Tab:**
```
Today
  Gandhi Street, House 5
  • 8 Mason
  • 3 Plumber
```
❌ Cannot see nsnwjw's or kumar's entries

**kumar's History Tab:**
```
Today
  MG Road, Villa 8
  • 12 Electrician
  • 4 Helper
```
❌ Cannot see nsnwjw's or ravi's entries

#### Accountant Dashboard:

**Labour Entries Tab:**
```
Today
  Rajiv Nagar, Plot 12 - by nsnwjw
  • 10 Mason
  • 5 Carpenter

  Gandhi Street, House 5 - by ravi
  • 8 Mason
  • 3 Plumber

  MG Road, Villa 8 - by kumar
  • 12 Electrician
  • 4 Helper
```
✅ Sees ALL entries from ALL supervisors

---

## Database Structure

### labour_entries Table

```
┌──────────────────────────────────────┬─────────────┬──────────────────────────────────────┬──────────────┐
│ id                                   │ labour_type │ supervisor_id                        │ labour_count │
├──────────────────────────────────────┼─────────────┼──────────────────────────────────────┼──────────────┤
│ entry-1                              │ Mason       │ 5be9eb15... (nsnwjw)                 │ 10           │
│ entry-2                              │ Carpenter   │ 5be9eb15... (nsnwjw)                 │ 5            │
│ entry-3                              │ Mason       │ abc123... (ravi)                     │ 8            │
│ entry-4                              │ Plumber     │ abc123... (ravi)                     │ 3            │
│ entry-5                              │ Electrician │ xyz789... (kumar)                    │ 12           │
│ entry-6                              │ Helper      │ xyz789... (kumar)                    │ 4            │
└──────────────────────────────────────┴─────────────┴──────────────────────────────────────┴──────────────┘
```

### Query Results by Role

**nsnwjw queries history:**
```sql
WHERE supervisor_id = '5be9eb15...'
```
Returns: entry-1, entry-2 only ✅

**ravi queries history:**
```sql
WHERE supervisor_id = 'abc123...'
```
Returns: entry-3, entry-4 only ✅

**Accountant queries all:**
```sql
SELECT * FROM labour_entries
```
Returns: ALL 6 entries ✅

---

## Security Features

### 1. JWT Token Validation
Every API request validates the JWT token to ensure:
- Token is valid and not expired
- User exists in the database
- User has permission for the requested action

### 2. Database-Level Isolation
Queries automatically filter by `supervisor_id` from the JWT token:
```python
user_id = request.user['user_id']  # From JWT token
query = "SELECT * FROM labour_entries WHERE supervisor_id = %s"
results = fetch_all(query, (user_id,))
```

### 3. Role-Based Access Control
Different endpoints for different roles:
- `/api/construction/supervisor/history/` - Only supervisor's own data
- `/api/construction/accountant/all-entries/` - All data with supervisor names

---

## Testing Data Isolation

Run the verification script to test:

```bash
cd django-backend
python verify_data_isolation.py
```

This will:
1. Create test entries for each supervisor
2. Verify each supervisor sees only their own data
3. Verify accountant sees all data
4. Confirm data isolation is working

---

## Common Questions

### Q: Can one supervisor see another supervisor's data?
**A:** No. Each supervisor sees only entries where `supervisor_id = their_user_id`.

### Q: Can a supervisor modify their submitted entries?
**A:** No. Once submitted, entries are read-only for supervisors. Only accountants can modify them.

### Q: What if two supervisors work on the same site?
**A:** Each supervisor's entries are stored separately with their own `supervisor_id`. Both can submit entries for the same site, and both will appear in the accountant's view with their respective names.

### Q: Can data get mixed up between users?
**A:** No. The `supervisor_id` is taken directly from the JWT token, which is unique per user. There's no way for data to get mixed up.

### Q: What happens if a supervisor logs out and logs back in?
**A:** They get a new JWT token with the same `user_id`, so they still see all their previous entries.

---

## Summary

✅ **Each user has a unique user_id (UUID)**  
✅ **JWT token contains user_id for every request**  
✅ **Database stores supervisor_id with every entry**  
✅ **Queries filter by supervisor_id automatically**  
✅ **Supervisors see ONLY their own data**  
✅ **Accountants see ALL data with supervisor names**  
✅ **No risk of data collision or mixing**  
✅ **Complete data isolation guaranteed**  

Your system is designed correctly for multi-user operation with complete data isolation! 🎉
