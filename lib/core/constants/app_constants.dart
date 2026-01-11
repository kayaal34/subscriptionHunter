class AppConstants {
  static const String appName = 'Subscription Tracker';
  static const String appVersion = '1.0.0';

  // Billing cycle days
  static const List<int> billingDays = [
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
    11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
    21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31,
  ];

  // Warning threshold (days)
  static const int warningThresholdDays = 3;

  // Notification time
  static const int notificationHour = 10;
  static const int notificationMinute = 0;
}
