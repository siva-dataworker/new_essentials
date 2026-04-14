# Construction Management System - API Endpoints

## Base URL
```
http://192.168.1.7:8000/api
```

## Authentication
All construction endpoints require JWT token in header:
```
Authorization: Bearer <token>
```

---

## 📝 LABOUR & MATERIAL SUBMISSION APIs

### 1. Submit Labour Count (POST)
**Endpoint**: `/construction/labour/`  
**Method**: `POST`  
**Auth**: Required (Supervisor)  
**Description**: Submit daily labour count by type

**Request Body**:
```json
{
  "site_id": "uuid-of-site",
  "labour_count": 5,
  "labour_type": "Carpenter",
  "notes": "Optional notes"
}
```

**Response** (201 Created):
```json
{
  "message": "Labour count submitted successfully",
  "entry_id": "uuid-of-entry"
}
```

**Flutter Usage**:
```dart
final result = await _constructionService.submitLabourCount(
  siteId: siteId,
  labourCount: 5,
  labourType: 'Carpenter',
);
```

---

### 2. Submit Material Balance (POST)
**Endpoint**: `/construction/material-balance/`  
**Method**: `POST`  
**Auth**: Required (Supervisor)  
**Description**: Submit material quantities

**Request Body**:
```json
{
  "site_id": "uuid-of-site",
  "materials": [
    {
      "material_type": "Bricks",
      "quantity": 1000,
      "unit": "nos"
    },
    {
      "material_type": "Cement",
      "quantity": 50,
      "unit": "bags"
    }
  ]
}
```

**Response** (201 Created):
```json
{
  "message": "Material balance submitted successfully"
}
```

**Flutter Usage**:
```dart
final materials = [
  {'material_type': 'Bricks', 'quantity': 1000, 'unit': 'nos'},
  {'material_type': 'Cement', 'quantity': 50, 'unit': 'bags'},
];

final result = await _constructionService.submitMaterialBalance(
  siteId: siteId,
  materials: materials,
);
```

---

## 📊 HISTORY & REPORTING APIs

### 3. Get Supervisor History (GET)
**Endpoint**: `/construction/supervisor/history/`  
**Method**: `GET`  
**Auth**: Required (Supervisor)  
**Description**: Get supervisor's own labour and material entry history

**Response** (200 OK):
```json
{
  "labour_entries": [
    {
      "id": "uuid",
      "labour_type": "Carpenter",
      "labour_count": 5,
      "entry_date": "2024-12-24T10:30:00Z",
      "site_name": "Customer Name Site Name",
      "area": "Area Name",
      "street": "Street Name"
    }
  ],
  "material_entries": [
    {
      "id": "uuid",
      "material_type": "Bricks",
      "quantity": 1000.0,
      "unit": "nos",
      "entry_date": "2024-12-24T15:00:00Z",
      "site_name": "Customer Name Site Name",
      "area": "Area Name",
      "street": "Street Name"
    }
  ]
}
```

**Flutter Usage**:
```dart
final history = await _constructionService.getSupervisorHistory();
final labourEntries = history['labour_entries'];
final materialEntries = history['material_entries'];
```

---

### 4. Get All Entries for Accountant (GET)
**Endpoint**: `/construction/accountant/all-entries/`  
**Method**: `GET`  
**Auth**: Required (Accountant)  
**Description**: Get ALL labour and material entries from ALL supervisors

**Response** (200 OK):
```json
{
  "labour_entries": [
    {
      "id": "uuid",
      "labour_type": "Carpenter",
      "labour_count": 5,
      "entry_date": "2024-12-24T10:30:00Z",
      "site_name": "Customer Name Site Name",
      "area": "Area Name",
      "street": "Street Name",
      "supervisor_name": "John Doe"
    }
  ],
  "material_entries": [
    {
      "id": "uuid",
      "material_type": "Bricks",
      "quantity": 1000.0,
      "unit": "nos",
      "entry_date": "2024-12-24T15:00:00Z",
      "site_name": "Customer Name Site Name",
      "area": "Area Name",
      "street": "Street Name",
      "supervisor_name": "John Doe"
    }
  ]
}
```

**Flutter Usage**:
```dart
final data = await _constructionService.getAccountantEntries();
final labourEntries = data['labour_entries'];
final materialEntries = data['material_entries'];
```

---

## 🏗️ COMMON APIs (All Roles)

### 5. Get Areas (GET)
**Endpoint**: `/construction/areas/`  
**Method**: `GET`  
**Auth**: Required  
**Description**: Get list of all areas

**Response** (200 OK):
```json
{
  "areas": ["Area 1", "Area 2", "Area 3"]
}
```

---

### 6. Get Streets by Area (GET)
**Endpoint**: `/construction/streets/{area}/`  
**Method**: `GET`  
**Auth**: Required  
**Description**: Get streets in a specific area

**Response** (200 OK):
```json
{
  "streets": ["Street 1", "Street 2", "Street 3"]
}
```

---

### 7. Get Sites (GET)
**Endpoint**: `/construction/sites/`  
**Method**: `GET`  
**Auth**: Required  
**Query Parameters**: 
- `area` (optional): Filter by area
- `street` (optional): Filter by street

**Response** (200 OK):
```json
{
  "sites": [
    {
      "id": "uuid",
      "site_name": "Site Name",
      "customer_name": "Customer Name",
      "display_name": "Customer Name Site Name"
    }
  ]
}
```

---

## 🔐 AUTHENTICATION APIs

### 8. Login (POST)
**Endpoint**: `/auth/login/`  
**Method**: `POST`  
**Auth**: Not required  

**Request Body**:
```json
{
  "username": "nsjskakaka",
  "password": "Test123"
}
```

**Response** (200 OK):
```json
{
  "access_token": "jwt-token-here",
  "user": {
    "id": "uuid",
    "username": "nsjskakaka",
    "full_name": "John Doe",
    "email": "john@example.com",
    "role": "Supervisor",
    "phone": "1234567890"
  }
}
```

---

### 9. Register (POST)
**Endpoint**: `/auth/register/`  
**Method**: `POST`  
**Auth**: Not required  

**Request Body**:
```json
{
  "username": "newuser",
  "email": "user@example.com",
  "phone": "1234567890",
  "password": "Password123",
  "full_name": "New User",
  "role": "Supervisor"
}
```

**Response** (201 Created):
```json
{
  "message": "Registration successful. Please wait for admin approval.",
  "user_id": "uuid",
  "status": "PENDING"
}
```

---

## 📋 COMPLETE FLOW EXAMPLE

### Supervisor Submits Labour and Materials

```dart
// 1. Login
final loginResult = await _authService.login(
  username: 'nsjskakaka',
  password: 'Test123',
);

// 2. Get sites
final sites = await _constructionService.getSites(
  area: 'Area 1',
  street: 'Street 1',
);

// 3. Submit labour (multiple types)
await _constructionService.submitLabourCount(
  siteId: sites[0]['id'],
  labourCount: 2,
  labourType: 'Carpenter',
);

await _constructionService.submitLabourCount(
  siteId: sites[0]['id'],
  labourCount: 3,
  labourType: 'Mason',
);

// 4. Submit materials
final materials = [
  {'material_type': 'Bricks', 'quantity': 1000, 'unit': 'nos'},
  {'material_type': 'Cement', 'quantity': 50, 'unit': 'bags'},
];

await _constructionService.submitMaterialBalance(
  siteId: sites[0]['id'],
  materials: materials,
);

// 5. Check history
final history = await _constructionService.getSupervisorHistory();
print('Labour entries: ${history['labour_entries'].length}');
print('Material entries: ${history['material_entries'].length}');
```

### Accountant Views All Data

```dart
// 1. Login as accountant
final loginResult = await _authService.login(
  username: 'accountant_username',
  password: 'password',
);

// 2. Get all entries from all supervisors
final data = await _constructionService.getAccountantEntries();

// 3. Display data
for (var entry in data['labour_entries']) {
  print('${entry['supervisor_name']}: ${entry['labour_type']} - ${entry['labour_count']}');
}

for (var entry in data['material_entries']) {
  print('${entry['supervisor_name']}: ${entry['material_type']} - ${entry['quantity']}');
}
```

---

## 🔧 IMPLEMENTATION STATUS

### ✅ Implemented & Working
1. ✅ POST `/construction/labour/` - Submit labour count
2. ✅ POST `/construction/material-balance/` - Submit materials
3. ✅ GET `/construction/supervisor/history/` - Supervisor history
4. ✅ GET `/construction/accountant/all-entries/` - Accountant view
5. ✅ GET `/construction/areas/` - Get areas
6. ✅ GET `/construction/streets/{area}/` - Get streets
7. ✅ GET `/construction/sites/` - Get sites
8. ✅ POST `/auth/login/` - Login
9. ✅ POST `/auth/register/` - Register

### 📱 Flutter Service Methods
All methods are in `otp_phone_auth/lib/services/construction_service.dart`:
- ✅ `submitLabourCount()`
- ✅ `submitMaterialBalance()`
- ✅ `getSupervisorHistory()`
- ✅ `getAccountantEntries()`
- ✅ `getAreas()`
- ✅ `getStreets()`
- ✅ `getSites()`

---

## 🐛 TROUBLESHOOTING

### Issue: Data not showing in history
**Cause**: Database UNIQUE constraint or backend not restarted  
**Solution**: 
1. Run: `python run_constraint_fix.py` (already done)
2. Restart backend: `python manage.py runserver 192.168.1.7:8000`

### Issue: "Labour count already submitted"
**Cause**: Old backend code still running  
**Solution**: Restart Django backend

### Issue: Empty response from APIs
**Cause**: No data in database  
**Solution**: Submit data from Flutter app first, then check history

---

## 📝 TESTING CHECKLIST

- [ ] Backend running on `http://192.168.1.7:8000`
- [ ] Login as supervisor works
- [ ] Can select site from feed
- [ ] Can submit multiple labour types
- [ ] Can submit multiple materials
- [ ] History tab shows submitted entries
- [ ] Login as accountant works
- [ ] Accountant sees all entries with supervisor names
- [ ] Logout works for all roles

---

## 🚀 READY TO USE

All APIs are implemented and ready. Just ensure:
1. Django backend is running
2. Database constraint is removed (already done)
3. Flutter app is connected to backend

**Test credentials**:
- Supervisor: `nsjskakaka` / `Test123`
- Admin: `admin` / `admin123`
