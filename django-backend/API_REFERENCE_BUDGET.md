# Budget Management API Reference

Quick reference for all budget management endpoints.

## Authentication

All endpoints require JWT authentication:
```
Authorization: Bearer YOUR_JWT_TOKEN
```

Get token from login endpoint:
```bash
POST /api/auth/login/
Body: {"email": "admin@example.com", "password": "password"}
```

## Endpoints

### 1. Set Budget

Allocate or update budget for a site (Admin only).

**Endpoint**: `POST /api/admin/sites/budget/set/`

**Request**:
```json
{
  "site_id": "uuid-string",
  "budget_amount": 5000000.00
}
```

**Response** (201 Created):
```json
{
  "success": true,
  "budget": {
    "budget_id": "uuid-string",
    "site_id": "uuid-string",
    "site_name": "Site Name",
    "allocated_amount": 5000000.00,
    "utilized_amount": 0.00,
    "remaining_amount": 5000000.00,
    "allocated_by": "Admin Name",
    "allocated_at": "2024-01-15T10:30:00Z",
    "is_active": true
  }
}
```

**Errors**:
- 400: Invalid budget amount or site not found
- 403: User is not an admin
- 401: Invalid or missing token

---

### 2. Get Budget

Get active budget for a specific site (Admin/Accountant).

**Endpoint**: `GET /api/admin/sites/{site_id}/budget/`

**Response** (200 OK):
```json
{
  "success": true,
  "budget": {
    "budget_id": "uuid-string",
    "site_id": "uuid-string",
    "site_name": "Site Name",
    "allocated_amount": 5000000.00,
    "utilized_amount": 1500000.00,
    "remaining_amount": 3500000.00,
    "allocated_by": "Admin Name",
    "allocated_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-20T14:20:00Z",
    "is_active": true
  }
}
```

**Errors**:
- 404: No active budget found
- 403: Access denied
- 401: Invalid or missing token

---

### 3. Get Budget Utilization

Get budget utilization statistics (Admin/Accountant).

**Endpoint**: `GET /api/admin/sites/{site_id}/budget/utilization/`

**Response** (200 OK):
```json
{
  "success": true,
  "site_id": "uuid-string",
  "allocated_amount": 5000000.00,
  "utilized_amount": 1500000.00,
  "remaining_amount": 3500000.00,
  "utilization_percentage": 30.00
}
```

**Errors**:
- 404: No active budget found
- 403: Access denied
- 401: Invalid or missing token

---

### 4. Get All Sites Budgets

Get budgets for all sites (Admin only).

**Endpoint**: `GET /api/admin/budgets/all/`

**Response** (200 OK):
```json
{
  "success": true,
  "budgets": [
    {
      "budget_id": "uuid-string",
      "site_id": "uuid-string",
      "site_name": "Site 1",
      "allocated_amount": 5000000.00,
      "utilized_amount": 1500000.00,
      "remaining_amount": 3500000.00,
      "allocated_by": "Admin Name",
      "allocated_at": "2024-01-15T10:30:00Z",
      "updated_at": "2024-01-20T14:20:00Z",
      "is_active": true
    },
    {
      "site_id": "uuid-string",
      "site_name": "Site 2",
      "allocated_amount": 0,
      "utilized_amount": 0,
      "remaining_amount": 0,
      "has_budget": false
    }
  ],
  "count": 2
}
```

**Errors**:
- 403: User is not an admin
- 401: Invalid or missing token

---

### 5. Get Real-time Updates

Get pending real-time updates (Admin/Accountant).

**Endpoint**: `GET /api/admin/realtime-updates/`

**Query Parameters**:
- `last_sync` (optional): ISO timestamp of last sync
- `site_id` (optional): Filter by specific site UUID

**Example**:
```
GET /api/admin/realtime-updates/?last_sync=2024-01-15T10:00:00Z&site_id=uuid-string
```

**Response** (200 OK):
```json
{
  "success": true,
  "updates": [
    {
      "update_id": "uuid-string",
      "site_id": "uuid-string",
      "site_name": "Site Name",
      "update_type": "LABOUR_ENTRY",
      "record_type": "labour_entries",
      "record_id": "uuid-string",
      "action": "CREATE",
      "changed_by": "Supervisor Name",
      "changed_at": "2024-01-15T10:15:00Z"
    },
    {
      "update_id": "uuid-string",
      "site_id": "uuid-string",
      "site_name": "Site Name",
      "update_type": "BUDGET_UPDATE",
      "record_type": "site_budgets",
      "record_id": "uuid-string",
      "action": "CREATE",
      "changed_by": "Admin Name",
      "changed_at": "2024-01-15T10:30:00Z"
    }
  ],
  "count": 2
}
```

**Update Types**:
- `LABOUR_ENTRY` - New labour entry submitted
- `LABOUR_CORRECTION` - Labour entry corrected by accountant
- `BILL_UPLOAD` - Material bill uploaded
- `BUDGET_UPDATE` - Budget allocated or updated

**Errors**:
- 400: Invalid query parameters
- 403: Access denied
- 401: Invalid or missing token

---

### 6. Get Audit Trail

Get audit trail for a site (Admin only).

**Endpoint**: `GET /api/admin/sites/{site_id}/audit-trail/`

**Query Parameters**:
- `table_name` (optional): Filter by table name
- `changed_by` (optional): Filter by user UUID
- `date_from` (optional): Filter from date (ISO format)
- `date_to` (optional): Filter to date (ISO format)
- `page` (optional): Page number (default: 1)
- `page_size` (optional): Records per page (default: 50, max: 100)

**Example**:
```
GET /api/admin/sites/{site_id}/audit-trail/?table_name=site_budgets&page=1&page_size=20
```

**Response** (200 OK):
```json
{
  "success": true,
  "logs": [
    {
      "audit_id": "uuid-string",
      "table_name": "site_budgets",
      "record_id": "uuid-string",
      "field_name": "allocated_amount",
      "old_value": null,
      "new_value": "5000000.00",
      "change_type": "CREATE",
      "changed_by": "Admin Name",
      "changed_by_role": "Admin",
      "changed_at": "2024-01-15T10:30:00Z",
      "reason": null
    },
    {
      "audit_id": "uuid-string",
      "table_name": "labour_entries",
      "record_id": "uuid-string",
      "field_name": "labour_count",
      "old_value": "30",
      "new_value": "25",
      "change_type": "UPDATE",
      "changed_by": "Accountant Name",
      "changed_by_role": "Accountant",
      "changed_at": "2024-01-15T14:20:00Z",
      "reason": "Supervisor counted incorrectly"
    }
  ],
  "total_count": 45,
  "page": 1,
  "page_size": 20,
  "has_next": true
}
```

**Change Types**:
- `CREATE` - New record created
- `UPDATE` - Record modified
- `DELETE` - Record deleted

**Errors**:
- 400: Invalid query parameters
- 403: User is not an admin
- 401: Invalid or missing token

---

## cURL Examples

### Set Budget
```bash
curl -X POST http://localhost:8000/api/admin/sites/budget/set/ \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "site_id": "123e4567-e89b-12d3-a456-426614174000",
    "budget_amount": 5000000.00
  }'
```

### Get Budget
```bash
curl -X GET http://localhost:8000/api/admin/sites/123e4567-e89b-12d3-a456-426614174000/budget/ \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Get Real-time Updates
```bash
curl -X GET "http://localhost:8000/api/admin/realtime-updates/?last_sync=2024-01-15T10:00:00Z" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Get Audit Trail
```bash
curl -X GET "http://localhost:8000/api/admin/sites/123e4567-e89b-12d3-a456-426614174000/audit-trail/?page=1&page_size=20" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## Error Responses

All endpoints return consistent error responses:

**400 Bad Request**:
```json
{
  "error": "Budget amount must be positive"
}
```

**401 Unauthorized**:
```json
{
  "detail": "Authentication credentials were not provided."
}
```

**403 Forbidden**:
```json
{
  "error": "Only admins can allocate budgets"
}
```

**404 Not Found**:
```json
{
  "success": false,
  "error": "No active budget found"
}
```

---

## Rate Limiting

- No rate limiting currently implemented
- Recommended: 100 requests/minute per user

## Data Types

- **UUID**: String format `"123e4567-e89b-12d3-a456-426614174000"`
- **Decimal**: Number with 2 decimal places `5000000.00`
- **DateTime**: ISO 8601 format `"2024-01-15T10:30:00Z"`
- **Boolean**: `true` or `false`

## Best Practices

1. **Always include Authorization header** with valid JWT token
2. **Use UUID strings** for site_id and user_id parameters
3. **Handle errors gracefully** - check response status codes
4. **Use pagination** for audit trail queries
5. **Filter updates** by last_sync timestamp for efficiency
6. **Validate input** before sending requests

## Testing

Use the provided test script:
```bash
cd django-backend
python test_budget_apis.py
```

Update credentials in the script before running.

---

**Last Updated**: February 2024
**API Version**: 1.0
**Base URL**: `http://localhost:8000/api`
