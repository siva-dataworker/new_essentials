import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ArchitectEstimationScreen extends StatefulWidget {
  final String siteId;
  final String siteName;

  const ArchitectEstimationScreen({
    super.key,
    required this.siteId,
    required this.siteName,
  });

  @override
  State<ArchitectEstimationScreen> createState() => _ArchitectEstimationScreenState();
}

class _ArchitectEstimationScreenState extends State<ArchitectEstimationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _estimationController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;
  bool _isPlanExtended = false;
  String? _selectedFileName;
  PlatformFile? _selectedFile;

  List<Map<String, dynamic>> _estimationHistory = [];

  @override
  void initState() {
    super.initState();
    _loadEstimationHistory();
  }

  @override
  void dispose() {
    _estimationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadEstimationHistory() async {
    setState(() => _isLoading = true);
    try {
      // TODO: Load estimation history from backend
      // For now, using mock data
      setState(() {
        _estimationHistory = [
          {
            'id': '1',
            'amount': '₹25,00,000',
            'date': '2024-01-15',
            'notes': 'Initial estimation',
            'isPlanExtended': false,
          },
        ];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading history: $e')),
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
        allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx'],
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

  Future<void> _submitEstimation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      // TODO: Submit to backend

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isPlanExtended
                  ? 'Revised estimation uploaded. Client and owner notified.'
                  : 'Estimation uploaded successfully.',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
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
              'Site Estimation',
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
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Upload Form
                    _buildUploadForm(),
                    SizedBox(height: 24.h),

                    // History
                    _buildHistorySection(),
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
              'Upload Estimation',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 20.h),

            // Estimation Amount
            TextFormField(
              controller: _estimationController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Estimation Amount (₹)',
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
                  borderSide: const BorderSide(color: Colors.blue),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter estimation amount';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),

            // Plan Extended Checkbox
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: _isPlanExtended,
                    onChanged: (value) {
                      setState(() => _isPlanExtended = value ?? false);
                    },
                    activeColor: Colors.blue,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Plan Extended',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Check if this is a revised estimation due to plan extension',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
                    color: _selectedFile != null ? Colors.blue : Colors.grey[800]!,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _selectedFile != null ? Icons.check_circle : Icons.upload_file,
                      color: _selectedFile != null ? Colors.blue : Colors.grey[400],
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        _selectedFileName ?? 'Upload Estimation Document',
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

            // Notes
            TextFormField(
              controller: _notesController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Notes (Optional)',
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
                  borderSide: const BorderSide(color: Colors.blue),
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitEstimation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
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
                        'Upload Estimation',
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

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estimation History',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12.h),
        if (_estimationHistory.isEmpty)
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
                  Icon(Icons.history, size: 48.sp, color: Colors.grey[600]),
                  SizedBox(height: 12.h),
                  Text(
                    'No estimation history',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
          )
        else
          ..._estimationHistory.map((estimation) => _buildHistoryCard(estimation)),
      ],
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> estimation) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[800]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                estimation['amount'],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (estimation['isPlanExtended'])
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    'Plan Extended',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            estimation['date'],
            style: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
          ),
          if (estimation['notes'] != null) ...[
            SizedBox(height: 8.h),
            Text(
              estimation['notes'],
              style: TextStyle(color: Colors.grey[500], fontSize: 13.sp),
            ),
          ],
        ],
      ),
    );
  }
}
