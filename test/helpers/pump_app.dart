import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subscription_tracker/app/theme/app_theme.dart';
import 'package:subscription_tracker/core/providers/settings_providers.dart';
import 'package:subscription_tracker/l10n/generated/app_localizations.dart';

/// Wraps [child] in a ProviderScope with the preference store faked out.
///
/// Riverpod 3 does not export the `Override` type, so the override list can
/// only be built inline - helpers cannot accept or return one. Tests therefore
/// pass the *data* they want faked (preferences) rather than overrides.
Future<Widget> withTestScope(
  Widget child, {
  Map<String, Object> initialPreferences = const {},
  String countryCode = 'TR',
}) async {
  SharedPreferences.setMockInitialValues(initialPreferences);
  final preferences = await SharedPreferences.getInstance();

  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(preferences),
      deviceCountryCodeProvider.overrideWithValue(countryCode),
    ],
    child: child,
  );
}

/// Pumps [child] inside the same localisation and theme setup the real app
/// uses, so widget tests exercise the strings and colours users actually see.
///
/// Set [settle] to false for trees containing an indefinite animation - a
/// shimmer placeholder or a progress indicator schedules frames forever, so
/// `pumpAndSettle` times out instead of returning.
Future<void> pumpApp(
  WidgetTester tester,
  Widget child, {
  Map<String, Object> initialPreferences = const {},
  Locale? locale,
  ThemeMode themeMode = ThemeMode.light,
  bool settle = true,
}) async {
  final scoped = await withTestScope(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: child,
    ),
    initialPreferences: initialPreferences,
  );

  await tester.pumpWidget(scoped);
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }
}
