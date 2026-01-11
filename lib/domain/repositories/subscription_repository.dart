import 'package:subscription_tracker/domain/entities/subscription.dart';

abstract class SubscriptionRepository {
  Future<List<Subscription>> getAllSubscriptions();
  Future<void> addSubscription(Subscription subscription);
  Future<void> updateSubscription(Subscription subscription);
  Future<void> deleteSubscription(String id);
  Future<Subscription?> getSubscriptionById(String id);
  Stream<List<Subscription>> watchAllSubscriptions();
}
