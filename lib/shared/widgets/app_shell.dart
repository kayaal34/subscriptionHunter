import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_router.dart';
import '../../core/extensions/context_extensions.dart';

/// Bottom-navigation frame around the three main tabs.
class AppShell extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isHome = navigationShell.currentIndex == 0;

    return Scaffold(
      body: navigationShell,
      floatingActionButton: AnimatedScale(
        // Hidden off the home tab rather than removed, so switching tabs does
        // not make the layout jump.
        scale: isHome ? 1 : 0,
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
