import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../features/subscriptions/domain/billing_cycle.dart';
import '../../features/subscriptions/domain/subscription_category.dart';

part 'app_database.g.dart';

/// Persisted subscription rows.
///
/// Named [SubscriptionRow] on purpose: Drift derives the row class from the
/// table name, and the default (`Subscription`) would collide with the domain
/// entity of the same name.
@DataClassName('SubscriptionRow')
class SubscriptionTable extends Table {
  @override
  String get tableName => 'subscriptions';

  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  RealColumn get price => real()();
  TextColumn get currencyCode => text().withLength(min: 3, max: 3)();

  /// Stored as the enum's name, not its index, so reordering the enum cannot
  /// silently re-interpret existing rows.
  TextColumn get billingCycle => textEnum<BillingCycle>()();
  TextColumn get category => textEnum<SubscriptionCategory>()();

  DateTimeColumn get anchorDate => dateTime()();
  IntColumn get brandColor => integer()();

  TextColumn get presetId => text().nullable()();
  TextColumn get logoAsset => text().nullable()();
  TextColumn get logoUrl => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();

  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  BoolColumn get reminderEnabled =>
      boolean().withDefault(const Constant(true))();
  IntColumn get reminderDaysBefore =>
      integer().withDefault(const Constant(1))();
  IntColumn get reminderHour => integer().withDefault(const Constant(10))();
  IntColumn get reminderMinute => integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [SubscriptionTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// In-memory database for unit and widget tests - no file system, no
  /// leakage between test cases.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    beforeOpen: (details) async {
      // Off by default in SQLite; harmless now and required the moment a
      // second table references subscriptions.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

QueryExecutor _openConnection() => LazyDatabase(() async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File(p.join(dir.path, 'subscription_hunter.sqlite'));
  // createInBackground runs SQLite on its own isolate, so large reads never
  // block the UI thread. Noticeable on older hardware such as the Galaxy S9+.
  return NativeDatabase.createInBackground(file);
});
