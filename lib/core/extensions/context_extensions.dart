import 'package:flutter/material.dart';

import '../../features/subscriptions/domain/billing_cycle.dart';
import '../../features/subscriptions/domain/subscription_category.dart';
import '../../l10n/generated/app_localizations.dart';

/// Shorthands that keep build methods readable.
extension BuildContextX on BuildContext {
  /// Non-null because l10n.yaml sets `nullable-getter: false`.
  AppLocalizations get l10n => AppLocalizations.of(this);

  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;

  /// Locale tag for `intl` formatters, e.g. "tr" or "en".
  String get localeName => Localizations.localeOf(this).toLanguageTag();

  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

extension DueLabel on AppLocalizations {
  /// "Due today" / "Due tomorrow" / "Due in N days".
  ///
  /// The first two are separate keys rather than a plural case because several
  /// languages phrase them idiomatically rather than as "in 0/1 days".
  String dueLabel(int daysAway) => switch (daysAway) {
    <= 0 => dueToday,
    1 => dueTomorrow,
    _ => dueInDays(daysAway),
  };
}

/// Enum labels live next to the enums rather than inside widgets so a new
/// value cannot be added without the compiler flagging every missing label.
extension BillingCycleLabel on BillingCycle {
  String label(AppLocalizations l10n) => switch (this) {
    BillingCycle.weekly => l10n.cycleWeekly,
    BillingCycle.monthly => l10n.cycleMonthly,
    BillingCycle.quarterly => l10n.cycleQuarterly,
    BillingCycle.yearly => l10n.cycleYearly,
  };
}

extension SubscriptionCategoryLabel on SubscriptionCategory {
  String label(AppLocalizations l10n) => switch (this) {
    SubscriptionCategory.streaming => l10n.categoryStreaming,
    SubscriptionCategory.music => l10n.categoryMusic,
    SubscriptionCategory.gaming => l10n.categoryGaming,
    SubscriptionCategory.software => l10n.categorySoftware,
    SubscriptionCategory.ai => l10n.categoryAi,
    SubscriptionCategory.cloud => l10n.categoryCloud,
    SubscriptionCategory.news => l10n.categoryNews,
    SubscriptionCategory.fitness => l10n.categoryFitness,
    SubscriptionCategory.education => l10n.categoryEducation,
    SubscriptionCategory.shopping => l10n.categoryShopping,
    SubscriptionCategory.finance => l10n.categoryFinance,
    SubscriptionCategory.other => l10n.categoryOther,
  };

  IconData get icon => switch (this) {
    SubscriptionCategory.streaming => Icons.play_circle_outline,
    SubscriptionCategory.music => Icons.music_note_outlined,
    SubscriptionCategory.gaming => Icons.sports_esports_outlined,
    SubscriptionCategory.software => Icons.code_outlined,
    SubscriptionCategory.ai => Icons.auto_awesome_outlined,
    SubscriptionCategory.cloud => Icons.cloud_outlined,
    SubscriptionCategory.news => Icons.article_outlined,
    SubscriptionCategory.fitness => Icons.fitness_center_outlined,
    SubscriptionCategory.education => Icons.school_outlined,
    SubscriptionCategory.shopping => Icons.shopping_bag_outlined,
    SubscriptionCategory.finance => Icons.account_balance_outlined,
    SubscriptionCategory.other => Icons.category_outlined,
  };
}
