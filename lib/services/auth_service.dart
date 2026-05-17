import 'package:firebase_auth/firebase_auth.dart';

/// Email/password authentication via Firebase Auth.
class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  /// Currently signed-in user, if any.
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state for session persistence.
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// Signs in with email and password.
  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
  }

  /// Creates a new account with email and password.
  Future<UserCredential> signUp(String email, String password) {
    return _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
  }

  /// Signs out the current user.
  Future<void> signOut() => _auth.signOut();
}
