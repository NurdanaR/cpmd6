import '../core/errors.dart';
import '../models/fitness_model.dart';
import '../services/api_service.dart';
import '../services/connectivity_service.dart';
import '../services/firestore_service.dart';
import '../services/food_cache_service.dart';
import '../services/food_remote_source.dart';

/// Coordinates Firestore, REST API, and offline cache for nutrition data.
class FoodRepository {
  FoodRepository({
    FoodRemoteSource? firestore,
    FoodRemoteSource? api,
    FoodCacheService? cache,
    ConnectivityService? connectivity,
  })  : _firestore = firestore ?? FirestoreService(),
        _api = api ?? ApiService(),
        _cache = cache ?? FoodCacheService(),
        _connectivity = connectivity ?? ConnectivityService();

  final FoodRemoteSource _firestore;
  final FoodRemoteSource _api;
  final FoodCacheService _cache;
  final ConnectivityService _connectivity;

  /// Loads foods: online Firestore → REST → cache; offline uses cache only.
  Future<List<Food>> fetchFoods() async {
    final online = await _connectivity.hasConnection();

    if (online) {
      try {
        final fromFirestore = await _firestore.fetchFoods();
        if (fromFirestore.isNotEmpty) {
          await _cache.saveFoods(fromFirestore);
          return fromFirestore;
        }
      } catch (_) {}

      try {
        final fromApi = await _api.fetchFoods();
        await _cache.saveFoods(fromApi);
        return fromApi;
      } catch (_) {}
    }

    final cached = await _cache.loadFoods();
    if (cached.isNotEmpty) return cached;

    if (!online) {
      throw const DataLoadException(
        'No internet connection and no cached foods. Connect once to sync.',
      );
    }

    throw const DataLoadException('Unable to load foods from Firestore or API.');
  }

  /// Forces refresh from remote sources when online.
  Future<List<Food>> refresh() async {
    if (!await _connectivity.hasConnection()) {
      final cached = await _cache.loadFoods();
      if (cached.isEmpty) {
        throw const DataLoadException('Offline — cannot refresh without cache.');
      }
      return cached;
    }
    return fetchFoods();
  }
}
