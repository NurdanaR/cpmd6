import '../models/daily_nutrition_plan.dart';
import '../models/food_log_entry.dart';
import '../models/workout_session_log.dart';
import '../services/auth_service.dart';
import '../services/firestore_user_data_service.dart';
import '../services/storage_service.dart';

/// Syncs user data between device (SharedPreferences) and Firestore.
class UserDataRepository {
  UserDataRepository({
    required AuthService authService,
    StorageService? storage,
    FirestoreUserDataService? firestore,
  })  : _auth = authService,
        _storage = storage ?? StorageService(),
        _firestore = firestore ?? FirestoreUserDataService();

  final AuthService _auth;
  final StorageService _storage;
  final FirestoreUserDataService _firestore;

  String? get userId => _auth.currentUser?.uid;

  /// Loads profile: Firestore first, then local cache.
  Future<Map<String, String>> loadProfile() async {
    final uid = userId;
    if (uid != null) {
      try {
        final cloud = await _firestore.loadProfile(uid);
        if (cloud != null && _hasProfileData(cloud)) {
          await _storage.saveName(cloud['name'] ?? '');
          await _storage.saveMetrics(cloud['height'] ?? '', cloud['weight'] ?? '');
          return cloud;
        }
      } catch (_) {}
    }
    return {
      'name': await _storage.getName(),
      ...await _storage.getMetrics(),
    };
  }

  /// Saves profile locally and to Firestore when signed in.
  Future<void> saveProfile({
    required String name,
    required String height,
    required String weight,
  }) async {
    await _storage.saveName(name);
    await _storage.saveMetrics(height, weight);
    final uid = userId;
    if (uid != null) {
      await _firestore.saveProfile(uid, name: name, height: height, weight: weight);
    }
  }

  /// Loads food log from cloud or device.
  Future<List<FoodLogEntry>> loadFoodLog() async {
    final uid = userId;
    if (uid != null) {
      try {
        final cloud = await _firestore.loadFoodLog(uid);
        if (cloud.isNotEmpty) {
          await _storage.saveFoodLog(cloud);
          return cloud;
        }
      } catch (_) {}
    }
    return _storage.loadFoodLog();
  }

  /// Saves food log locally and uploads to Firestore.
  Future<void> saveFoodLog(List<FoodLogEntry> entries) async {
    await _storage.saveFoodLog(entries);
    final uid = userId;
    if (uid != null) {
      await _firestore.saveFoodLog(uid, entries);
    }
  }

  /// Loads daily plan from cloud or device.
  Future<DailyNutritionPlan?> loadDailyPlan() async {
    final uid = userId;
    if (uid != null) {
      try {
        final cloud = await _firestore.loadDailyPlan(uid);
        if (cloud != null) {
          await _storage.saveDailyPlan(cloud);
          return cloud;
        }
      } catch (_) {}
    }
    return _storage.loadDailyPlan();
  }

  /// Saves daily plan locally and to Firestore.
  Future<void> saveDailyPlan(DailyNutritionPlan plan) async {
    await _storage.saveDailyPlan(plan);
    final uid = userId;
    if (uid != null) {
      await _firestore.saveDailyPlan(uid, plan);
    }
  }

  /// Uploads local data only when Firestore has no data yet (first sync).
  Future<void> migrateLocalToCloudIfNeeded() async {
    final uid = userId;
    if (uid == null) return;

    try {
      final cloudProfile = await _firestore.loadProfile(uid);
      if (cloudProfile == null || !_hasProfileData(cloudProfile)) {
        final name = await _storage.getName();
        final metrics = await _storage.getMetrics();
        if (_hasProfileData({'name': name, ...metrics})) {
          await _firestore.saveProfile(
            uid,
            name: name,
            height: metrics['height'] ?? '',
            weight: metrics['weight'] ?? '',
          );
        }
      }

      final cloudLog = await _firestore.loadFoodLog(uid);
      if (cloudLog.isEmpty) {
        final localLog = await _storage.loadFoodLog();
        if (localLog.isNotEmpty) await _firestore.saveFoodLog(uid, localLog);
      }

      final cloudPlan = await _firestore.loadDailyPlan(uid);
      if (cloudPlan == null) {
        final localPlan = await _storage.loadDailyPlan();
        if (localPlan != null) await _firestore.saveDailyPlan(uid, localPlan);
      }
    } catch (_) {}
  }

  /// Loads burned calories from cloud or device.
  Future<int> loadBurnedCalories() async {
    final uid = userId;
    if (uid != null) {
      try {
        return await _firestore.loadBurnedCalories(uid);
      } catch (_) {}
    }
    return _storage.loadBurnedCalories();
  }

  /// Saves burned calories locally and to Firestore.
  Future<void> saveBurnedCalories(int kcal) async {
    await _storage.saveBurnedCalories(kcal);
    final uid = userId;
    if (uid != null) {
      await _firestore.saveBurnedCalories(uid, kcal);
    }
  }

  /// Records a completed workout session.
  Future<void> addWorkoutSession(WorkoutSessionLog session) async {
    await _storage.addWorkoutSession(session);
    final uid = userId;
    if (uid != null) {
      await _firestore.addWorkoutSession(uid, session);
    }
  }

  bool _hasProfileData(Map<String, String> profile) {
    return (profile['height']?.isNotEmpty ?? false) ||
        (profile['weight']?.isNotEmpty ?? false) ||
        (profile['name']?.isNotEmpty ?? false);
  }
}
