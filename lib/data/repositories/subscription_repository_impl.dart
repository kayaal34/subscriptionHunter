import 'package:subscription_tracker/data/datasources/local_subscription_datasource.dart';
import 'package:subscription_tracker/data/models/subscription_model.dart';
import 'package:subscription_tracker/domain/entities/subscription.dart';
import 'package:subscription_tracker/domain/repositories/subscription_repository.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {

  SubscriptionRepositoryImpl({required this.localDataSource});
  final LocalSubscriptionDataSource localDataSource;

  @override
  Future<void> addSubscription(Subscription subscription) async {
    final model = SubscriptionModel.fromEntity(subscription);
    await localDataSource.addSubscription(model);
  }

  @override
  Future<void> deleteSubscription(String id) async {
    await localDataSource.deleteSubscription(id);
  }

  @override
  Future<List<Subscription>> getAllSubscriptions() async {
    final models = await localDataSource.getAllSubscriptions();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Subscription?> getSubscriptionById(String id) async {
    final model = await localDataSource.getSubscriptionById(id);
    return model?.toEntity();
  }

  @override
  Future<void> updateSubscription(Subscription subscription) async {
    final model = SubscriptionModel.fromEntity(subscription);
    await localDataSource.updateSubscription(model);
  }

  @override
  Stream<List<Subscription>> watchAllSubscriptions() => localDataSource
        .watchAllSubscriptions()
        .map((models) => models.map((model) => model.toEntity()).toList());
}
