import '../models/fitness_model.dart';

/// Contract for remote nutrition data providers (Firestore, REST).
abstract class FoodRemoteSource {
  /// Fetches food list from a remote backend.
  Future<List<Food>> fetchFoods();
}
