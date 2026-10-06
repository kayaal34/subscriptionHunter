import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/providers/settings_providers.dart';
import '../../../../core/utils/money_formatter.dart';
import '../providers/subscription_providers.dart';
import 'subscription_card.dart' show monoStyle;

/// The next thirty days as a ruled line, one dot per charge.
///
/// Tap a dot to read which subscription it is, when it charges and how much.
/// Dots for other currencies are hollow because they are not part of the
/// headline total.
class UpcomingTimeline extends ConsumerStatefulWidget {
  const UpcomingTimeline({super.key});

  @override
  ConsumerState<UpcomingTimeline> createState() => _UpcomingTimelineState();
}

class _UpcomingTimelineState extends ConsumerState<UpcomingTimeline> {
  /// Subscription id of the dot the user tapped; null follows the soonest.
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    final bills = ref.watch(upcomingBillsProvider);
    if (bills.isEmpty) return const SizedBox.shrink();

    final colors = context.colors;
    final currency = ref.watch(currencyCodeProvider);
    final today = DateUtils.dateOnly(ref.watch(nowProvider)());
    final dayFormat = DateFormat.MMMd(context.localeName);
    final ground = Theme.of(context).scaffoldBackgroundColor;

    final selected = bills.firstWhere(
      (b) => b.subscription.id == _selectedId,
      orElse: () => bills.first,
    );

    const ticks = [0, 7, 14, 21, 28];
    final labelStyle = monoStyle(
      size: 9.5,
    ).copyWith(color: colors.onSurfaceVariant, letterSpacing: 1);

    final caption =
        '${context.upper(selected.subscription.name)} · '
        '${context.upper(dayFormat.format(selected.date))} · '
        '${MoneyFormatter.format(amount: selected.subscription.price, currencyCode: selected.subscription.currencyCode, localeName: context.localeName)}';

    return LayoutBuilder(
      builder: (context, box) {
        final width = box.maxWidth;
        double x(int day) => day / 30 * width;
        final selectedX = x(selected.daysAway.clamp(0, 30));

        return SizedBox(
          height: 78,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: (selectedX - 20).clamp(0.0, width - 250),
                top: 0,
                child: Text(
                  caption,
                  style: monoStyle(size: 10.5).copyWith(letterSpacing: 0.3),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 40,
                child: Container(height: 1.5, color: colors.onSurface),
              ),
              for (final d in ticks)
                Positioned(
                  left: x(d) - 0.75,
                  top: 36,
                  child: Container(
                    width: 1.5,
                    height: 9,
                    color: colors.onSurface,
                  ),
                ),
              for (final d in ticks)
                Positioned(
                  left: d == 28 ? null : (d == 0 ? 0 : x(d) - 24),
                  right: d == 28 ? 0 : null,
                  top: 56,
                  child: Text(
                    context.upper(
                      dayFormat.format(
                        DateTime(today.year, today.month, today.day + d),
                      ),
                    ),
                    style: labelStyle,
                  ),
                ),
              // Later bills first so the soonest ends up on top when dots
              // share a day.
              for (final b in bills.reversed)
                Positioned(
                  left: x(b.daysAway.clamp(0, 30)) - 14,
                  top: 26,
                  child: GestureDetector(
                    key: Key('timeline-dot-${b.subscription.id}'),
                    behavior: HitTestBehavior.opaque,
                    onTap: () =>
                        setState(() => _selectedId = b.subscription.id),
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: b.subscription.currencyCode == currency
                                ? colors.primary
                                : ground,
                            border: Border.all(
                              color: colors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: selectedX - 10,
                top: 31,
                child: IgnorePointer(
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.primary, width: 1.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
