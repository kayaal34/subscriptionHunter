import 'package:hive/hive.dart';
import 'package:subscription_tracker/data/models/subscription_model.dart';

abstract class LocalSubscriptionDataSource {
  Future<List<SubscriptionModel>> getAllSubscriptions();
  Future<void> addSubscription(SubscriptionModel model);
  Future<void> updateSubscription(SubscriptionModel model);
  Future<void> deleteSubscription(String id);
  Future<SubscriptionModel?> getSubscriptionById(String id);
  Stream<List<SubscriptionModel>> watchAllSubscriptions();
}

class LocalSubscriptionDataSourceImpl implements LocalSubscriptionDataSource {

  LocalSubscriptionDataSourceImpl(this._box);
  static const String boxName = 'subscriptions';
  late final Box<SubscriptionModel> _box;

  @override
  Future<void> addSubscription(SubscriptionModel model) async {
    await _box.put(model.id, model);
  }

  @override
  Future<void> deleteSubscription(String id) async {
    await _box.delete(id);
  }

  @override
  Future<List<SubscriptionModel>> getAllSubscriptions() async => _box.values.toList();

  @override
  Future<SubscriptionModel?> getSubscriptionById(String id) async => _box.get(id);

  @override
  Future<void> updateSubscription(SubscriptionModel model) async {
    await _box.put(model.id, model);
  }

  @override
  Stream<List<SubscriptionModel>> watchAllSubscriptions() async* {
    // Emit initial data immediately
    yield _box.values.toList();
    // Then watch for changes
    yield* _box.watch().map((_) => _box.values.toList());
  }
}
