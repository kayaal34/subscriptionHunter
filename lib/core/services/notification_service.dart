import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Required for Color
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz_time;
import 'package:logger/logger.dart';
import 'notification_service_web.dart' if (dart.library.io) 'notification_service_stub.dart';
import 'hive_encryption_service.dart';

class NotificationService {

  NotificationService({
    FlutterLocalNotificationsPlugin? notificationsPlugin,
    Logger? logger,
  })  : _notificationsPlugin = notificationsPlugin ?? FlutterLocalNotificationsPlugin(),
        _logger = logger ?? Logger();
  static const String channelId = 'subscription_reminders';
  static const String channelName = 'Subscription Reminders';
  
  /// Sanitize string to be UTF-16 compatible
  String _sanitizeForUtf16(String input) {
    try {
      // Remove non-BMP characters (emojis, special unicode)
      final sanitized = input.runes
          .where((rune) => rune < 0x10000) // Keep only BMP characters
          .map(String.fromCharCode)
          .join();
      return sanitized.isEmpty ? input.replaceAll(RegExp(r'[^\x20-\x7E\u00A0-\uFFFF]'), '') : sanitized;
    } catch (e) {
      _logger.w('Failed to sanitize string, using fallback: $e');
      return input.replaceAll(RegExp(r'[^\x20-\x7E\u00A0-\uFFFF]'), '');
    }
  }

  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  final Logger _logger;

  /// Check and request exact alarm permission (Android 12+)
  Future<bool> checkExactAlarmPermission() async {
    if (kIsWeb) return true;
    
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final status = await Permission.scheduleExactAlarm.status;
        
        if (status.isDenied || !status.isGranted) {
          _logger.w('🔴 Exact alarm permission NOT granted - status: $status');
          // Open settings for user to grant permission
          await Permission.scheduleExactAlarm.request();
          
          // Check again after request
          final newStatus = await Permission.scheduleExactAlarm.status;
          if (!newStatus.isGranted) {
            _logger.e('❌ EXACT ALARM STILL NOT GRANTED - Opening settings');
            await openAppSettings();
            return false;
          }
          _logger.i('✅ Exact alarm permission NOW granted after request');
          return true;
        }
        
        _logger.i('✅ Exact alarm permission already granted');
        return true;
      }
      return true;
    } catch (e) {
      _logger.e('❌ Failed to check exact alarm permission', error: e);
      return false; // Return false on error to alert user
    }
  }
  
  /// Diagnostic function to check all permissions and settings
  Future<Map<String, dynamic>> getDiagnosticInfo() async {
    final Map<String, dynamic> info = {};
    
    try {
      // Notification permission
      if (defaultTargetPlatform == TargetPlatform.android) {
        final notifStatus = await Permission.notification.status;
        info['notification_permission'] = notifStatus.isGranted;
        info['notification_status'] = notifStatus.toString();
        
        // Exact alarm permission (critical for scheduled notifications)
        final alarmStatus = await Permission.scheduleExactAlarm.status;
        info['exact_alarm_permission'] = alarmStatus.isGranted;
        info['exact_alarm_status'] = alarmStatus.toString();
        
        // Battery optimization (critical for Doze Mode bypass)
        final batteryStatus = await Permission.ignoreBatteryOptimizations.status;
        info['battery_exemption'] = batteryStatus.isGranted;
        info['battery_status'] = batteryStatus.toString();
        
        // Samsung-specific debug info
        info['android_api_level'] = 'Android 12+ (Requires SCHEDULE_EXACT_ALARM)';
        info['doze_mode_bypass'] = 'Using AndroidScheduleMode.exactAllowWhileIdle + fullScreenIntent';
      } else {
        info['platform'] = 'iOS or other';
        info['notification_permission'] = true;
        info['exact_alarm_permission'] = true;
        info['battery_exemption'] = true;
      }
      
      // Pending notifications count with detailed info
      final pending = await _notificationsPlugin.pendingNotificationRequests();
      info['pending_notifications_count'] = pending.length;
      info['pending_notifications'] = pending.map((p) => {
        'id': p.id,
        'title': p.title,
        'body': p.body,
        'payload': p.payload,
      }).toList();
      
      // Timezone and time info
      info['timezone'] = tz_time.local.name;
      info['timezone_offset'] = DateTime.now().timeZoneOffset.toString();
      info['current_time'] = DateTime.now().toString();
      info['tz_current_time'] = tz_time.TZDateTime.now(tz_time.local).toString();
      info['utc_time'] = DateTime.now().toUtc().toString();
      
      // Channel configuration
      info['notification_channel_id'] = channelId;
      info['notification_channel_name'] = channelName;
      info['channel_importance'] = 'Importance.max (Highest)';
      info['channel_visibility'] = 'NotificationVisibility.public (Shows on lock screen)';
      info['fullScreenIntent_enabled'] = 'true (Forces display even in Doze Mode)';
      
      _logger.i('📊 Diagnostic Info: $info');
      return info;
    } catch (e, stack) {
      _logger.e('❌ Failed to get diagnostic info', error: e, stackTrace: stack);
      info['error'] = e.toString();
      return info;
    }
  }
  
  /// Initialize notification service
  Future<void> initialize() async {
    // Notifications are not supported on web; bail out to prevent runtime errors.
    if (kIsWeb) return;
    try {
      // CRITICAL: Initialize timezone data and set local location FIRST
      try {
        tz.initializeTimeZones();
        
        // Get device's actual timezone (e.g., 'Europe/Istanbul', 'Asia/Yekaterinburg')
        final String timezoneName = await FlutterTimezone.getLocalTimezone();
        tz_time.setLocalLocation(tz_time.getLocation(timezoneName));
        
        _logger.i('✅ Timezone set to LOCAL: $timezoneName');
        _logger.i('✅ Current local time: ${tz_time.TZDateTime.now(tz_time.local)}');
        _logger.i('✅ UTC time: ${DateTime.now().toUtc()}');
      } catch (e) {
        _logger.e('⚠️ Could not get local timezone, using UTC', error: e);
        tz_time.setLocalLocation(tz_time.getLocation('UTC'));
      }
      
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

      // Create Android channel with ULTRA-AGGRESSIVE settings for Samsung Doze Mode bypass
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        channelId,
        channelName,
        description: 'Notifications for subscription billing reminders',
        importance: Importance.max, // Highest priority
        enableVibration: true,
        playSound: true,
        showBadge: true,
        enableLights: true, // Visual indicator
        // Note: ledColor and visibility are set per-notification in NotificationDetails
      );

      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      _logger.i('✅ Notification service initialized successfully');
    } catch (e) {
      _logger.e('❌ Failed to initialize notification service', error: e);
    }
  }

  /// Check if notification permission was already requested
  Future<bool> _wasPermissionAlreadyRequested() async {
    try {
      final appSettings = await openEncryptedBox('app_settings');
      return appSettings.get('notificationPermissionRequested', defaultValue: false) as bool;
    } catch (e) {
      _logger.e('Failed to check permission flag', error: e);
      return false;
    }
  }
  
  /// Mark notification permission as requested
  Future<void> _markPermissionAsRequested() async {
    try {
      final appSettings = await openEncryptedBox('app_settings');
      await appSettings.put('notificationPermissionRequested', true);
    } catch (e) {
      _logger.e('Failed to set permission flag', error: e);
    }
  }

  /// Request battery optimization exemption (Samsung compatibility)
  Future<bool> requestBatteryOptimizationExemption() async {
    if (defaultTargetPlatform != TargetPlatform.android) return true;
    
    try {
      final status = await Permission.ignoreBatteryOptimizations.status;
      
      if (status.isGranted) {
        _logger.i('💡 ✅ Battery optimization already disabled');
        return true;
      }
      
      _logger.i('💡 🔋 Requesting battery optimization exemption...');
      final result = await Permission.ignoreBatteryOptimizations.request();
      
      if (result.isGranted) {
        _logger.i('💡 ✅ Battery optimization exemption granted');
        return true;
      } else {
        _logger.w('💡 ⚠️ Battery optimization exemption denied');
        return false;
      }
    } catch (e, stack) {
      _logger.e('💡 ❌ Failed to request battery optimization exemption', error: e, stackTrace: stack);
      return false;
    }
  }

  /// Request notification permissions from the user (with one-time check)
  Future<bool> requestNotificationPermission({bool forceRequest = false}) async {
    try {
      // Check if permission was already requested (unless forced)
      if (!forceRequest) {
        final alreadyRequested = await _wasPermissionAlreadyRequested();
        if (alreadyRequested) {
          _logger.i('Permission already requested, checking current status');
          // Check current permission status without requesting again
          if (defaultTargetPlatform == TargetPlatform.android) {
            final status = await Permission.notification.status;
            return status.isGranted;
          }
          return true;
        }
      }
      
      if (kIsWeb) {
        // Request web notification permission
        final granted = await requestWebNotificationPermission();
        _logger.i('Web notification permission: $granted');
        await _markPermissionAsRequested();
        return granted;
      }
      
      // Android 13+ (API 33+) requires runtime permission
      if (defaultTargetPlatform == TargetPlatform.android) {
        final status = await Permission.notification.request();
        await _markPermissionAsRequested();
        
        if (status.isDenied) {
          _logger.w('Notification permission denied');
          return false;
        }
        if (status.isPermanentlyDenied) {
          _logger.w('Notification permission permanently denied');
          // Optionally open app settings
          await openAppSettings();
          return false;
        }
        _logger.i('Android notification permission granted');
        return status.isGranted;
      }
      
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
        _logger.i('iOS notification permission: $granted');
        return granted ?? false;
      }
      
      _logger.i('Notification permissions requested');
      return true;
    } catch (e) {
      _logger.e('Failed to request notification permission', error: e);
      return false;
    }
  }

  /// Send an immediate test notification
  Future<void> showTestNotification() async {
    if (kIsWeb) {
      _logger.i('Test notifications not supported on web');
      return;
    }
    
    try {
      // Check exact alarm permission
      await checkExactAlarmPermission();
      
      // Simple ASCII-only content for compatibility
      const title = 'Test Notification';
      const body = 'Notifications are working correctly!';
      
      const androidDetails = AndroidNotificationDetails(
        'subscription_reminders',
        'Subscription Reminders',
        channelDescription: 'Payment reminders for subscriptions',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        showWhen: true,
        ticker: 'Test notification',
        // Samsung-specific: Show on lock screen
        visibility: NotificationVisibility.public,
        category: AndroidNotificationCategory.message,
      );

      const notificationDetails = NotificationDetails(android: androidDetails);

      // First: Immediate notification
      await _notificationsPlugin.show(
        999999, // Test notification ID
        title,
        body,
        notificationDetails,
      );
      
      _logger.i('✅ Test notification sent successfully');
      
      // Second: Scheduled notification in 5 seconds to test zonedSchedule
      _logger.i('🕐 Scheduling test notification for 5 seconds from now...');
      final now = tz_time.TZDateTime.now(tz_time.local);
      final scheduledTime = now.add(const Duration(seconds: 5));
      
      await _notificationsPlugin.zonedSchedule(
        999998, // Scheduled test notification ID
        'Scheduled Test',
        'This should appear in 5 seconds!',
        scheduledTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
      
      _logger.i('🕐 Scheduled test notification for ${scheduledTime.toIso8601String()}');
    } catch (e, stack) {
      _logger.e('❌ Failed to send test notification', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Schedule notification with custom hour
  Future<void> scheduleSubscriptionReminder({
    required String subscriptionId,
    required String subscriptionTitle,
    required int billingDay,
    required int notificationHour,
    required int notificationMinute,
    required int notificationDaysBefore,
    required bool enabled,
  }) async {
    if (kIsWeb) return;
    try {
      // Cancel existing notification first
      await cancelNotification(subscriptionId);

      // Don't schedule if disabled
      if (!enabled) {
        _logger.i('❌ Notifications disabled for $subscriptionTitle');
        return;
      }
      
      // CRITICAL: Check exact alarm permission with debug output
      final hasPermission = await checkExactAlarmPermission();
      if (!hasPermission) {
        _logger.e('🚫 CRITICAL: Cannot schedule notification - Exact Alarm permission DENIED!');
        _logger.e('🚫 User MUST grant "Alarms and Reminders" permission in Settings');
        _logger.e('🚫 Path: Settings > Apps > subscription_tracker > Alarms & Reminders > Allow');
        return;
      }
      
      _logger.i('✅ Exact Alarm permission verified - proceeding with scheduling');

      // Use timezone-aware current time (ALWAYS use local timezone)
      final now = tz_time.TZDateTime.now(tz_time.local);
      
      _logger.i('🕐 Current LOCAL time: $now (${tz_time.local.name})');
      
      // Calculate next payment date
      int paymentMonth = now.month;
      int paymentYear = now.year;
      
      // If billing day has passed this month, schedule for next month
      if (now.day > billingDay) {
        paymentMonth++;
        if (paymentMonth > 12) {
          paymentMonth = 1;
          paymentYear++;
        }
      }
      
      // Create payment date IN LOCAL TIMEZONE
      final paymentDate = tz_time.TZDateTime(
        tz_time.local,
        paymentYear,
        paymentMonth,
        billingDay,
        12,
        0,
      );
      
      // Calculate reminder date (X days before payment)
      final reminderDate = paymentDate.subtract(Duration(days: notificationDaysBefore));
      
      // Set notification time IN LOCAL TIMEZONE
      var scheduledDateTime = tz_time.TZDateTime(
        tz_time.local,
        reminderDate.year,
        reminderDate.month,
        reminderDate.day,
        notificationHour,
        notificationMinute,
        0,
      );
      
      // CRITICAL GUARD: Prevent "is in the past" error
      if (scheduledDateTime.isBefore(now) || scheduledDateTime.isAtSameMomentAs(now)) {
        _logger.w('⚠️ Scheduled time ($scheduledDateTime) is in past or now!');
        _logger.w('⚠️ Moving to NOW + 10 seconds for immediate test/verification');
        scheduledDateTime = now.add(const Duration(seconds: 10));
        _logger.i('✅ New scheduled time: $scheduledDateTime');
      }
      
      // Calculate days until payment for dynamic message
      final daysUntilPayment = paymentDate.difference(scheduledDateTime).inDays;
      
      // Create dynamic notification content
      String notificationBody;
      if (daysUntilPayment == 0) {
        notificationBody = 'Bugun $subscriptionTitle odemeniz gerceklesecek!';
      } else if (daysUntilPayment == 1) {
        notificationBody = 'Odemenize az kaldi! Yarin $subscriptionTitle odemeniz gerceklesecek.';
      } else {
        notificationBody = 'Odemenize az kaldi! $daysUntilPayment gun sonra $subscriptionTitle odemeniz gerceklesecek.';
      }
      
      // Sanitize for UTF-16
      final title = _sanitizeForUtf16('Odeme Hatirlatici');
      final body = _sanitizeForUtf16(notificationBody);

      // Schedule with ULTRA-AGGRESSIVE Samsung Doze Mode bypass
      await _notificationsPlugin.zonedSchedule(
        subscriptionId.hashCode,
        title,
        body,
        scheduledDateTime, // Already TZDateTime in local timezone
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: 'Subscription payment reminders',
            importance: Importance.max, // Highest priority
            priority: Priority.high, // High priority flag
            enableVibration: true,
            enableLights: true,
            playSound: true,
            showWhen: true,
            when: scheduledDateTime.millisecondsSinceEpoch, // Explicit timestamp
            ticker: 'Subscription reminder',
            // CRITICAL for Samsung lock screen visibility
            visibility: NotificationVisibility.public, // Show full content on lock screen
            category: AndroidNotificationCategory.reminder, // Proper categorization
            // Samsung-specific: Full-screen intent for maximum visibility
            fullScreenIntent: true, // Forces notification to be shown even in Doze Mode
            channelShowBadge: true,
            autoCancel: false, // Don't auto-dismiss - user must manually clear
            ongoing: false, // Not persistent (ongoing = false allows swipe-dismiss)
            // Additional wake-up flags (Samsung compatibility)
            color: const Color.fromARGB(255, 33, 150, 243), // Blue color for notification
            ledColor: const Color.fromARGB(255, 33, 150, 243), // Blue LED (0xFF2196F3)
            ledOnMs: 1000,
            ledOffMs: 500,
            timeoutAfter: 3600000, // Timeout after 1 hour (in milliseconds)
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'default',
          ),
        ),
        // CRITICAL: Use exactAllowWhileIdle to bypass Doze Mode
        // This uses setExactAndAllowWhileIdle() internally on Android API 23+
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: null, // No recurring pattern
      );

      _logger.i('✅ Scheduled: $subscriptionTitle');
      _logger.i('   📅 Payment Date: ${paymentDate.toIso8601String()} (${tz_time.local.name})');
      _logger.i('   ⏰ Notification Time: ${scheduledDateTime.toIso8601String()} (${tz_time.local.name})');
      _logger.i('   📊 Days before payment: $notificationDaysBefore');
      _logger.i('   🕐 Notification will arrive at: ${scheduledDateTime.hour}:${scheduledDateTime.minute.toString().padLeft(2, "0")}');
    } catch (e, stack) {
      _logger.e('❌ Failed to schedule notification for $subscriptionTitle', error: e, stackTrace: stack);
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
      notificationDaysBefore: 1,
      enabled: true,
    );

  /// Cancel notification
  Future<void> cancelNotification(String subscriptionId) async {
    if (kIsWeb) return;
    try {
      await _notificationsPlugin.cancel(subscriptionId.hashCode);
      _logger.i('Cancelled notification for subscription: $subscriptionId');
    } catch (e) {
      _logger.e('Failed to cancel notification', error: e);
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    if (kIsWeb) return;
    try {
      await _notificationsPlugin.cancelAll();
      _logger.i('Cancelled all notifications');
    } catch (e) {
      _logger.e('Failed to cancel all notifications', error: e);
    }
  }

  /// Get pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (kIsWeb) return [];
    try {
      final pending = await _notificationsPlugin.pendingNotificationRequests();
      _logger.i('Pending notifications: ${pending.length}');
      for (final notif in pending) {
        _logger.i('  - ID: ${notif.id}, Title: ${notif.title}, Body: ${notif.body}');
      }
      return pending;
    } catch (e) {
      _logger.e('Failed to get pending notifications', error: e);
      return [];
    }
  }

  /// Handle notification tap
  void _handleNotificationResponse(NotificationResponse response) {
    _logger.i('Notification tapped: ${response.payload}');
  }

  /// Send a test notification immediately
  Future<void> sendTestNotification() async {
    try {
      if (kIsWeb) {
        // Web notification using browser API
        final now = DateTime.now();
        final time = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
        await sendWebNotification(
          'Test Bildirimi',
          'Bildirimler çalışıyor! $time',
        );
        _logger.i('Web test notification sent');
        return;
      }
      
      // Mobile/Desktop notification
      await _notificationsPlugin.show(
        999999,
        'Test Bildirimi',
        'Bildirimler çalışıyor! ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            importance: Importance.max,
            priority: Priority.max,
            enableVibration: true,
            showWhen: true,
            playSound: true,
            // Use default system notification sound
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'default',
          ),
        ),
      );
      _logger.i('Test notification sent');
    } catch (e) {
      _logger.e('Failed to send test notification', error: e);
    }
  }
}
