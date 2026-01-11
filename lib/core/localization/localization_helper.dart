import 'package:subscription_tracker/presentation/providers/theme_provider.dart';
import 'package:subscription_tracker/core/localization/strings.dart';

/// Localization Helper
/// Provides easy access to localized strings based on current language
class LocalizationHelper {
  LocalizationHelper(this.language);

  final AppLanguage language;

  /// Get a localized string by key
  String get(String key) => getString(key, language);

  // Common
  String get cancel => get('cancel');
  String get save => get('save');
  String get delete => get('delete');
  String get edit => get('edit');
  String get search => get('search');

  // Home Page
  String get home => get('home');
  String get upcoming => get('upcoming');
  String get statistics => get('statistics');
  String get settings => get('settings');
  String get totalMonthly => get('totalMonthly');
  String get totalAnnual => get('totalAnnual');

  // Add Subscription
  String get addSubscription => get('addSubscription');
  String get subscriptionName => get('subscriptionName');
  String get billingDay => get('billingDay');
  String get cost => get('cost');
  String get currency => get('currency');
  String get category => get('category');
  String get startDate => get('startDate');
  String get billingCycle => get('billingCycle');
  String get monthly => get('monthly');
  String get yearly => get('yearly');
  String get exampleName => get('exampleName');
  String get exampleCost => get('exampleCost');

  // Notifications
  String get notifications => get('notifications');
  String get notificationHour => get('notificationHour');
  String get enableNotifications => get('enableNotifications');
  String get notificationTime => get('notificationTime');

  // Dates
  String get today => get('today');
  String get tomorrow => get('tomorrow');
  String get daysFromNow => get('daysFromNow');

  // Stats
  String get monthlySpending => get('monthlySpending');
  String get annualSpending => get('annualSpending');
  String get spendingByCategory => get('spendingByCategory');
  String get mostExpensive => get('mostExpensive');
  String get cheapest => get('cheapest');

  // Settings
  String get darkMode => get('darkMode');
  String get appLanguage => get('language');
  String get about => get('about');
  String get contact => get('contact');
  String get contactEmail => get('contactEmail');

  // Messages
  String get deleteConfirm => get('deleteConfirm');
  String get noSubscriptions => get('noSubscriptions');
  String get addFirst => get('addFirst');

  // Extra
  String get deleteAccount => get('deleteAccount');
  String get sortBy => get('sortBy');
  String get notificationSettings => get('notificationSettings');
  String get notificationDaysBefore => get('notificationDaysBefore');
}
