import 'package:flutter/material.dart';

import '../../app/theme/app_palette.dart';

/// Card surface used across the app.
///
/// Material 3 conveys elevation with surface tint alone, which reads flat in a
/// dense list. This keeps the M3 surface colours but adds the soft, diffuse
/// shadow from [AppShadows], and routes taps through an ink-splashed
/// [InkWell] so the whole card responds to touch.
class SoftCard extends StatelessWidget {
  const SoftCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.color,
    this.borderRadius = AppSpacing.cardRadius,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(borderRadius);
    final surface =
        color ??
        (theme.brightness == Brightness.light
            ? theme.colorScheme.surface
            : theme.colorScheme.surfaceContainerHigh);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: radius,
        boxShadow: AppShadows.card(theme.brightness),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
