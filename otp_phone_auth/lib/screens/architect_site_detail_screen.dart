import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import '../utils/app_colors.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ArchitectSiteDetailScreen extends StatefulWidget {
  final Map<String, dynamic> site;
  final UserModel user;

  const ArchitectSiteDetailScreen({
    super.key,
    required this.site,
    required this.user,
  });

  @override
  State<ArchitectSiteDetailScreen> createState() => _ArchitectSiteDetailScreenState();
}

class _ArchitectSiteDetailScreenState extends State<ArchitectSiteDetailScreen> {
  int _currentIndex = 0;
  final _authService = AuthService();
  List<Map<String, dynamic>> _projectFiles = [];
  bool _isLoadingFiles = false;

  @override
  void initState() {
    super.initState();
    _loadProjectFiles();
  }

  Future<void> _loadProjectFiles() async {
    setState(() => _isLoadingFiles = true);

    try {
      final token = await _authService.getToken();

      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/construction/project-files/${widget.site['id']}/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _projectFiles = List<Map<String, dynamic>>.from(data['files']);
          _isLoadingFiles = false;
        });
      } else {
        setState(() => _isLoadingFiles = false);
      }
    } catch (e) {
      setState(() => _isLoadingFiles = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightSlate,
      appBar: AppBar(
        title: Text(
          widget.site['display_name'] ?? widget.site['site_name'] ?? 'Site Details',
          style: TextStyle(
            color: AppColors.deepNavy,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.cleanWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.deepNavy),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildProjectFilesTab(),
         
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: AppColors.cleanWhite,
        selectedItemColor: Colors.purple.shade600,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
        unselectedLabelStyle: TextStyle(fontSize: 12.sp),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Project Files',
          ),
          
        ],
      ),
    );
  }

  Widget _buildProjectFilesTab() {
    return Column(
      children: [
        // Upload Button
        Container(
          padding: EdgeInsets.all(16.r),
          color: AppColors.cleanWhite,
          child: ElevatedButton.icon(
            onPressed: () => _showUploadDialog(),
            icon: Icon(Icons.upload_file, size: 20.sp),
            label: Text('Upload File', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade600,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              minimumSize: Size(double.infinity, 0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
          ),
        ),

        // Files List
        Expanded(
          child: _isLoadingFiles
              ? const Center(child: CircularProgressIndicator(color: Colors.purple))
              : _projectFiles.isEmpty
                  ? _buildEmptyFilesState()
                  : RefreshIndicator(
                      onRefresh: _loadProjectFiles,
                      color: Colors.purple.shade600,
                      child: ListView.builder(
                        padding: EdgeInsets.all(16.r),
                        itemCount: _projectFiles.length,
                        itemBuilder: (context, index) => _buildFileCard(_projectFiles[index]),
                      ),
                    ),
        ),
      ],
    );
  }

  

  Widget _buildFileCard(Map<String, dynamic> file) {
    final fileType = file['file_type'] ?? 'OTHER';
    final icon = _getFileIcon(fileType);
    final color = _getFileColor(fileType);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.cleanWhite,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(icon, color: color, size: 20.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file['title'] ?? fileType,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepNavy,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        fileType.replaceAll('_', ' '),
                        style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: color),
                  ),
                  child: Text(
                    fileType,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            if (file['description'] != null && file['description'].toString().isNotEmpty) ...[
              SizedBox(height: 12.h),
              Text(
                file['description'],
                style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
              ),
            ],
            if (file['amount'] != null) ...[
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.currency_rupee, size: 16.sp, color: Colors.blue.shade600),
                    SizedBox(width: 6.w),
                    Text(
                      'Amount: ₹${file['amount']}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade600,
                      ),
                    ),
                    if (file['is_plan_extended'] == true) ...[
                      SizedBox(width: 12.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          'Plan Extended',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(Icons.person, size: 14.sp, color: AppColors.textSecondary),
                SizedBox(width: 4.w),
                Text(
                  file['uploaded_by'] ?? 'Unknown',
                  style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                ),
                const Spacer(),
                Icon(Icons.calendar_today, size: 14.sp, color: AppColors.textSecondary),
                SizedBox(width: 4.w),
                Text(
                  _formatDate(file['uploaded_at']),
                  style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFilesState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 80.sp, color: AppColors.textSecondary.withValues(alpha: 0.5)),
            SizedBox(height: 16.h),
            Text(
              'No Project Files',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppColors.deepNavy),
            ),
            SizedBox(height: 8.h),
            Text(
              'Upload estimation files, plans, and designs',
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showUploadDialog() async {
    String? selectedFileType = 'ESTIMATION';
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    bool isPlanExtended = false;
    PlatformFile? selectedFile;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Upload Project File', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // File Picker Button
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'jpg', 'jpeg', 'png'],
                    );
                    if (result != null) {
                      setState(() => selectedFile = result.files.first);
                    }
                  },
                  icon: const Icon(Icons.attach_file),
                  label: Text(selectedFile == null ? 'Select File' : selectedFile!.name),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade100,
                    foregroundColor: Colors.purple.shade700,
                  ),
                ),
                const SizedBox(height: 16),

                // File Type Dropdown
                DropdownButtonFormField<String>(
                  value: selectedFileType,
                  decoration: const InputDecoration(
                    labelText: 'File Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'ESTIMATION', child: Text('Estimation')),
                    DropdownMenuItem(value: 'FLOOR_PLAN', child: Text('Floor Plan')),
                    DropdownMenuItem(value: 'ELEVATION', child: Text('Elevation')),
                    DropdownMenuItem(value: 'STRUCTURE', child: Text('Structure')),
                    DropdownMenuItem(value: 'DESIGN', child: Text('Design')),
                    DropdownMenuItem(value: 'OTHER', child: Text('Other')),
                  ],
                  onChanged: (value) => setState(() => selectedFileType = value),
                ),
                const SizedBox(height: 16),

                // Title
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),

                // Estimation-specific fields
                if (selectedFileType == 'ESTIMATION') ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount (₹)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.currency_rupee),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    title: const Text('Plan Extended'),
                    value: isPlanExtended,
                    onChanged: (value) => setState(() => isPlanExtended = value ?? false),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedFile == null
                  ? null
                  : () async {
                      Navigator.pop(context);
                      await _uploadFile(
                        selectedFile!,
                        selectedFileType!,
                        titleController.text,
                        descriptionController.text,
                        amountController.text,
                        isPlanExtended,
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadFile(
    PlatformFile file,
    String fileType,
    String title,
    String description,
    String amount,
    bool isPlanExtended,
  ) async {
    try {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uploading file...'), duration: Duration(seconds: 30)),
      );

      final token = await _authService.getToken();
      final uri = Uri.parse('${AuthService.baseUrl}/construction/upload-project-file/');

      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['site_id'] = widget.site['id'].toString();
      request.fields['file_type'] = fileType;
      if (title.isNotEmpty) request.fields['title'] = title;
      if (description.isNotEmpty) request.fields['description'] = description;
      if (fileType == 'ESTIMATION' && amount.isNotEmpty) {
        request.fields['amount'] = amount;
        request.fields['is_plan_extended'] = isPlanExtended.toString();
      }

      if (file.bytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          file.bytes!,
          filename: file.name,
        ));
      } else if (file.path != null) {
        request.files.add(await http.MultipartFile.fromPath('file', file.path!));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File uploaded successfully!'), backgroundColor: Colors.green),
        );
        _loadProjectFiles();
      } else {
        final data = json.decode(responseBody);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${data['error'] ?? 'Unknown error'}'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }



  IconData _getFileIcon(String fileType) {
    switch (fileType) {
      case 'ESTIMATION':
        return Icons.calculate;
      case 'FLOOR_PLAN':
        return Icons.architecture;
      case 'ELEVATION':
        return Icons.apartment;
      case 'STRUCTURE':
        return Icons.foundation;
      case 'DESIGN':
        return Icons.design_services;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor(String fileType) {
    switch (fileType) {
      case 'ESTIMATION':
        return Colors.blue.shade600;
      case 'FLOOR_PLAN':
        return Colors.purple.shade600;
      case 'ELEVATION':
        return Colors.indigo.shade600;
      case 'STRUCTURE':
        return Colors.teal.shade600;
      case 'DESIGN':
        return Colors.pink.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
