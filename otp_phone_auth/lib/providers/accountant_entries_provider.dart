import 'package:flutter/foundation.dart';

class AccountantEntriesProvider extends ChangeNotifier {
  // Compare screen state
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _supervisorEntries = [];
  List<Map<String, dynamic>> _engineerEntries = [];
  List<Map<String, dynamic>> _accountantEntries = [];

  // Selection state
  String? _selectedEntryId;
  String? _selectedEntryType; // 'supervisor', 'site_engineer', 'accountant'
  bool _isLockedForSite = false;
  Map<String, dynamic>? _lockInfo;

  // UI state
  bool _isLoading = false;
  String? _error;
  bool _isConfirming = false;

  // Approved entries state
  List<Map<String, dynamic>> _approvedEntries = [];
  String? _selectedArea;
  String? _selectedStreet;
  List<String> _areas = [];
  List<String> _streets = [];

  // Getters
  DateTime get selectedDate => _selectedDate;
  List<Map<String, dynamic>> get supervisorEntries => _supervisorEntries;
  List<Map<String, dynamic>> get engineerEntries => _engineerEntries;
  List<Map<String, dynamic>> get accountantEntries => _accountantEntries;
  String? get selectedEntryId => _selectedEntryId;
  String? get selectedEntryType => _selectedEntryType;
  bool get isLockedForSite => _isLockedForSite;
  Map<String, dynamic>? get lockInfo => _lockInfo;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isConfirming => _isConfirming;
  List<Map<String, dynamic>> get approvedEntries => _approvedEntries;
  String? get selectedArea => _selectedArea;
  String? get selectedStreet => _selectedStreet;
  List<String> get areas => _areas;
  List<String> get streets => _streets;

  // Compare Screen Setters
  void setSelectedDate(DateTime date) {
    if (_selectedDate != date) {
      _selectedDate = date;
      clearSelection();
      notifyListeners();
    }
  }

  void setSupervisorEntries(List<Map<String, dynamic>> entries) {
    if (_supervisorEntries != entries) {
      _supervisorEntries = entries;
      notifyListeners();
    }
  }

  void setEngineerEntries(List<Map<String, dynamic>> entries) {
    if (_engineerEntries != entries) {
      _engineerEntries = entries;
      notifyListeners();
    }
  }

  void setAccountantEntries(List<Map<String, dynamic>> entries) {
    if (_accountantEntries != entries) {
      _accountantEntries = entries;
      notifyListeners();
    }
  }

  void selectEntry(String entryId, String entryType) {
    _selectedEntryId = entryId;
    _selectedEntryType = entryType;
    notifyListeners();
  }

  void clearSelection() {
    _selectedEntryId = null;
    _selectedEntryType = null;
    notifyListeners();
  }

  void setLockStatus(bool locked, Map<String, dynamic>? info) {
    _isLockedForSite = locked;
    _lockInfo = info;
    notifyListeners();
  }

  void setIsLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void setError(String? error) {
    if (_error != error) {
      _error = error;
      notifyListeners();
    }
  }

  void setIsConfirming(bool confirming) {
    if (_isConfirming != confirming) {
      _isConfirming = confirming;
      notifyListeners();
    }
  }

  // Approved Entries Setters
  void setApprovedEntries(List<Map<String, dynamic>> entries) {
    if (_approvedEntries != entries) {
      _approvedEntries = entries;
      notifyListeners();
    }
  }

  void setSelectedArea(String? area) {
    if (_selectedArea != area) {
      _selectedArea = area;
      _selectedStreet = null; // Reset street when area changes
      notifyListeners();
    }
  }

  void setSelectedStreet(String? street) {
    if (_selectedStreet != street) {
      _selectedStreet = street;
      notifyListeners();
    }
  }

  void setAreas(List<String> areas) {
    if (_areas != areas) {
      _areas = areas;
      notifyListeners();
    }
  }

  void setStreets(List<String> streets) {
    if (_streets != streets) {
      _streets = streets;
      notifyListeners();
    }
  }

  // Clear all data
  void clearAllData() {
    _supervisorEntries = [];
    _engineerEntries = [];
    _accountantEntries = [];
    _approvedEntries = [];
    _selectedEntryId = null;
    _selectedEntryType = null;
    _isLockedForSite = false;
    _lockInfo = null;
    _error = null;
    notifyListeners();
  }
}
