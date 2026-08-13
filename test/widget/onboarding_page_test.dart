import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subscription_tracker/core/providers/settings_providers.dart';
import 'package:subscription_tracker/features/onboarding/presentation/onboarding_page.dart';

import '../helpers/pump_app.dart';

/// Advances past the three intro panes to the consent gate.
Future<void> goToConsent(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await tester.tap(find.byKey(const Key('onboarding-primary-action')));
    await tester.pumpAndSettle();
  }
}

ProviderContainer containerOf(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(OnboardingPage)));

void main() {
  testWidgets('starts on the first intro pane', (tester) async {
    await pumpApp(tester, const OnboardingPage(), locale: const Locale('en'));

    expect(find.text('Every subscription in one place'), findsOneWidget);
  });

  testWidgets('walks through the intro panes to the consent gate', (
    tester,
  ) async {
    await pumpApp(tester, const OnboardingPage(), locale: const Locale('en'));
    await goToConsent(tester);

    expect(find.text('Before you start'), findsOneWidget);
    expect(find.byKey(const Key('onboarding-privacy-checkbox')), findsOneWidget);
  });

  testWidgets('the final button is disabled until consent is given', (
    tester,
  ) async {
    // The gate is the point of this screen: without consent there must be no
    // way through to the app.
    await pumpApp(tester, const OnboardingPage(), locale: const Locale('en'));
    await goToConsent(tester);

    final button = tester.widget<FilledButton>(
      find.byKey(const Key('onboarding-primary-action')),
    );
    expect(button.onPressed, isNull);
    expect(find.text('Please accept the data notice to continue.'), findsOneWidget);
  });

  testWidgets('ticking consent enables the button and completes onboarding', (
    tester,
  ) async {
    await pumpApp(tester, const OnboardingPage(), locale: const Locale('en'));
    await goToConsent(tester);

    expect(containerOf(tester).read(onboardingCompletedProvider), isFalse);

    await tester.tap(find.byKey(const Key('onboarding-privacy-checkbox')));
    await tester.pumpAndSettle();

    final button = tester.widget<FilledButton>(
      find.byKey(const Key('onboarding-primary-action')),
    );
    expect(button.onPressed, isNotNull);

    await tester.tap(find.byKey(const Key('onboarding-primary-action')));
    await tester.pumpAndSettle();

    expect(containerOf(tester).read(onboardingCompletedProvider), isTrue);
  });

  testWidgets('tapping the consent card toggles the checkbox too', (
    tester,
  ) async {
    await pumpApp(tester, const OnboardingPage(), locale: const Locale('en'));
    await goToConsent(tester);

    await tester.tap(find.text('I agree to how my data is handled'));
    await tester.pumpAndSettle();

    final checkbox = tester.widget<Checkbox>(
      find.byKey(const Key('onboarding-privacy-checkbox')),
    );
    expect(checkbox.value, isTrue);
  });

  testWidgets('states plainly that data never leaves the device', (
    tester,
  ) async {
    await pumpApp(tester, const OnboardingPage(), locale: const Locale('en'));
    await goToConsent(tester);

    expect(
      find.textContaining('stored only on this device'),
      findsOneWidget,
    );
  });

  testWidgets('translates the consent gate into Turkish', (tester) async {
    await pumpApp(tester, const OnboardingPage(), locale: const Locale('tr'));
    await goToConsent(tester);

    expect(find.text('Başlamadan önce'), findsOneWidget);
    expect(
      find.text('Verilerimin işlenmesini kabul ediyorum'),
      findsOneWidget,
    );
  });

  testWidgets('onboarding is skipped once completed', (tester) async {
    await pumpApp(
      tester,
      const OnboardingPage(),
      locale: const Locale('en'),
      initialPreferences: {'flutter.onboarding.completed': true},
    );

    expect(containerOf(tester).read(onboardingCompletedProvider), isTrue);
  });
}
