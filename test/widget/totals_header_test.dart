import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subscription_tracker/app/theme/app_theme.dart';
import 'package:subscription_tracker/core/providers/settings_providers.dart';
import 'package:subscription_tracker/features/subscriptions/domain/subscription.dart';
import 'package:subscription_tracker/features/subscriptions/presentation/providers/subscription_providers.dart';
import 'package:subscription_tracker/features/subscriptions/presentation/widgets/totals_header.dart';
import 'package:subscription_tracker/l10n/generated/app_localizations.dart';

import '../unit/subscription_test.dart' show buildSubscription;

/// Pumps [TotalsHeader] wired to the real providers exactly as `HomePage`
/// wires it, so the multi-currency disclosure is exercised end to end.
Future<void> pumpHeader(
  WidgetTester tester, {
  required List<Subscription> subscriptions,
  String currency = 'TRY',
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        subscriptionsProvider.overrideWith((ref) => Stream.value(subscriptions)),
        nowProvider.overrideWithValue(() => DateTime(2026, 8, 13)),
        currencyCodeProvider.overrideWithValue(currency),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light(),
        home: Consumer(
          builder: (context, ref, _) => Scaffold(
            body: TotalsHeader(
              monthlyTotal: ref.watch(monthlyTotalProvider),
              yearlyTotal: ref.watch(yearlyTotalProvider),
              activeCount: ref.watch(activeSubscriptionsProvider).length,
              currencyCode: ref.watch(currencyCodeProvider),
              hasOtherCurrencies: ref
                  .watch(secondaryCurrenciesProvider)
                  .isNotEmpty,
            ),
          ),
        ),
      ),
    ),
  );

  // Let the subscriptions stream deliver its first value.
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('shows no currency disclosure when every subscription matches', (
    tester,
  ) async {
    await pumpHeader(
      tester,
      subscriptions: [
        buildSubscription(id: 'a', price: 100),
        buildSubscription(id: 'b', price: 50),
      ],
    );

    expect(find.textContaining('Not in the total'), findsNothing);
    expect(find.textContaining('₺'), findsWidgets);
  });

  testWidgets('discloses subscriptions billed in another currency', (
    tester,
  ) async {
    await pumpHeader(
      tester,
      subscriptions: [
        buildSubscription(id: 'try', price: 100),
        buildSubscription(id: 'usd', price: 20, currencyCode: 'USD'),
      ],
    );

    final note = find.textContaining('Not in the total');
    expect(note, findsOneWidget);
    expect(tester.widget<Text>(note).data, contains('USD'));
  });

  testWidgets(
    'replaces a misleading zero when nothing is billed in the selected currency',
    (tester) async {
      await pumpHeader(
        tester,
        currency: 'USD',
        subscriptions: [
          buildSubscription(id: 'try1', price: 100),
          buildSubscription(id: 'try2', price: 60),
        ],
      );

      expect(find.text('No USD subscriptions yet'), findsOneWidget);
      // The bare "$0.00" that used to show here must be gone.
      expect(find.textContaining('0.00'), findsNothing);
      expect(find.textContaining('Not in the total'), findsOneWidget);
    },
  );
}
