/// Base class for all server-side or network-related failures.
/// Never expose [DioException] or any HTTP-specific type beyond the
/// data layer boundary.
sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when the remote server returns a non-successful response (4xx / 5xx).
final class ServerException extends AppException {
  const ServerException([super.message = 'An unexpected server error occurred.']);
}

/// Thrown when a connect / send / receive timeout is reached.
final class NetworkTimeoutException extends AppException {
  const NetworkTimeoutException([super.message = 'The request timed out. Check your connection.']);
}

/// Thrown when no network connection is available.
final class NoConnectionException extends AppException {
  const NoConnectionException([super.message = 'No internet connection available.']);
}
