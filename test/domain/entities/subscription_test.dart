import 'package:flutter_test/flutter_test.dart';
import 'package:subscription_tracker/domain/entities/subscription.dart';

void main() {
  group('Subscription Entity', () {
    test('getDaysUntilBilling returns integer >= 0', () {
      final now = DateTime.now();
      final sub = Subscription(
        id: 'test-1',
        title: 'Netflix',
        cost: 9.99,
        billingDay: now.day + 1,
        icon: 'streaming',
        createdAt: now,
      );

      final days = sub.getDaysUntilBilling();
      expect(days, isA<int>());
      expect(days, greaterThanOrEqualTo(0));
    });

    test('isBillingSoon returns true when days < 3', () {
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));
      
      final sub = Subscription(
        id: 'test-1',
        title: 'Netflix',
        cost: 9.99,
        billingDay: tomorrow.day,
        icon: 'streaming',
        createdAt: now,
      );

      expect(sub.isBillingSoon(), true);
    });

    test('isBillingToday returns true when days == 0', () {
      final now = DateTime.now();
      
      final sub = Subscription(
        id: 'test-1',
        title: 'Netflix',
        cost: 9.99,
        billingDay: now.day,
        icon: 'streaming',
        createdAt: now,
      );

      expect(sub.isBillingToday(), true);
    });

    test('equality works correctly', () {
      final now = DateTime.now();
      
      final sub1 = Subscription(
        id: 'test-1',
        title: 'Netflix',
        cost: 9.99,
        billingDay: 15,
        icon: 'streaming',
        createdAt: now,
      );

      final sub2 = Subscription(
        id: 'test-1',
        title: 'Netflix',
        cost: 9.99,
        billingDay: 15,
        icon: 'streaming',
        createdAt: now,
      );

      expect(sub1, equals(sub2));
    });
  });

  group('Subscription - Date Calculation', () {
    test('correctly calculates next billing date', () {
      final now = DateTime.now();
      
      // If today is before the billing day, next billing is this month
      final sub = Subscription(
        id: 'test-1',
        title: 'Test',
        cost: 10,
        billingDay: 28, // Usually in the future
        icon: 'other',
        createdAt: now,
      );

      final daysUntil = sub.getDaysUntilBilling();
      
      // Should be positive (in the future)
      if (now.day < 28) {
        expect(daysUntil, greaterThan(0));
      }
    });
  });
}
