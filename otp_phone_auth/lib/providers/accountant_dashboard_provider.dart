import 'package:flutter/foundation.dart';

class AccountantDashboardProvider extends ChangeNotifier {
  // Dashboard state
  int _labourEntriesCount = 0;
  int _workingSitesCount = 0;
  double _totalConfirmedSalary = 0.0;
  List<Map<String, dynamic>> _cashBySite = [];
  int _approvedEntriesCount = 0;

  // UI state
  bool _isLoading = true;
  String? _error;
  String? _selectedLabourRole; // null = All
  DateTime? _selectedDate; // null = All dates
  String? _selectedSiteId; // null = All sites

  // Getters
  int get labourEntriesCount => _labourEntriesCount;
  int get workingSitesCount => _workingSitesCount;
  double get totalConfirmedSalary => _totalConfirmedSalary;
  List<Map<String, dynamic>> get cashBySite => _cashBySite;
  int get approvedEntriesCount => _approvedEntriesCount;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedLabourRole => _selectedLabourRole;
  DateTime? get selectedDate => _selectedDate;
  String? get selectedSiteId => _selectedSiteId;

  // Setters with notification
  void setLabourEntriesCount(int count) {
    if (_labourEntriesCount != count) {
      _labourEntriesCount = count;
      notifyListeners();
    }
  }

  void setWorkingSitesCount(int count) {
    if (_workingSitesCount != count) {
      _workingSitesCount = count;
      notifyListeners();
    }
  }

  void setTotalConfirmedSalary(double salary) {
    if (_totalConfirmedSalary != salary) {
      _totalConfirmedSalary = salary;
      notifyListeners();
    }
  }

  void setCashBySite(List<Map<String, dynamic>> data) {
    if (_cashBySite != data) {
      _cashBySite = data;
      notifyListeners();
    }
  }

  void setApprovedEntriesCount(int count) {
    if (_approvedEntriesCount != count) {
      _approvedEntriesCount = count;
      notifyListeners();
    }
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

  void setSelectedLabourRole(String? role) {
    if (_selectedLabourRole != role) {
      _selectedLabourRole = role;
      notifyListeners();
    }
  }

  void setSelectedDate(DateTime? date) {
    if (_selectedDate != date) {
      _selectedDate = date;
      notifyListeners();
    }
  }

  void setSelectedSiteId(String? siteId) {
    if (_selectedSiteId != siteId) {
      _selectedSiteId = siteId;
      notifyListeners();
    }
  }

  // Reset filters
  void resetFilters() {
    _selectedLabourRole = null;
    _selectedDate = null;
    _selectedSiteId = null;
    notifyListeners();
  }

  // Clear all data
  void clearData() {
    _labourEntriesCount = 0;
    _workingSitesCount = 0;
    _totalConfirmedSalary = 0.0;
    _cashBySite = [];
    _approvedEntriesCount = 0;
    _error = null;
    notifyListeners();
  }
}
