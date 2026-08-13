import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../subscriptions/domain/billing_calculator.dart';
import '../../../subscriptions/domain/subscription.dart';
import '../../../subscriptions/domain/subscription_category.dart';
import '../../../subscriptions/presentation/providers/subscription_providers.dart';

/// Which chart the statistics screen is currently featuring.
enum StatsChartView { categories, trend }

class StatsChartViewController extends Notifier<StatsChartView> {
  @override
  StatsChartView build() => StatsChartView.categories;

  void select(StatsChartView view) => state = view;
}

/// The two charts answer different questions - "what am I paying for" versus
/// "is it growing" - so the screen features one at a time instead of stacking
/// them into a wall of graphics.
final statsChartViewProvider =
    NotifierProvider<StatsChartViewController, StatsChartView>(
      StatsChartViewController.new,
    );

/// One slice of the category pie chart.
class CategorySlice {
  const CategorySlice({
    required this.category,
    required this.monthlyTotal,
    required this.share,
  });

  final SubscriptionCategory category;

  /// Normalised to a month so yearly and monthly plans are comparable.
  final double monthlyTotal;

  /// Fraction of total monthly spend, 0..1.
  final double share;
}

final categoryBreakdownProvider = Provider<List<CategorySlice>>((ref) {
  final subscriptions = ref.watch(primaryCurrencySubscriptionsProvider);

  final totals = <SubscriptionCategory, double>{};
  for (final s in subscriptions) {
    totals[s.category] = (totals[s.category] ?? 0) + s.monthlyCost;
  }

  final grandTotal = totals.values.fold<double>(0, (a, b) => a + b);
  if (grandTotal <= 0) return const [];

  final slices =
      totals.entries
          .map(
            (e) => CategorySlice(
              category: e.key,
              monthlyTotal: BillingCalculator.roundMoney(e.value),
              share: e.value / grandTotal,
            ),
          )
          .toList()
        ..sort((a, b) => b.monthlyTotal.compareTo(a.monthlyTotal));

  return slices;
});

/// Total actually charged in a single calendar month.
class MonthlySpend {
  const MonthlySpend({required this.month, required this.total});

  /// First day of the month this covers.
  final DateTime month;
  final double total;
}

/// Spend for each of the last six months, current month last.
///
/// Counts the real charge dates in each month rather than repeating the
/// monthly average, so a yearly plan shows up as one spike in its renewal
/// month instead of being smeared across the year.
final monthlyTrendProvider = Provider<List<MonthlySpend>>((ref) {
  final now = ref.watch(nowProvider)();
  final subscriptions = ref.watch(primaryCurrencySubscriptionsProvider);

  return [
    for (var offset = 5; offset >= 0; offset--)
      _spendForMonth(
        // DateTime normalises out-of-range months, so month - 5 rolls the
        // year back correctly in January.
        DateTime(now.year, now.month - offset, 1),
        subscriptions,
      ),
  ];
});

MonthlySpend _spendForMonth(
  DateTime monthStart,
  List<Subscription> subscriptions,
) {
  // Day 0 of the next month is the last day of this one.
  final monthEnd = DateTime(monthStart.year, monthStart.month + 1, 0);

  var total = 0.0;
  for (final subscription in subscriptions) {
    final charges = BillingCalculator.occurrencesInRange(
      anchor: subscription.anchorDate,
      cycle: subscription.billingCycle,
      rangeStart: monthStart,
      rangeEnd: monthEnd,
      endDate: subscription.endDate,
    );
    total += charges.length * subscription.price;
  }

  return MonthlySpend(
    month: monthStart,
    total: BillingCalculator.roundMoney(total),
  );
}

/// Active subscriptions ordered by monthly cost, most expensive first.
///
/// Compared on monthly-equivalent cost so a 1200/year plan does not outrank a
/// 150/month one just because its raw price is a bigger number.
final rankedByCostProvider = Provider<List<Subscription>>((ref) {
  final items = [...ref.watch(primaryCurrencySubscriptionsProvider)]
    ..sort((a, b) => b.monthlyCost.compareTo(a.monthlyCost));
  return items;
});

/// The single most expensive active subscription, normalised per month.
final mostExpensiveProvider = Provider<Subscription?>((ref) {
  final subscriptions = ref.watch(primaryCurrencySubscriptionsProvider);
  if (subscriptions.isEmpty) return null;
  return subscriptions.reduce((a, b) => a.monthlyCost >= b.monthlyCost ? a : b);
});
