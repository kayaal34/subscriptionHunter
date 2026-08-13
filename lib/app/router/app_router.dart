import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/settings_providers.dart';
import '../../features/onboarding/presentation/onboarding_page.dart';
import '../../features/settings/presentation/pages/privacy_policy_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/statistics/presentation/pages/statistics_page.dart';
import '../../features/subscriptions/presentation/pages/add_subscription_page.dart';
import '../../features/subscriptions/presentation/pages/home_page.dart';
import '../../features/subscriptions/presentation/pages/subscription_detail_page.dart';
import '../../shared/widgets/app_shell.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const statistics = '/statistics';
  static const settings = '/settings';
  static const add = '/add';
  static const detail = '/subscription';
  static const onboarding = '/onboarding';
  static const privacy = '/privacy';

  static String detailFor(String id) => '$detail/$id';
}

/// App navigation.
///
/// A provider rather than a top-level value so the redirect can read whether
/// onboarding is finished. Recreating the router on that change is what moves
/// the user from the consent screen to the home screen.
///
/// The three tabs live in a [StatefulShellRoute] so each keeps its own
/// navigation stack and scroll position when switching - the bottom bar no
/// longer rebuilds the whole page tree on every tap.
final routerProvider = Provider<GoRouter>((ref) {
  final onboarded = ref.watch(onboardingCompletedProvider);

  final router = GoRouter(
    initialLocation: onboarded ? AppRoutes.home : AppRoutes.onboarding,
    redirect: (context, state) {
      final atOnboarding = state.matchedLocation == AppRoutes.onboarding;

      // The data notice is a gate: nothing else is reachable until it is
      // accepted, and it is pointless once it has been.
      if (!onboarded && !atOnboarding) return AppRoutes.onboarding;
      if (onboarded && atOnboarding) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.statistics,
                builder: (context, state) => const StatisticsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: AppRoutes.privacy,
        builder: (context, state) => const PrivacyPolicyPage(),
      ),

      // Presented above the shell so the bottom bar is hidden while editing.
      GoRoute(
        path: AppRoutes.add,
        pageBuilder: (context, state) => const MaterialPage(
          fullscreenDialog: true,
          child: AddSubscriptionPage(),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.detail}/:id',
        builder: (context, state) =>
            SubscriptionDetailPage(id: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'edit',
            pageBuilder: (context, state) => MaterialPage(
              fullscreenDialog: true,
              child: AddSubscriptionPage(
                editingId: state.pathParameters['id'],
              ),
            ),
          ),
        ],
      ),
    ],
  );

  // Completing onboarding rebuilds this provider, which replaces the router.
  // Without this the previous instance keeps its listeners attached to the
  // platform route information provider.
  ref.onDispose(router.dispose);

  return router;
});
