import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ArchitectPlansScreen extends StatefulWidget {
  final String siteId;
  final String siteName;

  const ArchitectPlansScreen({
    super.key,
    required this.siteId,
    required this.siteName,
  });

  @override
  State<ArchitectPlansScreen> createState() => _ArchitectPlansScreenState();
}

class _ArchitectPlansScreenState extends State<ArchitectPlansScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  String _selectedType = 'Floor Plan';
  String? _selectedFileName;
  PlatformFile? _selectedFile;

  List<Map<String, dynamic>> _uploadedPlans = [];

  final List<String> _planTypes = [
    'Floor Plan',
    'Elevation',
    'Structure Drawing',
    'Design',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadUploadedPlans();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadUploadedPlans() async {
    setState(() => _isLoading = true);
    try {
      // TODO: Load from backend
      setState(() {
        _uploadedPlans = [
          {
            'id': '1',
            'title': 'Ground Floor Plan',
            'type': 'Floor Plan',
            'date': '2024-01-15',
            'version': 'v1.0',
            'isLatest': true,
          },
        ];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading plans: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'dwg', 'dxf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = result.files.first;
          _selectedFileName = result.files.first.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  Future<void> _uploadPlan() async {
    if (!_formKey.currentState!.validate() || _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file to upload')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // TODO: Upload to backend

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Plan uploaded! Notifications sent to site engineers, owners, and client.',
            ),
            backgroundColor: Colors.green,
          ),
        );
        _titleController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedFile = null;
          _selectedFileName = null;
        });
        _loadUploadedPlans();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Floor Plans & Designs',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              widget.siteName,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.purple))
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Upload Form
                    _buildUploadForm(),
                    SizedBox(height: 24.h),

                    // Uploaded Plans
                    _buildUploadedPlansSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildUploadForm() {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey[800]!, width: 1),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload New Plan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 20.h),

            // Plan Type Dropdown
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: InputDecoration(
                labelText: 'Plan Type',
                labelStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.black,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey[800]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey[800]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Colors.purple),
                ),
              ),
              dropdownColor: const Color(0xFF1C1C1E),
              style: const TextStyle(color: Colors.white),
              items: _planTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedType = value!);
              },
            ),
            SizedBox(height: 16.h),

            // Title
            TextFormField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.black,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey[800]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey[800]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Colors.purple),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),

            // File Upload
            InkWell(
              onTap: _pickFile,
              child: Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: _selectedFile != null ? Colors.purple : Colors.grey[800]!,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _selectedFile != null ? Icons.check_circle : Icons.upload_file,
                      color: _selectedFile != null ? Colors.purple : Colors.grey[400],
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        _selectedFileName ?? 'Upload Plan File (PDF, DWG, DXF, Image)',
                        style: TextStyle(
                          color: _selectedFile != null ? Colors.white : Colors.grey[400],
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Description
            TextFormField(
              controller: _descriptionController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description / Changes (Optional)',
                labelStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.black,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey[800]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey[800]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Colors.purple),
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Info Box
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.purple.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.purple, size: 20.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Notifications will be sent to site engineers, owners, and client to download the latest file.',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _uploadPlan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20.h,
                        width: 20.w,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Upload & Notify',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadedPlansSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Uploaded Plans',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12.h),
        if (_uploadedPlans.isEmpty)
          Container(
            padding: EdgeInsets.all(40.r),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.grey[800]!, width: 1),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.architecture, size: 48.sp, color: Colors.grey[600]),
                  SizedBox(height: 12.h),
                  Text(
                    'No plans uploaded yet',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
          )
        else
          ..._uploadedPlans.map((plan) => _buildPlanCard(plan)),
      ],
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: plan['isLatest'] ? Colors.purple : Colors.grey[800]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan['title'],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      plan['type'],
                      style: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
                    ),
                  ],
                ),
              ),
              if (plan['isLatest'])
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    'Latest',
                    style: TextStyle(
                      color: Colors.purple,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14.sp, color: Colors.grey[500]),
              SizedBox(width: 6.w),
              Text(
                plan['date'],
                style: TextStyle(color: Colors.grey[500], fontSize: 13.sp),
              ),
              SizedBox(width: 16.w),
              Icon(Icons.label, size: 14.sp, color: Colors.grey[500]),
              SizedBox(width: 6.w),
              Text(
                plan['version'],
                style: TextStyle(color: Colors.grey[500], fontSize: 13.sp),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Download file
                  },
                  icon: Icon(Icons.download, size: 18.sp),
                  label: const Text('Download'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.purple,
                    side: const BorderSide(color: Colors.purple),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: View version history
                  },
                  icon: Icon(Icons.history, size: 18.sp),
                  label: const Text('History'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[400],
                    side: BorderSide(color: Colors.grey[800]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
