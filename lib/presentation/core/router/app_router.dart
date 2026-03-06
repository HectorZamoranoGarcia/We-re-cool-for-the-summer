import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:app_comidas/presentation/pantry/views/dashboard_screen.dart';
import 'package:app_comidas/presentation/prices/views/price_history_screen.dart';
import 'package:app_comidas/presentation/scanner/views/scanner_screen.dart';

// Each navigator key MUST be unique across the entire router tree.
// Reusing a key between the root navigator and a shell branch causes
// the "must be 'base'" assertion that freezes the app.
final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _dashboardBranchKey = GlobalKey<NavigatorState>(debugLabel: 'dashboardBranch');
final _cameraBranchKey = GlobalKey<NavigatorState>(debugLabel: 'cameraBranch');
final _searchBranchKey = GlobalKey<NavigatorState>(debugLabel: 'searchBranch');

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/dashboard',
    debugLogDiagnostics: true, // Print every navigation event to help debugging
    routes: [
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
          // The tab tap is intercepted in _AppBottomNavigationBar to push
          // the full-screen scanner instead of navigating within the shell.
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
        ],
      ),

      // Full-screen routes pushed above the shell (parentNavigatorKey = root)
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
          icon: Icon(Icons.qr_code_scanner_outlined),
          activeIcon: Icon(Icons.qr_code_scanner),
          label: 'Scan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_outlined),
          activeIcon: Icon(Icons.bar_chart),
          label: 'Prices',
        ),
      ],
    );
  }
}
