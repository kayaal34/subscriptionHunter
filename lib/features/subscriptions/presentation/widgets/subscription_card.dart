import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../shared/widgets/soft_card.dart';
import '../../../../shared/widgets/subscription_logo.dart';
import '../../domain/subscription.dart';

/// One row in the subscription list.
class SubscriptionCard extends StatelessWidget {
  const SubscriptionCard({
    required this.subscription,
    required this.daysAway,
    this.onTap,
    super.key,
  });

  final Subscription subscription;
  final int daysAway;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;

    // Urgency drives the chip colour: overdue-today reads as an alert, the
    // next few days as a warning, anything further out stays neutral so the
    // list is not a wall of red.
    final (Color chipBg, Color chipFg) = switch (daysAway) {
      <= 0 => (AppPalette.danger.withValues(alpha: 0.14), AppPalette.danger),
      <= 3 => (AppPalette.warning.withValues(alpha: 0.14), AppPalette.warning),
      _ => (colors.surfaceContainerHighest, colors.onSurfaceVariant),
    };

    return SoftCard(
      onTap: onTap,
      child: Row(
        children: [
          Hero(
            // Shared element into the detail page.
            tag: 'logo-${subscription.id}',
            child: SubscriptionLogo(
              monogram: _monogramFor(subscription.name),
              brandColor: subscription.brandColor,
              assetPath: subscription.logoAsset,
              logoUrl: subscription.logoUrl,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  subscription.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: chipBg,
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                  ),
                  child: Text(
                    l10n.dueLabel(daysAway),
                    style: context.text.labelSmall?.copyWith(
                      color: chipFg,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                MoneyFormatter.format(
                  amount: subscription.price,
                  currencyCode: subscription.currencyCode,
                  localeName: context.localeName,
                ),
                style: context.text.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subscription.billingCycle.label(l10n),
                style: context.text.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Up to two initials from the service name, used when no preset monogram is
/// available (custom subscriptions).
String _monogramFor(String name) {
  final words = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList();
  if (words.isEmpty) return '?';
  if (words.length == 1) {
    final word = words.first;
    return word.substring(0, word.length >= 2 ? 2 : 1).toUpperCase();
  }
  return (words[0][0] + words[1][0]).toUpperCase();
}
