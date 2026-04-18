import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/app_colors.dart';
import '../services/auth_service.dart';

class AdminLabourCountScreen extends StatefulWidget {
  const AdminLabourCountScreen({Key? key}) : super(key: key);

  @override
  State<AdminLabourCountScreen> createState() => _AdminLabourCountScreenState();
}

class _AdminLabourCountScreenState extends State<AdminLabourCountScreen> {
  final _authService = AuthService();
  
  List<Map<String, dynamic>> _sites = [];
  String? _selectedSiteId;
  String? _selectedSiteName;
  List<Map<String, dynamic>> _labourData = [];
  bool _isLoadingSites = false;
  bool _isLoadingData = false;

  @override
  void initState() {
    super.initState();
    _loadSites();
  }

  Future<void> _loadSites() async {
    setState(() => _isLoadingSites = true);

    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/admin/sites/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token ?? ''}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _sites = List<Map<String, dynamic>>.from(data['sites']);
        });
      }
    } catch (e) {
      print('Error loading sites: $e');
    } finally {
      setState(() => _isLoadingSites = false);
    }
  }

  Future<void> _loadLabourData(String siteId) async {
    setState(() => _isLoadingData = true);

    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/admin/sites/$siteId/labour-count/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token ?? ''}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _labourData = List<Map<String, dynamic>>.from(data['labour_data']);
        });
      }
    } catch (e) {
      print('Error loading labour data: $e');
    } finally {
      setState(() => _isLoadingData = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightSlate,
      appBar: AppBar(
        title: const Text(
          'Labour Count View',
          style: TextStyle(
            color: AppColors.deepNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.cleanWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.deepNavy),
      ),
      body: Column(
        children: [
          // Site selector
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.cleanWhite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Site',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepNavy,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedSiteId,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppColors.lightSlate,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  hint: const Text('Choose a site'),
                  items: _sites.map((site) {
                    return DropdownMenuItem<String>(
                      value: site['id'],
                      child: Text(site['site_name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      final site = _sites.firstWhere((s) => s['id'] == value);
                      setState(() {
                        _selectedSiteId = value;
                        _selectedSiteName = site['site_name'];
                      });
                      _loadLabourData(value);
                    }
                  },
                ),
              ],
            ),
          ),
          
          // Labour data list
          Expanded(
            child: _isLoadingData
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.statusCompleted),
                  )
                : _labourData.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 80,
                              color: AppColors.textSecondary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _selectedSiteId == null
                                  ? 'Select a site to view labour count'
                                  : 'No labour data available',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _labourData.length,
                        itemBuilder: (context, index) {
                          final entry = _labourData[index];
                          return _buildLabourCard(entry);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabourCard(Map<String, dynamic> entry) {
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
              color: AppColors.statusCompleted.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.people,
              color: AppColors.statusCompleted,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry['report_date'] ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Entered by: ${entry['entered_by'] ?? 'Unknown'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppColors.orangeGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${entry['labour_count']} Workers',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
