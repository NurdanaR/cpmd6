/// Base class for domain-level failures.
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Thrown when remote data cannot be loaded and cache is empty.
class DataLoadException extends AppException {
  const DataLoadException(super.message);
}

/// Thrown when local database operations fail.
class LocalStorageException extends AppException {
  const LocalStorageException(super.message);
}

/// Thrown when an action requires a signed-in user.
class NotAuthenticatedException extends AppException {
  const NotAuthenticatedException()
      : super('Sign in to access your favorites.');
}
