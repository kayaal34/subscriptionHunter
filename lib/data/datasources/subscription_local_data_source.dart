import 'package:hive/hive.dart';
import '../models/subscription_model.dart';

class SubscriptionLocalDataSource {
  SubscriptionLocalDataSource(this._box);

  final Box<SubscriptionModel> _box;

  Future<void> saveSubscription(String key, SubscriptionModel value) async {
    await _box.put(key, value);
  }

  SubscriptionModel? getSubscription(String key) => _box.get(key);

  Future<void> deleteSubscription(String key) async {
    await _box.delete(key);
  }

  Future<void> clearAllSubscriptions() async {
    await _box.clear();
  }
}