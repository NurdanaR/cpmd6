import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

/// ViewModel for login state and Firebase Auth actions.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService);

  final AuthService _authService;
  StreamSubscription<User?>? _subscription;

  User? _user;
  bool _initializing = true;
  String? _errorMessage;
  bool _busy = false;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isInitializing => _initializing;
  String? get errorMessage => _errorMessage;
  bool get isBusy => _busy;

  /// Listens to Firebase session changes (auto-login on restart).
  void init() {
    _subscription = _authService.authStateChanges().listen((user) {
      _user = user;
      _initializing = false;
      notifyListeners();
    });
  }

  /// Signs in with email/password; sets [errorMessage] on failure.
  Future<bool> signIn(String email, String password) async {
    return _runAuth(() => _authService.signIn(email, password));
  }

  /// Registers a new account; sets [errorMessage] on failure.
  Future<bool> signUp(String email, String password) async {
    return _runAuth(() => _authService.signUp(email, password));
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    _errorMessage = null;
    await _authService.signOut();
  }

  /// Clears displayed auth error.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Runs an auth action with loading state and error handling.
  Future<bool> _runAuth(Future<UserCredential> Function() action) async {
    _busy = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
      _busy = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapAuthError(e);
    } catch (e) {
      _errorMessage = e.toString();
    }
    _busy = false;
    notifyListeners();
    return false;
  }

  /// Maps Firebase error codes to user-readable messages.
  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-not-found':
        return 'No account found for this email. Try Sign in instead.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'This email is already registered. Use Sign in.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'configuration-not-found':
        return 'Firebase Authentication is not set up. In Firebase Console open Authentication → Get started, then enable Email/Password under Sign-in method. Also enable "Identity Toolkit API" in Google Cloud Console for this project.';
      case 'operation-not-allowed':
        return 'Email/Password is disabled in Firebase. Open Console → Authentication → Sign-in method → enable Email/Password.';
      case 'too-many-requests':
        return 'Too many attempts. Wait a few minutes and try again.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      case 'admin-restricted-operation':
        return 'Sign-up is restricted for this project. Check Firebase Authentication settings.';
      default:
        if (e.message?.toUpperCase().contains('CONFIGURATION_NOT_FOUND') == true ||
            e.code.toUpperCase().contains('CONFIGURATION')) {
          return 'Firebase Authentication is not set up. In Firebase Console open Authentication → Get started, then enable Email/Password. In Google Cloud enable Identity Toolkit API.';
        }
        final detail = (e.message != null && e.message != 'Error')
            ? e.message!
            : 'code: ${e.code}';
        return 'Authentication failed ($detail).';
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
