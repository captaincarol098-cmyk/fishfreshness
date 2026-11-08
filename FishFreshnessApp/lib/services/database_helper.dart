import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/scan_result.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'fish_freshness.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE scan_results(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        classification TEXT NOT NULL,
        fresh_confidence REAL NOT NULL,
        not_fresh_confidence REAL NOT NULL,
        timestamp INTEGER NOT NULL,
        image_path TEXT
      )
    ''');

    // Create index for faster queries
    await db.execute('''
      CREATE INDEX idx_timestamp ON scan_results(timestamp DESC)
    ''');

    await db.execute('''
      CREATE INDEX idx_classification ON scan_results(classification)
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here when needed
    if (oldVersion < newVersion) {
      // Add migration logic here for future versions
    }
  }

  // Insert a new scan result
  Future<int> insertScanResult(ScanResult scanResult) async {
    final db = await database;
    return await db.insert('scan_results', scanResult.toMap());
  }

  // Get all scan results ordered by timestamp (newest first)
  Future<List<ScanResult>> getAllScanResults() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'scan_results',
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return ScanResult.fromMap(maps[i]);
    });
  }

  // Get scan results with pagination
  Future<List<ScanResult>> getScanResults({int? limit, int? offset}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'scan_results',
      orderBy: 'timestamp DESC',
      limit: limit,
      offset: offset,
    );

    return List.generate(maps.length, (i) {
      return ScanResult.fromMap(maps[i]);
    });
  }

  // Get scan results by classification
  Future<List<ScanResult>> getScanResultsByClassification(String classification) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'scan_results',
      where: 'classification = ?',
      whereArgs: [classification],
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return ScanResult.fromMap(maps[i]);
    });
  }

  // Get scan results within date range
  Future<List<ScanResult>> getScanResultsByDateRange(DateTime startDate, DateTime endDate) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'scan_results',
      where: 'timestamp BETWEEN ? AND ?',
      whereArgs: [startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch],
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return ScanResult.fromMap(maps[i]);
    });
  }

  // Get statistics
  Future<Map<String, dynamic>> getStatistics() async {
    final db = await database;
    
    // Total scans
    final totalResult = await db.rawQuery('SELECT COUNT(*) as count FROM scan_results');
    final totalScans = totalResult.first['count'] as int;

    // Fresh scans
    final freshResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM scan_results WHERE classification = ?',
      ['fresh']
    );
    final freshScans = freshResult.first['count'] as int;

    // Not fresh scans
    final notFreshResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM scan_results WHERE classification = ?',
      ['not_fresh']
    );
    final notFreshScans = notFreshResult.first['count'] as int;

    // Average confidence for fresh fish
    final avgFreshConfidence = await db.rawQuery(
      'SELECT AVG(fresh_confidence) as avg FROM scan_results WHERE classification = ?',
      ['fresh']
    );
    final avgFresh = (avgFreshConfidence.first['avg'] as double?) ?? 0.0;

    // Average confidence for not fresh fish
    final avgNotFreshConfidence = await db.rawQuery(
      'SELECT AVG(not_fresh_confidence) as avg FROM scan_results WHERE classification = ?',
      ['not_fresh']
    );
    final avgNotFresh = (avgNotFreshConfidence.first['avg'] as double?) ?? 0.0;

    // Recent scans (last 7 days)
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final recentResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM scan_results WHERE timestamp >= ?',
      [sevenDaysAgo.millisecondsSinceEpoch]
    );
    final recentScans = recentResult.first['count'] as int;

    return {
      'totalScans': totalScans,
      'freshScans': freshScans,
      'notFreshScans': notFreshScans,
      'freshPercentage': totalScans > 0 ? (freshScans / totalScans * 100) : 0.0,
      'notFreshPercentage': totalScans > 0 ? (notFreshScans / totalScans * 100) : 0.0,
      'averageFreshConfidence': avgFresh * 100,
      'averageNotFreshConfidence': avgNotFresh * 100,
      'recentScans': recentScans,
    };
  }

  // Delete a scan result
  Future<void> deleteScanResult(int id) async {
    final db = await database;
    await db.delete(
      'scan_results',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete all scan results
  Future<void> deleteAllScanResults() async {
    final db = await database;
    await db.delete('scan_results');
  }

  // Update a scan result
  Future<void> updateScanResult(ScanResult scanResult) async {
    final db = await database;
    await db.update(
      'scan_results',
      scanResult.toMap(),
      where: 'id = ?',
      whereArgs: [scanResult.id],
    );
  }

  // Get scan result by ID
  Future<ScanResult?> getScanResultById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'scan_results',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return ScanResult.fromMap(maps.first);
    }
    return null;
  }

  // Close database connection
  Future<void> close() async {
    final db = await database;
    db.close();
  }

  // Export data for backup
  Future<List<Map<String, dynamic>>> exportData() async {
    final db = await database;
    return await db.query('scan_results', orderBy: 'timestamp DESC');
  }

  // Import data from backup
  Future<void> importData(List<Map<String, dynamic>> data) async {
    final db = await database;
    final batch = db.batch();
    
    for (final item in data) {
      // Remove id to let SQLite auto-assign new IDs
      final itemCopy = Map<String, dynamic>.from(item);
      itemCopy.remove('id');
      batch.insert('scan_results', itemCopy);
    }
    
    await batch.commit();
  }
}