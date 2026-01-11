import 'package:hive/hive.dart';

class SubscriptionLocalDataSource {
  SubscriptionLocalDataSource(this._box);

  final Box _box;

  Future<void> saveSubscription(String key, dynamic value) async {
    await _box.put(key, value);
  }

  dynamic getSubscription(String key) => _box.get(key);

  Future<void> deleteSubscription(String key) async {
    await _box.delete(key);
  }

  Future<void> clearAllSubscriptions() async {
    await _box.clear();
  }
}