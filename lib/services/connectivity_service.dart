import 'package:connectivity_plus/connectivity_plus.dart';

/// Wraps connectivity checks for offline-aware repositories.
class ConnectivityService {
  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  /// Returns true when device has Wi‑Fi or mobile data.
  Future<bool> hasConnection() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }
}
