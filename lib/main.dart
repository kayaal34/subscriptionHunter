import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/providers/settings_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // The layouts are designed for portrait; landscape only overflowed.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Android 15 draws apps edge to edge; opt in explicitly so older versions
  // behave the same. Screens already pad themselves with SafeArea.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Loaded before the first frame so the saved theme and language are already
  // known - the app never flashes the wrong colours or the wrong language on
  // launch, which is why this is awaited rather than resolved in a provider.
  final preferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        deviceCountryCodeProvider.overrideWithValue(
          PlatformDispatcher.instance.locale.countryCode,
        ),
      ],
      child: const SubscriptionHunterApp(),
    ),
  );
}
