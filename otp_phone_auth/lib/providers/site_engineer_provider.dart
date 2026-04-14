import 'package:flutter/foundation.dart';
import '../services/site_engineer_service.dart';

class SiteEngineerProvider with ChangeNotifier {
  final SiteEngineerService _service = SiteEngineerService();

  // Loading states
  bool _isLoading = false;
  bool _isSubmitting = false;

  // Data loaded flags
  bool _sitesLoaded = false;
  bool _complaintsLoaded = false;
  bool _projectFilesLoaded = false;

  // Data
  List<Map<String, dynamic>> _sites = [];
  Map<String, dynamic>? _selectedSite;
  List<Map<String, dynamic>> _complaints = [];
  List<Map<String, dynamic>> _projectFiles = [];
  Map<String, dynamic>? _dailyStatus;
  List<Map<String, dynamic>> _workActivities = [];

  // Error
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  List<Map<String, dynamic>> get sites => _sites;
  Map<String, dynamic>? get selectedSite => _selectedSite;
  List<Map<String, dynamic>> get complaints => _complaints;
  List<Map<String, dynamic>> get projectFiles => _projectFiles;
  Map<String, dynamic>? get dailyStatus => _dailyStatus;
  List<Map<String, dynamic>> get workActivities => _workActivities;
  String? get error => _error;

  // Get open complaints count
  int get openComplaintsCount => _complaints.where((c) => c['status'] == 'OPEN').length;

  // Check if morning update done
  bool get isMorningUpdateDone => _dailyStatus?['morning_update_done'] ?? false;

  // Check if evening update done
  bool get isEveningUpdateDone => _dailyStatus?['evening_update_done'] ?? false;

  // Load assigned sites
  Future<void> loadSites({bool forceRefresh = false}) async {
    if (_sitesLoaded && !forceRefresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _sites = await _service.getAssignedSites();
      _sitesLoaded = true;
      
      // Auto-select first site if available
      if (_sites.isNotEmpty && _selectedSite == null) {
        _selectedSite = _sites[0];
        // Load data for selected site
        await loadDailyStatus();
        await loadComplaints();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Select site
  Future<void> selectSite(Map<String, dynamic> site) async {
    _selectedSite = site;
    _complaintsLoaded = false;
    _projectFilesLoaded = false;
    notifyListeners();

    // Load data for selected site
    await loadDailyStatus();
    await loadComplaints();
  }

  // Load daily status
  Future<void> loadDailyStatus({bool forceRefresh = false}) async {
    if (_selectedSite == null) return;

    try {
      _dailyStatus = await _service.getDailyStatus(_selectedSite!['site_id'].toString());
      _workActivities = List<Map<String, dynamic>>.from(_dailyStatus?['work_activities'] ?? []);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Load complaints
  Future<void> loadComplaints({bool forceRefresh = false}) async {
    if (_selectedSite == null) return;
    if (_complaintsLoaded && !forceRefresh) return;

    try {
      _complaints = await _service.getComplaints(_selectedSite!['site_id'].toString());
      _complaintsLoaded = true;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Load project files
  Future<void> loadProjectFiles({bool forceRefresh = false}) async {
    if (_selectedSite == null) return;
    if (_projectFilesLoaded && !forceRefresh) return;

    _isLoading = true;
    notifyListeners();

    try {
      _projectFiles = await _service.getProjectFiles(_selectedSite!['site_id'].toString());
      _projectFilesLoaded = true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Upload work activity
  Future<Map<String, dynamic>> uploadWorkActivity({
    required String activityType,
    required String imagePath,
    String? notes,
  }) async {
    if (_selectedSite == null) {
      return {'success': false, 'error': 'No site selected'};
    }

    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.uploadWorkActivity(
        siteId: _selectedSite!['site_id'].toString(),
        activityType: activityType,
        imagePath: imagePath,
        notes: notes,
      );

      if (result['success'] == true) {
        // Reload daily status
        await loadDailyStatus(forceRefresh: true);
      }

      return result;
    } catch (e) {
      _error = e.toString();
      return {'success': false, 'error': e.toString()};
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // Upload complaint rectification
  Future<Map<String, dynamic>> uploadComplaintRectification({
    required String complaintId,
    required String imagePath,
    String? notes,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.uploadComplaintRectification(
        complaintId: complaintId,
        imagePath: imagePath,
        notes: notes,
      );

      if (result['success'] == true) {
        // Reload complaints
        await loadComplaints(forceRefresh: true);
      }

      return result;
    } catch (e) {
      _error = e.toString();
      return {'success': false, 'error': e.toString()};
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // Submit extra work
  Future<Map<String, dynamic>> submitExtraWork({
    required String description,
    required double amount,
    int? labourCount,
  }) async {
    if (_selectedSite == null) {
      return {'success': false, 'error': 'No site selected'};
    }

    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.submitExtraWork(
        siteId: _selectedSite!['site_id'].toString(),
        description: description,
        amount: amount,
        labourCount: labourCount,
      );

      return result;
    } catch (e) {
      _error = e.toString();
      return {'success': false, 'error': e.toString()};
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear all data (on logout)
  void clearData() {
    _sites = [];
    _selectedSite = null;
    _complaints = [];
    _projectFiles = [];
    _dailyStatus = null;
    _workActivities = [];
    _error = null;
    _sitesLoaded = false;
    _complaintsLoaded = false;
    _projectFilesLoaded = false;
    notifyListeners();
  }
}
