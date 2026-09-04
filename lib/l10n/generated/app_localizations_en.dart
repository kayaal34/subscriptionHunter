// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Subscription Hunter';

  @override
  String get navHome => 'Home';

  @override
  String get navStatistics => 'Statistics';

  @override
  String get navSettings => 'Settings';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionClose => 'Close';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionUndo => 'Undo';

  @override
  String get actionChange => 'Change';

  @override
  String get addCustomSubscription => 'Create a custom subscription';

  @override
  String get homeMonthlyTotal => 'Monthly';

  @override
  String get homeYearlyTotal => 'Yearly';

  @override
  String get homeActiveCount => 'Active';

  @override
  String get homeUpcoming => 'Upcoming payments';

  @override
  String get homeAllSubscriptions => 'All subscriptions';

  @override
  String get homeSearchHint => 'Search subscriptions';

  @override
  String get homeEmptyTitle => 'No subscriptions yet';

  @override
  String get homeEmptyMessage =>
      'Add your first subscription to start tracking what you spend each month.';

  @override
  String get homeEmptyAction => 'Add subscription';

  @override
  String currencyAmountIn(String amount, String code) {
    return '$amount in $code';
  }

  @override
  String currencyNotIncludedInTotal(String amounts) {
    return 'Not in the total: $amounts';
  }

  @override
  String currencyNoneYet(String code) {
    return 'No $code subscriptions yet';
  }

  @override
  String currencyTotalsShownIn(String code) {
    return 'Totals shown in $code';
  }

  @override
  String get homeNoUpcoming => 'Nothing due in the next 30 days.';

  @override
  String homeNoResults(String query) {
    return 'No subscriptions match \"$query\".';
  }

  @override
  String get dueToday => 'Due today';

  @override
  String get dueTomorrow => 'Due tomorrow';

  @override
  String dueInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Due in $count days',
      one: 'Due in 1 day',
    );
    return '$_temp0';
  }

  @override
  String get perMonth => 'per month';

  @override
  String get perYear => 'per year';

  @override
  String get cycleWeekly => 'Weekly';

  @override
  String get cycleMonthly => 'Monthly';

  @override
  String get cycleQuarterly => 'Quarterly';

  @override
  String get cycleYearly => 'Yearly';

  @override
  String get addTitle => 'Add subscription';

  @override
  String get editTitle => 'Edit subscription';

  @override
  String get addChoosePreset => 'Popular services';

  @override
  String get addChoosePresetSubtitle =>
      'Pick a service to fill in the details automatically.';

  @override
  String get addCustomService => 'Custom';

  @override
  String get addSearchServices => 'Search services';

  @override
  String get addDetailsSection => 'Details';

  @override
  String get addReminderSection => 'Reminder';

  @override
  String get fieldName => 'Name';

  @override
  String get fieldPrice => 'Price';

  @override
  String get fieldCurrency => 'Currency';

  @override
  String get fieldCycle => 'Billing cycle';

  @override
  String get fieldFirstPayment => 'First payment';

  @override
  String get fieldCategory => 'Category';

  @override
  String get fieldNotes => 'Notes (optional)';

  @override
  String get fieldEndDate => 'Ends on (optional)';

  @override
  String get reminderEnabled => 'Remind me before payment';

  @override
  String reminderDaysBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days before',
      one: '1 day before',
      zero: 'On the payment day',
    );
    return '$_temp0';
  }

  @override
  String get reminderTime => 'Reminder time';

  @override
  String get validationNameRequired => 'Enter a name';

  @override
  String get validationPriceRequired => 'Enter a price';

  @override
  String get validationPriceInvalid => 'Enter a valid amount greater than zero';

  @override
  String get detailNextPayment => 'Next payment';

  @override
  String get detailLastPayment => 'Last payment';

  @override
  String get detailCostPerMonth => 'Cost per month';

  @override
  String get detailCostPerYear => 'Cost per year';

  @override
  String get detailNotes => 'Notes';

  @override
  String get detailStarted => 'Started';

  @override
  String get detailNeverBilled => 'Not billed yet';

  @override
  String get deleteConfirmTitle => 'Delete subscription?';

  @override
  String deleteConfirmMessage(String name) {
    return '$name will be removed permanently. This cannot be undone.';
  }

  @override
  String deletedSnack(String name) {
    return '$name deleted';
  }

  @override
  String get savedSnack => 'Saved';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get statsByCategory => 'Spending by category';

  @override
  String get statsMonthlyTrend => 'Last 6 months';

  @override
  String get statsTotalMonthly => 'Monthly total';

  @override
  String get statsTotalYearly => 'Yearly total';

  @override
  String get statsAveragePerService => 'Average per service';

  @override
  String get statsEmpty => 'Add a subscription to see your spending breakdown.';

  @override
  String get statsMostExpensive => 'Most expensive';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsCurrency => 'Default currency';

  @override
  String get settingsCurrencyHelp =>
      'New subscriptions start in this currency. Home and Statistics totals are shown in it; subscriptions in other currencies are listed on their own.';

  @override
  String settingsCurrencyChanged(String code) {
    return 'Totals now shown in $code';
  }

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsEnabled => 'Payment reminders';

  @override
  String get settingsNotificationsSubtitle =>
      'Get notified before a subscription renews';

  @override
  String get settingsNotificationsBlocked =>
      'Notifications are turned off in system settings.';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsEraseAll => 'Erase all data';

  @override
  String get settingsEraseConfirm =>
      'Delete every subscription? This cannot be undone.';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsVersion => 'Version';

  @override
  String get onboardingTitle1 => 'Every subscription in one place';

  @override
  String get onboardingBody1 =>
      'Add what you pay for and see the real monthly and yearly cost at a glance.';

  @override
  String get onboardingTitle2 => 'Never miss a renewal';

  @override
  String get onboardingBody2 =>
      'Get a reminder before each charge, so a free trial never turns into a surprise.';

  @override
  String get onboardingTitle3 => 'Know where the money goes';

  @override
  String get onboardingBody3 =>
      'Category breakdowns and monthly trends show exactly what is adding up.';

  @override
  String get onboardingConsentTitle => 'Before you start';

  @override
  String get onboardingConsentIntro => 'Two quick things, then you are ready.';

  @override
  String get onboardingPrivacyLabel => 'I agree to how my data is handled';

  @override
  String get onboardingPrivacyDetail =>
      'Your subscriptions are stored only on this device. Nothing is uploaded, no account is required, and no analytics are collected. Brand logos are fetched from Google\'s favicon service, which receives only the service\'s domain name.';

  @override
  String get onboardingNotificationsTitle => 'Payment reminders';

  @override
  String get onboardingNotificationsDetail =>
      'Allow notifications so we can remind you before a subscription renews. You can change this later in Settings.';

  @override
  String get onboardingAllowNotifications => 'Allow notifications';

  @override
  String get onboardingNotificationsGranted => 'Notifications enabled';

  @override
  String get onboardingNotificationsSkipped => 'Continue without reminders';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Get started';

  @override
  String get onboardingConsentRequired =>
      'Please accept the data notice to continue.';

  @override
  String get statsViewCategories => 'Categories';

  @override
  String get statsViewTrend => 'Trend';

  @override
  String get settingsSupport => 'Contact & support';

  @override
  String get settingsSupportSubtitle => 'Report a problem or send a suggestion';

  @override
  String settingsSupportUnavailable(String email) {
    return 'No email app found. Write to $email';
  }

  @override
  String get privacyTitle => 'Privacy Policy';

  @override
  String get privacyUpdated => 'Last updated: 13 August 2026';

  @override
  String get privacyIntro =>
      'Subscription Hunter is built to work without an account and without sending your data anywhere. This page explains exactly what the app stores, what leaves your device, and what it does not do.';

  @override
  String get privacyStorageTitle => 'What the app stores';

  @override
  String get privacyStorageBody =>
      'Everything you enter - subscription names, prices, billing dates, categories, notes and reminder settings - is written to a database file inside the app\'s private storage on your device. There is no account, no sign-in and no cloud sync. We never receive a copy.';

  @override
  String get privacyNetworkTitle => 'What leaves your device';

  @override
  String get privacyNetworkBody =>
      'One thing only: to show a brand logo, the app asks Google\'s favicon service for the icon of a public website, for example netflix.com. That request contains the service\'s domain name and nothing else - no subscription prices, no personal data, and no identifier for you or your device. Offline, the app draws a coloured tile instead and works normally.';

  @override
  String get privacyNotificationsTitle => 'Notifications';

  @override
  String get privacyNotificationsBody =>
      'Payment reminders are scheduled by your device\'s own alarm system. They are generated locally from the data you entered and never pass through a server.';

  @override
  String get privacySupportTitle => 'If you contact support';

  @override
  String get privacySupportBody =>
      'The support option opens your own email app with a message you can read and edit before sending. It is pre-filled with the app version and your Android version so a problem can be reproduced. If you send it, we receive your email address and what you wrote, and use them only to answer you.';

  @override
  String get privacyNoTrackingTitle => 'What the app does not do';

  @override
  String get privacyNoTrackingBody =>
      'No analytics, no advertising, no tracking or profiling, no third-party marketing SDKs, and no selling or sharing of data. There is nothing to sell - the data never reaches us.';

  @override
  String get privacyControlTitle => 'Your control over your data';

  @override
  String get privacyControlBody =>
      'You can delete everything at any time from Settings, using Erase all data. Uninstalling the app also removes its database and settings from your device permanently. Because no copy exists anywhere else, deletion is immediate and final.';

  @override
  String get privacyChildrenTitle => 'Children';

  @override
  String get privacyChildrenBody =>
      'The app is a general-purpose budgeting tool, is not directed at children under 13, and no data is knowingly collected from them.';

  @override
  String get privacyContactTitle => 'Contact';

  @override
  String privacyContactBody(String email) {
    return 'Questions about this policy can be sent to $email.';
  }

  @override
  String get settingsPrivacy => 'Privacy Policy';

  @override
  String get settingsPrivacySubtitle =>
      'What is stored and what leaves your device';

  @override
  String get privacyViewOnline => 'View online';

  @override
  String get categoryStreaming => 'Streaming';

  @override
  String get categoryMusic => 'Music';

  @override
  String get categoryGaming => 'Gaming';

  @override
  String get categorySoftware => 'Software';

  @override
  String get categoryAi => 'AI';

  @override
  String get categoryCloud => 'Cloud';

  @override
  String get categoryNews => 'News';

  @override
  String get categoryFitness => 'Fitness';

  @override
  String get categoryEducation => 'Education';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categoryFinance => 'Finance';

  @override
  String get categoryOther => 'Other';

  @override
  String notificationTitle(String name) {
    return '$name renews soon';
  }

  @override
  String notificationBodyToday(String name, String amount) {
    return '$name charges $amount today.';
  }

  @override
  String notificationBodyUpcoming(String name, String amount, String date) {
    return '$name charges $amount on $date.';
  }

  @override
  String get notificationChannelName => 'Payment reminders';

  @override
  String get notificationChannelDescription =>
      'Reminders before a subscription renews';
}
