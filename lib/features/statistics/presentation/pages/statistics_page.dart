import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/providers/settings_providers.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/soft_card.dart';
import '../../../subscriptions/presentation/providers/subscription_providers.dart';
import '../providers/statistics_providers.dart';

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final slices = ref.watch(categoryBreakdownProvider);
    final currency = ref.watch(currencyCodeProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: slices.isEmpty
            ? EmptyState(
                icon: Icons.insights_outlined,
                title: l10n.statsTitle,
                message: l10n.statsEmpty,
              )
            : CustomScrollView(
                slivers: [
                  SliverAppBar(floating: true, title: Text(l10n.statsTitle)),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      96,
                    ),
                    sliver: SliverList.list(
                      children: [
                        _SummaryRow(currency: currency),
                        const SizedBox(height: AppSpacing.xl),
                        const _ChartSwitcher(),
                        const SizedBox(height: AppSpacing.lg),
                        _FeaturedChart(slices: slices, currency: currency),
                        const SizedBox(height: AppSpacing.md),
                        _MostExpensiveCard(currency: currency),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Segmented control choosing which chart is featured.
class _ChartSwitcher extends ConsumerWidget {
  const _ChartSwitcher();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final selected = ref.watch(statsChartViewProvider);

    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<StatsChartView>(
        key: const Key('stats-chart-switcher'),
        segments: [
          ButtonSegment(
            value: StatsChartView.categories,
            icon: const Icon(Icons.donut_small_rounded),
            label: Text(l10n.statsViewCategories),
          ),
          ButtonSegment(
            value: StatsChartView.trend,
            icon: const Icon(Icons.bar_chart_rounded),
            label: Text(l10n.statsViewTrend),
          ),
        ],
        selected: {selected},
        showSelectedIcon: false,
        onSelectionChanged: (value) =>
            ref.read(statsChartViewProvider.notifier).select(value.first),
      ),
    );
  }
}

/// Cross-fades between the two charts.
class _FeaturedChart extends ConsumerWidget {
  const _FeaturedChart({required this.slices, required this.currency});

  final List<CategorySlice> slices;
  final String currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(statsChartViewProvider);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOutCubic,
      // Size-animated so swapping a tall chart for a short one does not make
      // the content below jump.
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SizeTransition(
          sizeFactor: animation,
          axisAlignment: -1,
          child: child,
        ),
      ),
      child: switch (view) {
        StatsChartView.categories => _CategoryChartCard(
          key: const ValueKey('categories'),
          slices: slices,
          currency: currency,
        ),
        StatsChartView.trend => _TrendChartCard(
          key: const ValueKey('trend'),
          currency: currency,
        ),
      },
    );
  }
}

/// Highlights the single biggest recurring cost.
class _MostExpensiveCard extends ConsumerWidget {
  const _MostExpensiveCard({required this.currency});

  final String currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscription = ref.watch(mostExpensiveProvider);
    if (subscription == null) return const SizedBox.shrink();

    return SoftCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: context.colors.secondaryContainer,
              borderRadius: BorderRadius.circular(AppSpacing.md),
            ),
            child: Icon(
              Icons.local_fire_department_rounded,
              color: context.colors.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.statsMostExpensive,
                  style: context.text.labelSmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subscription.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleMedium,
                ),
              ],
            ),
          ),
          Text(
            MoneyFormatter.compact(
              amount: subscription.monthlyCost,
              currencyCode: currency,
              localeName: context.localeName,
            ),
            style: context.text.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 120.ms, duration: 320.ms);
  }
}

class _SummaryRow extends ConsumerWidget {
  const _SummaryRow({required this.currency});

  final String currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final secondary = ref.watch(secondaryCurrenciesProvider);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatTile(
                label: l10n.statsTotalMonthly,
                value: MoneyFormatter.compact(
                  amount: ref.watch(monthlyTotalProvider),
                  currencyCode: currency,
                  localeName: context.localeName,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _StatTile(
                label: l10n.statsTotalYearly,
                value: MoneyFormatter.compact(
                  amount: ref.watch(yearlyTotalProvider),
                  currencyCode: currency,
                  localeName: context.localeName,
                ),
              ),
            ),
          ],
        ),
        // Totals only cover one currency, so say so instead of silently
        // omitting subscriptions billed in another.
        if (secondary.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 15,
                color: context.colors.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  '$currency · ${secondary.join(", ")}',
                  style: context.text.labelSmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => SoftCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.text.labelSmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: context.text.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );
}

class _CategoryChartCard extends StatefulWidget {
  const _CategoryChartCard({
    required this.slices,
    required this.currency,
    super.key,
  });

  final List<CategorySlice> slices;
  final String currency;

  @override
  State<_CategoryChartCard> createState() => _CategoryChartCardState();
}

class _CategoryChartCardState extends State<_CategoryChartCard> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.statsByCategory, style: context.text.titleMedium),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 52,
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    setState(() {
                      _touchedIndex =
                          response?.touchedSection?.touchedSectionIndex ?? -1;
                    });
                  },
                ),
                sections: [
                  for (var i = 0; i < widget.slices.length; i++)
                    _section(i, widget.slices[i]),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // A legend carries the labels so the slices stay uncluttered and
          // remain readable when a category is only a few percent.
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              for (var i = 0; i < widget.slices.length; i++)
                _LegendChip(
                  color: AppPalette.chartColorAt(i),
                  label: widget.slices[i].category.label(l10n),
                  value: MoneyFormatter.compact(
                    amount: widget.slices[i].monthlyTotal,
                    currencyCode: widget.currency,
                    localeName: context.localeName,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  PieChartSectionData _section(int index, CategorySlice slice) {
    final isTouched = index == _touchedIndex;
    return PieChartSectionData(
      value: slice.monthlyTotal,
      color: AppPalette.chartColorAt(index),
      radius: isTouched ? 64 : 56,
      title: slice.share >= 0.08 ? '${(slice.share * 100).round()}%' : '',
      titleStyle: TextStyle(
        fontSize: isTouched ? 15 : 13,
        fontWeight: FontWeight.w800,
        color: Colors.white,
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: AppSpacing.sm),
      Text(label, style: context.text.labelSmall),
      const SizedBox(width: AppSpacing.xs),
      Text(
        value,
        style: context.text.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: context.colors.onSurfaceVariant,
        ),
      ),
    ],
  );
}

class _TrendChartCard extends ConsumerWidget {
  const _TrendChartCard({required this.currency, super.key});

  final String currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final trend = ref.watch(monthlyTrendProvider);
    final maxValue = trend.fold<double>(0, (m, e) => e.total > m ? e.total : m);
    final monthLabel = DateFormat.MMM(context.localeName);

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.statsMonthlyTrend, style: context.text.titleMedium),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            height: 190,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                // Headroom above the tallest bar so the tooltip is not clipped.
                maxY: maxValue <= 0 ? 1 : maxValue * 1.25,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: maxValue <= 0 ? 1 : maxValue / 2,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: context.colors.outlineVariant.withValues(alpha: 0.4),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  // Values are read from the tooltip, so only the month axis
                  // carries labels. AxisTitles hides its side by default.
                  leftTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= trend.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.sm),
                          child: Text(
                            monthLabel.format(trend[index].month),
                            style: context.text.labelSmall,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => context.colors.inverseSurface,
                    getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                      MoneyFormatter.compact(
                        amount: rod.toY,
                        currencyCode: currency,
                        localeName: context.localeName,
                      ),
                      TextStyle(
                        color: context.colors.onInverseSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < trend.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: trend[i].total,
                          width: 18,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                          // The current month is the last entry; highlighting
                          // it separates "so far" from settled history.
                          color: i == trend.length - 1
                              ? context.colors.primary
                              : context.colors.primary.withValues(alpha: 0.4),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
