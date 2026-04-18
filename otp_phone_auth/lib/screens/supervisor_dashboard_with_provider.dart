import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/supervisor_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/common_widgets.dart';
import 'login_screen.dart';
import 'site_detail_screen.dart';
import 'supervisor_history_screen.dart';

class SupervisorDashboardWithProvider extends StatefulWidget {
  const SupervisorDashboardWithProvider({super.key});

  @override
  State<SupervisorDashboardWithProvider> createState() => _SupervisorDashboardWithProviderState();
}

class _SupervisorDashboardWithProviderState extends State<SupervisorDashboardWithProvider> {
  int _selectedIndex = 0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final provider = context.read<SupervisorProvider>();
    await provider.initialize(enableAutoRefresh: true);
    setState(() => _isInitialized = true);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SupervisorProvider, AuthProvider>(
      builder: (context, supervisorProvider, authProvider, child) {
        if (!_isInitialized) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Supervisor Dashboard'),
            backgroundColor: AppColors.primary,
            actions: [
              // Refresh button
              IconButton(
                icon: supervisorProvider.isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(Icons.refresh),
                onPressed: supervisorProvider.isLoading
                    ? null
                    : () => supervisorProvider.refreshData(),
              ),
              // Logout
              IconButton(
                icon: Icon(Icons.logout),
                onPressed: () async {
                  await authProvider.logout();
                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                    );
                  }
                },
              ),
            ],
          ),
          body: _buildBody(supervisorProvider),
          bottomNavigationBar: _buildBottomNav(),
        );
      },
    );
  }

  Widget _buildBody(SupervisorProvider provider) {
    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('Error: ${provider.error}'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                provider.clearError();
                provider.refreshData();
              },
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    switch (_selectedIndex) {
      case 0:
        return _buildDashboardTab(provider);
      case 1:
        return _buildHistoryTab(provider);
      case 2:
        return _buildReportsTab(provider);
      default:
        return _buildDashboardTab(provider);
    }
  }

  Widget _buildDashboardTab(SupervisorProvider provider) {
    return RefreshIndicator(
      onRefresh: () => provider.refreshData(),
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Area Dropdown
            _buildDropdown(
              label: 'Select Area',
              value: provider.selectedArea,
              items: provider.areas,
              onChanged: (value) async {
                if (value != null) {
                  await provider.loadStreets(value);
                }
              },
            ),
            SizedBox(height: 16),
            
            // Street Dropdown
            if (provider.streets.isNotEmpty)
              _buildDropdown(
                label: 'Select Street',
                value: provider.selectedStreet,
                items: provider.streets,
                onChanged: (value) async {
                  if (value != null) {
                    await provider.loadSites(
                      area: provider.selectedArea,
                      street: value,
                    );
                  }
                },
              ),
            SizedBox(height: 16),
            
            // Sites List
            if (provider.sites.isNotEmpty) ...[
              Text(
                'Sites (${provider.sites.length})',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              ...provider.sites.map((site) => _buildSiteCard(site, provider)),
            ],
            
            // Today's Entries
            if (provider.selectedSite != null && provider.todayEntries != null) ...[
              SizedBox(height: 24),
              Text(
                'Today\'s Entries',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              _buildTodayEntriesCard(provider.todayEntries!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab(SupervisorProvider provider) {
    if (provider.selectedSite == null) {
      return Center(
        child: Text('Please select a site from Dashboard'),
      );
    }

    final labourEntries = provider.historyData['labour_entries'] as List? ?? [];
    final materialEntries = provider.historyData['material_entries'] as List? ?? [];

    return RefreshIndicator(
      onRefresh: () => provider.refreshData(),
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text(
            'Labour History (${labourEntries.length})',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          ...labourEntries.map((entry) => _buildHistoryCard(entry, 'Labour')),
          SizedBox(height: 24),
          Text(
            'Material History (${materialEntries.length})',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          ...materialEntries.map((entry) => _buildHistoryCard(entry, 'Material')),
        ],
      ),
    );
  }

  Widget _buildReportsTab(SupervisorProvider provider) {
    return Center(
      child: Text('Reports - Coming Soon'),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSiteCard(Map<String, dynamic> site, SupervisorProvider provider) {
    final isSelected = provider.selectedSite == site['id'];
    
    return Card(
      color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
      child: ListTile(
        title: Text(site['site_name'] ?? 'Unknown'),
        subtitle: Text('${site['area']} - ${site['street']}'),
        trailing: Icon(
          isSelected ? Icons.check_circle : Icons.arrow_forward_ios,
          color: isSelected ? AppColors.primary : null,
        ),
        onTap: () {
          provider.setSelectedSite(site['id']);
        },
      ),
    );
  }

  Widget _buildTodayEntriesCard(Map<String, dynamic> entries) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Labour: ${entries['labour_count'] ?? 0}'),
            SizedBox(height: 8),
            Text('Materials: ${entries['material_count'] ?? 0}'),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> entry, String type) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(type),
        subtitle: Text(entry['entry_date'] ?? 'Unknown date'),
        trailing: Text(
          type == 'Labour'
              ? '${entry['labour_count']} workers'
              : '${entry['material_name']}',
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        BottomNavigationBarItem(icon: Icon(Icons.assessment), label: 'Reports'),
      ],
    );
  }
}
