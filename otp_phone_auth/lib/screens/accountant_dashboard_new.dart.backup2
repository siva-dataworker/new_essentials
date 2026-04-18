import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:excel/excel.dart' as excel;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/user_model.dart';
import '../providers/construction_provider.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import 'login_screen.dart';
import 'accountant_reports_screen.dart';
import 'accountant_entry_screen.dart';

class AccountantDashboardNew extends StatefulWidget {
  final UserModel user;

  const AccountantDashboardNew({super.key, required this.user});

  @override
  State<AccountantDashboardNew> createState() => _AccountantDashboardNewState();
}

class _AccountantDashboardNewState extends State<AccountantDashboardNew> {
  final _authService = AuthService();
  int _currentBottomIndex = 1; // Start with Dashboard (center icon)
  
  // Data variables
  List<Map<String, dynamic>> _labourEntries = [];
  List<Map<String, dynamic>> _materialEntries = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAccountantData();
  }

  Future<void> _loadAccountantData() async {
    print('🔄 [ACCOUNTANT NEW] Loading accountant data...');
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final provider = context.read<ConstructionProvider>();
      
      // Force fresh data load
      await provider.loadAccountantData(forceRefresh: true);
      
      // Get the data
      _labourEntries = List<Map<String, dynamic>>.from(provider.accountantLabourEntries);
      _materialEntries = List<Map<String, dynamic>>.from(provider.accountantMaterialEntries);
      
      print('✅ [ACCOUNTANT NEW] Loaded ${_labourEntries.length} labour entries');
      print('✅ [ACCOUNTANT NEW] Loaded ${_materialEntries.length} material entries');
      
      // Debug: Check for Lakshmi data
      final lakshmiLabour = _labourEntries.where((entry) => 
        entry['customer_name']?.toString().toLowerCase().contains('lakshmi') == true).toList();
      print('📋 [ACCOUNTANT NEW] Lakshmi labour entries: ${lakshmiLabour.length}');
      
      if (lakshmiLabour.isNotEmpty) {
        print('📝 [ACCOUNTANT NEW] Sample Lakshmi: ${lakshmiLabour[0]['customer_name']} ${lakshmiLabour[0]['site_name']}');
      }
      
    } catch (e) {
      print('❌ [ACCOUNTANT NEW] Error loading data: $e');
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Sign Out',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.deepNavy),
        ),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusOverdue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget currentScreen;
    switch (_currentBottomIndex) {
      case 0: // Entries
        currentScreen = const AccountantEntryScreen();
        break;
      case 1: // Dashboard (Center - Default)
        currentScreen = _buildDashboardScreen();
        break;
      case 2: // Reports
        currentScreen = const AccountantReportsScreen();
        break;
      case 3: // Export
        currentScreen = _buildExportScreen();
        break;
      default:
        currentScreen = _buildDashboardScreen();
    }

    return Scaffold(
      body: currentScreen,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildDashboardScreen() {
    return Scaffold(
      backgroundColor: AppColors.lightSlate,
      appBar: AppBar(
        title: Text(
          'Dashboard - ${widget.user.fullName}',
          style: const TextStyle(
            color: AppColors.deepNavy,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.cleanWhite,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.deepNavy),
            onPressed: _loadAccountantData,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.deepNavy),
            onPressed: _logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAccountantData,
        color: AppColors.deepNavy,
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.deepNavy),
                    SizedBox(height: 16),
                    Text(
                      'Loading accountant data...',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.statusOverdue,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading data',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.statusOverdue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadAccountantData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.deepNavy,
                          ),
                          child: const Text(
                            'Retry',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  )
                : _buildDashboardContent(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadAccountantData,
        backgroundColor: AppColors.safetyOrange,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildDashboardContent() {
    // Calculate totals
    final totalLabourEntries = _labourEntries.length;
    final totalMaterialEntries = _materialEntries.length;
    final totalWorkers = _labourEntries.fold<int>(0, (sum, entry) => sum + (entry['labour_count'] as int? ?? 0));
    
    // Get unique sites
    final uniqueSites = <String>{};
    for (var entry in _labourEntries + _materialEntries) {
      final customer = entry['customer_name']?.toString() ?? '';
      final site = entry['site_name']?.toString() ?? '';
      if (customer.isNotEmpty && site.isNotEmpty) {
        uniqueSites.add('$customer $site');
      }
    }

    // Get unique supervisors
    final uniqueSupervisors = <String>{};
    for (var entry in _labourEntries + _materialEntries) {
      final supervisor = entry['supervisor_name']?.toString() ?? '';
      if (supervisor.isNotEmpty) {
        uniqueSupervisors.add(supervisor);
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          const Text(
            'Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.deepNavy,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Labour Entries',
                  totalLabourEntries.toString(),
                  Icons.people,
                  AppColors.statusCompleted,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Material Entries',
                  totalMaterialEntries.toString(),
                  Icons.inventory_2,
                  AppColors.deepNavy,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Workers',
                  totalWorkers.toString(),
                  Icons.engineering,
                  AppColors.safetyOrange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Active Sites',
                  uniqueSites.length.toString(),
                  Icons.location_city,
                  AppColors.primaryPurple,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Recent Labour Entries
          const Text(
            'Recent Labour Entries',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.deepNavy,
            ),
          ),
          const SizedBox(height: 12),
          
          if (_labourEntries.isEmpty)
            _buildEmptyState('No labour entries found', Icons.people_outline)
          else
            ..._labourEntries.take(5).map((entry) => _buildLabourEntryCard(entry)).toList(),

          const SizedBox(height: 24),

          // Recent Material Entries
          const Text(
            'Recent Material Entries',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.deepNavy,
            ),
          ),
          const SizedBox(height: 12),
          
          if (_materialEntries.isEmpty)
            _buildEmptyState('No material entries found', Icons.inventory_2_outlined)
          else
            ..._materialEntries.take(5).map((entry) => _buildMaterialEntryCard(entry)).toList(),

          const SizedBox(height: 24),

          // Sites Summary
          const Text(
            'Sites Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.deepNavy,
            ),
          ),
          const SizedBox(height: 12),
          
          _buildSitesSummaryCard(uniqueSites.toList()),

          const SizedBox(height: 24),

          // Supervisors Summary
          const Text(
            'Supervisors Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.deepNavy,
            ),
          ),
          const SizedBox(height: 12),
          
          _buildSupervisorsSummaryCard(uniqueSupervisors.toList()),

          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabourEntryCard(Map<String, dynamic> entry) {
    final fullSiteName = '${entry['customer_name'] ?? ''} ${entry['site_name'] ?? ''}'.trim();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.statusCompleted.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.people,
              color: AppColors.statusCompleted,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry['labour_type'] ?? 'Unknown Type',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  fullSiteName,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Supervisor: ${entry['supervisor_name'] ?? 'Unknown'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry['labour_count'] ?? 0}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.statusCompleted,
                ),
              ),
              const Text(
                'Workers',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialEntryCard(Map<String, dynamic> entry) {
    final fullSiteName = '${entry['customer_name'] ?? ''} ${entry['site_name'] ?? ''}'.trim();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.deepNavy.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.inventory_2,
              color: AppColors.deepNavy,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry['material_type'] ?? 'Unknown Type',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  fullSiteName,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Supervisor: ${entry['supervisor_name'] ?? 'Unknown'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry['quantity'] ?? 0}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepNavy,
                ),
              ),
              Text(
                entry['unit'] ?? '',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSitesSummaryCard(List<String> sites) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_city, color: AppColors.primaryPurple),
              const SizedBox(width: 8),
              Text(
                '${sites.length} Active Sites',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...sites.take(5).map((site) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                const Icon(Icons.circle, size: 6, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    site,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
          if (sites.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'and ${sites.length - 5} more sites...',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSupervisorsSummaryCard(List<String> supervisors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.supervisor_account, color: AppColors.safetyOrange),
              const SizedBox(width: 8),
              Text(
                '${supervisors.length} Active Supervisors',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...supervisors.map((supervisor) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                const Icon(Icons.circle, size: 6, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    supervisor,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportScreen() {
    return Scaffold(
      backgroundColor: AppColors.lightSlate,
      appBar: AppBar(
        title: const Text(
          'Export Data',
          style: TextStyle(
            color: AppColors.deepNavy,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.cleanWhite,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.file_download,
              size: 64,
              color: AppColors.deepNavy,
            ),
            const SizedBox(height: 16),
            const Text(
              'Export to Excel',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.deepNavy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Export ${_labourEntries.length + _materialEntries.length} entries',
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _exportToExcel,
              icon: const Icon(Icons.download),
              label: const Text('Download Excel'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepNavy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportToExcel() async {
    try {
      final excelFile = excel.Excel.createExcel();
      
      // Labour sheet
      final labourSheet = excelFile['Labour Entries'];
      labourSheet.appendRow([
        excel.TextCellValue('Date'),
        excel.TextCellValue('Time'),
        excel.TextCellValue('Supervisor'),
        excel.TextCellValue('Site'),
        excel.TextCellValue('Area'),
        excel.TextCellValue('Street'),
        excel.TextCellValue('Labour Type'),
        excel.TextCellValue('Count'),
      ]);
      
      for (var entry in _labourEntries) {
        labourSheet.appendRow([
          excel.TextCellValue(entry['entry_date'] ?? ''),
          excel.TextCellValue(_formatTime(entry['entry_time'] ?? entry['entry_date'])),
          excel.TextCellValue(entry['supervisor_name'] ?? ''),
          excel.TextCellValue('${entry['customer_name'] ?? ''} ${entry['site_name'] ?? ''}'.trim()),
          excel.TextCellValue(entry['area'] ?? ''),
          excel.TextCellValue(entry['street'] ?? ''),
          excel.TextCellValue(entry['labour_type'] ?? ''),
          excel.IntCellValue(entry['labour_count'] ?? 0),
        ]);
      }
      
      // Material sheet
      final materialSheet = excelFile['Material Entries'];
      materialSheet.appendRow([
        excel.TextCellValue('Date'),
        excel.TextCellValue('Time'),
        excel.TextCellValue('Supervisor'),
        excel.TextCellValue('Site'),
        excel.TextCellValue('Area'),
        excel.TextCellValue('Street'),
        excel.TextCellValue('Material Type'),
        excel.TextCellValue('Quantity'),
        excel.TextCellValue('Unit'),
      ]);
      
      for (var entry in _materialEntries) {
        materialSheet.appendRow([
          excel.TextCellValue(entry['entry_date'] ?? ''),
          excel.TextCellValue(_formatTime(entry['updated_at'] ?? entry['entry_date'])),
          excel.TextCellValue(entry['supervisor_name'] ?? ''),
          excel.TextCellValue('${entry['customer_name'] ?? ''} ${entry['site_name'] ?? ''}'.trim()),
          excel.TextCellValue(entry['area'] ?? ''),
          excel.TextCellValue(entry['street'] ?? ''),
          excel.TextCellValue(entry['material_type'] ?? ''),
          excel.DoubleCellValue(entry['quantity']?.toDouble() ?? 0.0),
          excel.TextCellValue(entry['unit'] ?? ''),
        ]);
      }
      
      // Save file
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filePath = '${directory.path}/construction_data_$timestamp.xlsx';
      
      final file = File(filePath);
      await file.writeAsBytes(excelFile.encode()!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Excel file saved to: $filePath'),
            backgroundColor: AppColors.statusCompleted,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting: $e'),
            backgroundColor: AppColors.statusOverdue,
          ),
        );
      }
    }
  }

  String _formatTime(String? dateTimeStr) {
    if (dateTimeStr == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return DateFormat('MMM d, h:mm a').format(dateTime);
    } catch (e) {
      return dateTimeStr;
    }
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cleanWhite,
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentBottomIndex,
        onTap: (index) => setState(() => _currentBottomIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.cleanWhite,
        selectedItemColor: AppColors.deepNavy,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Entries',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment_outlined),
            activeIcon: Icon(Icons.assessment),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.file_download_outlined),
            activeIcon: Icon(Icons.file_download),
            label: 'Export',
          ),
        ],
      ),
    );
  }
}
