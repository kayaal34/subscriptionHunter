import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subscription_tracker/core/providers/settings_providers.dart';
import 'package:subscription_tracker/features/statistics/presentation/providers/statistics_providers.dart';
import 'package:subscription_tracker/features/subscriptions/domain/billing_cycle.dart';
import 'package:subscription_tracker/features/subscriptions/domain/subscription.dart';
import 'package:subscription_tracker/features/subscriptions/domain/subscription_category.dart';
import 'package:subscription_tracker/features/subscriptions/presentation/providers/subscription_providers.dart';

import 'subscription_test.dart' show buildSubscription;

/// Builds a container with the database and clock replaced, so aggregation
/// logic can be tested without SQLite or a real "today".
ProviderContainer buildContainer({
  required List<Subscription> subscriptions,
  DateTime? now,
  String currency = 'TRY',
}) {
  final container = ProviderContainer(
    overrides: [
      subscriptionsProvider.overrideWith((ref) => Stream.value(subscriptions)),
      nowProvider.overrideWithValue(() => now ?? DateTime(2026, 8, 13)),
      currencyCodeProvider.overrideWithValue(currency),
    ],
  );
  addTearDown(container.dispose);

  // Riverpod 3 disposes providers that have no listeners. Without this the
  // stream is torn down while still in its loading state and `.future` never
  // completes - the test just times out.
  container.listen(subscriptionsProvider, (_, _) {});

  return container;
}

void main() {
  // activeSubscriptionsProvider reads through a StreamProvider, so the first
  // value has to be delivered before the derived providers are read.
  Future<void> settle(ProviderContainer container) async {
    await container.read(subscriptionsProvider.future);
  }

  group('totals', () {
    test('sums monthly-equivalent cost across mixed billing cycles', () async {
      final container = buildContainer(
        subscriptions: [
          buildSubscription(id: 'a', price: 100),
          buildSubscription(
            id: 'b',
            price: 1200,
            billingCycle: BillingCycle.yearly,
          ),
        ],
      );
      await settle(container);

      // 100/month + 1200/year (= 100/month)
      expect(container.read(monthlyTotalProvider), closeTo(200, 0.01));
      expect(container.read(yearlyTotalProvider), closeTo(2400, 0.01));
    });

    test('excludes archived and ended subscriptions', () async {
      final container = buildContainer(
        subscriptions: [
          buildSubscription(id: 'a', price: 100),
          buildSubscription(id: 'b', price: 50, isArchived: true),
          buildSubscription(id: 'c', price: 25, endDate: DateTime(2026)),
        ],
      );
      await settle(container);

      expect(container.read(monthlyTotalProvider), closeTo(100, 0.01));
    });

    test('never mixes currencies into one total', () async {
      // Adding $20 to ₺100 and printing "₺120" would be plainly wrong, so the
      // headline total covers the active currency only.
      final container = buildContainer(
        subscriptions: [
          buildSubscription(id: 'a', price: 100),
          buildSubscription(id: 'b', price: 20, currencyCode: 'USD'),
        ],
      );
      await settle(container);

      expect(container.read(monthlyTotalProvider), closeTo(100, 0.01));
      expect(container.read(secondaryCurrenciesProvider), ['USD']);
      expect(container.read(monthlyTotalsByCurrencyProvider), {
        'TRY': closeTo(100, 0.01),
        'USD': closeTo(20, 0.01),
      });
    });
  });

  group('categoryBreakdown', () {
    test('is empty with no subscriptions', () async {
      final container = buildContainer(subscriptions: []);
      await settle(container);

      expect(container.read(categoryBreakdownProvider), isEmpty);
    });

    test('groups by category and computes each share', () async {
      final container = buildContainer(
        subscriptions: [
          buildSubscription(id: 'a', price: 75),
          buildSubscription(id: 'b', price: 25),
        ],
      );
      await settle(container);

      final slices = container.read(categoryBreakdownProvider);
      expect(slices, hasLength(1));
      expect(slices.first.category, SubscriptionCategory.streaming);
      expect(slices.first.monthlyTotal, closeTo(100, 0.01));
      expect(slices.first.share, closeTo(1, 0.001));
    });

    test('orders slices from most to least expensive', () async {
      final container = buildContainer(subscriptions: [buildSubscription()]);
      await settle(container);

      final slices = container.read(categoryBreakdownProvider);
      for (var i = 1; i < slices.length; i++) {
        expect(
          slices[i - 1].monthlyTotal,
          greaterThanOrEqualTo(slices[i].monthlyTotal),
        );
      }
    });
  });

  group('monthlyTrend', () {
    test('always covers six months ending with the current one', () async {
      final container = buildContainer(
        subscriptions: [buildSubscription()],
        now: DateTime(2026, 8, 13),
      );
      await settle(container);

      final trend = container.read(monthlyTrendProvider);
      expect(trend, hasLength(6));
      expect(trend.first.month, DateTime(2026, 3));
      expect(trend.last.month, DateTime(2026, 8));
    });

    test('rolls the year back correctly in January', () async {
      final container = buildContainer(
        subscriptions: [buildSubscription()],
        now: DateTime(2026, 1, 20),
      );
      await settle(container);

      expect(container.read(monthlyTrendProvider).first.month, DateTime(2025, 8));
    });

    test('counts a yearly plan once, in its renewal month only', () async {
      // The point of counting real charge dates rather than repeating an
      // average: a yearly plan is a spike, not a smear.
      final container = buildContainer(
        subscriptions: [
          buildSubscription(
            price: 1200,
            billingCycle: BillingCycle.yearly,
            anchorDate: DateTime(2026, 5, 10),
          ),
        ],
        now: DateTime(2026, 8, 13),
      );
      await settle(container);

      final trend = container.read(monthlyTrendProvider);
      final may = trend.firstWhere((m) => m.month == DateTime(2026, 5));
      final june = trend.firstWhere((m) => m.month == DateTime(2026, 6));

      expect(may.total, closeTo(1200, 0.01));
      expect(june.total, 0);
    });

    test('counts a monthly plan in every month it was active', () async {
      final container = buildContainer(
        subscriptions: [
          buildSubscription(price: 100, anchorDate: DateTime(2026, 1, 5)),
        ],
        now: DateTime(2026, 8, 13),
      );
      await settle(container);

      for (final month in container.read(monthlyTrendProvider)) {
        expect(month.total, closeTo(100, 0.01), reason: '${month.month}');
      }
    });
  });

  group('upcomingBills', () {
    test('is sorted by how soon the charge lands', () async {
      final container = buildContainer(
        subscriptions: [
          buildSubscription(id: 'later', anchorDate: DateTime(2026, 8, 25)),
          buildSubscription(id: 'sooner', anchorDate: DateTime(2026, 8, 15)),
        ],
        now: DateTime(2026, 8, 13),
      );
      await settle(container);

      final bills = container.read(upcomingBillsProvider);
      expect(bills.map((b) => b.subscription.id), ['sooner', 'later']);
      expect(bills.first.daysAway, 2);
    });

    test('excludes charges beyond the 30 day window', () async {
      final container = buildContainer(
        subscriptions: [
          buildSubscription(
            billingCycle: BillingCycle.yearly,
            anchorDate: DateTime(2026, 12),
          ),
        ],
        now: DateTime(2026, 8, 13),
      );
      await settle(container);

      expect(container.read(upcomingBillsProvider), isEmpty);
    });
  });

  group('mostExpensive', () {
    test('is null with no subscriptions', () async {
      final container = buildContainer(subscriptions: []);
      await settle(container);

      expect(container.read(mostExpensiveProvider), isNull);
    });

    test('compares on monthly-equivalent cost, not raw price', () async {
      // A 1200/year plan (100/month) must not beat a 150/month plan just
      // because 1200 is the bigger number.
      final container = buildContainer(
        subscriptions: [
          buildSubscription(id: 'yearly', price: 1200, billingCycle: BillingCycle.yearly),
          buildSubscription(id: 'monthly', price: 150),
        ],
      );
      await settle(container);

      expect(container.read(mostExpensiveProvider)?.id, 'monthly');
    });
  });
}
