import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_router.dart';
import '../../app/theme/app_palette.dart';
import '../../core/extensions/context_extensions.dart';

/// Frame around the three main tabs, with a floating bar whose centre button
/// adds a subscription.
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
    final ground = Theme.of(context).scaffoldBackgroundColor;
    final current = navigationShell.currentIndex;

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        // Content fades out under the bar instead of being cut by a hard edge.
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [ground.withValues(alpha: 0), ground],
            stops: const [0, 0.42],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.md,
            ),
            child: SizedBox(
              height: 64,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    key: const Key('nav-home'),
                    icon: Icons.home_outlined,
                    selectedIcon: Icons.home_rounded,
                    label: l10n.navHome,
                    selected: current == 0,
                    onTap: () => _onDestinationSelected(0),
                  ),
                  _NavItem(
                    key: const Key('nav-statistics'),
                    icon: Icons.bar_chart_outlined,
                    selectedIcon: Icons.bar_chart_rounded,
                    label: l10n.navStatistics,
                    selected: current == 1,
                    onTap: () => _onDestinationSelected(1),
                  ),
                  _AddButton(
                    label: l10n.addTitle,
                    onTap: () => context.push(AppRoutes.add),
                  ),
                  _NavItem(
                    key: const Key('nav-settings'),
                    icon: Icons.tune_rounded,
                    selectedIcon: Icons.tune_rounded,
                    label: l10n.navSettings,
                    selected: current == 2,
                    onTap: () => _onDestinationSelected(2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final active = colors.primary;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkResponse(
        onTap: onTap,
        radius: 34,
        child: SizedBox(
          width: 64,
          height: 64,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? selectedIcon : icon,
                size: 25,
                color: selected ? active : colors.onSurfaceVariant,
              ),
              const SizedBox(height: 6),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: selected ? 16 : 0,
                height: 3,
                decoration: BoxDecoration(
                  color: active,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final colors = context.colors;

    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        key: const Key('nav-add'),
        onTap: onTap,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isDark
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppPalette.champagneGradient,
                  )
                : null,
            color: isDark ? null : colors.primary,
            boxShadow: [
              BoxShadow(
                color: (isDark ? AppPalette.champagne : colors.primary)
                    .withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 10),
                spreadRadius: -6,
              ),
            ],
          ),
          child: Icon(
            Icons.add_rounded,
            size: 28,
            color: isDark ? const Color(0xFF1A1407) : colors.onPrimary,
          ),
        ),
      ),
    );
  }
}
