import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/repositories/i_auth_repository.dart';

/// Infrastructure implementation of [IAuthRepository] backed by Supabase Auth.
///
/// Uses the NATIVE Google Sign-In flow (google_sign_in package) rather than
/// the web OAuth redirect. This gives users the native Android account picker
/// dialog and avoids opening a Chrome Custom Tab.
///
/// Flow:
///   1. [GoogleSignIn] shows native account picker.
///   2. We retrieve an OpenID Connect [idToken] from the selected account.
///   3. We exchange that token with Supabase via [signInWithIdToken].
///   4. Supabase validates the token against the Web Client ID and issues a JWT.
///   5. [authStateChanges] emits [AuthChangeEvent.signedIn].
///   6. GoRouter's [refreshListenable] fires → redirect to /dashboard.
class SupabaseAuthRepository implements IAuthRepository {
  SupabaseAuthRepository(this._client, this._webClientId);

  final SupabaseClient _client;

  /// The OAuth 2.0 Web Client ID from Google Cloud Console.
  /// Used as [serverClientId] so Google includes an [idToken] in the response.
  final String _webClientId;

  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: _webClientId,
    scopes: ['email', 'profile'],
  );

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  @override
  Future<void> signInWithGoogle() async {
    debugPrint('👉 SupabaseAuthRepository: signInWithGoogle started.');
    debugPrint('👉 SupabaseAuthRepository: internal _webClientId is: [$_webClientId] (Length: ${_webClientId.length})');

    if (_webClientId.isEmpty) {
      // User explicitly requested to print to console instead of throwing/disabling.
      print('GOOGLE SIGN-IN WARNING: GOOGLE_WEB_CLIENT_ID is missing in .env.');
    }

    try {
      debugPrint('👉 SupabaseAuthRepository: Calling _googleSignIn.signIn() [Modal should appear here]');
      // Step 1: Show native account picker and request sign-in.
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      debugPrint('👉 SupabaseAuthRepository: _googleSignIn.signIn() returned: ${googleUser?.email ?? "NULL"}');

      if (googleUser == null) {
        debugPrint('👉 SupabaseAuthRepository: googleUser is null! This usually means the user cancelled, OR the Android Configuration (SHA-1 / Client ID) on Google Cloud is incorrect, causing Google Play Services to silently reject the request.');
        // User cancelled the native picker — treat as a no-op.
        return;
      }

      debugPrint('👉 SupabaseAuthRepository: Proceeding to request tokens for ${googleUser.email}');
      // Step 2: Obtain the auth tokens from the selected Google account.
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      debugPrint('👉 SupabaseAuthRepository: Tokens received. idToken is ${idToken != null ? "PRESENT" : "NULL"}');

      if (idToken == null) {
        throw Exception(
          'Google Sign-In succeeded but returned no idToken. '
          'Verify that the Web Client ID is correct in .env.',
        );
      }

      debugPrint('👉 SupabaseAuthRepository: Calling _client.auth.signInWithIdToken()');
      // Step 3: Exchange the Google ID token for a Supabase JWT.
      // Supabase validates the token signature against the Web Client ID.
      await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      debugPrint('👉 SupabaseAuthRepository: Supabase signInWithIdToken SUCCESS');
    } catch (e, stacktrace) {
      debugPrint('🔴 SupabaseAuthRepository EXCEPTION caught: $e');
      debugPrint('🔴 SupabaseAuthRepository STACKTRACE:\n$stacktrace');
      rethrow; // Let LoginScreen handle the UI error
    }
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _client.auth.signOut();
  }
}
