import 'package:subscription_tracker/domain/entities/subscription.dart';
import 'package:subscription_tracker/domain/repositories/subscription_repository.dart';

class GetAllSubscriptions {
  GetAllSubscriptions(this.repository);

  final SubscriptionRepository repository;

  Future<List<Subscription>> call() => repository.getAllSubscriptions();
}

class AddSubscription {
  AddSubscription(this.repository);

  final SubscriptionRepository repository;

  Future<void> call(Subscription subscription) =>
      repository.addSubscription(subscription);
}

class UpdateSubscription {
  UpdateSubscription(this.repository);

  final SubscriptionRepository repository;

  Future<void> call(Subscription subscription) =>
      repository.updateSubscription(subscription);
}

class DeleteSubscription {
  DeleteSubscription(this.repository);

  final SubscriptionRepository repository;

  Future<void> call(String id) => repository.deleteSubscription(id);
}

class WatchSubscriptions {
  WatchSubscriptions(this.repository);

  final SubscriptionRepository repository;

  Stream<List<Subscription>> call() => repository.watchAllSubscriptions();
}
