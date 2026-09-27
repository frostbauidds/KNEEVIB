// lib/core/router/app_router.dart
// go_router configuration for all screens.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/onboarding/onboarding_screen.dart';
import '../../features/connect/connect_screen.dart';
import '../../features/calibrate/calibrate_screen.dart';
import '../../features/session/new_session_screen.dart';
import '../../features/session/session_countdown_screen.dart';
import '../../features/sync/sync_screen.dart';
import '../../features/sessions/sessions_list_screen.dart';
import '../../features/result/result_screen.dart';
import '../../features/trends/trends_screen.dart';
import '../../features/export/export_screen.dart';
import '../../features/settings/settings_screen.dart';

// Named route constants
class AppRoutes {
  static const onboarding = '/onboarding';
  static const connect = '/connect';
  static const calibrate = '/calibrate';
  static const newSession = '/session/new';
  static const sessionCountdown = '/session/countdown';
  static const sync = '/sync';
  static const sessionsList = '/sessions';
  static const result = '/sessions/result';
  static const trends = '/trends';
  static const export_ = '/export';
  static const settings = '/settings';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.onboarding,
  routes: [
    GoRoute(
      path: AppRoutes.onboarding,
      name: 'onboarding',
      builder: (_, __) => const OnboardingScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => _MainShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.connect,
          name: 'connect',
          builder: (_, __) => const ConnectScreen(),
        ),
        GoRoute(
          path: AppRoutes.calibrate,
          name: 'calibrate',
          builder: (_, __) => const CalibrateScreen(),
        ),
        GoRoute(
          path: AppRoutes.newSession,
          name: 'newSession',
          builder: (_, __) => const NewSessionScreen(),
        ),
        GoRoute(
          path: AppRoutes.sessionCountdown,
          name: 'sessionCountdown',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return SessionCountdownScreen(
              participantId: extra?['participantId'] ?? '',
              side: extra?['side'] ?? 'L',
              durationSeconds: extra?['durationSeconds'] ?? 120,
            );
          },
        ),
        GoRoute(
          path: AppRoutes.sync,
          name: 'sync',
          builder: (_, __) => const SyncScreen(),
        ),
        GoRoute(
          path: AppRoutes.sessionsList,
          name: 'sessions',
          builder: (_, __) => const SessionsListScreen(),
        ),
        GoRoute(
          path: '${AppRoutes.result}/:sessionId',
          name: 'result',
          builder: (context, state) {
            final sessionId = int.parse(state.pathParameters['sessionId']!);
            return ResultScreen(sessionId: sessionId);
          },
        ),
        GoRoute(
          path: AppRoutes.trends,
          name: 'trends',
          builder: (_, __) => const TrendsScreen(),
        ),
        GoRoute(
          path: '${AppRoutes.export_}/:sessionId',
          name: 'export',
          builder: (context, state) {
            final sessionId = int.parse(state.pathParameters['sessionId']!);
            return ExportScreen(sessionId: sessionId);
          },
        ),
        GoRoute(
          path: AppRoutes.settings,
          name: 'settings',
          builder: (_, __) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);

// ─── Bottom navigation shell ──────────────────────────────────────────────────
class _MainShell extends StatelessWidget {
  final Widget child;
  const _MainShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    int selectedIndex = 0;
    if (location.startsWith(AppRoutes.connect) ||
        location.startsWith(AppRoutes.calibrate) ||
        location.startsWith(AppRoutes.newSession) ||
        location.startsWith(AppRoutes.sessionCountdown) ||
        location.startsWith(AppRoutes.sync)) {
      selectedIndex = 0;
    } else if (location.startsWith(AppRoutes.sessionsList) ||
        location.startsWith(AppRoutes.result)) {
      selectedIndex = 1;
    } else if (location.startsWith(AppRoutes.trends)) {
      selectedIndex = 2;
    } else if (location.startsWith(AppRoutes.settings)) {
      selectedIndex = 3;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) {
          switch (i) {
            case 0:
              context.go(AppRoutes.connect);
            case 1:
              context.go(AppRoutes.sessionsList);
            case 2:
              context.go(AppRoutes.trends);
            case 3:
              context.go(AppRoutes.settings);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.bluetooth_outlined),
            selectedIcon: Icon(Icons.bluetooth),
            label: 'Device',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
            label: 'Sessions',
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart_outlined),
            selectedIcon: Icon(Icons.show_chart),
            label: 'Trends',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
