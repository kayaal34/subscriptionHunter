import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../features/subscriptions/domain/subscription.dart';
import '../../features/subscriptions/presentation/providers/subscription_providers.dart';
import '../../l10n/generated/app_localizations.dart';
import '../extensions/context_extensions.dart';
import '../providers/settings_providers.dart';
import '../utils/money_formatter.dart';
import 'notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(),
);

/// Keeps the scheduled reminders in sync with the database and the user's
/// settings.
///
/// Mounted inside `MaterialApp.builder` so it sits below `Localizations` and
/// can build reminder text in the active language. Re-running on every data
/// change means a rename, a price edit or a language switch all reschedule
/// with the correct content.
class NotificationCoordinator extends ConsumerStatefulWidget {
  const NotificationCoordinator({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<NotificationCoordinator> createState() =>
      _NotificationCoordinatorState();
}

class _NotificationCoordinatorState
    extends ConsumerState<NotificationCoordinator> {
  bool _initialised = false;

  late final ProviderSubscription<AsyncValue<List<Subscription>>>
  _subscriptionsSub;
  late final ProviderSubscription<bool> _notificationsEnabledSub;

  @override
  void initState() {
    super.initState();

    // listenManual here, deliberately not ref.listen inside build().
    //
    // This widget sits above every page, so it is the first thing to touch
    // subscriptionsProvider. Creating a StreamProvider during the build phase
    // makes Riverpod schedule a refresh while the framework is still
    // building, which throws "setState() called during build" on first launch.
    // Subscribing from initState creates the provider outside the build phase.
    _subscriptionsSub = ref.listenManual(
      subscriptionsProvider,
      (_, _) => _reschedule(),
    );
    _notificationsEnabledSub = ref.listenManual(
      settingsProvider.select((s) => s.notificationsEnabled),
      (_, _) => _reschedule(),
    );

    // Deferred: permission prompts and plugin setup must not run during the
    // first build.
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    _subscriptionsSub.close();
    _notificationsEnabledSub.close();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    if (!mounted) return;
    final l10n = context.l10n;
    final service = ref.read(notificationServiceProvider);

    await service.init(
      channelName: l10n.notificationChannelName,
      channelDescription: l10n.notificationChannelDescription,
    );
    await service.requestPermissions();

    _initialised = true;
    await _reschedule();
  }

  Future<void> _reschedule() async {
    if (!_initialised || !mounted) return;

    final settings = ref.read(settingsProvider);
    final subscriptions = ref.read(activeSubscriptionsProvider);
    final l10n = context.l10n;
    final localeName = context.localeName;
    final now = ref.read(nowProvider)();

    await ref
        .read(notificationServiceProvider)
        .rescheduleAll(
          subscriptions: subscriptions,
          notificationsEnabled: settings.notificationsEnabled,
          now: now,
          textFor: (subscription, charge) => _textFor(
            subscription: subscription,
            charge: charge,
            l10n: l10n,
            localeName: localeName,
            now: now,
          ),
        );
  }

  ReminderText _textFor({
    required Subscription subscription,
    required DateTime charge,
    required AppLocalizations l10n,
    required String localeName,
    required DateTime now,
  }) {
    final amount = MoneyFormatter.format(
      amount: subscription.price,
      currencyCode: subscription.currencyCode,
      localeName: localeName,
    );
    final isToday =
        subscription.reminderDaysBefore == 0 ||
        DateUtils.isSameDay(charge, now);

    return ReminderText(
      title: l10n.notificationTitle(subscription.name),
      body: isToday
          ? l10n.notificationBodyToday(subscription.name, amount)
          : l10n.notificationBodyUpcoming(
              subscription.name,
              amount,
              DateFormat.yMMMd(localeName).format(charge),
            ),
    );
  }

  // The subscriptions above drive rescheduling; this widget only passes the
  // app through.
  @override
  Widget build(BuildContext context) => widget.child;
}
