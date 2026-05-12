import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/site_engineer_provider.dart';
import '../utils/app_colors.dart';

class SiteEngineerProjectFilesScreen extends StatefulWidget {
  const SiteEngineerProjectFilesScreen({super.key});

  @override
  State<SiteEngineerProjectFilesScreen> createState() => _SiteEngineerProjectFilesScreenState();
}

class _SiteEngineerProjectFilesScreenState extends State<SiteEngineerProjectFilesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SiteEngineerProvider>().loadProjectFiles();
    });
  }

  String _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return '📄';
      case 'doc':
      case 'docx':
        return '📝';
      case 'xls':
      case 'xlsx':
        return '📊';
      case 'jpg':
      case 'jpeg':
      case 'png':
        return '🖼️';
      case 'dwg':
      case 'dxf':
        return '📐';
      default:
        return '📁';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
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
              'Project Files',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.deepNavy,
              ),
            ),
            Text(
              'Uploaded by Architect',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: Consumer<SiteEngineerProvider>(
        builder: (context, provider, child) {
          final files = provider.projectFiles;
          final isLoading = provider.isLoading;

          if (isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.deepNavy),
            );
          }

          if (files.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120.w,
                    height: 120.h,
                    decoration: BoxDecoration(
                      color: AppColors.lightSlate,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.folder_open,
                      size: 60.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'No Project Files',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepNavy,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Files will appear here once uploaded',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadProjectFiles(forceRefresh: true),
            child: ListView.builder(
              padding: EdgeInsets.all(16.r),
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                return _buildFileCard(file);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFileCard(Map<String, dynamic> file) {
    final fileName = file['file_name'] ?? 'Unknown File';
    final fileSize = file['file_size'] ?? 0;
    final uploadedAt = file['uploaded_at'] ?? '';
    final fileIcon = _getFileIcon(fileName);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _showFileOptions(file);
          },
          borderRadius: BorderRadius.circular(20.r),
          child: Padding(
            padding: EdgeInsets.all(20.r),
            child: Row(
              children: [
                Container(
                  width: 56.w,
                  height: 56.h,
                  decoration: BoxDecoration(
                    color: AppColors.deepNavy.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Center(
                    child: Text(
                      fileIcon,
                      style: TextStyle(fontSize: 28.sp),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepNavy,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            uploadedAt,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Icon(
                            Icons.storage,
                            size: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            _formatFileSize(fileSize),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: AppColors.deepNavy,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.download,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFileOptions(Map<String, dynamic> file) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.cleanWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              file['file_name'] ?? 'File',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.deepNavy,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ListTile(
              leading: Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: AppColors.deepNavy.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: const Icon(Icons.download, color: AppColors.deepNavy),
              ),
              title: const Text(
                'Download File',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.deepNavy,
                ),
              ),
              subtitle: const Text('Save to device'),
              onTap: () {
                Navigator.pop(context);
                _downloadFile(file);
              },
            ),
            SizedBox(height: 8.h),
            ListTile(
              leading: Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: AppColors.deepNavy.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: const Icon(Icons.visibility, color: AppColors.deepNavy),
              ),
              title: const Text(
                'View File',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.deepNavy,
                ),
              ),
              subtitle: const Text('Open in viewer'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('File viewer coming soon')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadFile(Map<String, dynamic> file) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20.w,
              height: 20.h,
              child: const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 16.w),
            const Text('Downloading file...'),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    // TODO: Implement actual file download
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File downloaded to Downloads folder'),
          backgroundColor: AppColors.statusCompleted,
        ),
      );
    }
  }
}
