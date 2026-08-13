import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subscription_tracker/features/subscriptions/domain/billing_cycle.dart';
import 'package:subscription_tracker/features/subscriptions/presentation/widgets/subscription_card.dart';

import '../helpers/pump_app.dart';
import '../unit/subscription_test.dart' show buildSubscription;

void main() {
  testWidgets('shows the name, price and billing cycle', (tester) async {
    await pumpApp(
      tester,
      Scaffold(
        body: SubscriptionCard(
          subscription: buildSubscription(name: 'Netflix', price: 149.99),
          daysAway: 5,
        ),
      ),
      locale: const Locale('en'),
    );

    expect(find.text('Netflix'), findsOneWidget);
    expect(find.textContaining('149'), findsOneWidget);
    expect(find.text('Monthly'), findsOneWidget);
  });

  testWidgets('renders the localised countdown for a distant charge', (
    tester,
  ) async {
    await pumpApp(
      tester,
      Scaffold(
        body: SubscriptionCard(
          subscription: buildSubscription(),
          daysAway: 12,
        ),
      ),
      locale: const Locale('en'),
    );

    expect(find.text('Due in 12 days'), findsOneWidget);
  });

  testWidgets('uses the dedicated phrase for today rather than "0 days"', (
    tester,
  ) async {
    await pumpApp(
      tester,
      Scaffold(
        body: SubscriptionCard(
          subscription: buildSubscription(),
          daysAway: 0,
        ),
      ),
      locale: const Locale('en'),
    );

    expect(find.text('Due today'), findsOneWidget);
    expect(find.textContaining('0 day'), findsNothing);
  });

  testWidgets('uses the dedicated phrase for tomorrow', (tester) async {
    await pumpApp(
      tester,
      Scaffold(
        body: SubscriptionCard(
          subscription: buildSubscription(),
          daysAway: 1,
        ),
      ),
      locale: const Locale('en'),
    );

    expect(find.text('Due tomorrow'), findsOneWidget);
  });

  testWidgets('translates into Turkish', (tester) async {
    await pumpApp(
      tester,
      Scaffold(
        body: SubscriptionCard(
          subscription: buildSubscription(),
          daysAway: 0,
        ),
      ),
      locale: const Locale('tr'),
    );

    expect(find.text('Bugün ödenecek'), findsOneWidget);
    expect(find.text('Aylık'), findsOneWidget);
  });

  testWidgets('is tappable', (tester) async {
    var tapped = false;
    await pumpApp(
      tester,
      Scaffold(
        body: SubscriptionCard(
          subscription: buildSubscription(),
          daysAway: 3,
          onTap: () => tapped = true,
        ),
      ),
      locale: const Locale('en'),
    );

    await tester.tap(find.byType(SubscriptionCard));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });

  testWidgets('renders in dark mode without overflowing', (tester) async {
    await pumpApp(
      tester,
      Scaffold(
        body: SubscriptionCard(
          subscription: buildSubscription(
            name: 'A Very Long Subscription Service Name That Wraps',
            price: 1234567.89,
          ),
          daysAway: 2,
        ),
      ),
      locale: const Locale('en'),
      themeMode: ThemeMode.dark,
    );

    // tester.takeException() surfaces the RenderFlex overflow that a long
    // name plus a large price would otherwise trigger silently.
    expect(tester.takeException(), isNull);
  });

  testWidgets('a yearly plan is labelled yearly, not monthly', (tester) async {
    await pumpApp(
      tester,
      Scaffold(
        body: SubscriptionCard(
          subscription: buildSubscription(
            billingCycle: BillingCycle.yearly,
          ),
          daysAway: 20,
        ),
      ),
      locale: const Locale('en'),
    );

    expect(find.text('Yearly'), findsOneWidget);
    expect(find.text('Monthly'), findsNothing);
  });
}
