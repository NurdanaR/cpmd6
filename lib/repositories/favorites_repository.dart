import '../services/local_db_service.dart';

/// Repository for favorite exercises stored locally.
class FavoritesRepository {
  FavoritesRepository({LocalDbService? localDb})
      : _localDb = localDb ?? LocalDbService();

  final LocalDbService _localDb;

  /// Returns all saved favorites.
  Future<List<Map<String, dynamic>>> getAll() => _localDb.getFavorites();

  /// Saves exercise to favorites.
  Future<void> add(String title, String imageUrl) =>
      _localDb.addFavorite(title, imageUrl);

  /// Deletes favorite by database id.
  Future<void> remove(int id) => _localDb.removeFavorite(id);
}
