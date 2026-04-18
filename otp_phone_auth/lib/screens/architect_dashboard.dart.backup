import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/user_model.dart';
import '../providers/construction_provider.dart';
import '../services/construction_service.dart';
import '../utils/app_colors.dart';
import '../widgets/common_widgets.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'architect_client_complaints_screen.dart';

class ArchitectDashboard extends StatefulWidget {
  final UserModel user;

  const ArchitectDashboard({super.key, required this.user});

  @override
  State<ArchitectDashboard> createState() => _ArchitectDashboardState();
}

class _ArchitectDashboardState extends State<ArchitectDashboard> {
  final _authService = AuthService();
  int _selectedIndex = 0; // 0 = Sites, 1 = Profile
  
  // Dropdown state
  String? _selectedArea;
  String? _selectedStreet;
  String? _selectedSite;
  
  // Data lists
  List<String> _areas = [];
  List<String> _streets = [];
  List<Map<String, dynamic>> _sites = [];
  
  // Loading states
  bool _isLoadingAreas = false;
  bool _isLoadingStreets = false;
  bool _isLoadingSites = false;

  @override
  void initState() {
    super.initState();
    _loadAreas();
  }

  Future<void> _loadAreas() async {
    setState(() => _isLoadingAreas = true);
    try {
      final provider = context.read<ConstructionProvider>();
      final response = await provider.getAreas();
      if (response['success']) {
        setState(() {
          _areas = List<String>.from(response['areas']);
        });
      }
    } catch (e) {
      print('Error loading areas: $e');
    } finally {
      setState(() => _isLoadingAreas = false);
    }
  }

  Future<void> _loadStreets(String area) async {
    setState(() {
      _isLoadingStreets = true;
      _selectedStreet = null;
      _selectedSite = null;
      _streets = [];
      _sites = [];
    });
    
    try {
      final provider = context.read<ConstructionProvider>();
      final response = await provider.getStreets(area);
      if (response['success']) {
        setState(() {
          _streets = List<String>.from(response['streets']);
        });
      }
    } catch (e) {
      print('Error loading streets: $e');
    } finally {
      setState(() => _isLoadingStreets = false);
    }
  }

  Future<void> _loadSites(String area, String street) async {
    setState(() {
      _isLoadingSites = true;
      _selectedSite = null;
      _sites = [];
    });
    
    try {
      final provider = context.read<ConstructionProvider>();
      final response = await provider.getSitesByAreaStreet(area, street);
      if (response['success']) {
        setState(() {
          _sites = List<Map<String, dynamic>>.from(response['sites']);
        });
      }
    } catch (e) {
      print('Error loading sites: $e');
    } finally {
      setState(() => _isLoadingSites = false);
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _onAreaChanged(String? area) {
    setState(() {
      _selectedArea = area;
      _selectedStreet = null;
      _selectedSite = null;
      _streets = [];
      _sites = [];
    });
    
    if (area != null) {
      _loadStreets(area);
    }
  }

  void _onStreetChanged(String? street) {
    setState(() {
      _selectedStreet = street;
      _selectedSite = null;
      _sites = [];
    });
    
    if (street != null && _selectedArea != null) {
      _loadSites(_selectedArea!, street);
    }
  }

  void _onSiteChanged(String? siteId) {
    setState(() => _selectedSite = siteId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightSlate,
      body: _selectedIndex == 0 ? _buildSitesTab() : _buildProfileTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: AppColors.deepNavy,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.location_city),
            label: 'Sites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildSitesTab() {
    // If no site is selected, show dropdown selection screen
    if (_selectedSite == null) {
      return _buildSiteSelectionScreen();
    }
    
    // If site is selected, show architect tools
    return _buildArchitectToolsScreen();
  }

  Widget _buildSiteSelectionScreen() {
    return Scaffold(
      backgroundColor: AppColors.lightSlate,
      appBar: CommonWidgets.buildAppBar(
        context,
        title: '${widget.user.name ?? 'Architect'} - Select Site',
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.deepNavy),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cleanWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.deepNavy.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple.shade600, Colors.purple.shade400],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        (widget.user.name ?? 'A').substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user.name ?? 'Architect',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.deepNavy,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Select site to manage documents & complaints',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Site Selection Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.cleanWhite,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.deepNavy.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Site Selection',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepNavy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Choose area, street, and site to manage',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Area Dropdown
                  _buildDropdownSection(
                    title: 'Area',
                    icon: Icons.location_city,
                    value: _selectedArea,
                    items: _areas,
                    onChanged: _onAreaChanged,
                    isLoading: _isLoadingAreas,
                    hint: 'Select an area',
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Street Dropdown
                  _buildDropdownSection(
                    title: 'Street',
                    icon: Icons.route,
                    value: _selectedStreet,
                    items: _streets,
                    onChanged: _onStreetChanged,
                    isLoading: _isLoadingStreets,
                    hint: 'Select a street',
                    enabled: _selectedArea != null,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Site Dropdown
                  _buildSiteDropdownSection(),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.purple.shade200,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.purple.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Select all three dropdowns to access architect tools for the site.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.purple.shade700,
                        height: 1.4,
                      ),
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

  Widget _buildArchitectToolsScreen() {
    final site = _sites.firstWhere((s) => s['id'] == _selectedSite);
    final siteName = site['display_name'] ?? site['site_name'] ?? 'Site';
    
    return Scaffold(
      backgroundColor: AppColors.lightSlate,
      appBar: CommonWidgets.buildAppBar(
        context,
        title: '$siteName - Architect Tools',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _selectedSite = null;
              _selectedArea = null;
              _selectedStreet = null;
              _streets.clear();
              _sites.clear();
            });
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Site Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cleanWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.deepNavy.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple.shade600, Colors.purple.shade400],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.architecture, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          siteName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.deepNavy,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${site['area']} • ${site['street']}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildActionCard(
                    title: 'Upload Documents',
                    subtitle: 'Plans, designs, drawings',
                    icon: Icons.upload_file,
                    color: Colors.blue.shade600,
                    onTap: () => _showDocumentUpload(),
                  ),
                  _buildActionCard(
                    title: 'Raise Complaint',
                    subtitle: 'Report issues to site engineer',
                    icon: Icons.report_problem,
                    color: Colors.orange.shade600,
                    onTap: () => _showComplaintForm(),
                  ),
                  _buildActionCard(
                    title: 'Client Complaints',
                    subtitle: 'View & respond to client issues',
                    icon: Icons.chat_bubble_outline,
                    color: Colors.red.shade600,
                    onTap: () => _showClientComplaints(),
                  ),
                  _buildActionCard(
                    title: 'Site Estimation',
                    subtitle: 'Upload cost estimates',
                    icon: Icons.calculate,
                    color: Colors.green.shade600,
                    onTap: () => _showEstimationForm(),
                  ),
                  _buildActionCard(
                    title: 'View History',
                    subtitle: 'Previous uploads & complaints',
                    icon: Icons.history,
                    color: Colors.purple.shade600,
                    onTap: () => _showHistory(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownSection({
    required String title,
    required IconData icon,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required bool isLoading,
    required String hint,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.purple.shade600),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: enabled ? AppColors.lightBackground : AppColors.lightBackground.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: enabled ? Colors.purple.shade300 : AppColors.textSecondary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: isLoading
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.purple.shade600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Loading...',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value,
                    hint: Text(
                      enabled ? hint : 'Select ${title.toLowerCase()} first',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: enabled ? Colors.purple.shade600 : AppColors.textSecondary,
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.purple.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                    items: enabled
                        ? items.map((item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            );
                          }).toList()
                        : null,
                    onChanged: enabled ? onChanged : null,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSiteDropdownSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.business, size: 18, color: Colors.purple.shade600),
            const SizedBox(width: 8),
            Text(
              'Site',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: _selectedStreet != null ? AppColors.lightBackground : AppColors.lightBackground.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _selectedStreet != null ? Colors.purple.shade300 : AppColors.textSecondary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: _isLoadingSites
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.purple.shade600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Loading sites...',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedSite,
                    hint: Text(
                      _selectedStreet != null ? 'Select a site' : 'Select street first',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: _selectedStreet != null ? Colors.purple.shade600 : AppColors.textSecondary,
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.purple.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                    items: _selectedStreet != null
                        ? _sites.map((site) {
                            return DropdownMenuItem<String>(
                              value: site['id'],
                              child: Text(site['display_name'] ?? site['site_name'] ?? 'Site'),
                            );
                          }).toList()
                        : null,
                    onChanged: _selectedStreet != null ? _onSiteChanged : null,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cleanWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.deepNavy.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.deepNavy,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showDocumentUpload() {
    showDialog(
      context: context,
      builder: (context) => _DocumentUploadDialog(
        siteId: _selectedSite!,
        onUploadSuccess: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Document uploaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  void _showComplaintForm() {
    showDialog(
      context: context,
      builder: (context) => _ComplaintFormDialog(
        siteId: _selectedSite!,
        onSubmitSuccess: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Complaint submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  void _showEstimationForm() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Estimation form coming soon!')),
    );
  }

  void _showClientComplaints() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArchitectClientComplaintsScreen(siteId: _selectedSite!),
      ),
    );
  }

  void _showHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArchitectHistoryScreen(siteId: _selectedSite!),
      ),
    );
  }

  // ============================================
  // PROFILE TAB
  // ============================================

  Widget _buildProfileTab() {
    return Scaffold(
      backgroundColor: AppColors.lightSlate,
      appBar: CommonWidgets.buildAppBar(
        context,
        title: 'Profile',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Avatar
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade600, Colors.purple.shade400],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              widget.user.name ?? 'Architect',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.deepNavy,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.user.email ?? '',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade600, Colors.purple.shade400],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Architect',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Profile Options
            _buildProfileOption(Icons.person_outline, 'Edit Profile', () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit Profile - Coming Soon')),
              );
            }),
            _buildProfileOption(Icons.lock_outline, 'Change Password', () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Change Password - Coming Soon')),
              );
            }),
            _buildProfileOption(Icons.settings_outlined, 'Settings', () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings - Coming Soon')),
              );
            }),
            _buildProfileOption(Icons.help_outline, 'Help & Support', () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help & Support - Coming Soon')),
              );
            }),
            _buildProfileOption(Icons.info_outline, 'About', () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('About - Coming Soon')),
              );
            }),
            const SizedBox(height: 16),
            _buildProfileOption(
              Icons.logout,
              'Sign Out',
              _logout,
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : AppColors.deepNavy,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDestructive ? Colors.red : AppColors.deepNavy,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: isDestructive ? Colors.red : Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}

// Document Upload Dialog
class _DocumentUploadDialog extends StatefulWidget {
  final String siteId;
  final VoidCallback onUploadSuccess;

  const _DocumentUploadDialog({
    required this.siteId,
    required this.onUploadSuccess,
  });

  @override
  State<_DocumentUploadDialog> createState() => _DocumentUploadDialogState();
}

class _DocumentUploadDialogState extends State<_DocumentUploadDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedDocumentType = 'Floor Plan';
  bool _isUploading = false;
  PlatformFile? _selectedFile;

  final List<String> _documentTypes = [
    'Floor Plan',
    'Elevation',
    'Structure Drawing',
    'Design',
    'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  Future<void> _uploadDocument() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file to upload')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final constructionService = ConstructionService();
      final result = await constructionService.uploadArchitectDocument(
        siteId: widget.siteId,
        documentType: _selectedDocumentType,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        filePath: _selectedFile!.path!,
      );

      if (result['success']) {
        widget.onUploadSuccess();
        Navigator.pop(context);
        
        // Refresh architect data in provider
        if (mounted) {
          context.read<ConstructionProvider>().loadArchitectData(
            forceRefresh: true,
            siteId: widget.siteId,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${result['error']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload Document',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.deepNavy,
              ),
            ),
            const SizedBox(height: 20),
            
            // Document Type Dropdown
            const Text(
              'Document Type',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.deepNavy,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.purple.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedDocumentType,
                  isExpanded: true,
                  items: _documentTypes.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedDocumentType = value!);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // File Selection
            const Text(
              'Select File',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.deepNavy,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _selectedFile != null ? Colors.purple.shade600 : Colors.purple.shade300,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: _selectedFile != null ? Colors.purple.shade50 : Colors.grey.shade50,
                ),
                child: Row(
                  children: [
                    Icon(
                      _selectedFile != null ? Icons.check_circle : Icons.upload_file,
                      color: _selectedFile != null ? Colors.purple.shade600 : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedFile != null ? _selectedFile!.name : 'Tap to select file',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _selectedFile != null ? Colors.purple.shade700 : Colors.grey.shade600,
                            ),
                          ),
                          if (_selectedFile != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${(_selectedFile!.size / 1024 / 1024).toStringAsFixed(2)} MB',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ] else ...[
                            const SizedBox(height: 4),
                            Text(
                              'Supported: PDF, JPG, PNG, DOC, DOCX',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Title Field
            const Text(
              'Title',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.deepNavy,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Enter document title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.purple.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.purple.shade600),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Description Field
            const Text(
              'Description (Optional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.deepNavy,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.purple.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.purple.shade600),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isUploading ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isUploading ? null : _uploadDocument,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade600,
                    foregroundColor: Colors.white,
                  ),
                  child: _isUploading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Upload'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Complaint Form Dialog
class _ComplaintFormDialog extends StatefulWidget {
  final String siteId;
  final VoidCallback onSubmitSuccess;

  const _ComplaintFormDialog({
    required this.siteId,
    required this.onSubmitSuccess,
  });

  @override
  State<_ComplaintFormDialog> createState() => _ComplaintFormDialogState();
}

class _ComplaintFormDialogState extends State<_ComplaintFormDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedPriority = 'MEDIUM';
  bool _isSubmitting = false;

  final List<String> _priorities = ['LOW', 'MEDIUM', 'HIGH', 'URGENT'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitComplaint() async {
    if (_titleController.text.trim().isEmpty || _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final constructionService = ConstructionService();
      final result = await constructionService.uploadArchitectComplaint(
        siteId: widget.siteId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _selectedPriority,
      );

      if (result['success']) {
        widget.onSubmitSuccess();
        Navigator.pop(context);
        
        // Refresh architect data in provider
        if (mounted) {
          context.read<ConstructionProvider>().loadArchitectData(
            forceRefresh: true,
            siteId: widget.siteId,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission failed: ${result['error']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission failed: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Raise Complaint',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.deepNavy,
              ),
            ),
            const SizedBox(height: 20),
            
            // Priority Dropdown
            const Text(
              'Priority',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.deepNavy,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPriority,
                  isExpanded: true,
                  items: _priorities.map((priority) {
                    return DropdownMenuItem(value: priority, child: Text(priority));
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedPriority = value!);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Title Field
            const Text(
              'Title',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.deepNavy,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Enter complaint title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.orange.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.orange.shade600),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Description Field
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.deepNavy,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe the issue in detail',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.orange.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.orange.shade600),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitComplaint,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    foregroundColor: Colors.white,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Submit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Architect History Screen (placeholder for now)
class ArchitectHistoryScreen extends StatelessWidget {
  final String siteId;

  const ArchitectHistoryScreen({super.key, required this.siteId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Architect History'),
        backgroundColor: AppColors.cleanWhite,
        foregroundColor: AppColors.deepNavy,
      ),
      body: const Center(
        child: Text(
          'Architect History with dropdown date filtering\nwill be implemented here',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
