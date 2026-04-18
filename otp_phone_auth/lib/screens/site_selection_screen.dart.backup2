import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/site_model.dart';
import '../utils/app_colors.dart';
import 'supervisor_dashboard.dart';
import 'supervisor_profile_screen.dart';

class SiteSelectionScreen extends StatelessWidget {
  final String phoneNumber;

  const SiteSelectionScreen({super.key, required this.phoneNumber});

  List<SiteModel> _getMockSites() {
    final now = DateTime.now();
    return [
      SiteModel(
        id: '1',
        areaId: 'area1',
        streetId: 'street1',
        name: 'Kasakudy Residential',
        customerName: 'John Doe',
        builtUpArea: 2500.0,
        projectValue: 5000000.0,
        startDate: now.subtract(const Duration(days: 90)),
        createdAt: now.subtract(const Duration(days: 90)),
      ),
      SiteModel(
        id: '2',
        areaId: 'area2',
        streetId: 'street2',
        name: 'Thiruvettakudy Complex',
        customerName: 'Jane Smith',
        builtUpArea: 3200.0,
        projectValue: 7500000.0,
        startDate: now.subtract(const Duration(days: 60)),
        createdAt: now.subtract(const Duration(days: 60)),
      ),
      SiteModel(
        id: '3',
        areaId: 'area3',
        streetId: 'street3',
        name: 'Karaikal Villa',
        customerName: 'Bob Johnson',
        builtUpArea: 1800.0,
        projectValue: 3500000.0,
        startDate: now.subtract(const Duration(days: 30)),
        createdAt: now.subtract(const Duration(days: 30)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Get mock sites
    final sites = _getMockSites();
    
    // Create mock user from phone number
    final user = UserModel(
      uid: 'mock-uid-${phoneNumber.hashCode}',
      phoneNumber: phoneNumber,
      name: 'Supervisor',
      role: UserRole.supervisor,
      createdAt: DateTime.now(),
      isProfileComplete: true,
    );

    return WillPopScope(
      onWillPop: () async => false, // Prevent going back to login
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false, // Remove back button
          title: const Text('Select Site'),
          backgroundColor: AppColors.deepNavy,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.account_circle_outlined, size: 28),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SupervisorProfileScreen(user: user),
                  ),
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.deepNavy,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_city_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome, ${user.name ?? "Supervisor"}!',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Select a site to continue',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Sites List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: sites.length,
                  itemBuilder: (context, index) {
                    final site = sites[index];
                    return _buildSiteCard(context, site, user);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSiteCard(BuildContext context, SiteModel site, UserModel user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => SupervisorDashboard(user: user),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Site Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.safetyOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.apartment_rounded,
                    size: 32,
                    color: AppColors.safetyOrange,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Site Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        site.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${site.builtUpArea.toInt()} sq ft',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.statusCompleted.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Active',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.statusCompleted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Arrow Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.deepNavy.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: AppColors.deepNavy,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
