import 'subscription.dart';

/// Storage contract for subscriptions.
///
/// The presentation layer depends on this, never on Drift directly, so the
/// database can be swapped or faked in tests without touching the UI.
abstract interface class SubscriptionRepository {
  /// Emits the full list on every change, so the UI never polls.
  Stream<List<Subscription>> watchAll();

  Future<List<Subscription>> getAll();

  Future<Subscription?> getById(String id);

  Future<void> add(Subscription subscription);

  Future<void> update(Subscription subscription);

  Future<void> delete(String id);

  /// Removes every row. Used by the "erase all data" settings action and to
  /// isolate integration tests from each other.
  Future<void> deleteAll();
}
