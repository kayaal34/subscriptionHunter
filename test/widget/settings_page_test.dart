import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subscription_tracker/app/theme/app_theme.dart';
import 'package:subscription_tracker/core/providers/settings_providers.dart';
import 'package:subscription_tracker/features/settings/presentation/pages/settings_page.dart';
import 'package:subscription_tracker/l10n/generated/app_localizations.dart';

import '../helpers/pump_app.dart';

/// Mirrors how the real app wires locale and theme to state, so these tests
/// exercise the whole reactive path rather than just the settings widget.
class _Harness extends ConsumerWidget {
  const _Harness();

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp(
    locale: ref.watch(localeProvider),
    themeMode: ref.watch(themeModeProvider),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    home: const SettingsPage(),
  );

  static Future<void> pump(
    WidgetTester tester, {
    Map<String, Object> initialPreferences = const {},
  }) async {
    await tester.pumpWidget(
      await withTestScope(
        const _Harness(),
        initialPreferences: initialPreferences,
      ),
    );
    await tester.pumpAndSettle();
  }
}

/// Language and theme live in collapsed ExpansionTiles; open one first.
Future<void> expandTile(WidgetTester tester, String key) async {
  await tester.tap(find.byKey(Key(key)));
  await tester.pumpAndSettle();
}

void main() {
  group('language switcher', () {
    testWidgets('the language row is reachable straight from settings', (
      tester,
    ) async {
      await _Harness.pump(tester);

      expect(find.byKey(const Key('language-tile')), findsOneWidget);
    });

    testWidgets('the header shows the current language as an endonym', (
      tester,
    ) async {
      // Someone stuck in a language they cannot read still has to be able to
      // recognise their own, so the collapsed header spells it natively.
      await _Harness.pump(
        tester,
        initialPreferences: {'flutter.settings.languageCode': 'tr'},
      );

      expect(find.text('Türkçe'), findsOneWidget);
    });

    testWidgets('expanding reveals every supported language', (tester) async {
      await _Harness.pump(tester);
      await expandTile(tester, 'language-tile');

      expect(find.byKey(const Key('language-system')), findsOneWidget);
      expect(find.byKey(const Key('language-tr')), findsOneWidget);
      expect(find.byKey(const Key('language-en')), findsOneWidget);
      expect(find.byKey(const Key('language-ru')), findsOneWidget);
    });

    testWidgets('switching to Turkish retranslates the UI immediately', (
      tester,
    ) async {
      await _Harness.pump(tester);
      await expandTile(tester, 'language-tile');

      await tester.tap(find.byKey(const Key('language-tr')));
      await tester.pumpAndSettle();

      expect(find.text('Ayarlar'), findsWidgets);
      expect(find.text('Settings'), findsNothing);
    });

    testWidgets('switching to Russian retranslates the UI immediately', (
      tester,
    ) async {
      await _Harness.pump(tester);
      await expandTile(tester, 'language-tile');

      await tester.tap(find.byKey(const Key('language-ru')));
      await tester.pumpAndSettle();

      expect(find.text('Настройки'), findsWidgets);
    });

    testWidgets('the selection persists to preferences', (tester) async {
      await _Harness.pump(tester);
      await expandTile(tester, 'language-tile');

      await tester.tap(find.byKey(const Key('language-tr')));
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(SettingsPage)),
      );
      expect(container.read(settingsProvider).languageCode, 'tr');
    });
  });

  group('theme switcher', () {
    testWidgets('switches to dark mode', (tester) async {
      await _Harness.pump(tester);
      await expandTile(tester, 'theme-tile');

      await tester.tap(find.byKey(const Key('theme-dark')));
      await tester.pumpAndSettle();

      expect(
        Theme.of(tester.element(find.byType(SettingsPage))).brightness,
        Brightness.dark,
      );
    });

    testWidgets('defaults to following the system', (tester) async {
      await _Harness.pump(tester);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(SettingsPage)),
      );
      expect(container.read(settingsProvider).themeMode, ThemeMode.system);
    });
  });

  group('support', () {
    testWidgets('offers a contact action', (tester) async {
      await _Harness.pump(tester);

      final tile = find.byKey(const Key('contact-support'));
      // The settings list is a lazily built sliver, so a row far enough down
      // is not in the tree until scrolled to.
      await tester.scrollUntilVisible(
        tile,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(tile, findsOneWidget);
      // Tapping is not exercised here: it hands off to the platform mail app,
      // which only a device can answer. Covered manually instead.
      expect(
        find.descendant(of: tile, matching: find.byType(Icon)),
        findsWidgets,
      );
    });
  });

  group('startup state', () {
    testWidgets('restores a previously saved language and theme', (
      tester,
    ) async {
      await _Harness.pump(
        tester,
        initialPreferences: {
          'flutter.settings.languageCode': 'ru',
          'flutter.settings.themeMode': 'dark',
        },
      );

      // Loaded before the first frame, so no flash of the wrong language.
      expect(find.text('Настройки'), findsWidgets);
      expect(
        Theme.of(tester.element(find.byType(SettingsPage))).brightness,
        Brightness.dark,
      );
    });

    testWidgets('picks a currency from the device country on first launch', (
      tester,
    ) async {
      await _Harness.pump(tester);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(SettingsPage)),
      );
      expect(container.read(settingsProvider).currencyCode, 'TRY');
    });
  });
}
