import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/local/app_database.dart';

/// Provides the single, canonical [AppDatabase] instance for the whole app.
///
/// Using [Provider] (not a future/async provider) is correct here because
/// [AppDatabase] itself is constructed synchronously – it wraps a
/// [LazyDatabase] that defers all real I/O to a background isolate until
/// the first query is executed.  No blocking work happens at provider
/// creation time.
///
/// [ref.onDispose] guarantees that the SQLite connection is closed cleanly
/// when the [ProviderScope] is disposed (e.g., during hot-restart or
/// widget-test teardown), preventing the "database is already open" error
/// that was causing the double-connection deadlock.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Provides a pre-configured [Dio] HTTP client.
///
/// Base-URL, timeouts and the User-Agent header required by Open Food Facts
/// are baked in here so that every data-source gets an identical client
/// without any boilerplate.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://world.openfoodfacts.org/',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'PantryPro/1.0 (Flutter; contact@pantrypro.app)',
      },
    ),
  );
  ref.onDispose(dio.close);
  return dio;
});

/// Exposes the global [SharedPreferences] instance.
/// Must be overridden in the root [ProviderScope] during app bootstrap.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});
