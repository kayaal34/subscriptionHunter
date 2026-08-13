import 'dart:ui' show Locale;

import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/currencies.dart';

/// User preferences that affect the whole app.
class AppSettings {
  const AppSettings({
    required this.themeMode,
    required this.languageCode,
    required this.currencyCode,
    required this.notificationsEnabled,
  });

  final ThemeMode themeMode;

  /// null means "follow the device language".
  final String? languageCode;

  final String currencyCode;
  final bool notificationsEnabled;

  Locale? get locale => languageCode == null ? null : Locale(languageCode!);

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? languageCode,
    bool clearLanguage = false,
    String? currencyCode,
    bool? notificationsEnabled,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    languageCode: clearLanguage ? null : (languageCode ?? this.languageCode),
    currencyCode: currencyCode ?? this.currencyCode,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
  );
}

/// Overridden in `main()` once SharedPreferences has loaded.
///
/// Keeping it synchronous downstream means the first frame already knows the
/// saved theme, so the app never flashes the wrong colours on launch.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main()',
  ),
);

/// Device locale at startup, used to pick a sensible default currency on the
/// very first launch. Overridden in `main()`.
final deviceCountryCodeProvider = Provider<String?>((ref) => null);

class SettingsController extends Notifier<AppSettings> {
  static const _kThemeMode = 'settings.themeMode';
  static const _kLanguage = 'settings.languageCode';
  static const _kCurrency = 'settings.currencyCode';
  static const _kNotifications = 'settings.notificationsEnabled';

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  AppSettings build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final storedCurrency = prefs.getString(_kCurrency);

    return AppSettings(
      themeMode: switch (prefs.getString(_kThemeMode)) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
      languageCode: prefs.getString(_kLanguage),
      currencyCode:
          storedCurrency ??
          Currencies.forCountryCode(ref.read(deviceCountryCodeProvider)),
      notificationsEnabled: prefs.getBool(_kNotifications) ?? true,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _prefs.setString(_kThemeMode, mode.name);
  }

  /// Pass null to follow the device language.
  Future<void> setLanguage(String? languageCode) async {
    state = state.copyWith(
      languageCode: languageCode,
      clearLanguage: languageCode == null,
    );
    if (languageCode == null) {
      await _prefs.remove(_kLanguage);
    } else {
      await _prefs.setString(_kLanguage, languageCode);
    }
  }

  Future<void> setCurrency(String code) async {
    state = state.copyWith(currencyCode: code);
    await _prefs.setString(_kCurrency, code);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    await _prefs.setBool(_kNotifications, enabled);
  }
}

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);

/// Narrow selectors so a currency change does not rebuild widgets that only
/// care about the theme.
final themeModeProvider = Provider<ThemeMode>(
  (ref) => ref.watch(settingsProvider.select((s) => s.themeMode)),
);

final localeProvider = Provider<Locale?>(
  (ref) => ref.watch(settingsProvider.select((s) => s.locale)),
);

final currencyCodeProvider = Provider<String>(
  (ref) => ref.watch(settingsProvider.select((s) => s.currencyCode)),
);

/// Whether the user has finished onboarding and accepted the data notice.
///
/// Kept separate from [AppSettings] because the router redirects on it: a
/// dedicated notifier means accepting consent rebuilds the route and nothing
/// else.
class OnboardingController extends Notifier<bool> {
  static const _key = 'onboarding.completed';

  @override
  bool build() =>
      ref.read(sharedPreferencesProvider).getBool(_key) ?? false;

  /// Called once the data notice is accepted. Irreversible from the UI - the
  /// notice is informational, and re-showing it would just be noise.
  Future<void> complete() async {
    state = true;
    await ref.read(sharedPreferencesProvider).setBool(_key, true);
  }
}

final onboardingCompletedProvider =
    NotifierProvider<OnboardingController, bool>(OnboardingController.new);
