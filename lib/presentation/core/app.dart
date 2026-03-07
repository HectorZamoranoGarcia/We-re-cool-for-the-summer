import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app_comidas/presentation/core/theme/app_theme.dart';
import 'package:app_comidas/presentation/core/router/app_router.dart';
import 'package:app_comidas/presentation/settings/controllers/settings_controller.dart';

/// The root application widget.
///
/// This widget is intentionally kept thin. Its only responsibility is to:
///   1. Obtain the [GoRouter] instance from [routerProvider].
///   2. Apply the global [AppTheme].
///   3. Hand everything off to [MaterialApp.router].
///
/// No business logic, no state initialisation, no I/O lives here.
class PantryProApp extends ConsumerWidget {
  const PantryProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The GoRouter instance is provided by Riverpod so that it can access
    // other providers (e.g., auth state) reactively if needed in the future.
    final router = ref.watch(routerProvider);
    final settingsAsyncValue = ref.watch(settingsControllerProvider);

    // Default to system theme until the provider loads (it loads synchronously
    // from disk so this is instantaneous).
    final currentThemeMode = settingsAsyncValue.when(
      data: (prefs) => prefs.themeMode,
      loading: () => ThemeMode.system,
      error: (_, __) => ThemeMode.system,
    );

    return MaterialApp.router(
      title: 'PantryPro',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: currentThemeMode,
    );
  }
}
