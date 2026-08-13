import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../domain/subscription.dart';
import '../domain/subscription_repository.dart';

/// Drift-backed [SubscriptionRepository].
///
/// The only place in the app that knows subscriptions live in SQLite.
class SubscriptionRepositoryImpl implements SubscriptionRepository {
  const SubscriptionRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Subscription>> watchAll() =>
      (_db.select(_db.subscriptionTable)..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ]))
          .watch()
          .map((rows) => rows.map(_toEntity).toList());

  @override
  Future<List<Subscription>> getAll() async {
    final rows =
        await (_db.select(_db.subscriptionTable)..orderBy([
              (t) => OrderingTerm(
                expression: t.createdAt,
                mode: OrderingMode.desc,
              ),
            ]))
            .get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<Subscription?> getById(String id) async {
    final row = await (_db.select(
      _db.subscriptionTable,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toEntity(row);
  }

  @override
  Future<void> add(Subscription subscription) =>
      _db.into(_db.subscriptionTable).insert(_toCompanion(subscription));

  @override
  Future<void> update(Subscription subscription) =>
      (_db.update(_db.subscriptionTable)
            ..where((t) => t.id.equals(subscription.id)))
          .write(_toCompanion(subscription));

  @override
  Future<void> delete(String id) =>
      (_db.delete(_db.subscriptionTable)..where((t) => t.id.equals(id))).go();

  @override
  Future<void> deleteAll() => _db.delete(_db.subscriptionTable).go();

  Subscription _toEntity(SubscriptionRow row) => Subscription(
    id: row.id,
    name: row.name,
    price: row.price,
    currencyCode: row.currencyCode,
    billingCycle: row.billingCycle,
    anchorDate: row.anchorDate,
    category: row.category,
    brandColor: row.brandColor,
    presetId: row.presetId,
    logoAsset: row.logoAsset,
    logoUrl: row.logoUrl,
    notes: row.notes,
    endDate: row.endDate,
    isArchived: row.isArchived,
    reminderEnabled: row.reminderEnabled,
    reminderDaysBefore: row.reminderDaysBefore,
    reminderHour: row.reminderHour,
    reminderMinute: row.reminderMinute,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );

  SubscriptionTableCompanion _toCompanion(Subscription s) =>
      SubscriptionTableCompanion(
        id: Value(s.id),
        name: Value(s.name),
        price: Value(s.price),
        currencyCode: Value(s.currencyCode),
        billingCycle: Value(s.billingCycle),
        category: Value(s.category),
        anchorDate: Value(s.anchorDate),
        brandColor: Value(s.brandColor),
        // Value.absentIfNull would leave the column untouched on update, which
        // makes clearing a note or an end date impossible. Always write.
        presetId: Value(s.presetId),
        logoAsset: Value(s.logoAsset),
        logoUrl: Value(s.logoUrl),
        notes: Value(s.notes),
        endDate: Value(s.endDate),
        isArchived: Value(s.isArchived),
        reminderEnabled: Value(s.reminderEnabled),
        reminderDaysBefore: Value(s.reminderDaysBefore),
        reminderHour: Value(s.reminderHour),
        reminderMinute: Value(s.reminderMinute),
        createdAt: Value(s.createdAt),
        updatedAt: Value(s.updatedAt),
      );
}
