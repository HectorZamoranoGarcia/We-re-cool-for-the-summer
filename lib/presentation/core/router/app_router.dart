import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:app_comidas/core/di/auth_providers.dart';
import 'package:app_comidas/presentation/auth/views/login_screen.dart';
import 'package:app_comidas/presentation/pantry/views/dashboard_screen.dart';
import 'package:app_comidas/presentation/prices/views/price_history_screen.dart';
import 'package:app_comidas/presentation/scanner/views/scanner_screen.dart';
import 'package:app_comidas/presentation/settings/views/settings_screen.dart';

// Each navigator key MUST be unique across the entire router tree.
// Reusing a key between the root navigator and a shell branch causes
// the "must be 'base'" assertion that freezes the app.
final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _dashboardBranchKey = GlobalKey<NavigatorState>(debugLabel: 'dashboardBranch');
final _cameraBranchKey = GlobalKey<NavigatorState>(debugLabel: 'cameraBranch');
final _searchBranchKey = GlobalKey<NavigatorState>(debugLabel: 'searchBranch');
final _settingsBranchKey = GlobalKey<NavigatorState>(debugLabel: 'settingsBranch');

// Routes that should NOT redirect to /login even when unauthenticated.
const _publicRoutes = ['/login'];

final routerProvider = Provider<GoRouter>((ref) {
  // Listen to authState stream so GoRouter re-evaluates redirect on every
  // sign-in or sign-out event. The listenable tells Router to rebuild.
  final authNotifier = ValueNotifier<AsyncValue<AuthState>?>(null);
  ref.listen<AsyncValue<AuthState>>(authStateProvider, (_, next) {
    authNotifier.value = next;
  });

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/dashboard',
    refreshListenable: authNotifier,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final currentUser = ref.read(currentUserProvider);
      final isAuthenticated = currentUser != null;
      final isGoingToPublic = _publicRoutes.contains(state.matchedLocation);

      // If not logged in and trying to access a protected route → /login
      if (!isAuthenticated && !isGoingToPublic) return '/login';

      // If already logged in and trying to access /login → /dashboard
      if (isAuthenticated && isGoingToPublic) return '/dashboard';

      return null; // No redirect needed
    },
    routes: [
      // ── Public: authentication ──────────────────────────────────────────
      GoRoute(
        path: '/login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),

      // ── Protected: shell with bottom navigation ─────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: _AppBottomNavigationBar(
              navigationShell: navigationShell,
            ),
          );
        },
        branches: [
          // Branch 0 – Dashboard (Pantry overview)
          StatefulShellBranch(
            navigatorKey: _dashboardBranchKey,
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),

          // Branch 1 – Camera placeholder.
          StatefulShellBranch(
            navigatorKey: _cameraBranchKey,
            routes: [
              GoRoute(
                path: '/camera',
                builder: (context, state) => const SizedBox.shrink(),
              ),
            ],
          ),

          // Branch 2 – Price history / search
          StatefulShellBranch(
            navigatorKey: _searchBranchKey,
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => const Center(
                  child: Text('Search for a product to see its price history.'),
                ),
              ),
            ],
          ),

          // Branch 3 – Settings
          StatefulShellBranch(
            navigatorKey: _settingsBranchKey,
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),

      // ── Full-screen routes pushed above the shell ───────────────────────
      GoRoute(
        path: '/scanner',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ScannerScreen(),
      ),
      GoRoute(
        path: '/price_history/:barcode',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final barcode = state.pathParameters['barcode']!;
          return PriceHistoryScreen(barcode: barcode);
        },
      ),
    ],
  );
});

class _AppBottomNavigationBar extends StatelessWidget {
  const _AppBottomNavigationBar({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: navigationShell.currentIndex,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed, // Required for >3 items
      onTap: (index) {
        if (index == 1) {
          // Intercept the camera tab: push the full-screen scanner instead
          // of rendering inside the shell (which would lose the NavBar).
          context.push('/scanner');
          return;
        }
        navigationShell.goBranch(
          index,
          // If the user taps the active tab, jump back to its initial route.
          initialLocation: index == navigationShell.currentIndex,
        );
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.kitchen_outlined),
          activeIcon: Icon(Icons.kitchen),
          label: 'Pantry',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.barcode_reader),
          activeIcon: Icon(Icons.barcode_reader),
          label: 'Scan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_outlined),
          activeIcon: Icon(Icons.bar_chart),
          label: 'Prices',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
