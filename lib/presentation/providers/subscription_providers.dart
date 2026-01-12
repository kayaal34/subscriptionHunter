import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:subscription_tracker/core/services/notification_service.dart';
import 'package:subscription_tracker/data/datasources/local_subscription_datasource.dart';
import 'package:subscription_tracker/data/models/subscription_model.dart';
import 'package:subscription_tracker/data/repositories/subscription_repository_impl.dart';
import 'package:subscription_tracker/domain/entities/subscription.dart';
import 'package:subscription_tracker/domain/repositories/subscription_repository.dart';
import 'package:subscription_tracker/domain/usecases/subscription_usecases.dart';
import 'package:logger/logger.dart';
import 'package:subscription_tracker/presentation/providers/currency_provider.dart';

// Logger Provider
final loggerProvider = Provider<Logger>((ref) => Logger());

// Notification Service Provider
final notificationServiceProvider = Provider<NotificationService>((ref) => NotificationService(logger: ref.watch(loggerProvider)));

// Hive Box Provider
final subscriptionBoxProvider = FutureProvider<Box<SubscriptionModel>>((ref) async {
  
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(SubscriptionModelAdapter());
  }

  // Clear old box if schema changed - migration for new fields
  const boxName = LocalSubscriptionDataSourceImpl.boxName;
  // Previously we had logic here to check for broken data and clear the box.
  // Removed to prevent accidental data loss. Safe migration should be handled in Model getters.

  return Hive.openBox<SubscriptionModel>(boxName);
});

// Data Source Provider - handles both Web and Mobile
final localDataSourceProvider = FutureProvider<LocalSubscriptionDataSource>((ref) async {
  // Use Hive for both Web and Mobile
  final box = await ref.watch(subscriptionBoxProvider.future);
  return LocalSubscriptionDataSourceImpl(box);
});

// Repository Provider
final subscriptionRepositoryProvider = FutureProvider<SubscriptionRepository>((ref) async {
  final dataSource = await ref.watch(localDataSourceProvider.future);
  return SubscriptionRepositoryImpl(localDataSource: dataSource);
});

// Use Cases Providers
final getAllSubscriptionsProvider =
    FutureProvider<GetAllSubscriptions>((ref) async {
  final repository = await ref.watch(subscriptionRepositoryProvider.future);
  return GetAllSubscriptions(repository);
});

final addSubscriptionProvider = FutureProvider<AddSubscription>((ref) async {
  final repository = await ref.watch(subscriptionRepositoryProvider.future);
  return AddSubscription(repository);
});

final updateSubscriptionProvider = FutureProvider<UpdateSubscription>((ref) async {
  final repository = await ref.watch(subscriptionRepositoryProvider.future);
  return UpdateSubscription(repository);
});

final deleteSubscriptionProvider = FutureProvider<DeleteSubscription>((ref) async {
  final repository = await ref.watch(subscriptionRepositoryProvider.future);
  return DeleteSubscription(repository);
});

final watchSubscriptionsProvider = StreamProvider<List<Subscription>>((ref) async* {
  final repository = await ref.watch(subscriptionRepositoryProvider.future);
  yield* WatchSubscriptions(repository).call();
});

// Sorted Subscriptions Provider
final sortedSubscriptionsProvider = StreamProvider<List<Subscription>>((ref) async* {
  final subscriptions = ref.watch(watchSubscriptionsProvider);

  yield* subscriptions.when(
    data: (subs) {
      // Sort by days until billing
      final sorted = subs.cast<Subscription>();
      sorted.sort((a, b) => a.getDaysUntilBilling().compareTo(b.getDaysUntilBilling()));
      return Stream.value(sorted);
    },
    loading: () => Stream.value(<Subscription>[]),
    error: Stream.error,
  );
});

// Total Monthly Cost Provider
final totalMonthlyCostProvider = StreamProvider<double>((ref) async* {
  final subscriptions = ref.watch(watchSubscriptionsProvider);
  final targetCurrency = ref.watch(currencyProvider);
  final currencyService = ref.read(currencyServiceProvider);

  yield* subscriptions.when(
    data: (subs) {
      final total = subs.fold<double>(0, (sum, sub) {
        // Convert yearly costs to monthly equivalent
        final monthlyAmount = sub.billingCycle == BillingCycle.yearly
            ? sub.cost / 12
            : sub.cost;
        
        final converted = currencyService.convert(
          amount: monthlyAmount,
          fromCurrency: sub.currency,
          toCurrency: targetCurrency,
        );
        return sum + converted;
      });
      return Stream.value(total);
    },
    loading: () => Stream.value(0),
    error: Stream.error,
  );
});
