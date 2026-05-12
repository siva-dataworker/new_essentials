import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../utils/smooth_animations.dart';

class AdminSiteDocumentsScreen extends StatefulWidget {
  final String siteId;
  final String siteName;
  
  const AdminSiteDocumentsScreen({
    super.key,
    required this.siteId,
    required this.siteName,
  });

  @override
  State<AdminSiteDocumentsScreen> createState() => _AdminSiteDocumentsScreenState();
}

class _AdminSiteDocumentsScreenState extends State<AdminSiteDocumentsScreen> {
  Map<String, List<Map<String, dynamic>>> _documents = {
    'PLAN': [],
    'ELEVATION': [],
    'STRUCTURE': [],
    'FINAL_OUTPUT': [],
  };
  String _selectedType = 'PLAN';

  final Map<String, Map<String, dynamic>> _documentTypes = {
    'PLAN': {
      'title': 'Plans',
      'icon': Icons.architecture,
      'color': const Color(0xFF1A1A2E),
    },
    'ELEVATION': {
      'title': 'Elevations',
      'icon': Icons.apartment,
      'color': const Color(0xFF1A1A2E),
    },
    'STRUCTURE': {
      'title': 'Structure',
      'icon': Icons.foundation,
      'color': const Color(0xFF4CAF50),
    },
    'FINAL_OUTPUT': {
      'title': 'Final Output',
      'icon': Icons.photo_library,
      'color': Colors.purple,
    },
  };

  @override
  void initState() {
    super.initState();
    // Load documents using provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDocuments(context.read<AdminProvider>());
    });
  }

  Future<void> _loadDocuments(AdminProvider provider) async {
    final docs = await provider.getDocuments(widget.siteId, forceRefresh: true);
    if (mounted) {
      setState(() => _documents = docs);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        final isLoading = adminProvider.isLoading('docs_${widget.siteId}');
        
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Site Documents',
                  style: TextStyle(
                    color: const Color(0xFF1A1A2E),
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.siteName,
                  style: TextStyle(
                    color: const Color(0xFF6B7280),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Color(0xFF1A1A2E)),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => _loadDocuments(adminProvider),
                tooltip: 'Refresh',
              ),
            ],
          ),
          body: Column(
            children: [
              // Document type tabs
              Container(
                padding: EdgeInsets.all(16.r),
                color: Colors.white,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _documentTypes.entries.map((entry) {
                      return _buildTypeChip(
                        entry.key,
                        entry.value['title'],
                        entry.value['icon'],
                        entry.value['color'],
                      );
                    }).toList(),
                  ),
                ),
              ),
              
              // Documents list
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Color(0xFF1A1A2E)),
                      )
                    : _documents[_selectedType]!.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _documentTypes[_selectedType]!['icon'],
                                  size: 80.sp,
                                  color: const Color(0xFF6B7280).withValues(alpha: 0.5),
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'No ${_documentTypes[_selectedType]!['title'].toLowerCase()} found',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => _loadDocuments(adminProvider),
                            color: _documentTypes[_selectedType]!['color'],
                            child: ListView.builder(
                              physics: const SmoothScrollPhysics(),
                              padding: EdgeInsets.all(16.r),
                              itemCount: _documents[_selectedType]!.length,
                              itemBuilder: (context, index) {
                                final doc = _documents[_selectedType]![index];
                                return _buildDocumentCard(doc);
                              },
                            ),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypeChip(String type, String title, IconData icon, Color color) {
    final isSelected = _selectedType == type;
    final count = _documents[type]?.length ?? 0;
    
    return GestureDetector(
      onTap: () {
        setState(() => _selectedType = type);
      },
      child: Container(
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? color : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18.sp,
              color: isSelected ? Colors.white : const Color(0xFF6B7280),
            ),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFF6B7280),
              ),
            ),
            if (count > 0) ...[
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : color,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? color : Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentCard(Map<String, dynamic> doc) {
    final color = _documentTypes[_selectedType]!['color'];
    
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              _documentTypes[_selectedType]!['icon'],
              color: color,
              size: 28.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc['document_name'] ?? 'Untitled',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 14.sp,
                      color: const Color(0xFF6B7280),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      doc['uploaded_by'] ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14.sp,
                      color: const Color(0xFF6B7280),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      _formatDate(doc['uploaded_at']),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.visibility, color: color),
            onPressed: () {
              // TODO: Implement document viewer
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Document viewer coming soon')),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }
}
