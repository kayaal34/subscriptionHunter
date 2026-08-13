import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_router.dart';
import '../../core/extensions/context_extensions.dart';
import '../../features/subscriptions/presentation/providers/subscription_providers.dart';

/// Bottom-navigation frame around the three main tabs.
class AppShell extends ConsumerWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    // initialLocation: true on re-tap pops that branch back to its root,
    // matching the platform convention.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isHome = navigationShell.currentIndex == 0;
    // The empty state already offers a large "add subscription" call to
    // action. Showing the FAB as well put two identical buttons on the same
    // screen, so it only appears once there is a list to sit above.
    final showFab = isHome && ref.watch(hasSubscriptionsProvider);

    return Scaffold(
      body: navigationShell,
      floatingActionButton: AnimatedScale(
        // Scaled rather than removed, so showing or hiding it does not make
        // the layout jump.
        scale: showFab ? 1 : 0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        child: FloatingActionButton.extended(
          heroTag: 'add-subscription',
          onPressed: () => context.push(AppRoutes.add),
          icon: const Icon(Icons.add_rounded),
          label: Text(l10n.actionAdd),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: [
          NavigationDestination(
            key: const Key('nav-home'),
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: l10n.navHome,
          ),
          NavigationDestination(
            key: const Key('nav-statistics'),
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart_rounded),
            label: l10n.navStatistics,
          ),
          NavigationDestination(
            key: const Key('nav-settings'),
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings_rounded),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}
