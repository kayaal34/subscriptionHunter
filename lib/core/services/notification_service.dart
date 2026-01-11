import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz_time;
import 'package:logger/logger.dart';

class NotificationService {

  NotificationService({
    FlutterLocalNotificationsPlugin? notificationsPlugin,
    Logger? logger,
  })  : _notificationsPlugin = notificationsPlugin ?? FlutterLocalNotificationsPlugin(),
        _logger = logger ?? Logger();
  static const String channelId = 'subscription_reminders';
  static const String channelName = 'Subscription Reminders';

  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  final Logger _logger;

  /// Initialize notification service
  Future<void> initialize() async {
    try {
      // Initialize timezone data
      tz.initializeTimeZones();
      
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

      const InitializationSettings initializationSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _handleNotificationResponse,
      );

      // Create Android channel with maximum importance for lock screen
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        channelId,
        channelName,
        description: 'Notifications for subscription billing reminders',
        importance: Importance.max,
        enableVibration: true,
        playSound: true,
        showBadge: true,
      );

      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      _logger.i('Notification service initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize notification service', error: e);
    }
  }

  /// Request notification permissions from the user
  Future<bool> requestNotificationPermission() async {
    try {
      // Request iOS permissions explicitly
      final IOSFlutterLocalNotificationsPlugin? iosPlugin =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      
      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
      
      // For Android, permissions are handled via AndroidManifest.xml and runtime permissions
      // flutter_local_notifications will automatically request POST_NOTIFICATIONS on Android 13+
      _logger.i('Notification permissions requested');
      return true;
    } catch (e) {
      _logger.e('Failed to request notification permission', error: e);
      return true; // Don't fail, as notification might still work
    }
  }

  /// Schedule notification with custom hour
  Future<void> scheduleSubscriptionReminder({
    required String subscriptionId,
    required String subscriptionTitle,
    required int billingDay,
    required int notificationHour,
    required int notificationMinute,
    required bool enabled,
  }) async {
    try {
      // Ensure timezone is initialized
      try {
        tz.initializeTimeZones();
      } catch (e) {
        // Timezone already initialized, ignore
      }

      // Cancel existing notification
      await cancelNotification(subscriptionId);

      // Don't schedule if disabled
      if (!enabled) {
        _logger.i('Notifications disabled for $subscriptionTitle');
        return;
      }

      final now = DateTime.now();
      final currentMonth = now.month;
      final currentYear = now.year;

      // Calculate the billing date
      int billingMonth = currentMonth;
      int billingYear = currentYear;

      if (now.day >= billingDay) {
        billingMonth = currentMonth + 1;
        if (billingMonth > 12) {
          billingMonth = 1;
          billingYear = currentYear + 1;
        }
      }

      // Schedule for billing day at specified hour
      final scheduledDate = DateTime(billingYear, billingMonth, billingDay);
      final scheduledTime = DateTime(
        billingYear,
        billingMonth,
        billingDay,
        notificationHour,
        notificationMinute,
        0,
      );

      // Only schedule if it's in the future
      if (scheduledTime.isAfter(now)) {
        // Get local timezone location
        final location = tz_time.getLocation('Europe/Istanbul');
        final tzScheduledTime = tz_time.TZDateTime.from(scheduledTime, location);

        await _notificationsPlugin.zonedSchedule(
          subscriptionId.hashCode,
          'Abonelik Ödemesi',
          '$subscriptionTitle ödemesi ${scheduledDate.day}/${scheduledDate.month} tarihinde yapılacak',
          tzScheduledTime,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              channelId,
              channelName,
              importance: Importance.max,
              priority: Priority.max,
              enableVibration: true,
              showWhen: true,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
        );

        _logger.i('Scheduled reminder for $subscriptionTitle on $scheduledTime');
      }
    } catch (e) {
      _logger.e('Failed to schedule notification', error: e);
    }
  }

  /// Schedule notification 1 day before billing date at 10:00 AM (deprecated - use scheduleSubscriptionReminder)
  Future<void> scheduleSubscriptionReminder_Deprecated({
    required String subscriptionId,
    required String subscriptionTitle,
    required int billingDay,
  }) async => scheduleSubscriptionReminder(
      subscriptionId: subscriptionId,
      subscriptionTitle: subscriptionTitle,
      billingDay: billingDay,
      notificationHour: 10,
      notificationMinute: 0,
      enabled: true,
    );

  /// Cancel notification
  Future<void> cancelNotification(String subscriptionId) async {
    try {
      await _notificationsPlugin.cancel(subscriptionId.hashCode);
      _logger.i('Cancelled notification for subscription: $subscriptionId');
    } catch (e) {
      _logger.e('Failed to cancel notification', error: e);
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
      _logger.i('Cancelled all notifications');
    } catch (e) {
      _logger.e('Failed to cancel all notifications', error: e);
    }
  }

  /// Handle notification tap
  void _handleNotificationResponse(NotificationResponse response) {
    _logger.i('Notification tapped: ${response.payload}');
  }
}
