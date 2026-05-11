import 'package:flutter/material.dart';
import '../services/construction_service.dart';
import '../services/cache_service.dart';

class AdminAllWorkingSitesScreen extends StatefulWidget {
  const AdminAllWorkingSitesScreen({super.key});

  @override
  State<AdminAllWorkingSitesScreen> createState() => _AdminAllWorkingSitesScreenState();
}

class _AdminAllWorkingSitesScreenState extends State<AdminAllWorkingSitesScreen> {
  final _constructionService = ConstructionService();
  List<Map<String, dynamic>> _allWorkingSites = [];
  List<Map<String, dynamic>> _filteredSites = [];
  bool _isLoading = false;
  
  // Filter state
  final TextEditingController _searchController = TextEditingController();
  String? _selectedArea;
  String? _selectedStreet;
  List<String> _availableAreas = [];
  List<String> _availableStreets = [];
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _loadWorkingSites();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadWorkingSites() async {
    // Try cache first
    final cached = await CacheService.loadAllWorkingSites();
    if (cached != null && mounted) {
      // Extract unique areas from cached data
      final areas = cached.map((s) => s['area']?.toString() ?? '').where((a) => a.isNotEmpty).toSet().toList();
      areas.sort();
      setState(() {
        _allWorkingSites = cached;
        _availableAreas = areas;
        _isLoading = false;
      });
      _applyFilters();
      return;
    }

    if (mounted) setState(() => _isLoading = true);

    try {
      final result = await _constructionService.getWorkingSites();

      print('🔍 [ADMIN] API Response: $result');

      if (result['success'] == true && mounted) {
        final sites = List<Map<String, dynamic>>.from(result['sites'] ?? []);
        print('✅ [ADMIN] Loaded ${sites.length} working sites');

        await CacheService.saveAllWorkingSites(sites);

        // Extract unique areas and streets
        final areas = sites.map((s) => s['area']?.toString() ?? '').where((a) => a.isNotEmpty).toSet().toList();
        areas.sort();

        if (mounted) {
          setState(() {
            _allWorkingSites = sites;
            _availableAreas = areas;
          });
          _applyFilters();
        }
      } else {
        print('❌ [ADMIN] Error: ${result['error']}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${result['error'] ?? 'Failed to load working sites'}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ [ADMIN] Exception: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading working sites: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Bypasses cache — called by pull-to-refresh and the refresh icon button.
  Future<void> _refreshWorkingSites() async {
    if (mounted) setState(() => _isLoading = true);

    try {
      final result = await _constructionService.getWorkingSites();

      print('🔍 [ADMIN] Refresh API Response: $result');

      if (result['success'] == true && mounted) {
        final sites = List<Map<String, dynamic>>.from(result['sites'] ?? []);
        print('✅ [ADMIN] Refreshed ${sites.length} working sites');

        await CacheService.saveAllWorkingSites(sites);

        // Extract unique areas and streets
        final areas = sites.map((s) => s['area']?.toString() ?? '').where((a) => a.isNotEmpty).toSet().toList();
        areas.sort();

        if (mounted) {
          setState(() {
            _allWorkingSites = sites;
            _availableAreas = areas;
          });
          _applyFilters();
        }
      } else {
        print('❌ [ADMIN] Refresh Error: ${result['error']}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${result['error'] ?? 'Failed to refresh working sites'}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ [ADMIN] Refresh Exception: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error refreshing working sites: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      _filteredSites = _allWorkingSites.where((site) {
        // Search filter
        final displayName = (site['display_name'] ?? site['site_name'] ?? '').toString().toLowerCase();
        final siteName = (site['site_name'] ?? '').toString().toLowerCase();
        final customerName = (site['customer_name'] ?? '').toString().toLowerCase();
        final matchesSearch = query.isEmpty || 
            displayName.contains(query) || 
            siteName.contains(query) || 
            customerName.contains(query);
        
        // Area filter
        final matchesArea = _selectedArea == null || site['area'] == _selectedArea;
        
        // Street filter
        final matchesStreet = _selectedStreet == null || site['street'] == _selectedStreet;
        
        return matchesSearch && matchesArea && matchesStreet;
      }).toList();
      
      // Update available streets based on selected area
      if (_selectedArea != null) {
        _availableStreets = _allWorkingSites
            .where((s) => s['area'] == _selectedArea)
            .map((s) => s['street']?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .toSet()
            .toList();
        _availableStreets.sort();
      } else {
        _availableStreets = [];
      }
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedArea = null;
      _selectedStreet = null;
      _availableStreets = [];
      _filteredSites = _allWorkingSites;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters = _searchController.text.isNotEmpty || 
                            _selectedArea != null || 
                            _selectedStreet != null;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'All Working Sites',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_alt : Icons.filter_alt_outlined),
            onPressed: () {
              setState(() => _showFilters = !_showFilters);
            },
            tooltip: 'Filters',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshWorkingSites,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar (always visible)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search sites...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF1A1A2E)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Color(0xFF6B7280)),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          
          // Filter Section (collapsible)
          if (_showFilters)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              color: Colors.white,
              child: Column(
                children: [
                  // Area Filter
                  DropdownButtonFormField<String>(
                    value: _selectedArea,
                    decoration: InputDecoration(
                      labelText: 'Filter by Area',
                      prefixIcon: const Icon(Icons.location_city, color: Color(0xFF1A1A2E), size: 20),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Areas')),
                      ..._availableAreas.map((area) => DropdownMenuItem(
                        value: area,
                        child: Text(area),
                      )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedArea = value;
                        _selectedStreet = null; // Reset street when area changes
                      });
                      _applyFilters();
                    },
                  ),
                  
                  // Street Filter (only show if area is selected)
                  if (_selectedArea != null) ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedStreet,
                      decoration: InputDecoration(
                        labelText: 'Filter by Street',
                        prefixIcon: const Icon(Icons.route, color: Color(0xFF1A1A2E), size: 20),
                        filled: true,
                        fillColor: const Color(0xFFF8F9FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All Streets')),
                        ..._availableStreets.map((street) => DropdownMenuItem(
                          value: street,
                          child: Text(street),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedStreet = value);
                        _applyFilters();
                      },
                    ),
                  ],
                  
                  // Clear Filters Button
                  if (hasActiveFilters) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _clearFilters,
                        icon: const Icon(Icons.clear_all, size: 18),
                        label: const Text('Clear All Filters'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1A1A2E),
                          side: const BorderSide(color: Color(0xFF1A1A2E)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          
          // Results Count
          if (!_isLoading)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFFF8F9FA),
              child: Row(
                children: [
                  Text(
                    '${_filteredSites.length} site${_filteredSites.length != 1 ? 's' : ''} found',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (hasActiveFilters) ...[
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A2E).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Filtered',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1A1A2E),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          
          const Divider(height: 1),
          
          // Sites List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF1A1A2E)),
                  )
                : _filteredSites.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                hasActiveFilters ? Icons.search_off : Icons.work_off,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              hasActiveFilters ? 'No Sites Found' : 'No Working Sites',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              hasActiveFilters 
                                  ? 'Try adjusting your filters'
                                  : 'Sites assigned by accountants\nwill appear here',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            if (hasActiveFilters) ...[
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _clearFilters,
                                icon: const Icon(Icons.clear_all, size: 18),
                                label: const Text('Clear Filters'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1A1A2E),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _refreshWorkingSites,
                        color: const Color(0xFF1A1A2E),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredSites.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final site = _filteredSites[index];
                            return _buildSiteCard(site);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSiteCard(Map<String, dynamic> site) {
    final siteName = site['site_name'] ?? 'Unknown Site';
    final customerName = site['customer_name'] ?? '';
    final area = site['area'] ?? '';
    final street = site['street'] ?? '';
    final displayName = site['display_name'] ?? (customerName.isNotEmpty ? '$customerName $siteName' : siteName);
    
    // Get update counts
    final labourCount = site['labour_count'] ?? 0;
    final materialCount = site['material_count'] ?? 0;
    final photoCount = site['photo_count'] ?? 0;
    final lastUpdate = site['last_update'] ?? '';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.construction, color: Color(0xFF1A1A2E), size: 24),
        ),
        title: Text(
          displayName,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // Area Badge
            if (area.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: const Color(0xFF1A1A2E).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_city, size: 12, color: Color(0xFF1A1A2E)),
                    const SizedBox(width: 4),
                    Text(
                      area,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 6),
            // Street
            Row(
              children: [
                const Icon(Icons.route, size: 14, color: Color(0xFF6B7280)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    street.isNotEmpty ? street : 'No street',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                ),
              ],
            ),
            
            // Update counts and last update
            if (labourCount > 0 || materialCount > 0 || photoCount > 0) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (labourCount > 0) ...[
                    _buildCountBadge(
                      icon: Icons.people,
                      count: labourCount,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (materialCount > 0) ...[
                    _buildCountBadge(
                      icon: Icons.inventory_2,
                      count: materialCount,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (photoCount > 0) ...[
                    _buildCountBadge(
                      icon: Icons.photo_camera,
                      count: photoCount,
                      color: Colors.orange,
                    ),
                  ],
                ],
              ),
            ],
            
            if (lastUpdate.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 12, color: Color(0xFF6B7280)),
                  const SizedBox(width: 4),
                  Text(
                    lastUpdate,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF6B7280)),
        onTap: () {
          // TODO: Navigate to site detail screen if needed
        },
      ),
    );
  }

  Widget _buildCountBadge({
    required IconData icon,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
