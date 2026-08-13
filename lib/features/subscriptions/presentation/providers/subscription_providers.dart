import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/providers/settings_providers.dart';
import '../../data/subscription_repository_impl.dart';
import '../../domain/billing_calculator.dart';
import '../../domain/subscription.dart';
import '../../domain/subscription_repository.dart';

/// The current time, injected rather than read from `DateTime.now()` at call
/// sites so tests can pin "today" and assert on countdowns deterministically.
final nowProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Process-wide database handle.
///
/// Deliberately a singleton rather than one instance per [ProviderScope].
/// Opening the same SQLite file from two `AppDatabase` objects makes Drift warn
/// that "race conditions will occur and might corrupt the database" - which
/// happens as soon as a second scope is created, for example between
/// integration tests or if the root scope is ever rebuilt.
///
/// It is never closed: the connection should live exactly as long as the
/// process does.
AppDatabase? _database;

final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => _database ??= AppDatabase(),
);

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>(
  (ref) => SubscriptionRepositoryImpl(ref.watch(appDatabaseProvider)),
);

/// Single source of truth for the list. Every screen derives from this, so a
/// write anywhere updates the whole UI without manual refresh calls.
final subscriptionsProvider = StreamProvider<List<Subscription>>(
  (ref) => ref.watch(subscriptionRepositoryProvider).watchAll(),
);

/// Whether anything has been added yet.
///
/// Drives the home FAB: with an empty list the empty state already shows a
/// large "add subscription" button, and a FAB alongside it was a duplicate.
final hasSubscriptionsProvider = Provider<bool>(
  (ref) => ref
      .watch(subscriptionsProvider)
      .maybeWhen(data: (items) => items.isNotEmpty, orElse: () => false),
);

/// Subscriptions that still charge - excludes archived and ended ones.
final activeSubscriptionsProvider = Provider<List<Subscription>>((ref) {
  final now = ref.watch(nowProvider)();
  return ref
      .watch(subscriptionsProvider)
      .maybeWhen(
        data: (items) => items.where((s) => s.isActiveOn(now)).toList(),
        orElse: () => const <Subscription>[],
      );
});

/// Monthly cost per currency.
///
/// Totals are grouped rather than summed into one number on purpose. Adding
/// $10 to €10 and printing "₺20" would be plainly wrong, and this app has no
/// exchange-rate source. Each currency is therefore totalled independently and
/// the UI reports the active one.
///
/// Mixed billing cycles *are* normalised to a month, so a yearly plan
/// contributes 1/12 of its price rather than its full amount.
final monthlyTotalsByCurrencyProvider = Provider<Map<String, double>>((ref) {
  final totals = <String, double>{};
  for (final s in ref.watch(activeSubscriptionsProvider)) {
    totals[s.currencyCode] = (totals[s.currencyCode] ?? 0) + s.monthlyCost;
  }
  return totals.map((k, v) => MapEntry(k, BillingCalculator.roundMoney(v)));
});

/// Subscriptions billed in the user's selected currency - the only set that
/// can be meaningfully totalled or charted together.
final primaryCurrencySubscriptionsProvider = Provider<List<Subscription>>((
  ref,
) {
  final currency = ref.watch(currencyCodeProvider);
  return ref
      .watch(activeSubscriptionsProvider)
      .where((s) => s.currencyCode == currency)
      .toList();
});

final monthlyTotalProvider = Provider<double>((ref) {
  final currency = ref.watch(currencyCodeProvider);
  return ref.watch(monthlyTotalsByCurrencyProvider)[currency] ?? 0;
});

final yearlyTotalProvider = Provider<double>((ref) {
  final total = ref
      .watch(primaryCurrencySubscriptionsProvider)
      .fold<double>(0, (sum, s) => sum + s.yearlyCost);
  return BillingCalculator.roundMoney(total);
});

/// Currencies in use other than the active one, so the UI can disclose that
/// some subscriptions are excluded from the headline total.
final secondaryCurrenciesProvider = Provider<List<String>>((ref) {
  final active = ref.watch(currencyCodeProvider);
  return ref
      .watch(monthlyTotalsByCurrencyProvider)
      .keys
      .where((code) => code != active)
      .toList()
    ..sort();
});

/// A charge coming up inside the next [upcomingWindowDays] days.
class UpcomingBill {
  const UpcomingBill({
    required this.subscription,
    required this.date,
    required this.daysAway,
  });

  final Subscription subscription;
  final DateTime date;
  final int daysAway;
}

const int upcomingWindowDays = 30;

final upcomingBillsProvider = Provider<List<UpcomingBill>>((ref) {
  final now = ref.watch(nowProvider)();
  final bills =
      ref
          .watch(activeSubscriptionsProvider)
          .map(
            (s) => UpcomingBill(
              subscription: s,
              date: s.nextBillingDate(now),
              daysAway: s.daysUntilNextBilling(now),
            ),
          )
          .where((b) => b.daysAway <= upcomingWindowDays)
          .toList()
        ..sort((a, b) => a.daysAway.compareTo(b.daysAway));
  return bills;
});

// ---------------------------------------------------------------------------
// List filtering / sorting
// ---------------------------------------------------------------------------

enum SubscriptionSort { nextPayment, priceHighToLow, priceLowToHigh, name }

class SearchQueryController extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value;
}

final searchQueryProvider = NotifierProvider<SearchQueryController, String>(
  SearchQueryController.new,
);

class SortController extends Notifier<SubscriptionSort> {
  @override
  SubscriptionSort build() => SubscriptionSort.nextPayment;

  void set(SubscriptionSort value) => state = value;
}

final sortProvider = NotifierProvider<SortController, SubscriptionSort>(
  SortController.new,
);

/// What the home list actually renders: active subscriptions, filtered by the
/// search box and ordered by the chosen sort.
final visibleSubscriptionsProvider = Provider<List<Subscription>>((ref) {
  final now = ref.watch(nowProvider)();
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final sort = ref.watch(sortProvider);

  final items = ref
      .watch(activeSubscriptionsProvider)
      .where((s) => query.isEmpty || s.name.toLowerCase().contains(query))
      .toList();

  items.sort(switch (sort) {
    SubscriptionSort.nextPayment =>
      (a, b) =>
          a.daysUntilNextBilling(now).compareTo(b.daysUntilNextBilling(now)),
    SubscriptionSort.priceHighToLow => (a, b) => b.monthlyCost.compareTo(
      a.monthlyCost,
    ),
    SubscriptionSort.priceLowToHigh => (a, b) => a.monthlyCost.compareTo(
      b.monthlyCost,
    ),
    SubscriptionSort.name => (a, b) => a.name.toLowerCase().compareTo(
      b.name.toLowerCase(),
    ),
  });

  return items;
});

/// Look up a single subscription for the detail screen.
final subscriptionByIdProvider = Provider.family<Subscription?, String>((
  ref,
  id,
) {
  final items = ref
      .watch(subscriptionsProvider)
      .maybeWhen(data: (v) => v, orElse: () => const <Subscription>[]);
  for (final item in items) {
    if (item.id == id) return item;
  }
  return null;
});

// ---------------------------------------------------------------------------
// Writes
// ---------------------------------------------------------------------------

/// Write operations, kept separate from the read providers so screens depend
/// on exactly what they need.
class SubscriptionActions {
  const SubscriptionActions(this._repository);

  final SubscriptionRepository _repository;

  Future<void> add(Subscription subscription) => _repository.add(subscription);

  Future<void> update(Subscription subscription) =>
      _repository.update(subscription);

  Future<void> delete(String id) => _repository.delete(id);

  Future<void> deleteAll() => _repository.deleteAll();
}

final subscriptionActionsProvider = Provider<SubscriptionActions>(
  (ref) => SubscriptionActions(ref.watch(subscriptionRepositoryProvider)),
);
