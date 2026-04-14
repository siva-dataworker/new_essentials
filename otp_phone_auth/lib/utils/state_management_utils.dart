import 'dart:async';
import 'package:flutter/foundation.dart';

/// Base class for all providers to ensure consistent state management patterns
abstract class BaseProvider with ChangeNotifier {
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;
  
  // Common getters
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  bool get hasError => _error != null;
  
  // Common state management methods
  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }
  
  void setSubmitting(bool submitting) {
    if (_isSubmitting != submitting) {
      _isSubmitting = submitting;
      notifyListeners();
    }
  }
  
  void setError(String? error) {
    if (_error != error) {
      _error = error;
      notifyListeners();
    }
  }
  
  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }
  
  // Helper method for async operations with loading state
  Future<T> executeWithLoading<T>(Future<T> Function() operation) async {
    setLoading(true);
    clearError();
    
    try {
      final result = await operation();
      return result;
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }
  
  // Helper method for async operations with submitting state
  Future<T> executeWithSubmitting<T>(Future<T> Function() operation) async {
    setSubmitting(true);
    clearError();
    
    try {
      final result = await operation();
      return result;
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setSubmitting(false);
    }
  }
  
  // Abstract method for clearing all data (to be implemented by subclasses)
  void clearData();
}

/// Mixin for providers that handle cached data
mixin CacheManagement<T> on BaseProvider {
  final Map<String, T> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  
  // Cache duration (default: 5 minutes)
  Duration get cacheDuration => const Duration(minutes: 5);
  
  // Check if cache is valid
  bool isCacheValid(String key) {
    if (!_cache.containsKey(key) || !_cacheTimestamps.containsKey(key)) {
      return false;
    }
    
    final timestamp = _cacheTimestamps[key]!;
    return DateTime.now().difference(timestamp) < cacheDuration;
  }
  
  // Get cached data
  T? getCached(String key) {
    if (isCacheValid(key)) {
      return _cache[key];
    }
    return null;
  }
  
  // Set cached data
  void setCache(String key, T data) {
    _cache[key] = data;
    _cacheTimestamps[key] = DateTime.now();
  }
  
  // Clear specific cache entry
  void clearCache(String key) {
    _cache.remove(key);
    _cacheTimestamps.remove(key);
  }
  
  // Clear all cache
  void clearAllCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }
}

/// Mixin for providers that handle paginated data
mixin PaginationManagement<T> on BaseProvider {
  List<T> _items = [];
  bool _hasMore = true;
  int _currentPage = 1;
  int _pageSize = 20;
  
  // Getters
  List<T> get items => _items;
  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.length;
  
  // Load first page
  Future<void> loadFirstPage(Future<List<T>> Function(int page, int pageSize) loader) async {
    _currentPage = 1;
    _items.clear();
    _hasMore = true;
    
    await executeWithLoading(() async {
      final newItems = await loader(_currentPage, _pageSize);
      _items.addAll(newItems);
      _hasMore = newItems.length == _pageSize;
      if (_hasMore) _currentPage++;
    });
  }
  
  // Load next page
  Future<void> loadNextPage(Future<List<T>> Function(int page, int pageSize) loader) async {
    if (!_hasMore || isLoading) return;
    
    await executeWithLoading(() async {
      final newItems = await loader(_currentPage, _pageSize);
      _items.addAll(newItems);
      _hasMore = newItems.length == _pageSize;
      if (_hasMore) _currentPage++;
    });
  }
  
  // Refresh data
  Future<void> refresh(Future<List<T>> Function(int page, int pageSize) loader) async {
    await loadFirstPage(loader);
  }
  
  // Clear pagination data
  void clearPagination() {
    _items.clear();
    _hasMore = true;
    _currentPage = 1;
    notifyListeners();
  }
}

/// Utility class for common state management operations
class StateUtils {
  // Debounce function calls
  static void debounce(
    String key,
    Duration delay,
    VoidCallback callback,
  ) {
    _debounceTimers[key]?.cancel();
    _debounceTimers[key] = Timer(delay, callback);
  }
  
  static final Map<String, Timer> _debounceTimers = {};
  
  // Throttle function calls
  static void throttle(
    String key,
    Duration delay,
    VoidCallback callback,
  ) {
    if (_throttleTimers.containsKey(key)) return;
    
    callback();
    _throttleTimers[key] = Timer(delay, () {
      _throttleTimers.remove(key);
    });
  }
  
  static final Map<String, Timer> _throttleTimers = {};
  
  // Format error messages
  static String formatError(dynamic error) {
    if (error is String) return error;
    if (error is Exception) return error.toString();
    return 'An unexpected error occurred';
  }
  
  // Check if data is fresh (within specified duration)
  static bool isDataFresh(DateTime? lastUpdated, Duration freshDuration) {
    if (lastUpdated == null) return false;
    return DateTime.now().difference(lastUpdated) < freshDuration;
  }
}

