import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/fitness_model.dart';

/// Reads nutrition catalog from Cloud Firestore.
class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// Fetches all documents from the `foods` collection.
  Future<List<Food>> fetchFoods() async {
    final snapshot = await _db.collection('foods').get();
    if (snapshot.docs.isEmpty) return [];
    return snapshot.docs
        .map((doc) => Food.fromFirestore(doc.id, doc.data()))
        .toList();
  }
}
