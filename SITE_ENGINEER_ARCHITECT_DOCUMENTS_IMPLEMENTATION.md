# Site Engineer & Architect Document Management System

## REQUIREMENTS

### 1. Site Engineer Can Upload PDF Documents
- Site Plans
- Floor Designs  
- Structural Plans
- Electrical Plans
- Plumbing Plans
- Other documents

### 2. Architect Can Upload PDF Documents (Already Exists)
- Floor Plans
- Elevations
- Structure Drawings
- Designs
- Other documents

### 3. Accountant Can View All Documents
- View Site Engineer documents
- View Architect documents
- Filter by site, document type, date
- Download documents

---

## DATABASE SCHEMA

### Table: `site_engineer_documents`
```sql
CREATE TABLE site_engineer_documents (
    id UUID PRIMARY KEY,
    site_id UUID REFERENCES sites(id),
    site_engineer_id UUID REFERENCES users(id),
    document_type VARCHAR(50), -- 'Site Plan', 'Floor Design', etc.
    title VARCHAR(200),
    description TEXT,
    file_url VARCHAR(500),
    file_name VARCHAR(200),
    file_size INTEGER,
    upload_date DATE,
    uploaded_at TIMESTAMP,
    day_of_week VARCHAR(10),
    is_active BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);
```

### Table: `architect_documents` (Already Exists)
```sql
CREATE TABLE architect_documents (
    id UUID PRIMARY KEY,
    site_id UUID REFERENCES sites(id),
    architect_id UUID REFERENCES users(id),
    document_type VARCHAR(50), -- 'Floor Plan', 'Elevation', etc.
    title VARCHAR(200),
    description TEXT,
    file_url VARCHAR(500),
    file_name VARCHAR(200),
    file_size INTEGER,
    upload_date DATE,
    uploaded_at TIMESTAMP,
    day_of_week VARCHAR(10),
    is_active BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);
```

---

## API ENDPOINTS

### Site Engineer Endpoints (NEW)

#### 1. Upload Document
```
POST /api/construction/upload-site-engineer-document/
Headers: Authorization: Bearer <token>
Body (multipart/form-data):
  - site_id: UUID
  - document_type: String ('Site Plan', 'Floor Design', etc.)
  - title: String
  - description: String (optional)
  - file: File (PDF)

Response:
{
  "message": "Site Plan uploaded successfully",
  "document_id": "uuid",
  "file_url": "/media/site_engineer_documents/...",
  "upload_date": "2024-02-12"
}
```

#### 2. Get Documents
```
GET /api/construction/site-engineer-documents/
Headers: Authorization: Bearer <token>
Query Params:
  - site_id: UUID (optional)
  - document_type: String (optional)
  - date_from: Date (optional)
  - date_to: Date (optional)

Response:
{
  "documents": [
    {
      "id": "uuid",
      "site_id": "uuid",
      "site_name": "ABC Construction",
      "area": "Downtown",
      "street": "Main St",
      "document_type": "Site Plan",
      "title": "Site Layout Plan",
      "description": "Initial site layout",
      "file_url": "/media/...",
      "file_name": "site_plan.pdf",
      "file_size": 1024000,
      "upload_date": "2024-02-12",
      "uploaded_at": "2024-02-12T10:30:00Z",
      "engineer_name": "John Doe"
    }
  ],
  "total_documents": 10
}
```

### Architect Endpoints (Already Exist)

#### 1. Upload Document
```
POST /api/construction/upload-architect-document/
```

#### 2. Get Documents
```
GET /api/construction/architect-documents/
```

### Accountant Endpoints (NEW)

#### Get All Documents (Site Engineer + Architect)
```
GET /api/construction/all-documents/
Headers: Authorization: Bearer <token>
Query Params:
  - site_id: UUID (optional)
  - role: String ('site_engineer' | 'architect' | 'all') (optional, default: 'all')
  - document_type: String (optional)
  - date_from: Date (optional)
  - date_to: Date (optional)

Response:
{
  "site_engineer_documents": [...],
  "architect_documents": [...],
  "total_documents": 25
}
```

---

## FLUTTER IMPLEMENTATION

### Services

#### 1. DocumentService (NEW)
```dart
class DocumentService {
  // Upload Site Engineer Document
  Future<Map<String, dynamic>> uploadSiteEngineerDocument({
    required String siteId,
    required String documentType,
    required String title,
    String? description,
    required File file,
  });
  
  // Get Site Engineer Documents
  Future<Map<String, dynamic>> getSiteEngineerDocuments({
    String? siteId,
    String? documentType,
  });
  
  // Get Architect Documents
  Future<Map<String, dynamic>> getArchitectDocuments({
    String? siteId,
    String? documentType,
  });
  
  // Get All Documents (for Accountant)
  Future<Map<String, dynamic>> getAllDocuments({
    String? siteId,
    String? role,
  });
}
```

### Screens

#### 1. Site Engineer Document Upload Screen
```
SiteEngineerDocumentScreen
  ├─ Site Selection
  ├─ Document Type Dropdown
  ├─ Title Input
  ├─ Description Input
  ├─ File Picker (PDF only)
  ├─ Upload Button
  └─ Document List (uploaded documents)
```

#### 2. Accountant Document View Screen
```
AccountantDocumentScreen
  ├─ Role Tabs: Site Engineer | Architect
  ├─ Document Type Filter
  ├─ Date Filter
  ├─ Document List
  │   ├─ Document Card
  │   │   ├─ Title
  │   │   ├─ Type
  │   │   ├─ Site Name
  │   │   ├─ Upload Date
  │   │   ├─ Uploaded By
  │   │   └─ Download Button
  └─ Empty State
```

---

## USER FLOWS

### Flow 1: Site Engineer Uploads Document

```
1. Login as Site Engineer
2. Go to Dashboard
3. Tap "Documents" button
4. Select Site (if multiple)
5. Tap "Upload Document"
6. Fill form:
   - Document Type: Site Plan
   - Title: Main Site Layout
   - Description: Initial layout plan
   - Select PDF file
7. Tap "Upload"
8. See success message
9. Document appears in list
```

### Flow 2: Architect Uploads Document

```
1. Login as Architect
2. Go to Dashboard
3. Tap "Documents" button
4. Select Site (if multiple)
5. Tap "Upload Document"
6. Fill form:
   - Document Type: Floor Plan
   - Title: Ground Floor Plan
   - Description: Residential floor plan
   - Select PDF file
7. Tap "Upload"
8. See success message
9. Document appears in list
```

### Flow 3: Accountant Views Documents

```
1. Login as Accountant
2. Select: Area → Street → Site
3. Tap "Documents" tab
4. See tabs: Site Engineer | Architect
5. Tap "Site Engineer" tab
6. View documents:
   
   📄 Site Plan
   Main Site Layout
   Uploaded: Feb 12, 2024
   By: John Doe
   [Download]
   
   📄 Floor Design
   Ground Floor Layout
   Uploaded: Feb 11, 2024
   By: John Doe
   [Download]
   
7. Tap "Architect" tab
8. View architect documents
9. Tap Download to view PDF
```

---

## DOCUMENT TYPES

### Site Engineer Document Types:
- Site Plan
- Floor Design
- Structural Plan
- Electrical Plan
- Plumbing Plan
- HVAC Plan
- Other

### Architect Document Types:
- Floor Plan
- Elevation
- Structure Drawing
- Design
- 3D Rendering
- Other

---

## FILE STORAGE

### Directory Structure:
```
media/
├── site_engineer_documents/
│   ├── {site_id}_Site_Plan_20240212_103000.pdf
│   ├── {site_id}_Floor_Design_20240212_110000.pdf
│   └── ...
├── architect_documents/
│   ├── {site_id}_Floor_Plan_20240212_140000.pdf
│   ├── {site_id}_Elevation_20240212_150000.pdf
│   └── ...
└── photos/
    └── ...
```

### File Naming Convention:
```
{site_id}_{document_type}_{timestamp}.{ext}

Example:
abc123_Site_Plan_20240212_103000.pdf
```

---

## SECURITY

### Access Control:
- Site Engineer: Can upload and view own documents
- Architect: Can upload and view own documents
- Accountant: Can view all documents (read-only)
- Admin: Full access

### File Validation:
- Only PDF files allowed
- Max file size: 10MB
- Virus scanning (optional)
- File type verification

---

## UI COMPONENTS

### Document Card:
```
┌─────────────────────────────────────┐
│ 📄 Site Plan                        │
│ Main Site Layout                    │
│                                     │
│ Site: ABC Construction              │
│ Uploaded: Feb 12, 2024 10:30 AM    │
│ By: John Doe (Site Engineer)       │
│ Size: 2.5 MB                        │
│                                     │
│ [View] [Download] [Share]           │
└─────────────────────────────────────┘
```

### Upload Form:
```
┌─────────────────────────────────────┐
│ Upload Document                     │
├─────────────────────────────────────┤
│ Site: [ABC Construction ▼]          │
│                                     │
│ Document Type: [Site Plan ▼]       │
│                                     │
│ Title: [________________]           │
│                                     │
│ Description:                        │
│ [_____________________________]     │
│ [_____________________________]     │
│                                     │
│ File: [Choose PDF] site_plan.pdf   │
│       2.5 MB                        │
│                                     │
│ [Cancel] [Upload Document]          │
└─────────────────────────────────────┘
```

---

## IMPLEMENTATION STEPS

### Backend (Django):
1. ✅ Create `site_engineer_documents` table
2. ⏳ Add upload endpoint
3. ⏳ Add get documents endpoint
4. ⏳ Add accountant view endpoint
5. ⏳ Add URL routes

### Flutter:
1. ⏳ Create `DocumentService`
2. ⏳ Create `SiteEngineerDocumentScreen`
3. ⏳ Add to Site Engineer dashboard
4. ⏳ Update Accountant screen with Documents tab
5. ⏳ Add file picker dependency
6. ⏳ Add PDF viewer dependency

### Testing:
1. ⏳ Test Site Engineer upload
2. ⏳ Test Architect upload
3. ⏳ Test Accountant view
4. ⏳ Test file download
5. ⏳ Test filters

---

## DEPENDENCIES

### Flutter Packages:
```yaml
dependencies:
  file_picker: ^6.0.0  # For PDF file selection
  path_provider: ^2.1.0  # For file paths
  http: ^1.1.0  # For API calls
  url_launcher: ^6.2.0  # For opening PDFs
  flutter_pdfview: ^1.3.0  # For viewing PDFs (optional)
```

### Backend:
- Django REST Framework (already installed)
- File storage (already configured)

---

## STATUS

✅ Database table created
✅ Implementation plan complete
⏳ Backend API endpoints (next)
⏳ Flutter implementation (next)
⏳ Testing (next)

---

## NEXT STEPS

1. Create backend API endpoints for Site Engineer documents
2. Create DocumentService in Flutter
3. Create document upload screen for Site Engineer
4. Add Documents tab to Accountant screen
5. Test complete flow
6. Add PDF viewer functionality

