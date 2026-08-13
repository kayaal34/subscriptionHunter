import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/extensions/context_extensions.dart';
import '../core/providers/settings_providers.dart';
import '../core/services/notification_coordinator.dart';
import '../l10n/generated/app_localizations.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class SubscriptionHunterApp extends ConsumerWidget {
  const SubscriptionHunterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watching narrow selectors means a currency change does not rebuild the
    // entire app just to re-read the theme.
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      routerConfig: ref.watch(routerProvider),
      debugShowCheckedModeBanner: false,

      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,

      // A null locale follows the device language. Setting it from state is
      // what makes the in-app language switch apply instantly, with no restart.
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateTitle: (context) => context.l10n.appTitle,

      // Sits below Localizations, so reminder text can be built in the
      // currently selected language.
      builder: (context, child) =>
          NotificationCoordinator(child: child ?? const SizedBox.shrink()),
    );
  }
}
