import '../datasources/subscription_local_data_source.dart';

class SubscriptionRepository {
  SubscriptionRepository(this._localDataSource);

  final SubscriptionLocalDataSource _localDataSource;

  Future<void> saveSubscription(String key, dynamic value) =>
      _localDataSource.saveSubscription(key, value);

  dynamic getSubscription(String key) => _localDataSource.getSubscription(key);

  Future<void> deleteSubscription(String key) =>
      _localDataSource.deleteSubscription(key);

  Future<void> clearAllSubscriptions() =>
      _localDataSource.clearAllSubscriptions();
}