/// Spending buckets used by the statistics screen.
///
/// Stored by [id] rather than by enum index so reordering or inserting a
/// category never silently re-labels rows already in the database.
enum SubscriptionCategory {
  streaming('streaming'),
  music('music'),
  gaming('gaming'),
  software('software'),
  ai('ai'),
  cloud('cloud'),
  news('news'),
  fitness('fitness'),
  education('education'),
  shopping('shopping'),
  finance('finance'),
  other('other');

  const SubscriptionCategory(this.id);

  final String id;

  static SubscriptionCategory fromId(String? id) =>
      values.firstWhere((c) => c.id == id, orElse: () => other);
}
