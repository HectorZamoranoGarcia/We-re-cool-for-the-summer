import 'package:supabase_flutter/supabase_flutter.dart';

/// Domain contract for authentication operations.
/// The implementation lives in the infrastructure layer (Supabase).
/// The UI and use-cases only interact with this interface.
abstract interface class IAuthRepository {
  /// Returns the currently signed-in user, or null if not authenticated.
  User? get currentUser;

  /// Triggers the native Google OAuth flow.
  /// On Android this opens a Chrome Custom Tab via Supabase GoTrue.
  Future<void> signInWithGoogle();

  /// Signs-out the current session both locally and on the Supabase server.
  Future<void> signOut();

  /// A stream of [AuthState] changes emitted whenever the session changes
  /// (sign-in, sign-out, token refresh, etc.).
  Stream<AuthState> get authStateChanges;
}
