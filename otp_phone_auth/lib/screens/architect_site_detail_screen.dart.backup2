import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import '../utils/app_colors.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

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
  List<Map<String, dynamic>> _complaints = [];
  bool _isLoadingFiles = false;
  bool _isLoadingComplaints = false;

  @override
  void initState() {
    super.initState();
    _loadProjectFiles();
    _loadComplaints();
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

  Future<void> _loadComplaints() async {
    setState(() => _isLoadingComplaints = true);
    
    try {
      final token = await _authService.getToken();
      
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/construction/complaints/?site_id=${widget.site['id']}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _complaints = List<Map<String, dynamic>>.from(data['complaints']);
          _isLoadingComplaints = false;
        });
      } else {
        setState(() => _isLoadingComplaints = false);
      }
    } catch (e) {
      setState(() => _isLoadingComplaints = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightSlate,
      appBar: AppBar(
        title: Text(
          widget.site['display_name'] ?? widget.site['site_name'] ?? 'Site Details',
          style: const TextStyle(
            color: AppColors.deepNavy,
            fontSize: 18,
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
          _buildComplaintsTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: AppColors.cleanWhite,
        selectedItemColor: Colors.purple.shade600,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Project Files',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem),
            label: 'Complaints',
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
          padding: const EdgeInsets.all(16),
          color: AppColors.cleanWhite,
          child: ElevatedButton.icon(
            onPressed: () => _showUploadDialog(),
            icon: const Icon(Icons.upload_file, size: 20),
            label: const Text('Upload File', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              minimumSize: const Size(double.infinity, 0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                        padding: const EdgeInsets.all(16),
                        itemCount: _projectFiles.length,
                        itemBuilder: (context, index) => _buildFileCard(_projectFiles[index]),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildComplaintsTab() {
    return Column(
      children: [
        // Raise Complaint Button
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.cleanWhite,
          child: ElevatedButton.icon(
            onPressed: () => _showComplaintDialog(),
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Raise Complaint', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              minimumSize: const Size(double.infinity, 0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        
        // Complaints List
        Expanded(
          child: _isLoadingComplaints
              ? const Center(child: CircularProgressIndicator(color: Colors.orange))
              : _complaints.isEmpty
                  ? _buildEmptyComplaintsState()
                  : RefreshIndicator(
                      onRefresh: _loadComplaints,
                      color: Colors.orange.shade600,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _complaints.length,
                        itemBuilder: (context, index) => _buildComplaintCard(_complaints[index]),
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cleanWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file['title'] ?? fileType,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepNavy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fileType.replaceAll('_', ' '),
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color),
                  ),
                  child: Text(
                    fileType,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            if (file['description'] != null && file['description'].toString().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                file['description'],
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
            if (file['amount'] != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.currency_rupee, size: 16, color: Colors.blue.shade600),
                    const SizedBox(width: 6),
                    Text(
                      'Amount: ₹${file['amount']}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade600,
                      ),
                    ),
                    if (file['is_plan_extended'] == true) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Plan Extended',
                          style: TextStyle(
                            fontSize: 11,
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
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  file['uploaded_by'] ?? 'Unknown',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const Spacer(),
                Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  _formatDate(file['uploaded_at']),
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintCard(Map<String, dynamic> complaint) {
    final priority = complaint['priority'] ?? 'MEDIUM';
    final status = complaint['status'] ?? 'OPEN';
    final priorityColor = _getPriorityColor(priority);
    final statusColor = status == 'RESOLVED' ? AppColors.statusCompleted : Colors.orange;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cleanWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [AppColors.cardShadow],
        border: Border.all(color: priorityColor.withValues(alpha: 0.3), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: priorityColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    complaint['title'] ?? 'Complaint',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepNavy,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              complaint['description'] ?? '',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    priority,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: priorityColor,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  _formatDate(complaint['created_at']),
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
            if (complaint['assigned_to_name'] != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'Assigned to: ${complaint['assigned_to_name']}',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFilesState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 80, color: AppColors.textSecondary.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text(
              'No Project Files',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.deepNavy),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload estimation files, plans, and designs',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyComplaintsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 80, color: AppColors.statusCompleted.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text(
              'No Complaints',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.deepNavy),
            ),
            const SizedBox(height: 8),
            Text(
              'All clear! No complaints raised yet',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
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
      // Show loading
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uploading file...'), duration: Duration(seconds: 30)),
      );

      final token = await _authService.getToken();
      final uri = Uri.parse('${AuthService.baseUrl}/construction/upload-project-file/');
      
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      
      // Add fields
      request.fields['site_id'] = widget.site['id'].toString();
      request.fields['file_type'] = fileType;
      if (title.isNotEmpty) request.fields['title'] = title;
      if (description.isNotEmpty) request.fields['description'] = description;
      if (fileType == 'ESTIMATION' && amount.isNotEmpty) {
        request.fields['amount'] = amount;
        request.fields['is_plan_extended'] = isPlanExtended.toString();
      }
      
      // Add file
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
        _loadProjectFiles(); // Refresh list
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

  Future<void> _showComplaintDialog() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedPriority = 'MEDIUM';

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Raise Complaint', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'LOW', child: Text('Low')),
                    DropdownMenuItem(value: 'MEDIUM', child: Text('Medium')),
                    DropdownMenuItem(value: 'HIGH', child: Text('High')),
                    DropdownMenuItem(value: 'URGENT', child: Text('Urgent')),
                  ],
                  onChanged: (value) => setState(() => selectedPriority = value!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }
                Navigator.pop(context);
                await _raiseComplaint(
                  titleController.text,
                  descriptionController.text,
                  selectedPriority,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _raiseComplaint(String title, String description, String priority) async {
    try {
      final token = await _authService.getToken();
      
      final response = await http.post(
        Uri.parse('${AuthService.baseUrl}/construction/raise-complaint/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'site_id': widget.site['id'],
          'title': title,
          'description': description,
          'priority': priority,
        }),
      );

      if (!mounted) return;
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Complaint raised successfully! Assigned to: ${data['assigned_to']}'),
            backgroundColor: Colors.green,
          ),
        );
        _loadComplaints(); // Refresh list
      } else {
        final data = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${data['error'] ?? 'Unknown error'}'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
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

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'LOW':
        return AppColors.statusCompleted;
      case 'MEDIUM':
        return Colors.orange;
      case 'HIGH':
        return Colors.deepOrange;
      case 'URGENT':
        return Colors.red;
      default:
        return Colors.grey;
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
