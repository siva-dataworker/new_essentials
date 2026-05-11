import 'package:flutter/material.dart';
import '../services/construction_service.dart';
import '../services/cache_service.dart';

class AdminManageMaterialsScreen extends StatefulWidget {
  const AdminManageMaterialsScreen({super.key});

  @override
  State<AdminManageMaterialsScreen> createState() => _AdminManageMaterialsScreenState();
}

class _AdminManageMaterialsScreenState extends State<AdminManageMaterialsScreen> {
  final _constructionService = ConstructionService();
  final _searchController = TextEditingController();
  final _addMaterialController = TextEditingController();
  
  List<Map<String, dynamic>> _allMaterials = [];
  List<Map<String, dynamic>> _filteredMaterials = [];
  bool _isLoading = false;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _loadMaterials();
    _searchController.addListener(_filterMaterials);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _addMaterialController.dispose();
    super.dispose();
  }

  Future<void> _loadMaterials() async {
    // Try cache first
    final cached = await CacheService.loadMaterialsList();
    if (cached != null) {
      if (mounted) {
        setState(() {
          _allMaterials = cached;
          _filteredMaterials = cached;
          _isLoading = false;
        });
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final materials = await _constructionService.getMaterials();

      await CacheService.saveMaterialsList(materials);

      if (mounted) {
        setState(() {
          _allMaterials = materials;
          _filteredMaterials = materials;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading materials: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterMaterials() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMaterials = _allMaterials.where((material) {
        final name = (material['name'] ?? '').toString().toLowerCase();
        return name.contains(query);
      }).toList();
    });
  }

  Future<void> _showAddMaterialDialog() async {
    _addMaterialController.clear();
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Material'),
        content: TextField(
          controller: _addMaterialController,
          decoration: const InputDecoration(
            labelText: 'Material Name',
            hintText: 'e.g., Cement, Bricks, Steel',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _addMaterial,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A2E),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _addMaterial() async {
    final materialName = _addMaterialController.text.trim();
    
    if (materialName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a material name'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.pop(context); // Close dialog
    
    setState(() => _isAdding = true);
    
    try {
      final result = await _constructionService.addMaterial(materialName);
      
      if (mounted) {
        setState(() => _isAdding = false);
        
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Material "$materialName" added successfully'),
              backgroundColor: Colors.green,
            ),
          );
          await CacheService.clearMaterialsList();
          _loadMaterials(); // Reload list
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'Failed to add material'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAdding = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Manage Materials',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMaterials,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search materials...',
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
          
          // Material Count
          if (!_isLoading && !_isAdding)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFFF8F9FA),
              child: Row(
                children: [
                  Text(
                    '${_filteredMaterials.length} material${_filteredMaterials.length != 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          
          const Divider(height: 1),
          
          // Materials List
          Expanded(
            child: _isLoading || _isAdding
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: Color(0xFF1A1A2E)),
                        const SizedBox(height: 16),
                        Text(
                          _isAdding ? 'Adding material...' : 'Loading materials...',
                          style: const TextStyle(color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  )
                : _filteredMaterials.isEmpty
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
                              child: const Icon(
                                Icons.inventory_2_outlined,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'No Materials Found',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchController.text.isNotEmpty
                                  ? 'Try a different search term'
                                  : 'Add materials to get started',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _showAddMaterialDialog,
                              icon: const Icon(Icons.add, size: 20),
                              label: const Text('Add First Material'),
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
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadMaterials,
                        color: const Color(0xFF1A1A2E),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredMaterials.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final material = _filteredMaterials[index];
                            return _buildMaterialCard(material);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: _filteredMaterials.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _showAddMaterialDialog,
              backgroundColor: const Color(0xFF1A1A2E),
              icon: const Icon(Icons.add),
              label: const Text('Add Material'),
            )
          : null,
    );
  }

  Widget _buildMaterialCard(Map<String, dynamic> material) {
    final name = material['name'] ?? 'Unknown';
    final createdAt = material['created_at'];
    
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
          child: const Icon(Icons.inventory_2, color: Color(0xFF1A1A2E), size: 24),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
          ),
        ),
        subtitle: createdAt != null
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Added: ${_formatDate(createdAt)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              )
            : null,
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      
      if (diff.inDays == 0) {
        return 'Today';
      } else if (diff.inDays == 1) {
        return 'Yesterday';
      } else if (diff.inDays < 7) {
        return '${diff.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return '';
    }
  }
}
