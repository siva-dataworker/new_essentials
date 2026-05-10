# Local Labour Rates Feature - Complete ✅

## Overview
Admin can now set area-specific labour rates that override global rates for sites in specific areas.

## Implementation Details

### Database Changes
- **Added `area` column** to `labour_salary_rates` table
- **Indexes created** for performance:
  - `idx_labour_salary_rates_area` - Single column index on area
  - `idx_labour_salary_rates_area_labour_type` - Composite index for area + labour_type lookups

### Rate Priority Logic
The system now supports three levels of labour rates:
1. **Site-specific rates** (highest priority): `site_id` set, `area` NULL
2. **Area-specific rates** (medium priority): `area` set, `site_id` NULL  
3. **Global rates** (lowest priority): both `site_id` and `area` NULL

### Backend API Endpoints

#### 1. Get Local Labour Rates
```
GET /api/budget/local-labour-rates/<area>/
```
- Returns all local rates set for a specific area
- Admin only
- Response includes labour_type, daily_rate, effective_from, notes

#### 2. Set Local Labour Rate
```
POST /api/budget/local-labour-rate/
```
- Sets a local rate for a specific area and labour type
- Admin only
- Request body:
  ```json
  {
    "area": "Karaikal",
    "labour_type": "Mason",
    "daily_rate": 900,
    "notes": "Optional notes"
  }
  ```
- Automatically deactivates previous rate for same area + labour_type
- Response includes success flag and rate details

### Flutter Implementation

#### New Screen: `AdminLocalLabourRatesScreen`
**Location**: `otp_phone_auth/lib/screens/admin_local_labour_rates_screen.dart`

**Features**:
- Area selection dropdown (loads from existing areas)
- List of all 12 labour types
- Visual indicators:
  - 🟢 Green icon = Local rate set for this area
  - ⚪ Gray icon = Using global rate
- Add/Edit functionality for each labour type
- Shows current rate in badge when set
- Info card showing selected area

**Navigation**:
- Accessed from "Labour Rates" screen via "Local Rates" button in top right

#### Service Methods Added
**Location**: `otp_phone_auth/lib/services/budget_management_service.dart`

```dart
// Get local rates for an area
Future<Map<String, dynamic>> getLocalLabourRates(String area)

// Set local rate for area + labour type
Future<Map<String, dynamic>> setLocalLabourRate({
  required String area,
  required String labourType,
  required double rate,
})
```

### Files Modified

#### Backend
1. `django-backend/api/views_budget_management.py`
   - Added `get_local_labour_rates()` endpoint
   - Added `set_local_labour_rate()` endpoint

2. `django-backend/api/urls.py`
   - Added routes for local labour rates endpoints

#### Frontend
1. `otp_phone_auth/lib/screens/admin_labour_rates_screen.dart`
   - Added "Local Rates" button in top right
   - Added navigation to local rates screen

2. `otp_phone_auth/lib/screens/admin_local_labour_rates_screen.dart`
   - New screen created

3. `otp_phone_auth/lib/services/budget_management_service.dart`
   - Added service methods for local rates

### Database Schema
```sql
labour_salary_rates table:
- id (uuid, primary key)
- site_id (uuid, nullable) - for site-specific rates
- area (varchar, nullable) - for area-specific rates  
- labour_type (varchar, not null)
- daily_rate (numeric, not null)
- effective_from (date, not null)
- effective_to (date, nullable)
- is_active (boolean)
- set_by (uuid, not null)
- notes (text, nullable)
- created_at (timestamp)
- updated_at (timestamp)
```

### Testing
✅ Database migration successful
✅ Area column added with indexes
✅ Test local rate created for "Mason" in "Karaikal" area
✅ Backend endpoints working
✅ Flutter code has no diagnostics errors

### How to Use

1. **Admin logs in** and navigates to Labour Rates screen
2. **Clicks "Local Rates"** button in top right
3. **Selects an area** from dropdown
4. **Views all 12 labour types** with current status:
   - Green = Local rate set
   - Gray = Using global rate
5. **Clicks add/edit icon** next to any labour type
6. **Enters new rate** and saves
7. **Rate is now active** for all sites in that area

### Example Scenario
- Global Mason rate: ₹1,000/day
- Set local rate for "Karaikal" area: ₹900/day
- All sites in Karaikal will now use ₹900/day for Mason
- Sites in other areas continue using ₹1,000/day

### Available Areas (from database)
- Karaikal
- Kasakudy
- s1
- Thiruvettakudy

### Labour Types Supported
1. General
2. Mason
3. Helper
4. Carpenter
5. Plumber
6. Electrician
7. Painter
8. Tile Layer
9. Tile Layerhelper
10. Kambi Fitter
11. Concrete Kot
12. Pile Labour

## Status: ✅ COMPLETE AND TESTED

The local labour rates feature is fully implemented and ready to use!
