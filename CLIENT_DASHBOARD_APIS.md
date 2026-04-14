# Client Dashboard APIs Documentation

## Overview
Comprehensive GET APIs for client dashboard to fetch site information, labour counts, photos, and documents.

## Authentication
All endpoints require JWT authentication:
```
Authorization: Bearer <access_token>
```

Only users with role `Client` or `client` can access these endpoints.

---

## API Endpoints

### 1. Get Comprehensive Site Details
**Endpoint:** `GET /api/client/site-details/`

**Description:** Fetches all information for client's assigned sites in a single call.

**Response:**
```json
{
  "success": true,
  "sites": [
    {
      "site_id": "uuid",
      "site_name": "Site Name",
      "customer_name": "Customer Name",
      "display_name": "Customer Name Site Name",
      "area": "Area Name",
      "street": "Street Name",
      "address": "Full Address",
      "description": "Site description",
      "status": "ACTIVE",
      "assigned_date": "2026-03-27",
      "created_at": "2026-01-15",
      
      "labour_summary": {
        "total_days": 45,
        "total_labour_count": 450,
        "last_entry_date": "2026-03-27"
      },
      
      "recent_labour": [
        {
          "entry_date": "2026-03-27",
          "labour_type": "General",
          "labour_count": 10,
          "day_of_week": "Friday",
          "supervisor_name": "John Doe"
        }
      ],
      
      "photos": [
        {
          "id": "uuid",
          "photo_url": "/media/supervisor_photos/...",
          "time_of_day": "Morning",
          "description": "Work progress",
          "uploaded_date": "2026-03-27",
          "day_of_week": "Friday",
          "supervisor_name": "John Doe"
        }
      ],
      
      "architect_documents": [
        {
          "id": "uuid",
          "document_type": "FLOOR_PLAN",
          "title": "Floor Plan - Ground Floor",
          "description": "Detailed floor plan",
          "file_url": "/media/architect_documents/...",
          "file_name": "floor_plan.pdf",
          "file_size": 1024000,
          "upload_date": "2026-03-20",
          "architect_name": "Jane Smith"
        }
      ],
      
      "engineer_documents": [
        {
          "id": "uuid",
          "document_type": "SITE_PLAN",
          "title": "Site Layout",
          "description": "Site layout plan",
          "file_url": "/media/site_engineer_documents/...",
          "file_name": "site_plan.pdf",
          "file_size": 2048000,
          "upload_date": "2026-03-15",
          "engineer_name": "Bob Johnson"
        }
      ],
      
      "extra_requirements": {
        "total_amount": 15000.0,
        "entries": [
          {
            "amount": 5000.0,
            "notes": "Additional electrical work",
            "date": "2026-03-25"
          }
        ]
      }
    }
  ],
  "count": 1
}
```

**Use Case:** Single API call to populate entire client dashboard.

---

### 2. Get Labour Summary
**Endpoint:** `GET /api/client/labour-summary/?site_id=<uuid>`

**Description:** Detailed labour count information for a specific site.

**Query Parameters:**
- `site_id` (required): UUID of the site

**Response:**
```json
{
  "success": true,
  "summary": {
    "total_days": 45,
    "total_labour": 450,
    "avg_labour_per_day": 10.0,
    "first_entry_date": "2026-01-15",
    "last_entry_date": "2026-03-27"
  },
  "entries": [
    {
      "entry_date": "2026-03-27",
      "labour_type": "General",
      "labour_count": 10,
      "day_of_week": "Friday",
      "notes": "Regular work",
      "supervisor_name": "John Doe"
    }
  ]
}
```

**Use Case:** Detailed labour tracking page.

---

### 3. Get Photos
**Endpoint:** `GET /api/client/photos/?site_id=<uuid>&time_of_day=Morning`

**Description:** Get supervisor-uploaded photos for a site.

**Query Parameters:**
- `site_id` (required): UUID of the site
- `time_of_day` (optional): Filter by "Morning" or "Evening"

**Response:**
```json
{
  "success": true,
  "photos": [
    {
      "id": "uuid",
      "photo_url": "/media/supervisor_photos/...",
      "time_of_day": "Morning",
      "description": "Work started",
      "uploaded_date": "2026-03-27",
      "day_of_week": "Friday",
      "supervisor_name": "John Doe"
    }
  ],
  "count": 20
}
```

**Use Case:** Photo gallery page with filtering.

---

### 4. Get Documents
**Endpoint:** `GET /api/client/documents/?site_id=<uuid>&document_type=FLOOR_PLAN`

**Description:** Get all documents (architect + engineer) for a site.

**Query Parameters:**
- `site_id` (required): UUID of the site
- `document_type` (optional): Filter by document type
  - Architect types: `FLOOR_PLAN`, `AGREEMENT`, `ESTIMATION`, `DESIGN`, `OTHER`
  - Engineer types: `SITE_PLAN`, `STRUCTURAL_DRAWING`, `ELECTRICAL_PLAN`, `PLUMBING_PLAN`, `OTHER`

**Response:**
```json
{
  "success": true,
  "documents": [
    {
      "id": "uuid",
      "document_type": "FLOOR_PLAN",
      "title": "Ground Floor Plan",
      "description": "Detailed floor plan",
      "file_url": "/media/architect_documents/...",
      "file_name": "floor_plan.pdf",
      "file_size": 1024000,
      "upload_date": "2026-03-20",
      "uploaded_by": "Jane Smith",
      "role": "Architect"
    }
  ],
  "count": 15,
  "architect_count": 8,
  "engineer_count": 7
}
```

**Use Case:** Documents page with filtering by type.

---

## Error Responses

### 403 Forbidden - Not a Client
```json
{
  "error": "This endpoint is only for clients"
}
```

### 403 Forbidden - No Access to Site
```json
{
  "error": "You do not have access to this site"
}
```

### 400 Bad Request - Missing Parameter
```json
{
  "error": "site_id is required"
}
```

### 500 Internal Server Error
```json
{
  "error": "Error fetching site details: <error message>"
}
```

---

## Document Types

### Architect Documents
- `FLOOR_PLAN` - Floor planning documents
- `AGREEMENT` - Agreement documents with project estimation
- `ESTIMATION` - Cost estimation documents
- `DESIGN` - Design documents
- `OTHER` - Other architect documents

### Site Engineer Documents
- `SITE_PLAN` - Site layout plans
- `STRUCTURAL_DRAWING` - Structural drawings
- `ELECTRICAL_PLAN` - Electrical plans
- `PLUMBING_PLAN` - Plumbing plans
- `PROJECT_FILE` - General project files
- `OTHER` - Other engineer documents

---

## Usage Examples

### Flutter/Dart Example
```dart
// Get comprehensive site details
final response = await http.get(
  Uri.parse('${baseUrl}/client/site-details/'),
  headers: {'Authorization': 'Bearer $token'},
);

if (response.statusCode == 200) {
  final data = json.decode(response.body);
  final sites = data['sites'];
  // Use the data to populate dashboard
}

// Get photos with filter
final photosResponse = await http.get(
  Uri.parse('${baseUrl}/client/photos/?site_id=$siteId&time_of_day=Morning'),
  headers: {'Authorization': 'Bearer $token'},
);

// Get documents with filter
final docsResponse = await http.get(
  Uri.parse('${baseUrl}/client/documents/?site_id=$siteId&document_type=FLOOR_PLAN'),
  headers: {'Authorization': 'Bearer $token'},
);
```

### Python Example
```python
import requests

headers = {'Authorization': f'Bearer {token}'}

# Get all site details
response = requests.get(
    'http://192.168.1.11:8000/api/client/site-details/',
    headers=headers
)
data = response.json()

# Get labour summary
labour = requests.get(
    'http://192.168.1.11:8000/api/client/labour-summary/',
    params={'site_id': site_id},
    headers=headers
)
```

---

## Testing

Run the test script:
```bash
cd django-backend
python test_client_apis.py
```

Update the password in the script before running.

---

## Database Tables Used

- `client_sites` - Client-site assignments
- `sites` - Site information
- `labour_entries` - Labour count entries
- `site_photos` - Supervisor uploaded photos
- `architect_documents` - Architect documents (floor plans, agreements)
- `site_engineer_documents` - Engineer documents (project files)
- `users` - User information

---

## Security

1. All endpoints require JWT authentication
2. Role-based access control (only Client role)
3. Site access verification (client can only access assigned sites)
4. Read-only access (no POST/PUT/DELETE)

---

## Performance Notes

1. `get_client_site_details` - Single comprehensive call, reduces multiple API requests
2. Photos limited to 20 most recent by default
3. All queries use proper indexes on foreign keys
4. File URLs are properly formatted with MEDIA_URL

---

**Created:** Current session
**Status:** ✅ Ready for testing
