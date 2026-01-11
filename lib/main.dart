import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:subscription_tracker/data/models/subscription_model.dart';
import 'package:subscription_tracker/presentation/providers/theme_provider.dart';
import 'package:subscription_tracker/presentation/pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize timezone data for notifications
  tz.initializeTimeZones();

  // Initialize Hive
  await Hive.initFlutter();
  // Register adapters
  Hive.registerAdapter(SubscriptionModelAdapter());

  runApp(
    const ProviderScope(
      child: SubscriptionTrackerApp(),
    ),
  );
}

class SubscriptionTrackerApp extends ConsumerWidget {
  const SubscriptionTrackerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final language = ref.watch(languageProvider);

    return MaterialApp(
      title: 'SubTracker',
      debugShowCheckedModeBanner: false,
      theme: theme,
      locale: language == AppLanguage.turkish 
        ? const Locale('tr', 'TR')
        : language == AppLanguage.russian
          ? const Locale('ru', 'RU')
          : const Locale('en', 'US'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('tr', 'TR'),
        Locale('ru', 'RU'),
      ],
      home: const SplashScreen(),
    );
  }
}
