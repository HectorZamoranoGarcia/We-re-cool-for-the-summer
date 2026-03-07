import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/supabase_auth_repository.dart';
import '../../domain/repositories/i_auth_repository.dart';

part 'auth_providers.g.dart';

// ---------------------------------------------------------------------------
// 1. Raw Supabase client provider
// ---------------------------------------------------------------------------

/// Exposes the global [SupabaseClient] singleton as a Riverpod provider.
/// All repository providers that need the client depend on this.
@riverpod
SupabaseClient supabaseClient(SupabaseClientRef ref) {
  return Supabase.instance.client;
}

// ---------------------------------------------------------------------------
// 2. Auth Repository provider
// ---------------------------------------------------------------------------

/// Provides the [IAuthRepository] implementation to the entire app.
/// Swap [SupabaseAuthRepository] for a mock in tests without touching any UI.
@riverpod
IAuthRepository authRepository(AuthRepositoryRef ref) {
  final client = ref.watch(supabaseClientProvider);
  final webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID']!;
  return SupabaseAuthRepository(client, webClientId);
}

// ---------------------------------------------------------------------------
// 3. Reactive session stream — the source of truth for auth state
// ---------------------------------------------------------------------------

/// Watches the Supabase auth state stream and emits the latest [AuthState].
/// Any widget or provider that needs to know if the user is logged in
/// subscribes here with `ref.watch(authStateProvider)`.
///
/// This is the ONLY place in the app that listens to the raw auth stream;
/// everything else reacts to this provider.
@riverpod
Stream<AuthState> authState(AuthStateRef ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges;
}

// ---------------------------------------------------------------------------
// 4. Convenience getter — current user (nullable)
// ---------------------------------------------------------------------------

/// Returns the current [User], or null if not authenticated.
/// Derived synchronously from the global Supabase singleton so it is
/// available even before the stream emits its first event.
@riverpod
User? currentUser(CurrentUserRef ref) {
  // Re-derive whenever the auth stream changes.
  ref.watch(authStateProvider);
  final repo = ref.read(authRepositoryProvider);
  return repo.currentUser;
}
