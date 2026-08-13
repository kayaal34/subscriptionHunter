import 'package:flutter_test/flutter_test.dart';
import 'package:subscription_tracker/features/subscriptions/domain/billing_cycle.dart';
import 'package:subscription_tracker/features/subscriptions/domain/subscription.dart';
import 'package:subscription_tracker/features/subscriptions/domain/subscription_category.dart';

Subscription buildSubscription({
  String id = 'test-id',
  String name = 'Netflix',
  double price = 149.99,
  String currencyCode = 'TRY',
  BillingCycle billingCycle = BillingCycle.monthly,
  DateTime? anchorDate,
  DateTime? endDate,
  bool isArchived = false,
}) {
  final created = DateTime(2026);
  return Subscription(
    id: id,
    name: name,
    price: price,
    currencyCode: currencyCode,
    billingCycle: billingCycle,
    anchorDate: anchorDate ?? DateTime(2026, 1, 15),
    category: SubscriptionCategory.streaming,
    brandColor: 0xFFE50914,
    endDate: endDate,
    isArchived: isArchived,
    createdAt: created,
    updatedAt: created,
  );
}

void main() {
  group('lifecycle', () {
    test('is active when it has no end date and is not archived', () {
      expect(buildSubscription().isActiveOn(DateTime(2026, 8, 13)), isTrue);
    });

    test('is inactive once the end date has passed', () {
      final subscription = buildSubscription(endDate: DateTime(2026, 6));
      expect(subscription.hasEndedBy(DateTime(2026, 8, 13)), isTrue);
      expect(subscription.isActiveOn(DateTime(2026, 8, 13)), isFalse);
    });

    test('ends on the end date itself, not the day after', () {
      final subscription = buildSubscription(endDate: DateTime(2026, 8, 13));
      expect(subscription.hasEndedBy(DateTime(2026, 8, 13, 9)), isTrue);
    });

    test('is still active the day before the end date', () {
      final subscription = buildSubscription(endDate: DateTime(2026, 8, 13));
      expect(subscription.isActiveOn(DateTime(2026, 8, 12, 23)), isTrue);
    });

    test('archived subscriptions never count as active', () {
      expect(
        buildSubscription(isArchived: true).isActiveOn(DateTime(2026, 8, 13)),
        isFalse,
      );
    });
  });

  group('cost', () {
    test('normalises a yearly plan to a monthly figure', () {
      final subscription = buildSubscription(
        price: 1200,
        billingCycle: BillingCycle.yearly,
      );
      expect(subscription.monthlyCost, closeTo(100, 0.001));
      expect(subscription.yearlyCost, closeTo(1200, 0.001));
    });
  });

  group('notificationId', () {
    test('is stable for the same id', () {
      expect(
        buildSubscription(id: 'abc').notificationId,
        buildSubscription(id: 'abc').notificationId,
      );
    });

    test('is always non-negative', () {
      // Dart hashCodes are frequently negative; Android rejects a negative
      // notification id.
      for (final id in ['a', 'zzzz', 'a-very-long-uuid-like-value', '']) {
        expect(buildSubscription(id: id).notificationId, greaterThanOrEqualTo(0));
      }
    });
  });

  group('copyWith', () {
    test('leaves the end date untouched when not specified', () {
      final original = buildSubscription(endDate: DateTime(2026, 12));
      expect(original.copyWith(name: 'Spotify').endDate, DateTime(2026, 12));
    });

    test('clears the end date only when explicitly asked', () {
      // "no change" and "set to null" are indistinguishable through a plain
      // nullable parameter, hence the separate flag.
      final original = buildSubscription(endDate: DateTime(2026, 12));
      expect(original.copyWith(clearEndDate: true).endDate, isNull);
    });

    test('preserves the id and creation time', () {
      final original = buildSubscription();
      final updated = original.copyWith(price: 1);
      expect(updated.id, original.id);
      expect(updated.createdAt, original.createdAt);
    });
  });

  group('equality', () {
    test('two identical subscriptions compare equal', () {
      expect(buildSubscription(), buildSubscription());
    });

    test('a price change breaks equality', () {
      expect(buildSubscription(price: 1), isNot(buildSubscription(price: 2)));
    });
  });
}
