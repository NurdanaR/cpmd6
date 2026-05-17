/// Favorite workout stored per user in Firestore.
class FavoriteExercise {
  const FavoriteExercise({
    required this.id,
    required this.title,
    required this.imageUrl,
  });

  final String id;
  final String title;
  final String imageUrl;

  /// Builds model from Firestore document fields.
  factory FavoriteExercise.fromFirestore(String docId, Map<String, dynamic> data) {
    return FavoriteExercise(
      id: docId,
      title: data['title'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
    );
  }
}
