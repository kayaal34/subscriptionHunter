import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../features/subscriptions/domain/billing_calculator.dart';
import '../../features/subscriptions/domain/subscription.dart';

/// Text for one scheduled reminder, resolved by the caller so this service
/// stays free of localisation concerns.
class ReminderText {
  const ReminderText({required this.title, required this.body});

  final String title;
  final String body;
}

/// Schedules local "your subscription renews soon" reminders.
///
/// Android specifics that matter here:
/// * `POST_NOTIFICATIONS` only exists on API 33+. On the API 29 test device the
///   request is a no-op and notifications are allowed by default.
/// * Exact alarms need permission only on API 31+. The service asks for exact
///   delivery and silently degrades to an inexact alarm when denied, rather
///   than throwing and losing the reminder entirely.
class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  static const String _channelId = 'subscription_reminders';

  /// How many future charges to pre-schedule per subscription.
  ///
  /// One would be lost the moment it fires if the user never reopens the app.
  /// Three covers roughly a quarter of monthly plans without approaching
  /// Android's ~500 pending-alarm ceiling.
  static const int _occurrencesAhead = 3;

  bool _initialised = false;

  /// True when exact alarms were refused, so the UI can explain that reminders
  /// may arrive a little late.
  bool exactAlarmsDenied = false;

  Future<void> init({
    required String channelName,
    required String channelDescription,
  }) async {
    if (_initialised) return;

    tz_data.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } on Object catch (error) {
      // A missing or unrecognised zone must not stop the app from starting;
      // UTC just means reminders land at the wrong local hour.
      debugPrint('Falling back to UTC, could not resolve timezone: $error');
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(
      AndroidNotificationChannel(
        _channelId,
        channelName,
        description: channelDescription,
        importance: Importance.high,
      ),
    );

    _initialised = true;
  }

  /// Asks for the permissions this Android version actually requires.
  /// Returns whether notifications may be posted at all.
  Future<bool> requestPermissions() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return false;

    // No-op below API 33; returns true there.
    final granted = await android.requestNotificationsPermission() ?? false;

    // No-op below API 31. Denial is recoverable, so it is recorded rather
    // than treated as failure.
    try {
      final exact = await android.requestExactAlarmsPermission() ?? false;
      exactAlarmsDenied = !exact;
    } on PlatformException catch (error) {
      debugPrint('Exact alarm permission unavailable: ${error.code}');
      exactAlarmsDenied = true;
    }

    return granted;
  }

  Future<bool> areNotificationsEnabled() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await android?.areNotificationsEnabled() ?? false;
  }

  /// Rebuilds the entire schedule from scratch.
  ///
  /// Cheaper to reason about than incremental updates: any add, edit, delete
  /// or settings change just calls this, so the scheduled set can never drift
  /// out of sync with the database.
  Future<void> rescheduleAll({
    required List<Subscription> subscriptions,
    required ReminderText Function(Subscription, DateTime charge) textFor,
    required bool notificationsEnabled,
    DateTime? now,
  }) async {
    await _plugin.cancelAll();
    if (!notificationsEnabled) return;

    final reference = now ?? DateTime.now();
    for (final subscription in subscriptions) {
      if (!subscription.isActiveOn(reference) ||
          !subscription.reminderEnabled) {
        continue;
      }
      await _scheduleFor(subscription, reference, textFor);
    }
  }

  Future<void> _scheduleFor(
    Subscription subscription,
    DateTime now,
    ReminderText Function(Subscription, DateTime charge) textFor,
  ) async {
    var cursor = now;

    for (var i = 0; i < _occurrencesAhead; i++) {
      final charge = BillingCalculator.nextBillingDate(
        anchor: subscription.anchorDate,
        cycle: subscription.billingCycle,
        from: cursor,
      );

      // Stop once the subscription's own end date is passed.
      if (subscription.endDate != null &&
          charge.isAfter(BillingCalculator.dateOnly(subscription.endDate!))) {
        return;
      }

      final fireAt = _reminderInstant(subscription, charge);
      // The first reminder can already be in the past (e.g. it is 18:00 and
      // the reminder time is 10:00 today). Skip it and keep the later ones.
      if (fireAt.isAfter(tz.TZDateTime.now(tz.local))) {
        await _schedule(
          id: _notificationIdFor(subscription, i),
          when: fireAt,
          text: textFor(subscription, charge),
          payload: subscription.id,
        );
      }

      cursor = charge.add(const Duration(days: 1));
    }
  }

  tz.TZDateTime _reminderInstant(Subscription subscription, DateTime charge) {
    final remindOn = charge.subtract(
      Duration(days: subscription.reminderDaysBefore),
    );
    return tz.TZDateTime(
      tz.local,
      remindOn.year,
      remindOn.month,
      remindOn.day,
      subscription.reminderHour,
      subscription.reminderMinute,
    );
  }

  /// Distinct id per subscription *and* per pre-scheduled occurrence.
  ///
  /// The occurrence index lives in the high bits so occurrences of the same
  /// subscription can never overwrite one another.
  int _notificationIdFor(Subscription subscription, int occurrence) =>
      (occurrence << 29) | (subscription.id.hashCode & 0x1FFFFFFF);

  Future<void> _schedule({
    required int id,
    required tz.TZDateTime when,
    required ReminderText text,
    required String payload,
  }) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        'Payment reminders',
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(text.body),
      ),
    );

    try {
      await _plugin.zonedSchedule(
        id: id,
        title: text.title,
        body: text.body,
        scheduledDate: when,
        notificationDetails: details,
        androidScheduleMode: exactAlarmsDenied
            ? AndroidScheduleMode.inexactAllowWhileIdle
            : AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
    } on PlatformException catch (error) {
      // Android 13+ can revoke exact-alarm permission at any time, including
      // between the permission check and this call. Retry inexact instead of
      // dropping the reminder.
      if (error.code == 'exact_alarms_not_permitted') {
        exactAlarmsDenied = true;
        await _plugin.zonedSchedule(
          id: id,
          title: text.title,
          body: text.body,
          scheduledDate: when,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: payload,
        );
      } else {
        rethrow;
      }
    }
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  @visibleForTesting
  Future<List<PendingNotificationRequest>> pending() =>
      _plugin.pendingNotificationRequests();
}
