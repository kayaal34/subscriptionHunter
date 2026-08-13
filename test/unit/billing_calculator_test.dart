import 'package:flutter_test/flutter_test.dart';
import 'package:subscription_tracker/features/subscriptions/domain/billing_calculator.dart';
import 'package:subscription_tracker/features/subscriptions/domain/billing_cycle.dart';

void main() {
  group('nextBillingDate', () {
    test('returns the anchor itself when the subscription has not started', () {
      final next = BillingCalculator.nextBillingDate(
        anchor: DateTime(2026, 9, 10),
        cycle: BillingCycle.monthly,
        from: DateTime(2026, 8, 13),
      );

      expect(next, DateTime(2026, 9, 10));
    });

    test('returns today when a charge falls today', () {
      // A bill due today has not been missed, so it must not roll forward.
      final next = BillingCalculator.nextBillingDate(
        anchor: DateTime(2026, 1, 13),
        cycle: BillingCycle.monthly,
        from: DateTime(2026, 8, 13, 18, 45),
      );

      expect(next, DateTime(2026, 8, 13));
    });

    test('advances monthly from the anchor day', () {
      final next = BillingCalculator.nextBillingDate(
        anchor: DateTime(2026, 1, 15),
        cycle: BillingCycle.monthly,
        from: DateTime(2026, 3, 20),
      );

      expect(next, DateTime(2026, 4, 15));
    });

    test('clamps a 31st anchor into a short month', () {
      final next = BillingCalculator.nextBillingDate(
        anchor: DateTime(2026, 1, 31),
        cycle: BillingCycle.monthly,
        from: DateTime(2026, 2, 1),
      );

      expect(next, DateTime(2026, 2, 28));
    });

    test('recovers the original day after a clamped month', () {
      // The regression this guards: stepping from the clamped Feb 28 instead
      // of the anchor would peg every later charge to the 28th.
      final next = BillingCalculator.nextBillingDate(
        anchor: DateTime(2026, 1, 31),
        cycle: BillingCycle.monthly,
        from: DateTime(2026, 3, 1),
      );

      expect(next, DateTime(2026, 3, 31));
    });

    test('clamps a Feb 29 yearly anchor in a non-leap year', () {
      final next = BillingCalculator.nextBillingDate(
        anchor: DateTime(2024, 2, 29),
        cycle: BillingCycle.yearly,
        from: DateTime(2025),
      );

      expect(next, DateTime(2025, 2, 28));
    });

    test('restores Feb 29 when the next leap year comes round', () {
      final next = BillingCalculator.nextBillingDate(
        anchor: DateTime(2024, 2, 29),
        cycle: BillingCycle.yearly,
        from: DateTime(2028),
      );

      expect(next, DateTime(2028, 2, 29));
    });

    test('advances weekly in 7 day steps', () {
      final next = BillingCalculator.nextBillingDate(
        anchor: DateTime(2026, 1),
        cycle: BillingCycle.weekly,
        from: DateTime(2026, 1, 9),
      );

      expect(next, DateTime(2026, 1, 15));
    });

    test('advances quarterly in 3 month steps', () {
      final next = BillingCalculator.nextBillingDate(
        anchor: DateTime(2026, 1, 10),
        cycle: BillingCycle.quarterly,
        from: DateTime(2026, 5),
      );

      expect(next, DateTime(2026, 7, 10));
    });

    test('handles an anchor many years in the past without drifting', () {
      final next = BillingCalculator.nextBillingDate(
        anchor: DateTime(2015, 6, 30),
        cycle: BillingCycle.monthly,
        from: DateTime(2026, 8, 13),
      );

      expect(next, DateTime(2026, 8, 30));
    });
  });

  group('daysUntilNextBilling', () {
    test('reports 0 for a charge due today, ignoring the time of day', () {
      // The old implementation used difference(now).inDays, which truncated
      // and reported 0 for tomorrow and -1 for today.
      final days = BillingCalculator.daysUntilNextBilling(
        anchor: DateTime(2026, 8, 13),
        cycle: BillingCycle.monthly,
        from: DateTime(2026, 8, 13, 23, 59),
      );

      expect(days, 0);
    });

    test('reports 1 for a charge due tomorrow, late in the day', () {
      final days = BillingCalculator.daysUntilNextBilling(
        anchor: DateTime(2026, 8, 14),
        cycle: BillingCycle.monthly,
        from: DateTime(2026, 8, 13, 23, 59),
      );

      expect(days, 1);
    });

    test('is unaffected by a daylight saving transition', () {
      // Europe/Istanbul no longer shifts, but the calculation must hold for
      // any device timezone: these are 30 calendar days apart regardless of
      // whether one of them is 23 or 25 hours long.
      final days = BillingCalculator.daysUntilNextBilling(
        anchor: DateTime(2026, 3, 1),
        cycle: BillingCycle.monthly,
        from: DateTime(2026, 3, 29, 12),
      );

      expect(days, 3);
    });
  });

  group('previousBillingDate', () {
    test('is null before the first charge', () {
      final previous = BillingCalculator.previousBillingDate(
        anchor: DateTime(2026, 9),
        cycle: BillingCycle.monthly,
        from: DateTime(2026, 8, 13),
      );

      expect(previous, isNull);
    });

    test('returns the charge immediately before the next one', () {
      final previous = BillingCalculator.previousBillingDate(
        anchor: DateTime(2026, 1, 15),
        cycle: BillingCycle.monthly,
        from: DateTime(2026, 3, 20),
      );

      expect(previous, DateTime(2026, 3, 15));
    });
  });

  group('occurrencesInRange', () {
    test('lists every monthly charge inside the window', () {
      final charges = BillingCalculator.occurrencesInRange(
        anchor: DateTime(2026, 1, 15),
        cycle: BillingCycle.monthly,
        rangeStart: DateTime(2026, 1),
        rangeEnd: DateTime(2026, 3, 31),
      );

      expect(charges, [
        DateTime(2026, 1, 15),
        DateTime(2026, 2, 15),
        DateTime(2026, 3, 15),
      ]);
    });

    test('yearly plans contribute a single charge to their renewal month', () {
      final charges = BillingCalculator.occurrencesInRange(
        anchor: DateTime(2026, 3, 5),
        cycle: BillingCycle.yearly,
        rangeStart: DateTime(2026, 3),
        rangeEnd: DateTime(2026, 3, 31),
      );

      expect(charges, [DateTime(2026, 3, 5)]);
    });

    test('stops at endDate', () {
      final charges = BillingCalculator.occurrencesInRange(
        anchor: DateTime(2026, 1, 10),
        cycle: BillingCycle.monthly,
        rangeStart: DateTime(2026, 1),
        rangeEnd: DateTime(2026, 6, 30),
        endDate: DateTime(2026, 3, 15),
      );

      expect(charges, [
        DateTime(2026, 1, 10),
        DateTime(2026, 2, 10),
        DateTime(2026, 3, 10),
      ]);
    });

    test('is empty when the window precedes the subscription', () {
      final charges = BillingCalculator.occurrencesInRange(
        anchor: DateTime(2026, 6),
        cycle: BillingCycle.monthly,
        rangeStart: DateTime(2026),
        rangeEnd: DateTime(2026, 2, 28),
      );

      expect(charges, isEmpty);
    });
  });

  group('cost normalisation', () {
    test('monthly plans pass through unchanged', () {
      expect(
        BillingCalculator.monthlyEquivalent(15.49, BillingCycle.monthly),
        closeTo(15.49, 0.001),
      );
    });

    test('a yearly plan spreads across twelve months', () {
      expect(
        BillingCalculator.monthlyEquivalent(120, BillingCycle.yearly),
        closeTo(10, 0.001),
      );
    });

    test('a quarterly plan spreads across three months', () {
      expect(
        BillingCalculator.monthlyEquivalent(30, BillingCycle.quarterly),
        closeTo(10, 0.001),
      );
    });

    test('weekly uses 365.25/7 charges a year, not a flat 52', () {
      // A flat 52 would under-report a weekly plan by roughly one payment
      // per year.
      expect(
        BillingCalculator.yearlyEquivalent(10, BillingCycle.weekly),
        closeTo(521.78, 0.01),
      );
    });

    test('yearly equivalent of a monthly plan is twelve payments', () {
      expect(
        BillingCalculator.yearlyEquivalent(9.99, BillingCycle.yearly),
        closeTo(9.99, 0.001),
      );
      expect(
        BillingCalculator.yearlyEquivalent(9.99, BillingCycle.monthly),
        closeTo(119.88, 0.001),
      );
    });
  });

  group('roundMoney', () {
    test('rounds to two decimal places', () {
      expect(BillingCalculator.roundMoney(10.005), 10.01);
      expect(BillingCalculator.roundMoney(0.1 + 0.2), 0.3);
    });
  });

  group('addMonthsClamped', () {
    test('rolls the year backwards for negative offsets', () {
      expect(
        BillingCalculator.addMonthsClamped(DateTime(2026, 1, 15), -1),
        DateTime(2025, 12, 15),
      );
      expect(
        BillingCalculator.addMonthsClamped(DateTime(2026, 1, 15), -13),
        DateTime(2024, 12, 15),
      );
    });
  });
}
