import 'package:flutter/foundation.dart';
import '../models/scan_result.dart';
import '../services/database_helper.dart';

class HistoryProvider extends ChangeNotifier {
  List<ScanResult> _history = [];
  bool _isLoading = false;
  Map<String, dynamic> _statistics = {};

  List<ScanResult> get history => _history;
  bool get isLoading => _isLoading;
  Map<String, dynamic> get statistics => _statistics;

  final DatabaseHelper _dbHelper = DatabaseHelper();

  HistoryProvider() {
    _loadHistory();
    _loadStatistics();
  }

  Future<void> _loadHistory() async {
    try {
      _isLoading = true;
      notifyListeners();

      _history = await _dbHelper.getAllScanResults();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      print('Error loading history: $e');
      notifyListeners();
    }
  }

  Future<void> _loadStatistics() async {
    try {
      _statistics = await _dbHelper.getStatistics();
      notifyListeners();
    } catch (e) {
      print('Error loading statistics: $e');
    }
  }

  Future<void> addScan(ScanResult scan) async {
    try {
      final id = await _dbHelper.insertScanResult(scan);
      final newScan = scan.copyWith(id: id);
      
      _history.insert(0, newScan);
      await _loadStatistics(); // Refresh statistics
      notifyListeners();
    } catch (e) {
      print('Error adding scan: $e');
    }
  }

  Future<void> deleteScan(int id) async {
    try {
      await _dbHelper.deleteScanResult(id);
      _history.removeWhere((scan) => scan.id == id);
      await _loadStatistics(); // Refresh statistics
      notifyListeners();
    } catch (e) {
      print('Error deleting scan: $e');
    }
  }

  Future<void> clearHistory() async {
    try {
      await _dbHelper.deleteAllScanResults();
      _history.clear();
      await _loadStatistics(); // Refresh statistics
      notifyListeners();
    } catch (e) {
      print('Error clearing history: $e');
    }
  }

  Future<void> refreshHistory() async {
    await _loadHistory();
    await _loadStatistics();
  }

  // Filter methods
  List<ScanResult> getFreshScans() {
    return _history.where((scan) => scan.classification == 'fresh').toList();
  }

  List<ScanResult> getNotFreshScans() {
    return _history.where((scan) => scan.classification == 'not_fresh').toList();
  }

  List<ScanResult> getRecentScans({int days = 7}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _history.where((scan) => scan.timestamp.isAfter(cutoffDate)).toList();
  }

  List<ScanResult> getScansForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return _history.where((scan) => 
      scan.timestamp.isAfter(startOfDay) && scan.timestamp.isBefore(endOfDay)
    ).toList();
  }

  // Search functionality
  List<ScanResult> searchScans(String query) {
    if (query.isEmpty) return _history;
    
    final lowerQuery = query.toLowerCase();
    return _history.where((scan) => 
      scan.classification.toLowerCase().contains(lowerQuery) ||
      scan.getDetailedStatus().toLowerCase().contains(lowerQuery)
    ).toList();
  }

  // Export/Import functionality
  Future<List<Map<String, dynamic>>> exportData() async {
    try {
      return await _dbHelper.exportData();
    } catch (e) {
      print('Error exporting data: $e');
      return [];
    }
  }

  Future<void> importData(List<Map<String, dynamic>> data) async {
    try {
      await _dbHelper.importData(data);
      await refreshHistory();
    } catch (e) {
      print('Error importing data: $e');
    }
  }

  // Get statistics summary text
  String getStatisticsSummary() {
    if (_statistics.isEmpty) return 'No scans yet';
    
    final total = _statistics['totalScans'] as int;
    final fresh = _statistics['freshScans'] as int;
    final notFresh = _statistics['notFreshScans'] as int;
    final freshPercentage = _statistics['freshPercentage'] as double;
    
    return 'Total: $total scans • Fresh: $fresh (${freshPercentage.toStringAsFixed(1)}%) • Not Fresh: $notFresh';
  }
}
