import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/favorite_exercise.dart';

/// Cloud storage for favorites under `users/{uid}/favorites`.
class FirestoreFavoritesService {
  FirestoreFavoritesService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// Reference to a user's favorites subcollection.
  CollectionReference<Map<String, dynamic>> _favorites(String userId) {
    return _db.collection('users').doc(userId).collection('favorites');
  }

  /// Loads all favorites for the given user, newest first.
  Future<List<FavoriteExercise>> getAll(String userId) async {
    final snapshot = await _favorites(userId).orderBy('createdAt', descending: true).get();
    return snapshot.docs
        .map((doc) => FavoriteExercise.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  /// Adds a favorite exercise for the user.
  Future<void> add(String userId, String title, String imageUrl) async {
    await _favorites(userId).add({
      'title': title,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Removes a favorite by document id.
  Future<void> remove(String userId, String favoriteId) async {
    await _favorites(userId).doc(favoriteId).delete();
  }
}
