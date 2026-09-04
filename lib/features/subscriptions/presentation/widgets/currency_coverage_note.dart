import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/money_formatter.dart';
import '../providers/subscription_providers.dart';

/// Discloses subscriptions the headline total leaves out because they are
/// billed in a currency other than the selected one.
///
/// The app has no exchange-rate source and deliberately never adds two
/// currencies together, so instead of silently dropping those subscriptions it
/// spells out how much sits in each other currency. Renders nothing when every
/// subscription shares the selected currency.
class CurrencyCoverageNote extends ConsumerWidget {
  const CurrencyCoverageNote({
    this.foreground,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  /// Overrides the text/icon colour, e.g. for the coloured totals card where
  /// [ColorScheme.onSurfaceVariant] would be illegible.
  final Color? foreground;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final secondary = ref.watch(secondaryCurrenciesProvider);
    if (secondary.isEmpty) return const SizedBox.shrink();

    final l10n = context.l10n;
    final totals = ref.watch(monthlyTotalsByCurrencyProvider);
    final locale = context.localeName;
    final color = foreground ?? context.colors.onSurfaceVariant;

    final amounts = secondary
        .map(
          (code) => l10n.currencyAmountIn(
            MoneyFormatter.compact(
              amount: totals[code] ?? 0,
              currencyCode: code,
              localeName: locale,
            ),
            code,
          ),
        )
        .join('  ·  ');

    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 15, color: color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              l10n.currencyNotIncludedInTotal(amounts),
              style: context.text.labelSmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
