# Site Engineer & Architect Document Management Implementation

## OVERVIEW

Implement document management system where:
- **Site Engineer** can upload site plans, floor designs (PDF format)
- **Architect** can upload documents (already exists)
- **Accountant** can view all documents from both roles

---

## BACKEND IMPLEMENTATION

### 1. Create Site Engineer Document Upload API

**File:** `django-backend/api/views_construction.py`

```python
@api_view(['POST'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def upload_site_engineer_document(request):
    """
    Site Engineer: Upload documents (site plans, floor designs, etc.)
    POST /api/construction/upload-site-engineer-document/
    """
    try:
        from django.core.files.storage import default_storage
        from django.conf import settings
        from .time_utils import get_day_of_week
        import os
        
        user_id = request.user['user_id']
        site_id = request.data.get('site_id')
        document_type = request.data.get('document_type')  # 'Site Plan', 'Floor Design', 'Layout', 'Other'
        title = request.data.get('title', '')
        description = request.data.get('description', '')
        file = request.FILES.get('file')
        
        if not all([site_id, document_type, title, file]):
            return Response({'error': 'site_id, document_type, title, and file are required'}, 
                          status=status.HTTP_400_BAD_REQUEST)
        
        # Validate document type
        valid_types = ['Site Plan', 'Floor Design', 'Layout', 'Specification', 'Other']
        if document_type not in valid_types:
            return Response({'error': f'document_type must be one of: {", ".join(valid_types)}'}, 
                          status=status.HTTP_400_BAD_REQUEST)
        
        # Validate file type (PDF only)
        if not file.name.lower().endswith('.pdf'):
            return Response({'error': 'Only PDF files are allowed'}, 
                          status=status.HTTP_400_BAD_REQUEST)
        
        # Create media directory if it doesn't exist
        media_dir = os.path.join(settings.MEDIA_ROOT, 'site_engineer_documents')
        os.makedirs(media_dir, exist_ok=True)
        
        # Generate unique filename
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        ext = os.path.splitext(file.name)[1]
        filename = f"{site_id}_{document_type.replace(' ', '_')}_{timestamp}{ext}"
        filepath = os.path.join('site_engineer_documents', filename)
        
        # Save file
        saved_path = default_storage.save(filepath, file)
        file_url = f"{settings.MEDIA_URL}{saved_path}"
        
        # Get current date and day of week
        today = datetime.now().date()
        day_of_week = get_day_of_week(datetime.now())
        
        # Insert into database
        document_id = str(uuid.uuid4())
        execute_query("""
            INSERT INTO site_engineer_documents 
            (id, site_id, engineer_id, document_type, title, description, file_url, file_name, file_size, upload_date, day_of_week)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (document_id, site_id, user_id, document_type, title, description, file_url, file.name, file.size, today, day_of_week))
        
        return Response({
            'message': f'{document_type} uploaded successfully',
            'document_id': document_id,
            'file_url': file_url,
            'upload_date': today.isoformat(),
            'day_of_week': day_of_week
        }, status=status.HTTP_201_CREATED)
        
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def get_site_engineer_documents(request):
    """
    Get Site Engineer documents for a site
    GET /api/construction/site-engineer-documents/?site_id=xxx
    """
    try:
        site_id = request.GET.get('site_id')
        
        if not site_id:
            return Response({'error': 'site_id is required'}, 
                          status=status.HTTP_400_BAD_REQUEST)
        
        documents = fetch_all("""
            SELECT 
                sed.id,
                sed.site_id,
                sed.engineer_id,
                sed.document_type,
                sed.title,
                sed.description,
                sed.file_url,
                sed.file_name,
                sed.file_size,
                sed.upload_date,
                sed.day_of_week,
                u.name as engineer_name,
                u.email as engineer_email
            FROM site_engineer_documents sed
            LEFT JOIN users u ON sed.engineer_id = u.id
            WHERE sed.site_id = %s
            ORDER BY sed.upload_date DESC, sed.created_at DESC
        """, (site_id,))
        
        return Response({
            'documents': documents,
            'count': len(documents)
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
```

### 2. Add URL Routes

**File:** `django-backend/api/urls.py`

```python
# Site Engineer Document Upload
path('construction/upload-site-engineer-document/', views_construction.upload_site_engineer_document, name='upload-site-engineer-document'),
path('construction/site-engineer-documents/', views_construction.get_site_engineer_documents, name='get-site-engineer-documents'),
```

### 3. Create Database Table

**SQL Migration:**

```sql
CREATE TABLE IF NOT EXISTS site_engineer_documents (
    id UUID PRIMARY KEY,
    site_id UUID NOT NULL,
    engineer_id UUID NOT NULL,
    document_type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    file_url VARCHAR(500) NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_size BIGINT,
    upload_date DATE NOT NULL,
    day_of_week VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (site_id) REFERENCES sites(id) ON DELETE CASCADE,
    FOREIGN KEY (engineer_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_site_engineer_docs_site ON site_engineer_documents(site_id);
CREATE INDEX idx_site_engineer_docs_engineer ON site_engineer_documents(engineer_id);
CREATE INDEX idx_site_engineer_docs_date ON site_engineer_documents(upload_date);
```

---

## FLUTTER IMPLEMENTATION

### 1. Create Document Service

**File:** `otp_phone_auth/lib/services/document_service.dart`

```dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'auth_service.dart';

class DocumentService {
  static final DocumentService _instance = DocumentService._internal();
  factory DocumentService() => _instance;
  DocumentService._internal();

  final _authService = AuthService();
  static const String baseUrl = 'http://192.168.1.7:8000/api';

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }

  // Site Engineer: Upload Document
  Future<Map<String, dynamic>> uploadSiteEngineerDocument({
    required String siteId,
    required String documentType,
    required String title,
    required String description,
    required File file,
  }) async {
    try {
      final token = await _authService.getToken();
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/construction/upload-site-engineer-document/'),
      );
      
      request.headers['Authorization'] = 'Bearer ${token ?? ''}';
      
      request.fields['site_id'] = siteId;
      request.fields['document_type'] = documentType;
      request.fields['title'] = title;
      request.fields['description'] = description;
      
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final data = json.decode(responseData);
      
      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'],
          'document_id': data['document_id'],
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Failed to upload document',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Get Site Engineer Documents
  Future<Map<String, dynamic>> getSiteEngineerDocuments(String siteId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/construction/site-engineer-documents/?site_id=$siteId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'documents': List<Map<String, dynamic>>.from(data['documents'] ?? []),
        };
      } else {
        return {'success': false, 'error': 'Failed to load documents'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Get Architect Documents
  Future<Map<String, dynamic>> getArchitectDocuments(String siteId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/construction/architect-documents/?site_id=$siteId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'documents': List<Map<String, dynamic>>.from(data['documents'] ?? []),
        };
      } else {
        return {'success': false, 'error': 'Failed to load documents'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Pick PDF File
  Future<File?> pickPDFFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      print('Error picking file: $e');
      return null;
    }
  }
}
```

### 2. Add Document Upload to Site Engineer Dashboard

**Quick Action Button:**
```dart
Row(
  children: [
    Expanded(
      child: _buildQuickActionButton(
        'Material Inventory',
        Icons.inventory_2,
        _openMaterialInventory,
      ),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: _buildQuickActionButton(
        'Labor Entry',
        Icons.people,
        _openLaborEntry,
      ),
    ),
  ],
),
const SizedBox(height: 12),
Row(
  children: [
    Expanded(
      child: _buildQuickActionButton(
        'Upload Documents',  // NEW
        Icons.upload_file,
        _openDocumentUpload,
      ),
    ),
  ],
),
```

### 3. Create Document Upload Screen

**File:** `otp_phone_auth/lib/screens/site_engineer_document_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'dart:io';
import '../services/document_service.dart';
import '../utils/app_colors.dart';

class SiteEngineerDocumentScreen extends StatefulWidget {
  final String siteId;
  final String siteName;

  const SiteEngineerDocumentScreen({
    super.key,
    required this.siteId,
    required this.siteName,
  });

  @override
  State<SiteEngineerDocumentScreen> createState() => _SiteEngineerDocumentScreenState();
}

class _SiteEngineerDocumentScreenState extends State<SiteEngineerDocumentScreen> {
  final _documentService = DocumentService();
  List<Map<String, dynamic>> _documents = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() => _isLoading = true);
    
    final result = await _documentService.getSiteEngineerDocuments(widget.siteId);
    
    if (result['success'] == true) {
      setState(() {
        _documents = result['documents'];
      });
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _uploadDocument() async {
    // Show upload dialog
    showDialog(
      context: context,
      builder: (context) => _DocumentUploadDialog(
        siteId: widget.siteId,
        onSuccess: () {
          _loadDocuments();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Documents - ${widget.siteName}'),
        backgroundColor: AppColors.deepNavy,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _documents.isEmpty
              ? _buildEmptyState()
              : _buildDocumentList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _uploadDocument,
        icon: Icon(Icons.upload_file),
        label: Text('Upload PDF'),
        backgroundColor: AppColors.deepNavy,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 80, color: AppColors.textSecondary),
          SizedBox(height: 16),
          Text('No Documents Yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Upload site plans and floor designs'),
        ],
      ),
    );
  }

  Widget _buildDocumentList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _documents.length,
      itemBuilder: (context, index) {
        final doc = _documents[index];
        return _buildDocumentCard(doc);
      },
    );
  }

  Widget _buildDocumentCard(Map<String, dynamic> doc) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(Icons.picture_as_pdf, color: Colors.red, size: 40),
        title: Text(doc['title'] ?? 'Untitled'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(doc['document_type'] ?? ''),
            Text(doc['upload_date'] ?? '', style: TextStyle(fontSize: 12)),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.download),
          onPressed: () {
            // Download/Open PDF
          },
        ),
      ),
    );
  }
}

class _DocumentUploadDialog extends StatefulWidget {
  final String siteId;
  final VoidCallback onSuccess;

  const _DocumentUploadDialog({
    required this.siteId,
    required this.onSuccess,
  });

  @override
  State<_DocumentUploadDialog> createState() => _DocumentUploadDialogState();
}

class _DocumentUploadDialogState extends State<_DocumentUploadDialog> {
  final _documentService = DocumentService();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'Site Plan';
  File? _selectedFile;
  bool _isUploading = false;

  final List<String> _documentTypes = [
    'Site Plan',
    'Floor Design',
    'Layout',
    'Specification',
    'Other',
  ];

  Future<void> _pickFile() async {
    final file = await _documentService.pickPDFFile();
    if (file != null) {
      setState(() => _selectedFile = file);
    }
  }

  Future<void> _upload() async {
    if (_selectedFile == null || _titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a file and enter a title')),
      );
      return;
    }

    setState(() => _isUploading = true);

    final result = await _documentService.uploadSiteEngineerDocument(
      siteId: widget.siteId,
      documentType: _selectedType,
      title: _titleController.text,
      description: _descriptionController.text,
      file: _selectedFile!,
    );

    setState(() => _isUploading = false);

    if (result['success'] == true) {
      Navigator.pop(context);
      widget.onSuccess();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Document uploaded successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ ${result['error']}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Upload Document'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedType,
              items: _documentTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) => setState(() => _selectedType = value!),
              decoration: InputDecoration(labelText: 'Document Type'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: Icon(Icons.attach_file),
              label: Text(_selectedFile == null ? 'Select PDF' : 'PDF Selected'),
            ),
            if (_selectedFile != null)
              Text(_selectedFile!.path.split('/').last, style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isUploading ? null : _upload,
          child: _isUploading
              ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text('Upload'),
        ),
      ],
    );
  }
}
```

### 4. Add Documents Tab to Accountant View

**Modify Accountant Entry Screen:**

```dart
// Add Documents tab to Site Engineer section
TabBar(
  controller: _siteEngineerTabController,
  tabs: const [
    Tab(text: 'Photos'),
    Tab(text: 'Labor'),
    Tab(text: 'Materials'),
    Tab(text: 'Documents'),  // NEW
  ],
),

// Add Documents tab view
Widget _buildSiteEngineerDocumentsTab(ConstructionProvider provider) {
  return _DocumentsView(siteId: _selectedSite);
}
```

---

## DEPENDENCIES

Add to `pubspec.yaml`:

```yaml
dependencies:
  file_picker: ^6.1.1
  path_provider: ^2.1.1
```

---

## TESTING STEPS

1. **Site Engineer Upload:**
   - Login as Site Engineer
   - Tap "Upload Documents"
   - Select site
   - Choose PDF file
   - Enter title and description
   - Upload

2. **Accountant View:**
   - Login as Accountant
   - Select site
   - Go to Site Engineer tab
   - Tap "Documents" tab
   - View uploaded documents

---

## STATUS

📋 Implementation plan complete
⏳ Ready to implement
🎯 Backend + Flutter + UI
