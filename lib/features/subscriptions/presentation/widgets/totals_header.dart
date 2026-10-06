import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/money_formatter.dart';
import 'currency_coverage_note.dart';
import 'subscription_card.dart' show monoStyle;

/// Monthly total, then a ruled row of yearly total, count and next charge.
///
/// No card behind it: the figure sits on the ground, in champagne on dark and
/// in ink on light, with small mono labels like a statement.
class TotalsHeader extends StatelessWidget {
  const TotalsHeader({
    required this.monthlyTotal,
    required this.yearlyTotal,
    required this.activeCount,
    required this.currencyCode,
    this.hasOtherCurrencies = false,
    this.nextLabel,
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

  /// Short text for the soonest charge. The column is hidden when null.
  final String? nextLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final isDark = context.isDark;

    final showsNothingInCurrency = hasOtherCurrencies && monthlyTotal == 0;

    final figureStyle = showsNothingInCurrency
        ? context.text.titleLarge?.copyWith(fontWeight: FontWeight.w300)
        : context.text.displayLarge?.copyWith(
            fontWeight: FontWeight.w400,
            letterSpacing: -2.5,
            height: 1.0,
            fontSize: 60,
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

    final month = context.upper(
      DateFormat.MMMM(context.localeName).format(DateTime.now()),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${context.upper(l10n.homeMonthlyTotal)} · $month',
          style: monoStyle(
            size: 11,
          ).copyWith(color: colors.onSurfaceVariant, letterSpacing: 2),
        ),
        const SizedBox(height: AppSpacing.sm),
        figure,
        if (hasOtherCurrencies)
          const CurrencyCoverageNote(
            padding: EdgeInsets.only(top: AppSpacing.md),
          ),
        const SizedBox(height: AppSpacing.lg),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.symmetric(
              horizontal: BorderSide(color: colors.outlineVariant),
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _Metric(
                    label: l10n.homeYearlyTotal,
                    value: MoneyFormatter.compact(
                      amount: yearlyTotal,
                      currencyCode: currencyCode,
                      localeName: context.localeName,
                    ),
                  ),
                ),
                VerticalDivider(width: 1, color: colors.outlineVariant),
                Expanded(
                  child: _Metric(
                    label: l10n.homeActiveCount,
                    value: '$activeCount',
                    inset: true,
                  ),
                ),
                if (nextLabel != null) ...[
                  VerticalDivider(width: 1, color: colors.outlineVariant),
                  Expanded(
                    child: _Metric(
                      label: l10n.detailNextPayment,
                      value: nextLabel!,
                      inset: true,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, this.inset = false});

  final String label;
  final String value;
  final bool inset;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(inset ? 14 : 0, 12, 0, 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          context.upper(label),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: monoStyle(size: 9.5).copyWith(
            color: context.colors.onSurfaceVariant,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: 5),
        Text(value, style: monoStyle(size: 16)),
      ],
    ),
  );
}
