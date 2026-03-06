import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/core/app.dart';

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

void main() {
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

  debugPrint('✅ main() — bindings ready, calling runApp()');

  runApp(
    ProviderScope(
      observers: const [_DebugProviderObserver()],
      child: const PantryProApp(),
    ),
  );

  debugPrint('✅ main() — runApp() returned');
}
