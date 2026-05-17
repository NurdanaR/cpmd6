import 'package:flutter_test/flutter_test.dart';
import 'package:data_persistence_networking_app/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('StorageService tracks onboarding completion', () async {
    final storage = StorageService();
    expect(await storage.isOnboardingComplete(), false);
    await storage.setOnboardingComplete();
    expect(await storage.isOnboardingComplete(), true);
  });

  test('StorageService saves and loads profile', () async {
    final storage = StorageService();
    await storage.saveName('Alex');
    await storage.saveMetrics('180', '75');
    expect(await storage.getName(), 'Alex');
    final metrics = await storage.getMetrics();
    expect(metrics['height'], '180');
    expect(metrics['weight'], '75');
  });
}
