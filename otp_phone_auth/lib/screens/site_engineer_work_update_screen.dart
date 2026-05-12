import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/site_engineer_provider.dart';
import '../utils/app_colors.dart';

class SiteEngineerWorkUpdateScreen extends StatefulWidget {
  final String activityType; // 'WORK_STARTED' or 'WORK_COMPLETED'

  const SiteEngineerWorkUpdateScreen({
    super.key,
    required this.activityType,
  });

  @override
  State<SiteEngineerWorkUpdateScreen> createState() => _SiteEngineerWorkUpdateScreenState();
}

class _SiteEngineerWorkUpdateScreenState extends State<SiteEngineerWorkUpdateScreen> {
  final _notesController = TextEditingController();
  final _imagePicker = ImagePicker();
  File? _selectedImage;
  bool _isUploading = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: AppColors.statusOverdue,
          ),
        );
      }
    }
  }

  Future<void> _uploadWorkActivity() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image'),
          backgroundColor: AppColors.statusOverdue,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    final provider = context.read<SiteEngineerProvider>();
    final result = await provider.uploadWorkActivity(
      activityType: widget.activityType,
      imagePath: _selectedImage!.path,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    setState(() => _isUploading = false);

    if (mounted) {
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.activityType == 'WORK_STARTED'
                  ? 'Morning update uploaded successfully'
                  : 'Evening update uploaded successfully',
            ),
            backgroundColor: AppColors.statusCompleted,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Failed to upload'),
            backgroundColor: AppColors.statusOverdue,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMorning = widget.activityType == 'WORK_STARTED';
    final title = isMorning ? 'Morning Update' : 'Evening Update';
    final subtitle = isMorning ? 'Upload work started photo' : 'Upload work finished photo';
    final icon = isMorning ? Icons.wb_sunny : Icons.nightlight;

    return Scaffold(
      backgroundColor: AppColors.lightSlate,
      appBar: AppBar(
        backgroundColor: AppColors.cleanWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.deepNavy),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.deepNavy,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info Card
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: isMorning
                    ? AppColors.statusPending.withValues(alpha: 0.1)
                    : AppColors.statusCompleted.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isMorning
                      ? AppColors.statusPending.withValues(alpha: 0.3)
                      : AppColors.statusCompleted.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48.w,
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: isMorning ? AppColors.statusPending : AppColors.statusCompleted,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(icon, color: Colors.white, size: 26.sp),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isMorning ? 'Before 1:00 PM' : 'End of Day',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: isMorning ? AppColors.statusPending : AppColors.statusCompleted,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          isMorning
                              ? 'Upload work started photo before 1pm to avoid notifications'
                              : 'Upload work finished photo. This will be sent to the client.',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Image Picker
            if (_selectedImage == null)
              Container(
                height: 300.h,
                decoration: BoxDecoration(
                  color: AppColors.cleanWhite,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: AppColors.deepNavy.withValues(alpha: 0.2),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 80.sp,
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Add Photo',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Camera'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.deepNavy,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        OutlinedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Gallery'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.deepNavy,
                            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                            side: const BorderSide(color: AppColors.deepNavy, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cleanWhite,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.deepNavy.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                      child: Image.file(
                        _selectedImage!,
                        height: 300.h,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.r),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => setState(() => _selectedImage = null),
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Remove'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.statusOverdue,
                                side: const BorderSide(color: AppColors.statusOverdue),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _pickImage(ImageSource.camera),
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Retake'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.deepNavy,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 24.h),

            // Notes Field
            Container(
              decoration: BoxDecoration(
                color: AppColors.cleanWhite,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.deepNavy.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _notesController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Add any notes about the work...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.cleanWhite,
                  contentPadding: EdgeInsets.all(16.r),
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // Upload Button
            ElevatedButton(
              onPressed: _isUploading ? null : _uploadWorkActivity,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepNavy,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 0,
              ),
              child: _isUploading
                  ? SizedBox(
                      height: 20.h,
                      width: 20.w,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload_outlined, size: 22.sp),
                        SizedBox(width: 12.w),
                        Text(
                          'Upload ${isMorning ? "Morning" : "Evening"} Update',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
