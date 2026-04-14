# Clear Working Sites API

## Overview
API endpoint to clear/remove all current working sites, allowing accountant to re-select them.

## Endpoint

### Clear Working Sites
**POST** `/api/construction/clear-working-sites/`

Deactivates all currently active working sites.

#### Authentication
- Requires JWT token
- Only **Accountant** role can access

#### Request
```http
POST /api/construction/clear-working-sites/
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

No request body required.

#### Response

**Success (200 OK)**
```json
{
  "success": true,
  "message": "Successfully cleared 15 working site(s)",
  "cleared_count": 15
}
```

**Error (403 Forbidden)**
```json
{
  "error": "Only accountants can clear working sites"
}
```

**Error (500 Internal Server Error)**
```json
{
  "error": "Error clearing working sites: <error_message>"
}
```

## Usage Flow

### 1. Clear Current Working Sites
```bash
curl -X POST "http://192.168.1.11:8000/api/construction/clear-working-sites/" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json"
```

### 2. Re-select Working Sites
After clearing, use the assign endpoint to select new sites:
```bash
curl -X POST "http://192.168.1.11:8000/api/construction/assign-working-sites/" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "sites": [
      {"site_id": "uuid-1", "description": "Site 1"},
      {"site_id": "uuid-2", "description": "Site 2"}
    ]
  }'
```

## What Happens When You Clear

1. **All active working sites are deactivated**
   - Sets `is_active = FALSE` for all working sites
   - Updates `updated_at` timestamp

2. **Supervisors lose access**
   - Supervisors will no longer see these sites in their working sites list
   - They cannot submit entries for cleared sites

3. **Data is preserved**
   - Working sites records are not deleted
   - Historical data remains in database
   - Only the `is_active` flag changes

4. **Ready for re-selection**
   - Accountant can now select new working sites
   - Can select same sites again or different ones

## Use Cases

### Daily Re-selection
```
Morning:
1. Accountant clears yesterday's working sites
2. Accountant selects today's working sites
3. Supervisors see only today's sites
```

### Mid-day Changes
```
During the day:
1. Need to change working sites
2. Clear current sites
3. Select new sites
4. Supervisors immediately see updated list
```

### Emergency Reset
```
If something goes wrong:
1. Clear all working sites
2. Start fresh with new selection
3. No data loss, just reset active status
```

## Frontend Integration

### Flutter/Dart Example
```dart
Future<void> clearWorkingSites() async {
  final token = await _authService.getToken();
  
  final response = await http.post(
    Uri.parse('${AuthService.baseUrl}/construction/clear-working-sites/'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    print('Cleared ${data['cleared_count']} sites');
    // Now show site selection UI
  }
}
```

## Database Impact

### Before Clear
```sql
SELECT * FROM working_sites WHERE is_active = TRUE;
-- Returns: 15 active sites
```

### After Clear
```sql
SELECT * FROM working_sites WHERE is_active = TRUE;
-- Returns: 0 active sites

SELECT * FROM working_sites WHERE is_active = FALSE;
-- Returns: 15 inactive sites (preserved)
```

## Notes

- **Instant Effect**: Changes take effect immediately
- **All Supervisors**: Affects all supervisors at once
- **Reversible**: Can re-assign same sites if needed
- **Audit Trail**: `updated_at` timestamp tracks when cleared
- **Safe Operation**: No data deletion, only status change

## Testing

Use the provided test script:
```bash
cd django-backend
python test_clear_working_sites.py
```

Or test manually:
1. Login as accountant to get JWT token
2. Call clear endpoint
3. Verify response shows cleared count
4. Check supervisor's working sites list (should be empty)
5. Re-assign sites
6. Verify supervisor sees new sites
