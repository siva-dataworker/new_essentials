import 'package:flutter/material.dart';
import '../services/construction_service.dart';
import '../utils/app_colors.dart';

class AssignWorkingSitesScreen extends StatefulWidget {
  const AssignWorkingSitesScreen({super.key});

  @override
  State<AssignWorkingSitesScreen> createState() => _AssignWorkingSitesScreenState();
}

class _AssignWorkingSitesScreenState extends State<AssignWorkingSitesScreen> {
  final _constructionService = ConstructionService();
  
  List<Map<String, dynamic>> _allSites = [];
  List<Map<String, dynamic>> _filteredSites = [];
  final Set<String> _selectedSiteIds = {};
  final Map<String, TextEditingController> _descriptionControllers = {};
  final TextEditingController _searchController = TextEditingController();
  
  bool _isLoadingSites = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadAllSites();
    _searchController.addListener(_filterSites);
  }

  @override
  void dispose() {
    for (var controller in _descriptionControllers.values) {
      controller.dispose();
    }
    _searchController.dispose();
    super.dispose();
  }

  void _filterSites() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredSites = _allSites;
      } else {
        _filteredSites = _allSites.where((site) {
          final displayName = (site['display_name'] ?? '').toString().toLowerCase();
          final siteName = (site['site_name'] ?? '').toString().toLowerCase();
          final customerName = (site['customer_name'] ?? '').toString().toLowerCase();
          return displayName.contains(query) || 
                 siteName.contains(query) || 
                 customerName.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _loadAllSites() async {
    setState(() => _isLoadingSites = true);
    
    try {
      final result = await _constructionService.getAllSites();
      
      if (result['success'] && mounted) {
        setState(() {
          _allSites = result['sites'] as List<Map<String, dynamic>>;
          _filteredSites = _allSites;
          _isLoadingSites = false;
        });
      } else {
        if (mounted) {
          setState(() => _isLoadingSites = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${result['error'] ?? 'Failed to load sites'}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingSites = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading sites: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitAssignment() async {
    if (_selectedSiteIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one site'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Prepare sites data
    final sites = _selectedSiteIds.map((siteId) {
      return {
        'site_id': siteId,
        'description': _descriptionControllers[siteId]?.text.trim() ?? '',
      };
    }).toList();

    final result = await _constructionService.assignWorkingSites(
      sites: sites,
    );

    setState(() => _isSubmitting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['success'] 
              ? '✅ ${result['message']}' 
              : '❌ ${result['error']}'),
          backgroundColor: result['success'] ? AppColors.statusCompleted : Colors.red,
        ),
      );

      if (result['success']) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightSlate,
      appBar: AppBar(
        title: const Text('Assign Working Sites'),
        backgroundColor: AppColors.deepNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header Info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.navyGradient,
              boxShadow: [AppColors.cardShadow],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Sites to Assign',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Selected sites will be assigned to all supervisors',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                if (_isLoadingSites) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Loading sites...',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ] else if (_allSites.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    '${_allSites.length} sites available',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Search Bar
          if (!_isLoadingSites && _allSites.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search sites...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.deepNavy),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppColors.deepNavy),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.lightSlate,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),

          // Sites List
          Expanded(
            child: _isLoadingSites
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppColors.deepNavy),
                        SizedBox(height: 16),
                        Text(
                          'Loading sites...',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.deepNavy,
                          ),
                        ),
                      ],
                    ),
                  )
                : _filteredSites.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchController.text.isNotEmpty 
                                  ? Icons.search_off 
                                  : Icons.construction,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isNotEmpty
                                  ? 'No sites found'
                                  : 'No sites available',
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.deepNavy,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredSites.length,
                        itemBuilder: (context, index) {
                          final site = _filteredSites[index];
                          final siteId = site['id'].toString();
                          final isSelected = _selectedSiteIds.contains(siteId);

                          // Create controller if not exists
                          if (!_descriptionControllers.containsKey(siteId)) {
                            _descriptionControllers[siteId] = TextEditingController();
                          }

                          return _buildSiteCard(site, siteId, isSelected);
                        },
                      ),
          ),

          // Submit Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitAssignment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.statusCompleted,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Assign ${_selectedSiteIds.length} Site${_selectedSiteIds.length != 1 ? 's' : ''} to All Supervisors',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSiteCard(Map<String, dynamic> site, String siteId, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cleanWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.statusCompleted : Colors.transparent,
          width: 2,
        ),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        children: [
          CheckboxListTile(
            value: isSelected,
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _selectedSiteIds.add(siteId);
                } else {
                  _selectedSiteIds.remove(siteId);
                }
              });
            },
            title: Text(
              site['display_name'] ?? site['site_name'] ?? 'Site',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.deepNavy,
              ),
            ),
            activeColor: AppColors.statusCompleted,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          
          // Description field (shown when selected)
          if (isSelected)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: TextField(
                controller: _descriptionControllers[siteId],
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Add description (optional)',
                  filled: true,
                  fillColor: AppColors.lightSlate,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
