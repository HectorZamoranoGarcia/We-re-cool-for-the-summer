import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'presentation/core/app.dart';
import 'core/di/infrastructure_providers.dart';

/// Logs every Riverpod provider error to the console so nothing is
/// swallowed silently during startup.
class _DebugProviderObserver extends ProviderObserver {
  const _DebugProviderObserver();

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    debugPrint('🔴 PROVIDER FAILED: ${provider.name ?? provider.runtimeType}');
    debugPrint('   error  : $error');
    debugPrint('   stack  : $stackTrace');
  }

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    if (newValue is AsyncError) {
      debugPrint('🔴 ASYNC ERROR in ${provider.name ?? provider.runtimeType}');
      debugPrint('   error  : ${newValue.error}');
      debugPrint('   stack  : ${newValue.stackTrace}');
    }
  }
}

void main() async {
  // Catch Flutter framework errors (layout, widget-build exceptions, etc.)
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('🔴 FLUTTER ERROR: ${details.exception}');
    debugPrint('   stack: ${details.stack}');
    // Still propagate to the default handler in debug mode.
    FlutterError.presentError(details);
  };

  // Catch async errors that escape the Flutter zone (e.g., isolate throw).
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('🔴 PLATFORM ERROR: $error');
    debugPrint('   stack: $stack');
    return true; // Prevents crash; let the app continue if possible.
  };

  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from the .env bundled asset.
  await dotenv.load(fileName: '.env');

  try {
    // Initialize the Supabase client once globally.
    // All subsequent accesses use Supabase.instance.client.
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );
  } catch (e) {
    debugPrint('🔴 SUPABASE INIT ERROR: $e');
    debugPrint('   Ensure SUPABASE_URL and SUPABASE_ANON_KEY are set in .env.');
  }

  debugPrint('✅ main() — initializing core dependencies');
  final sharedPrefs = await SharedPreferences.getInstance();

  debugPrint('✅ main() — bindings ready, calling runApp()');

  runApp(
    ProviderScope(
      observers: const [_DebugProviderObserver()],
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
      ],
      child: const PantryProApp(),
    ),
  );

  debugPrint('✅ main() — runApp() returned');
}
