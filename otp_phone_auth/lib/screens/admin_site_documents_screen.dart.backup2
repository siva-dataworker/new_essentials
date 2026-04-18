import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/app_colors.dart';
import '../services/auth_service.dart';

class AdminSiteDocumentsScreen extends StatefulWidget {
  final String siteId;
  final String siteName;
  
  const AdminSiteDocumentsScreen({
    Key? key,
    required this.siteId,
    required this.siteName,
  }) : super(key: key);

  @override
  State<AdminSiteDocumentsScreen> createState() => _AdminSiteDocumentsScreenState();
}

class _AdminSiteDocumentsScreenState extends State<AdminSiteDocumentsScreen> {
  final _authService = AuthService();
  
  Map<String, List<Map<String, dynamic>>> _documents = {
    'PLAN': [],
    'ELEVATION': [],
    'STRUCTURE': [],
    'FINAL_OUTPUT': [],
  };
  bool _isLoading = false;
  String _selectedType = 'PLAN';

  final Map<String, Map<String, dynamic>> _documentTypes = {
    'PLAN': {
      'title': 'Plans',
      'icon': Icons.architecture,
      'color': AppColors.deepNavy,
    },
    'ELEVATION': {
      'title': 'Elevations',
      'icon': Icons.apartment,
      'color': AppColors.safetyOrange,
    },
    'STRUCTURE': {
      'title': 'Structure',
      'icon': Icons.foundation,
      'color': AppColors.statusCompleted,
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
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() => _isLoading = true);

    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/admin/sites/${widget.siteId}/documents/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token ?? ''}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _documents = {
            'PLAN': List<Map<String, dynamic>>.from(data['documents']['PLAN'] ?? []),
            'ELEVATION': List<Map<String, dynamic>>.from(data['documents']['ELEVATION'] ?? []),
            'STRUCTURE': List<Map<String, dynamic>>.from(data['documents']['STRUCTURE'] ?? []),
            'FINAL_OUTPUT': List<Map<String, dynamic>>.from(data['documents']['FINAL_OUTPUT'] ?? []),
          };
        });
      }
    } catch (e) {
      print('Error loading documents: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightSlate,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Site Documents',
              style: TextStyle(
                color: AppColors.deepNavy,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.siteName,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.cleanWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.deepNavy),
      ),
      body: Column(
        children: [
          // Document type tabs
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.cleanWhite,
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
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.deepNavy),
                  )
                : _documents[_selectedType]!.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _documentTypes[_selectedType]!['icon'],
                              size: 80,
                              color: AppColors.textSecondary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No ${_documentTypes[_selectedType]!['title'].toLowerCase()} found',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadDocuments,
                        color: _documentTypes[_selectedType]!['color'],
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
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
  }

  Widget _buildTypeChip(String type, String title, IconData icon, Color color) {
    final isSelected = _selectedType == type;
    final count = _documents[type]?.length ?? 0;
    
    return GestureDetector(
      onTap: () {
        setState(() => _selectedType = type);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.lightSlate,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
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
              size: 18,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cleanWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _documentTypes[_selectedType]!['icon'],
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc['document_name'] ?? 'Untitled',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepNavy,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      doc['uploaded_by'] ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(doc['uploaded_at']),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
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
