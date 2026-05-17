import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../core/errors.dart';

/// SQLite-backed favorites on mobile; in-memory list on web.
class LocalDbService {
  static Database? _database;
  static final List<Map<String, dynamic>> _webFavorites = [];

  /// Opens or returns the SQLite database instance.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb('favorites.db');
    return _database!;
  }

  /// Creates favorites table on first launch.
  Future<Database> _initDb(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE favorites (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            imageUrl TEXT NOT NULL
          )
        ''');
      },
    );
  }

  /// Adds exercise to favorites (web uses in-memory store).
  Future<void> addFavorite(String title, String imageUrl) async {
    if (kIsWeb) {
      _webFavorites.add({
        'id': DateTime.now().millisecondsSinceEpoch,
        'title': title,
        'imageUrl': imageUrl,
      });
      return;
    }
    final db = await database;
    await db.insert(
      'favorites',
      {'title': title, 'imageUrl': imageUrl},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Returns all favorite exercises.
  Future<List<Map<String, dynamic>>> getFavorites() async {
    if (kIsWeb) {
      return List<Map<String, dynamic>>.from(_webFavorites);
    }
    try {
      final db = await database;
      return db.query('favorites', orderBy: 'id DESC');
    } catch (e) {
      throw LocalStorageException('Failed to load favorites: $e');
    }
  }

  /// Removes a favorite by id.
  Future<void> removeFavorite(int id) async {
    if (kIsWeb) {
      _webFavorites.removeWhere((item) => item['id'] == id);
      return;
    }
    final db = await database;
    await db.delete('favorites', where: 'id = ?', whereArgs: [id]);
  }
}
