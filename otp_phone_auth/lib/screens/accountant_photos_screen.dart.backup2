import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/construction_provider.dart';
import '../services/construction_service.dart';
import '../utils/app_colors.dart';

class AccountantPhotosScreen extends StatefulWidget {
  const AccountantPhotosScreen({super.key});

  @override
  State<AccountantPhotosScreen> createState() => _AccountantPhotosScreenState();
}

class _AccountantPhotosScreenState extends State<AccountantPhotosScreen> {
  String _selectedFilter = 'All';
  String _selectedSite = 'All Sites';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPhotos();
    });
  }

  Future<void> _loadPhotos() async {
    final provider = context.read<ConstructionProvider>();
    await provider.loadAccountantPhotos(forceRefresh: true);
  }

  List<Map<String, dynamic>> _getFilteredPhotos(List<Map<String, dynamic>> photos) {
    List<Map<String, dynamic>> filtered = photos;

    // Filter by photo type
    if (_selectedFilter != 'All') {
      String filterType = _selectedFilter == 'Morning' ? 'STARTED' : 'FINISHED';
      filtered = filtered.where((photo) => photo['update_type'] == filterType).toList();
    }

    // Filter by site
    if (_selectedSite != 'All Sites') {
      filtered = filtered.where((photo) => photo['full_site_name'] == _selectedSite).toList();
    }

    return filtered;
  }

  List<String> _getUniqueSites(List<Map<String, dynamic>> photos) {
    final sites = photos.map((photo) => photo['full_site_name'] as String).toSet().toList();
    sites.sort();
    return ['All Sites', ...sites];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConstructionProvider>(
      builder: (context, provider, child) {
        final allPhotos = provider.accountantPhotos;
        final filteredPhotos = _getFilteredPhotos(allPhotos);
        final uniqueSites = _getUniqueSites(allPhotos);
        final isLoading = provider.isLoadingAccountantPhotos;

        return Scaffold(
          backgroundColor: AppColors.lightSlate,
          appBar: AppBar(
            title: const Text(
              'Site Photos',
              style: TextStyle(
                color: AppColors.deepNavy,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppColors.cleanWhite,
            elevation: 0,
            iconTheme: const IconThemeData(color: AppColors.deepNavy),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadPhotos,
                tooltip: 'Refresh Photos',
              ),
            ],
          ),
          body: Column(
            children: [
              // Filter Section
              Container(
                color: AppColors.cleanWhite,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepNavy,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Photo Type Filter
                    Row(
                      children: [
                        const Text('Type: ', style: TextStyle(fontWeight: FontWeight.w600)),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: ['All', 'Morning', 'Evening']
                                  .map((filter) => _buildFilterChip(filter, _selectedFilter == filter, (value) {
                                        setState(() => _selectedFilter = value);
                                      }))
                                  .toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Site Filter
                    Row(
                      children: [
                        const Text('Site: ', style: TextStyle(fontWeight: FontWeight.w600)),
                        Expanded(
                          child: DropdownButton<String>(
                            value: _selectedSite,
                            isExpanded: true,
                            items: uniqueSites.map((site) {
                              return DropdownMenuItem<String>(
                                value: site,
                                child: Text(
                                  site,
                                  style: const TextStyle(fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedSite = value ?? 'All Sites');
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Results Summary
              Container(
                color: AppColors.cleanWhite,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'Found ${filteredPhotos.length} photo(s)',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.deepNavy,
                      ),
                    ),
                    const Spacer(),
                    if (_selectedFilter != 'All' || _selectedSite != 'All Sites')
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedFilter = 'All';
                            _selectedSite = 'All Sites';
                          });
                        },
                        icon: const Icon(Icons.clear, size: 16),
                        label: const Text('Clear Filters'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.deepNavy,
                        ),
                      ),
                  ],
                ),
              ),
              
              // Photos Grid
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.deepNavy),
                      )
                    : filteredPhotos.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: _loadPhotos,
                            color: AppColors.deepNavy,
                            child: GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.8,
                              ),
                              itemCount: filteredPhotos.length,
                              itemBuilder: (context, index) => _buildPhotoCard(filteredPhotos[index]),
                            ),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, Function(String) onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => onTap(label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.deepNavy : AppColors.lightSlate,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.deepNavy : AppColors.textSecondary.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.cleanWhite : AppColors.deepNavy,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoCard(Map<String, dynamic> photo) {
    final updateType = photo['update_type'] as String;
    final isMorning = updateType == 'STARTED';
    final photoTypeLabel = isMorning ? 'Morning' : 'Evening';
    final photoIcon = isMorning ? '🌅' : '🌆';
    final photoColor = isMorning ? Colors.orange : Colors.purple;

    return GestureDetector(
      onTap: () => _showPhotoDetail(photo),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cleanWhite,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.deepNavy.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.lightSlate,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    ConstructionService.getFullImageUrl(photo['image_url']),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.lightSlate,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: AppColors.textSecondary.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Image not available',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: AppColors.lightSlate,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.deepNavy,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            
            // Photo Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photo Type Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: photoColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(photoIcon, style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(
                            photoTypeLabel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: photoColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Site Name
                    Text(
                      photo['full_site_name'] ?? 'Unknown Site',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepNavy,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Upload Info
                    Text(
                      'By ${photo['uploaded_by'] ?? 'Unknown'}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    // Date
                    Text(
                      _formatDate(photo['update_date']),
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 80,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Photos Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.deepNavy,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter != 'All' || _selectedSite != 'All Sites'
                ? 'Try adjusting your filters'
                : 'Photos will appear here when Site Engineers upload them',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showPhotoDetail(Map<String, dynamic> photo) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          decoration: BoxDecoration(
            color: AppColors.cleanWhite,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.deepNavy,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        photo['full_site_name'] ?? 'Unknown Site',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              // Photo
              Flexible(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      ConstructionService.getFullImageUrl(photo['image_url']),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: AppColors.lightSlate,
                          child: const Center(
                            child: Text('Image not available'),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              
              // Details
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Type', photo['update_type'] == 'STARTED' ? 'Morning Photo' : 'Evening Photo'),
                    _buildDetailRow('Uploaded by', photo['uploaded_by'] ?? 'Unknown'),
                    _buildDetailRow('Role', photo['uploaded_by_role'] ?? 'Unknown'),
                    _buildDetailRow('Date', _formatDate(photo['update_date'])),
                    _buildDetailRow('Location', '${photo['area'] ?? ''}, ${photo['street'] ?? ''}'),
                    if (photo['description'] != null && photo['description'].toString().isNotEmpty)
                      _buildDetailRow('Description', photo['description']),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.deepNavy,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
