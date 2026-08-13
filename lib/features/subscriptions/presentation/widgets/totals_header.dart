import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/money_formatter.dart';

/// Monthly / yearly / count summary shown at the top of the home screen.
class TotalsHeader extends StatelessWidget {
  const TotalsHeader({
    required this.monthlyTotal,
    required this.yearlyTotal,
    required this.activeCount,
    required this.currencyCode,
    super.key,
  });

  final double monthlyTotal;
  final double yearlyTotal;
  final int activeCount;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.sheetRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primary, colors.primary.withValues(alpha: 0.82)],
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 10),
            spreadRadius: -8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.homeMonthlyTotal,
            style: context.text.labelLarge?.copyWith(
              color: colors.onPrimary.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              MoneyFormatter.format(
                amount: monthlyTotal,
                currencyCode: currencyCode,
                localeName: context.localeName,
              ),
              style: context.text.displaySmall?.copyWith(
                color: colors.onPrimary,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
          ),
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
                height: 32,
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                color: colors.onPrimary.withValues(alpha: 0.24),
              ),
              _Metric(label: l10n.homeActiveCount, value: '$activeCount'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: context.text.labelSmall?.copyWith(
            color: colors.onPrimary.withValues(alpha: 0.78),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: context.text.titleMedium?.copyWith(
            color: colors.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
