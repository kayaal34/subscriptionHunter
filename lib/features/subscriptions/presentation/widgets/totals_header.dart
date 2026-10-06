import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/money_formatter.dart';
import 'currency_coverage_note.dart';
import 'subscription_card.dart' show monoStyle;

/// Monthly total, yearly total and count shown above the wallet stack.
///
/// No card behind it: the figure sits straight on the ground, in champagne on
/// dark and in ink on light, with small mono labels like a statement.
class TotalsHeader extends StatelessWidget {
  const TotalsHeader({
    required this.monthlyTotal,
    required this.yearlyTotal,
    required this.activeCount,
    required this.currencyCode,
    this.hasOtherCurrencies = false,
    super.key,
  });

  final double monthlyTotal;
  final double yearlyTotal;
  final int activeCount;
  final String currencyCode;

  /// True when some active subscription is billed in a currency other than
  /// [currencyCode]. Drives the "not in the total" disclosure and stops a bare
  /// "0" reading as "you spend nothing" when the real reason is that every
  /// subscription is in another currency.
  final bool hasOtherCurrencies;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final isDark = context.isDark;

    final showsNothingInCurrency = hasOtherCurrencies && monthlyTotal == 0;

    final figureStyle = showsNothingInCurrency
        ? context.text.titleLarge?.copyWith(fontWeight: FontWeight.w300)
        : context.text.displayMedium?.copyWith(
            fontWeight: FontWeight.w300,
            letterSpacing: -1.5,
            height: 1.05,
          );

    Widget figure = FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        showsNothingInCurrency
            ? l10n.currencyNoneYet(currencyCode)
            : MoneyFormatter.format(
                amount: monthlyTotal,
                currencyCode: currencyCode,
                localeName: context.localeName,
              ),
        style: figureStyle?.copyWith(color: isDark ? null : colors.onSurface),
      ),
    );

    if (isDark) {
      figure = ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppPalette.champagneGradient,
        ).createShader(bounds),
        blendMode: BlendMode.srcIn,
        child: figure,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.upper(l10n.homeMonthlyTotal),
          style: monoStyle(size: 11).copyWith(
            color: colors.onSurfaceVariant,
            letterSpacing: 2.2,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        figure,
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            _Metric(
              label: l10n.homeYearlyTotal,
              value: MoneyFormatter.compact(
                amount: yearlyTotal,
                currencyCode: currencyCode,
                localeName: context.localeName,
              ),
            ),
            Container(
              width: 1,
              height: 30,
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              color: colors.outlineVariant,
            ),
            _Metric(label: l10n.homeActiveCount, value: '$activeCount'),
          ],
        ),
        if (hasOtherCurrencies)
          const CurrencyCoverageNote(
            padding: EdgeInsets.only(top: AppSpacing.lg),
          ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        context.upper(label),
        style: monoStyle(size: 10).copyWith(
          color: context.colors.onSurfaceVariant,
          letterSpacing: 1.8,
        ),
      ),
      const SizedBox(height: 4),
      Text(value, style: monoStyle(size: 17)),
    ],
  );
}
