import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../utils/app_colors.dart';

class SiteEngineerPhotoUploadScreen extends StatefulWidget {
  final Map<String, dynamic> site;

  const SiteEngineerPhotoUploadScreen({super.key, required this.site});

  @override
  State<SiteEngineerPhotoUploadScreen> createState() => _SiteEngineerPhotoUploadScreenState();
}

class _SiteEngineerPhotoUploadScreenState extends State<SiteEngineerPhotoUploadScreen> {
  final _authService = AuthService();
  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();
  
  File? _selectedImage;
  String _updateType = 'STARTED'; // STARTED or FINISHED
  bool _isUploading = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  bool _canUploadMorning() {
    final now = DateTime.now();
    return now.hour < 13; // Before 1 PM
  }

  bool _canUploadEvening() {
    final now = DateTime.now();
    return now.hour >= 13; // After 1 PM
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

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.cleanWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Choose Photo Source',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.deepNavy),
            ),
            const SizedBox(height: 24),
            _buildSourceOption(
              icon: Icons.camera_alt,
              title: 'Take Photo',
              subtitle: 'Use camera',
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 16),
            _buildSourceOption(
              icon: Icons.photo_library,
              title: 'Choose from Gallery',
              subtitle: 'Select existing photo',
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.lightSlate,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.deepNavy.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.deepNavy, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.deepNavy)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.deepNavy),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _uploadPhoto() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a photo first'),
          backgroundColor: AppColors.statusOverdue,
        ),
      );
      return;
    }

    // Validate time restrictions
    if (_updateType == 'STARTED' && !_canUploadMorning()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Morning photos must be uploaded before 1 PM'),
          backgroundColor: AppColors.statusOverdue,
        ),
      );
      return;
    }

    if (_updateType == 'FINISHED' && !_canUploadEvening()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Evening photos can only be uploaded after 1 PM'),
          backgroundColor: AppColors.statusOverdue,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final token = await _authService.getToken();
      
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${AuthService.baseUrl}/construction/upload-site-photo/'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['site_id'] = widget.site['id'].toString();
      request.fields['update_type'] = _updateType;
      request.fields['description'] = _descriptionController.text.trim();

      request.files.add(await http.MultipartFile.fromPath(
        'photo',
        _selectedImage!.path,
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      setState(() => _isUploading = false);

      if (response.statusCode == 201) {
        if (mounted) {
          Navigator.pop(context, true); // Return true to indicate success
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_updateType == "STARTED" ? "Morning" : "Evening"} photo uploaded successfully!'),
              backgroundColor: AppColors.statusCompleted,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Upload failed: ${response.body}'),
              backgroundColor: AppColors.statusOverdue,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading photo: $e'),
            backgroundColor: AppColors.statusOverdue,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightSlate,
      appBar: AppBar(
        title: const Text(
          'Upload Photo',
          style: TextStyle(color: AppColors.deepNavy, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.cleanWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.deepNavy),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Site Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cleanWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [AppColors.cardShadow],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Site',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.site['display_name'] ?? widget.site['site_name'] ?? 'Unknown Site',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.deepNavy),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.site['area'] ?? ''}, ${widget.site['street'] ?? ''}',
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Upload Type Selection
            const Text(
              'Upload Type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.deepNavy),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTypeOption(
                    icon: '🌅',
                    label: 'Morning',
                    subtitle: 'Work Started',
                    value: 'STARTED',
                    enabled: _canUploadMorning(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTypeOption(
                    icon: '🌆',
                    label: 'Evening',
                    subtitle: 'Work Completed',
                    value: 'FINISHED',
                    enabled: _canUploadEvening(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Photo Preview
            const Text(
              'Photo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.deepNavy),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _showImageSourceDialog,
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  color: AppColors.cleanWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.deepNavy.withValues(alpha: 0.2), width: 2),
                  boxShadow: [AppColors.cardShadow],
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          const Text(
                            'Tap to add photo',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Camera or Gallery',
                            style: TextStyle(fontSize: 14, color: AppColors.textSecondary.withValues(alpha: 0.7)),
                          ),
                        ],
                      ),
              ),
            ),
            if (_selectedImage != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _showImageSourceDialog,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Change Photo'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.deepNavy,
                        side: const BorderSide(color: AppColors.deepNavy),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () => setState(() => _selectedImage = null),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.statusOverdue,
                      side: const BorderSide(color: AppColors.statusOverdue),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Icon(Icons.delete, size: 20),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),

            // Description
            const Text(
              'Description (Optional)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.deepNavy),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add notes about the work...',
                filled: true,
                fillColor: AppColors.cleanWhite,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.deepNavy.withValues(alpha: 0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.deepNavy.withValues(alpha: 0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.deepNavy, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Upload Button
            ElevatedButton(
              onPressed: _isUploading ? null : _uploadPhoto,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepNavy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 2,
              ),
              child: _isUploading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'Upload Photo',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeOption({
    required String icon,
    required String label,
    required String subtitle,
    required String value,
    required bool enabled,
  }) {
    final isSelected = _updateType == value;
    
    return GestureDetector(
      onTap: enabled ? () => setState(() => _updateType = value) : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: enabled
              ? (isSelected ? AppColors.deepNavy : AppColors.cleanWhite)
              : AppColors.lightSlate,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: enabled
                ? (isSelected ? AppColors.deepNavy : AppColors.deepNavy.withValues(alpha: 0.2))
                : AppColors.textSecondary.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: enabled && isSelected ? [AppColors.cardShadow] : [],
        ),
        child: Column(
          children: [
            Text(icon, style: TextStyle(fontSize: 32, color: enabled ? null : Colors.grey)),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: enabled
                    ? (isSelected ? Colors.white : AppColors.deepNavy)
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: enabled
                    ? (isSelected ? Colors.white.withValues(alpha: 0.8) : AppColors.textSecondary)
                    : AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
            if (!enabled) ...[
              const SizedBox(height: 4),
              Icon(Icons.lock, size: 16, color: AppColors.textSecondary.withValues(alpha: 0.5)),
            ],
          ],
        ),
      ),
    );
  }
}
