import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('tr'),
  ];

  /// Application name shown in the app bar
  ///
  /// In en, this message translates to:
  /// **'Subscription Hunter'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navStatistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get navStatistics;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// No description provided for @actionUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get actionUndo;

  /// No description provided for @actionChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get actionChange;

  /// No description provided for @addCustomSubscription.
  ///
  /// In en, this message translates to:
  /// **'Create a custom subscription'**
  String get addCustomSubscription;

  /// No description provided for @homeMonthlyTotal.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get homeMonthlyTotal;

  /// No description provided for @homeYearlyTotal.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get homeYearlyTotal;

  /// No description provided for @homeActiveCount.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get homeActiveCount;

  /// No description provided for @homeUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming payments'**
  String get homeUpcoming;

  /// No description provided for @homeAllSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'All subscriptions'**
  String get homeAllSubscriptions;

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search subscriptions'**
  String get homeSearchHint;

  /// No description provided for @homeEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No subscriptions yet'**
  String get homeEmptyTitle;

  /// No description provided for @homeEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add your first subscription to start tracking what you spend each month.'**
  String get homeEmptyMessage;

  /// No description provided for @homeEmptyAction.
  ///
  /// In en, this message translates to:
  /// **'Add subscription'**
  String get homeEmptyAction;

  /// One currency's total, e.g. "$9.99 in USD", used in the multi-currency disclosure line
  ///
  /// In en, this message translates to:
  /// **'{amount} in {code}'**
  String currencyAmountIn(String amount, String code);

  /// Lists subscription costs in other currencies that the headline total leaves out
  ///
  /// In en, this message translates to:
  /// **'Not in the total: {amounts}'**
  String currencyNotIncludedInTotal(String amounts);

  /// Shown instead of a zero total when the selected currency has no subscriptions
  ///
  /// In en, this message translates to:
  /// **'No {code} subscriptions yet'**
  String currencyNoneYet(String code);

  /// Statistics header note naming the currency the figures are in
  ///
  /// In en, this message translates to:
  /// **'Totals shown in {code}'**
  String currencyTotalsShownIn(String code);

  /// No description provided for @homeNoUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Nothing due in the next 30 days.'**
  String get homeNoUpcoming;

  /// No description provided for @homeNoResults.
  ///
  /// In en, this message translates to:
  /// **'No subscriptions match \"{query}\".'**
  String homeNoResults(String query);

  /// No description provided for @dueToday.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get dueToday;

  /// No description provided for @dueTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Due tomorrow'**
  String get dueTomorrow;

  /// Countdown to the next charge
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Due in 1 day} other{Due in {count} days}}'**
  String dueInDays(int count);

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'per month'**
  String get perMonth;

  /// No description provided for @perYear.
  ///
  /// In en, this message translates to:
  /// **'per year'**
  String get perYear;

  /// No description provided for @cycleWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get cycleWeekly;

  /// No description provided for @cycleMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get cycleMonthly;

  /// No description provided for @cycleQuarterly.
  ///
  /// In en, this message translates to:
  /// **'Quarterly'**
  String get cycleQuarterly;

  /// No description provided for @cycleYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get cycleYearly;

  /// No description provided for @addTitle.
  ///
  /// In en, this message translates to:
  /// **'Add subscription'**
  String get addTitle;

  /// No description provided for @editTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit subscription'**
  String get editTitle;

  /// No description provided for @addChoosePreset.
  ///
  /// In en, this message translates to:
  /// **'Popular services'**
  String get addChoosePreset;

  /// No description provided for @addChoosePresetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a service to fill in the details automatically.'**
  String get addChoosePresetSubtitle;

  /// No description provided for @addCustomService.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get addCustomService;

  /// No description provided for @addSearchServices.
  ///
  /// In en, this message translates to:
  /// **'Search services'**
  String get addSearchServices;

  /// No description provided for @addDetailsSection.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get addDetailsSection;

  /// No description provided for @addReminderSection.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get addReminderSection;

  /// No description provided for @fieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get fieldName;

  /// No description provided for @fieldPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get fieldPrice;

  /// No description provided for @fieldCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get fieldCurrency;

  /// No description provided for @fieldCycle.
  ///
  /// In en, this message translates to:
  /// **'Billing cycle'**
  String get fieldCycle;

  /// No description provided for @fieldFirstPayment.
  ///
  /// In en, this message translates to:
  /// **'First payment'**
  String get fieldFirstPayment;

  /// No description provided for @fieldCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get fieldCategory;

  /// No description provided for @fieldNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get fieldNotes;

  /// No description provided for @fieldEndDate.
  ///
  /// In en, this message translates to:
  /// **'Ends on (optional)'**
  String get fieldEndDate;

  /// No description provided for @reminderEnabled.
  ///
  /// In en, this message translates to:
  /// **'Remind me before payment'**
  String get reminderEnabled;

  /// No description provided for @reminderDaysBefore.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{On the payment day} =1{1 day before} other{{count} days before}}'**
  String reminderDaysBefore(int count);

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get reminderTime;

  /// No description provided for @validationNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get validationNameRequired;

  /// No description provided for @validationPriceRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a price'**
  String get validationPriceRequired;

  /// No description provided for @validationPriceInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount greater than zero'**
  String get validationPriceInvalid;

  /// No description provided for @detailNextPayment.
  ///
  /// In en, this message translates to:
  /// **'Next payment'**
  String get detailNextPayment;

  /// No description provided for @detailLastPayment.
  ///
  /// In en, this message translates to:
  /// **'Last payment'**
  String get detailLastPayment;

  /// No description provided for @detailCostPerMonth.
  ///
  /// In en, this message translates to:
  /// **'Cost per month'**
  String get detailCostPerMonth;

  /// No description provided for @detailCostPerYear.
  ///
  /// In en, this message translates to:
  /// **'Cost per year'**
  String get detailCostPerYear;

  /// No description provided for @detailNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get detailNotes;

  /// No description provided for @detailStarted.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get detailStarted;

  /// No description provided for @detailNeverBilled.
  ///
  /// In en, this message translates to:
  /// **'Not billed yet'**
  String get detailNeverBilled;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete subscription?'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'{name} will be removed permanently. This cannot be undone.'**
  String deleteConfirmMessage(String name);

  /// No description provided for @deletedSnack.
  ///
  /// In en, this message translates to:
  /// **'{name} deleted'**
  String deletedSnack(String name);

  /// No description provided for @savedSnack.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedSnack;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statsTitle;

  /// No description provided for @statsByCategory.
  ///
  /// In en, this message translates to:
  /// **'Spending by category'**
  String get statsByCategory;

  /// No description provided for @statsMonthlyTrend.
  ///
  /// In en, this message translates to:
  /// **'Last 6 months'**
  String get statsMonthlyTrend;

  /// No description provided for @statsTotalMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly total'**
  String get statsTotalMonthly;

  /// No description provided for @statsTotalYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly total'**
  String get statsTotalYearly;

  /// No description provided for @statsAveragePerService.
  ///
  /// In en, this message translates to:
  /// **'Average per service'**
  String get statsAveragePerService;

  /// No description provided for @statsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Add a subscription to see your spending breakdown.'**
  String get statsEmpty;

  /// No description provided for @statsMostExpensive.
  ///
  /// In en, this message translates to:
  /// **'Most expensive'**
  String get statsMostExpensive;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsCurrency.
  ///
  /// In en, this message translates to:
  /// **'Default currency'**
  String get settingsCurrency;

  /// No description provided for @settingsCurrencyHelp.
  ///
  /// In en, this message translates to:
  /// **'New subscriptions start in this currency. Home and Statistics totals are shown in it; subscriptions in other currencies are listed on their own.'**
  String get settingsCurrencyHelp;

  /// Confirmation shown after the default currency is changed
  ///
  /// In en, this message translates to:
  /// **'Totals now shown in {code}'**
  String settingsCurrencyChanged(String code);

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Payment reminders'**
  String get settingsNotificationsEnabled;

  /// No description provided for @settingsNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get notified before a subscription renews'**
  String get settingsNotificationsSubtitle;

  /// No description provided for @settingsNotificationsBlocked.
  ///
  /// In en, this message translates to:
  /// **'Notifications are turned off in system settings.'**
  String get settingsNotificationsBlocked;

  /// No description provided for @settingsData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsData;

  /// No description provided for @settingsEraseAll.
  ///
  /// In en, this message translates to:
  /// **'Erase all data'**
  String get settingsEraseAll;

  /// No description provided for @settingsEraseConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete every subscription? This cannot be undone.'**
  String get settingsEraseConfirm;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Every subscription in one place'**
  String get onboardingTitle1;

  /// No description provided for @onboardingBody1.
  ///
  /// In en, this message translates to:
  /// **'Add what you pay for and see the real monthly and yearly cost at a glance.'**
  String get onboardingBody1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Never miss a renewal'**
  String get onboardingTitle2;

  /// No description provided for @onboardingBody2.
  ///
  /// In en, this message translates to:
  /// **'Get a reminder before each charge, so a free trial never turns into a surprise.'**
  String get onboardingBody2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Know where the money goes'**
  String get onboardingTitle3;

  /// No description provided for @onboardingBody3.
  ///
  /// In en, this message translates to:
  /// **'Category breakdowns and monthly trends show exactly what is adding up.'**
  String get onboardingBody3;

  /// No description provided for @onboardingConsentTitle.
  ///
  /// In en, this message translates to:
  /// **'Before you start'**
  String get onboardingConsentTitle;

  /// No description provided for @onboardingConsentIntro.
  ///
  /// In en, this message translates to:
  /// **'Two quick things, then you are ready.'**
  String get onboardingConsentIntro;

  /// No description provided for @onboardingPrivacyLabel.
  ///
  /// In en, this message translates to:
  /// **'I agree to how my data is handled'**
  String get onboardingPrivacyLabel;

  /// No description provided for @onboardingPrivacyDetail.
  ///
  /// In en, this message translates to:
  /// **'Your subscriptions are stored only on this device. Nothing is uploaded, no account is required, and no analytics are collected. Brand logos are fetched from Google\'s favicon service, which receives only the service\'s domain name.'**
  String get onboardingPrivacyDetail;

  /// No description provided for @onboardingNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment reminders'**
  String get onboardingNotificationsTitle;

  /// No description provided for @onboardingNotificationsDetail.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications so we can remind you before a subscription renews. You can change this later in Settings.'**
  String get onboardingNotificationsDetail;

  /// No description provided for @onboardingAllowNotifications.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get onboardingAllowNotifications;

  /// No description provided for @onboardingNotificationsGranted.
  ///
  /// In en, this message translates to:
  /// **'Notifications enabled'**
  String get onboardingNotificationsGranted;

  /// No description provided for @onboardingNotificationsSkipped.
  ///
  /// In en, this message translates to:
  /// **'Continue without reminders'**
  String get onboardingNotificationsSkipped;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingStart;

  /// No description provided for @onboardingConsentRequired.
  ///
  /// In en, this message translates to:
  /// **'Please accept the data notice to continue.'**
  String get onboardingConsentRequired;

  /// No description provided for @statsViewCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get statsViewCategories;

  /// No description provided for @statsViewTrend.
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get statsViewTrend;

  /// No description provided for @settingsSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact & support'**
  String get settingsSupport;

  /// No description provided for @settingsSupportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Report a problem or send a suggestion'**
  String get settingsSupportSubtitle;

  /// No description provided for @settingsSupportUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No email app found. Write to {email}'**
  String settingsSupportUnavailable(String email);

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyTitle;

  /// No description provided for @privacyUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: 13 August 2026'**
  String get privacyUpdated;

  /// No description provided for @privacyIntro.
  ///
  /// In en, this message translates to:
  /// **'Subscription Hunter is built to work without an account and without sending your data anywhere. This page explains exactly what the app stores, what leaves your device, and what it does not do.'**
  String get privacyIntro;

  /// No description provided for @privacyStorageTitle.
  ///
  /// In en, this message translates to:
  /// **'What the app stores'**
  String get privacyStorageTitle;

  /// No description provided for @privacyStorageBody.
  ///
  /// In en, this message translates to:
  /// **'Everything you enter - subscription names, prices, billing dates, categories, notes and reminder settings - is written to a database file inside the app\'s private storage on your device. There is no account, no sign-in and no cloud sync. We never receive a copy.'**
  String get privacyStorageBody;

  /// No description provided for @privacyNetworkTitle.
  ///
  /// In en, this message translates to:
  /// **'What leaves your device'**
  String get privacyNetworkTitle;

  /// No description provided for @privacyNetworkBody.
  ///
  /// In en, this message translates to:
  /// **'One thing only: to show a brand logo, the app asks Google\'s favicon service for the icon of a public website, for example netflix.com. That request contains the service\'s domain name and nothing else - no subscription prices, no personal data, and no identifier for you or your device. Offline, the app draws a coloured tile instead and works normally.'**
  String get privacyNetworkBody;

  /// No description provided for @privacyNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get privacyNotificationsTitle;

  /// No description provided for @privacyNotificationsBody.
  ///
  /// In en, this message translates to:
  /// **'Payment reminders are scheduled by your device\'s own alarm system. They are generated locally from the data you entered and never pass through a server.'**
  String get privacyNotificationsBody;

  /// No description provided for @privacySupportTitle.
  ///
  /// In en, this message translates to:
  /// **'If you contact support'**
  String get privacySupportTitle;

  /// No description provided for @privacySupportBody.
  ///
  /// In en, this message translates to:
  /// **'The support option opens your own email app with a message you can read and edit before sending. It is pre-filled with the app version and your Android version so a problem can be reproduced. If you send it, we receive your email address and what you wrote, and use them only to answer you.'**
  String get privacySupportBody;

  /// No description provided for @privacyNoTrackingTitle.
  ///
  /// In en, this message translates to:
  /// **'What the app does not do'**
  String get privacyNoTrackingTitle;

  /// No description provided for @privacyNoTrackingBody.
  ///
  /// In en, this message translates to:
  /// **'No analytics, no advertising, no tracking or profiling, no third-party marketing SDKs, and no selling or sharing of data. There is nothing to sell - the data never reaches us.'**
  String get privacyNoTrackingBody;

  /// No description provided for @privacyControlTitle.
  ///
  /// In en, this message translates to:
  /// **'Your control over your data'**
  String get privacyControlTitle;

  /// No description provided for @privacyControlBody.
  ///
  /// In en, this message translates to:
  /// **'You can delete everything at any time from Settings, using Erase all data. Uninstalling the app also removes its database and settings from your device permanently. Because no copy exists anywhere else, deletion is immediate and final.'**
  String get privacyControlBody;

  /// No description provided for @privacyChildrenTitle.
  ///
  /// In en, this message translates to:
  /// **'Children'**
  String get privacyChildrenTitle;

  /// No description provided for @privacyChildrenBody.
  ///
  /// In en, this message translates to:
  /// **'The app is a general-purpose budgeting tool, is not directed at children under 13, and no data is knowingly collected from them.'**
  String get privacyChildrenBody;

  /// No description provided for @privacyContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get privacyContactTitle;

  /// No description provided for @privacyContactBody.
  ///
  /// In en, this message translates to:
  /// **'Questions about this policy can be sent to {email}.'**
  String privacyContactBody(String email);

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacy;

  /// No description provided for @settingsPrivacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'What is stored and what leaves your device'**
  String get settingsPrivacySubtitle;

  /// No description provided for @privacyViewOnline.
  ///
  /// In en, this message translates to:
  /// **'View online'**
  String get privacyViewOnline;

  /// No description provided for @categoryStreaming.
  ///
  /// In en, this message translates to:
  /// **'Streaming'**
  String get categoryStreaming;

  /// No description provided for @categoryMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get categoryMusic;

  /// No description provided for @categoryGaming.
  ///
  /// In en, this message translates to:
  /// **'Gaming'**
  String get categoryGaming;

  /// No description provided for @categorySoftware.
  ///
  /// In en, this message translates to:
  /// **'Software'**
  String get categorySoftware;

  /// No description provided for @categoryAi.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get categoryAi;

  /// No description provided for @categoryCloud.
  ///
  /// In en, this message translates to:
  /// **'Cloud'**
  String get categoryCloud;

  /// No description provided for @categoryNews.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get categoryNews;

  /// No description provided for @categoryFitness.
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get categoryFitness;

  /// No description provided for @categoryEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get categoryEducation;

  /// No description provided for @categoryShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get categoryShopping;

  /// No description provided for @categoryFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get categoryFinance;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @notificationTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} renews soon'**
  String notificationTitle(String name);

  /// No description provided for @notificationBodyToday.
  ///
  /// In en, this message translates to:
  /// **'{name} charges {amount} today.'**
  String notificationBodyToday(String name, String amount);

  /// No description provided for @notificationBodyUpcoming.
  ///
  /// In en, this message translates to:
  /// **'{name} charges {amount} on {date}.'**
  String notificationBodyUpcoming(String name, String amount, String date);

  /// No description provided for @notificationChannelName.
  ///
  /// In en, this message translates to:
  /// **'Payment reminders'**
  String get notificationChannelName;

  /// No description provided for @notificationChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Reminders before a subscription renews'**
  String get notificationChannelDescription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
