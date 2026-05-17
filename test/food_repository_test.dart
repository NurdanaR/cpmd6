import 'package:flutter_test/flutter_test.dart';
import 'package:data_persistence_networking_app/models/fitness_model.dart';
import 'package:data_persistence_networking_app/repositories/food_repository.dart';
import 'package:data_persistence_networking_app/services/api_service.dart';
import 'package:data_persistence_networking_app/services/connectivity_service.dart';
import 'package:data_persistence_networking_app/services/firestore_service.dart';
import 'package:data_persistence_networking_app/services/food_cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeFirestore extends FirestoreService {
  _FakeFirestore(this._foods);
  final List<Food> _foods;

  @override
  Future<List<Food>> fetchFoods() async => _foods;
}

class _FakeApi extends ApiService {
  _FakeApi(this._foods);

  final List<Food> _foods;

  @override
  Future<List<Food>> fetchFoods() async => _foods;
}

class _OfflineConnectivity extends ConnectivityService {
  @override
  Future<bool> hasConnection() async => false;
}

class _OnlineConnectivity extends ConnectivityService {
  @override
  Future<bool> hasConnection() async => true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('FoodRepository returns Firestore data when online', () async {
    final foods = [
      Food(id: '1', name: 'Egg', calories: 70, protein: 6, fat: 5, carbs: 0.5),
    ];
    final repo = FoodRepository(
      firestore: _FakeFirestore(foods),
      api: _FakeApi([]),
      connectivity: _OnlineConnectivity(),
    );
    final result = await repo.fetchFoods();
    expect(result, hasLength(1));
    expect(result.first.name, 'Egg');
  });

  test('FoodRepository uses cache when offline', () async {
    final cache = FoodCacheService();
    await cache.saveFoods([
      Food(id: 'c1', name: 'Cached', calories: 100, protein: 1, fat: 1, carbs: 1),
    ]);
    final repo = FoodRepository(
      firestore: _FakeFirestore([]),
      api: _FakeApi([]),
      cache: cache,
      connectivity: _OfflineConnectivity(),
    );
    final result = await repo.fetchFoods();
    expect(result.first.name, 'Cached');
  });
}
