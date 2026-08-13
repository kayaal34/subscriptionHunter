import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subscription_tracker/app/app.dart';
import 'package:subscription_tracker/core/providers/settings_providers.dart';
import 'package:subscription_tracker/features/subscriptions/presentation/providers/subscription_providers.dart';
import 'package:subscription_tracker/features/subscriptions/presentation/widgets/subscription_card.dart';

/// End-to-end tests driven against the real app on a physical device.
///
/// Run with:
///   flutter test integration_test/app_test.dart -d DEVICE_ID
///
/// These exercise the real SQLite database and the real plugin channels, which
/// is the point: the widget tests already cover rendering, and only a device
/// can prove that Drift, shared_preferences and the notification channel
/// actually work together.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Pumps a bounded number of real frames.
  ///
  /// `pumpAndSettle` cannot be used here: while the subscription stream is
  /// still loading the home screen shows a `CircularProgressIndicator`, which
  /// schedules frames forever, so the tree never becomes idle and the test
  /// hangs instead of failing. Pumping a fixed window advances animations and
  /// lets async work complete without ever requiring an idle tree.
  Future<void> settle(
    WidgetTester tester, {
    Duration timeout = const Duration(seconds: 4),
  }) async {
    const step = Duration(milliseconds: 100);
    for (var elapsed = Duration.zero; elapsed < timeout; elapsed += step) {
      await tester.pump(step);
    }
  }

  /// Pumps until [finder] matches, then taps it.
  ///
  /// Preferable to a fixed settle window: the first time the add screen opens
  /// it parses 35 SVG tiles and kicks off 35 logo requests, which on an older
  /// device takes noticeably longer than on later openings once the caches are
  /// warm. Waiting on the widget itself is both faster and not flaky.
  Future<void> waitAndTap(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 20),
  }) async {
    const step = Duration(milliseconds: 150);
    for (var elapsed = Duration.zero; elapsed < timeout; elapsed += step) {
      await tester.pump(step);
      if (finder.evaluate().isNotEmpty) break;
    }
    expect(finder, findsWidgets, reason: 'timed out waiting for $finder');
    await tester.tap(finder.first);
  }

  /// Boots the real app with clean preferences and an empty database.
  ///
  /// [onboarded] defaults to true so tests land on the home screen; the
  /// onboarding gate has its own test below.
  Future<ProviderContainer> launchApp(
    WidgetTester tester, {
    bool onboarded = true,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.clear();
    if (onboarded) await preferences.setBool('onboarding.completed', true);

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        // Pinned so the expected currency and default language are stable
        // regardless of how the test device is configured.
        deviceCountryCodeProvider.overrideWithValue('TR'),
      ],
    );

    // The database is a process-wide singleton, so rows outlive a test. They
    // are cleared in tearDown rather than before pumping: reading a provider
    // before the first pumpWidget stalls on a platform channel, and clearing
    // mid-test makes the stream emit while the tree is building.
    addTearDown(() async {
      await container.read(subscriptionActionsProvider).deleteAll();
      container.dispose();
    });

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const SubscriptionHunterApp(),
      ),
    );
    await settle(tester);

    return container;
  }

  /// Walks the add flow from the home empty state and saves.
  ///
  /// No scrolling: the save button lives in a fixed bottom bar, and the
  /// service picker collapses once a preset is chosen, so every field the
  /// flow touches is on screen.
  Future<void> addPreset(
    WidgetTester tester, {
    required String presetId,
    required String price,
  }) async {
    await waitAndTap(tester, find.byKey(const Key('empty-state-action')));
    await waitAndTap(tester, find.byKey(Key('preset-$presetId')));
    await settle(tester, timeout: const Duration(seconds: 1));

    await tester.enterText(find.byKey(const Key('field-price')), price);
    await waitAndTap(tester, find.byKey(const Key('save-button')));
    await settle(tester);
  }

  group('onboarding', () {
    testWidgets('first launch is gated behind the data notice', (
      tester,
    ) async {
      await launchApp(tester, onboarded: false);

      // The app must not be reachable before consent.
      expect(find.byKey(const Key('onboarding-primary-action')), findsOneWidget);
      expect(find.byType(SubscriptionCard), findsNothing);
      expect(find.byKey(const Key('nav-home')), findsNothing);
    });

    testWidgets('accepting consent lets the user into the app', (tester) async {
      await launchApp(tester, onboarded: false);

      // Three intro panes, then the consent gate.
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byKey(const Key('onboarding-primary-action')));
        await settle(tester, timeout: const Duration(seconds: 1));
      }

      await tester.tap(find.byKey(const Key('onboarding-privacy-checkbox')));
      await settle(tester, timeout: const Duration(seconds: 1));
      await tester.tap(find.byKey(const Key('onboarding-primary-action')));
      await settle(tester);

      expect(find.byKey(const Key('nav-home')), findsOneWidget);
      expect(find.byKey(const Key('home-empty-state')), findsOneWidget);
    });
  });

  group('subscriptions', () {
    testWidgets('starts on an empty home screen', (tester) async {
      await launchApp(tester);

      expect(find.byKey(const Key('home-empty-state')), findsOneWidget);
      expect(find.byType(SubscriptionCard), findsNothing);
    });

    testWidgets('adds Netflix from the preset grid in one tap', (tester) async {
      await launchApp(tester);

      await waitAndTap(tester, find.byKey(const Key('empty-state-action')));

      // A single tap on the preset fills in name, colour and category, and
      // collapses the picker so the form is immediately usable.
      await waitAndTap(tester, find.byKey(const Key('preset-netflix')));
      await settle(tester, timeout: const Duration(seconds: 1));

      expect(
        tester
            .widget<TextFormField>(find.byKey(const Key('field-name')))
            .controller
            ?.text,
        'Netflix',
      );

      // Currency defaults to TRY, so the USD suggestion is deliberately not
      // prefilled and the price must be entered by hand.
      await tester.enterText(find.byKey(const Key('field-price')), '149,99');
      await waitAndTap(tester, find.byKey(const Key('save-button')));
      await settle(tester);

      expect(find.byType(SubscriptionCard), findsOneWidget);
      // Scoped to the card: the name also appears in the "upcoming payments"
      // strip above the list, so a bare find.text would match twice.
      expect(
        find.descendant(
          of: find.byType(SubscriptionCard),
          matching: find.text('Netflix'),
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('home-empty-state')), findsNothing);
    });

    testWidgets('persists the new subscription to SQLite', (tester) async {
      final container = await launchApp(tester);

      await addPreset(tester, presetId: 'spotify', price: '59,99');

      // Read straight from the database rather than the widget tree.
      final stored = await container
          .read(subscriptionRepositoryProvider)
          .getAll();

      expect(stored, hasLength(1));
      expect(stored.single.name, 'Spotify');
      expect(stored.single.price, closeTo(59.99, 0.001));
      expect(stored.single.currencyCode, 'TRY');
      expect(stored.single.presetId, 'spotify');
      // Clearbit URL is derived from the preset's domain.
      expect(stored.single.logoUrl, contains('spotify.com'));
    });

    testWidgets('opens the detail screen and deletes the subscription', (
      tester,
    ) async {
      final container = await launchApp(tester);
      await addPreset(tester, presetId: 'netflix', price: '149,99');

      await tester.tap(find.byType(SubscriptionCard));
      await settle(tester);
      expect(find.text('Netflix'), findsWidgets);

      await tester.tap(find.byKey(const Key('detail-delete')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('confirm-delete')));
      await settle(tester);

      expect(
        await container.read(subscriptionRepositoryProvider).getAll(),
        isEmpty,
      );
    });
  });

  group('statistics', () {
    testWidgets('offers both the category and the trend chart', (tester) async {
      await launchApp(tester);
      await addPreset(tester, presetId: 'netflix', price: '149,99');

      await tester.tap(find.byKey(const Key('nav-statistics')));
      await settle(tester);

      // Categories is the default view.
      expect(find.byType(PieChart), findsOneWidget);
      expect(find.byType(BarChart), findsNothing);

      await tester.tap(find.text('Trend'));
      await settle(tester);

      expect(find.byType(BarChart), findsOneWidget);
      expect(find.byType(PieChart), findsNothing);
    });
  });

  group('settings', () {
    testWidgets('switches language and retranslates the whole UI', (
      tester,
    ) async {
      await launchApp(tester);

      await tester.tap(find.byKey(const Key('nav-settings')));
      await settle(tester);

      // Language lives in a collapsed ExpansionTile.
      await tester.tap(find.byKey(const Key('language-tile')));
      await settle(tester, timeout: const Duration(seconds: 1));

      await tester.tap(find.byKey(const Key('language-tr')));
      await settle(tester, timeout: const Duration(seconds: 1));
      expect(find.text('Ayarlar'), findsWidgets);

      await tester.tap(find.byKey(const Key('language-en')));
      await settle(tester, timeout: const Duration(seconds: 1));
      expect(find.text('Settings'), findsWidgets);
      expect(find.text('Ayarlar'), findsNothing);

      // The language must survive navigation, not just the settings screen.
      await tester.tap(find.byKey(const Key('nav-home')));
      await settle(tester);
      expect(find.text('Home'), findsWidgets);
    });

    testWidgets('switches to dark mode and keeps rendering', (tester) async {
      await launchApp(tester);

      await tester.tap(find.byKey(const Key('nav-settings')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('theme-tile')));
      await settle(tester, timeout: const Duration(seconds: 1));
      await tester.tap(find.byKey(const Key('theme-dark')));
      await settle(tester, timeout: const Duration(seconds: 1));

      expect(
        Theme.of(tester.element(find.byType(Scaffold).first)).brightness,
        Brightness.dark,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('exposes a contact and support action', (tester) async {
      await launchApp(tester);

      await tester.tap(find.byKey(const Key('nav-settings')));
      await settle(tester);

      // Not tapped: it hands off to the platform mail app, which would leave
      // the device on a different screen for the remaining tests.
      expect(find.byKey(const Key('contact-support')), findsOneWidget);
    });
  });
}
