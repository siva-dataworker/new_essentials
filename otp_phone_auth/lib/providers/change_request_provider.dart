import 'package:flutter/foundation.dart';
import '../services/construction_service.dart';

class ChangeRequestProvider with ChangeNotifier {
  final ConstructionService _constructionService = ConstructionService();

  // Loading states
  bool _isLoadingRequests = false;
  bool _isLoadingModified = false;
  bool _isSubmitting = false;

  // Data loaded flags
  bool _myRequestsLoaded = false;
  bool _pendingRequestsLoaded = false;
  bool _modifiedEntriesLoaded = false;

  // Data
  List<Map<String, dynamic>> _myChangeRequests = [];
  List<Map<String, dynamic>> _pendingChangeRequests = [];
  List<Map<String, dynamic>> _modifiedLabourEntries = [];
  List<Map<String, dynamic>> _modifiedMaterialEntries = [];

  // Error
  String? _error;

  // Getters
  bool get isLoadingRequests => _isLoadingRequests;
  bool get isLoadingModified => _isLoadingModified;
  bool get isSubmitting => _isSubmitting;
  List<Map<String, dynamic>> get myChangeRequests => _myChangeRequests;
  List<Map<String, dynamic>> get pendingChangeRequests => _pendingChangeRequests;
  List<Map<String, dynamic>> get modifiedLabourEntries => _modifiedLabourEntries;
  List<Map<String, dynamic>> get modifiedMaterialEntries => _modifiedMaterialEntries;
  String? get error => _error;

  // Get pending count
  int get pendingCount => _pendingChangeRequests.length;

  // Load my change requests (for supervisor)
  Future<void> loadMyChangeRequests({bool forceRefresh = false}) async {
    // Only load if not already loaded or force refresh
    if (_myRequestsLoaded && !forceRefresh) return;
    
    _isLoadingRequests = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _constructionService.getMyChangeRequests();
      if (result['success'] == true) {
        _myChangeRequests = List<Map<String, dynamic>>.from(result['change_requests'] ?? []);
        _myRequestsLoaded = true;
      } else {
        _error = result['error'];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingRequests = false;
      notifyListeners();
    }
  }

  // Load pending change requests (for accountant)
  Future<void> loadPendingChangeRequests({bool forceRefresh = false}) async {
    // Only load if not already loaded or force refresh
    if (_pendingRequestsLoaded && !forceRefresh) return;
    
    _isLoadingRequests = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _constructionService.getPendingChangeRequests();
      if (result['success'] == true) {
        _pendingChangeRequests = List<Map<String, dynamic>>.from(result['change_requests'] ?? []);
        _pendingRequestsLoaded = true;
      } else {
        _error = result['error'];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingRequests = false;
      notifyListeners();
    }
  }

  // Load modified entries (for supervisor)
  Future<void> loadModifiedEntries({bool forceRefresh = false}) async {
    // Only load if not already loaded or force refresh
    if (_modifiedEntriesLoaded && !forceRefresh) return;
    
    _isLoadingModified = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _constructionService.getModifiedEntries();
      if (result['success'] == true) {
        _modifiedLabourEntries = List<Map<String, dynamic>>.from(result['labour_entries'] ?? []);
        _modifiedMaterialEntries = List<Map<String, dynamic>>.from(result['material_entries'] ?? []);
        _modifiedEntriesLoaded = true;
      } else {
        _error = result['error'];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingModified = false;
      notifyListeners();
    }
  }

  // Request change (supervisor)
  Future<Map<String, dynamic>> requestChange({
    required String entryId,
    required String entryType,
    required String requestMessage,
    Map<String, dynamic>? proposedChanges,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _constructionService.requestChange(
        entryId: entryId,
        entryType: entryType,
        requestMessage: requestMessage,
        proposedChanges: proposedChanges,
      );

      if (result['success'] == true) {
        // Reload requests after successful submission (force refresh)
        await loadMyChangeRequests(forceRefresh: true);
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

  // Handle change request (accountant)
  Future<Map<String, dynamic>> handleChangeRequest({
    required String requestId,
    required dynamic newValue,
    String? responseMessage,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _constructionService.handleChangeRequest(
        requestId: requestId,
        newValue: newValue,
        responseMessage: responseMessage,
      );

      if (result['success'] == true) {
        // Reload pending requests after successful handling (force refresh)
        await loadPendingChangeRequests(forceRefresh: true);
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

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear all data (on logout)
  void clearData() {
    _myChangeRequests = [];
    _pendingChangeRequests = [];
    _modifiedLabourEntries = [];
    _modifiedMaterialEntries = [];
    _error = null;
    _myRequestsLoaded = false;
    _pendingRequestsLoaded = false;
    _modifiedEntriesLoaded = false;
    notifyListeners();
  }
}
