import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/auth_service.dart';
import '../utils/admin_theme.dart';

class AdminSitesTestScreen extends StatefulWidget {
  const AdminSitesTestScreen({Key? key}) : super(key: key);

  @override
  State<AdminSitesTestScreen> createState() => _AdminSitesTestScreenState();
}

class _AdminSitesTestScreenState extends State<AdminSitesTestScreen> {
  List<Map<String, dynamic>> _sites = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSites();
  }

  Future<void> _loadSites() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('🔍 Loading sites from API...');
      final url = '${AuthService.baseUrl}/admin/sites/';
      print('📡 URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      print('📊 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _sites = List<Map<String, dynamic>>.from(data['sites']);
          _isLoading = false;
        });
        print('✅ Loaded ${_sites.length} sites');
      } else {
        setState(() {
          _error = 'Failed to load sites: ${response.statusCode}';
          _isLoading = false;
        });
        print('❌ Error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
      print('❌ Exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminTheme.lightGray,
      appBar: AppBar(
        title: const Text('Sites Test', style: AdminTheme.heading2),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AdminTheme.primaryBlue),
            onPressed: _loadSites,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AdminTheme.primaryBlue),
            SizedBox(height: 16),
            Text('Loading sites...', style: AdminTheme.bodyMedium),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AdminTheme.errorRed),
            const SizedBox(height: 16),
            Text(_error!, style: AdminTheme.bodyLarge),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSites,
              style: AdminTheme.primaryButton(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_sites.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_city_outlined, size: 64, color: AdminTheme.neutralGray),
            SizedBox(height: 16),
            Text('No sites found', style: AdminTheme.bodyLarge),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sites.length,
      itemBuilder: (context, index) {
        final site = _sites[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: AdminTheme.modernCard(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AdminTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.location_city,
                      color: AdminTheme.primaryBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          site['site_name'] ?? 'Unnamed Site',
                          style: AdminTheme.heading3,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          site['location'] ?? 'No location',
                          style: AdminTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AdminTheme.lightGray,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'ID: ${site['id']}',
                  style: AdminTheme.caption,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
