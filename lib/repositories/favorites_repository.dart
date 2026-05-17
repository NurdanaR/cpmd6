import '../core/errors.dart';
import '../models/favorite_exercise.dart';
import '../services/auth_service.dart';
import '../services/firestore_favorites_service.dart';

/// Loads and saves favorites in Firestore for the signed-in user.
class FavoritesRepository {
  FavoritesRepository({
    required AuthService authService,
    FirestoreFavoritesService? firestore,
  })  : _auth = authService,
        _firestore = firestore ?? FirestoreFavoritesService();

  final AuthService _auth;
  final FirestoreFavoritesService _firestore;

  /// Current Firebase user id or null if signed out.
  String? get userId => _auth.currentUser?.uid;

  /// Returns favorites for the logged-in user.
  Future<List<FavoriteExercise>> getAll() async {
    final uid = userId;
    if (uid == null) throw const NotAuthenticatedException();
    return _firestore.getAll(uid);
  }

  /// Adds a favorite for the logged-in user.
  Future<void> add(String title, String imageUrl) async {
    final uid = userId;
    if (uid == null) throw const NotAuthenticatedException();
    await _firestore.add(uid, title, imageUrl);
  }

  /// Removes a favorite by Firestore document id.
  Future<void> remove(String favoriteId) async {
    final uid = userId;
    if (uid == null) throw const NotAuthenticatedException();
    await _firestore.remove(uid, favoriteId);
  }
}
