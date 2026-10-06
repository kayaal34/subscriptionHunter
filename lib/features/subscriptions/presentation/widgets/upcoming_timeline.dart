import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/providers/settings_providers.dart';
import '../providers/subscription_providers.dart';
import 'subscription_card.dart' show monoStyle;

/// The next thirty days as a ruled line, one dot per charge.
///
/// The soonest charge gets a ring and its name; dots for other currencies are
/// hollow because they are not part of the headline total.
class UpcomingTimeline extends ConsumerWidget {
  const UpcomingTimeline({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bills = ref.watch(upcomingBillsProvider);
    if (bills.isEmpty) return const SizedBox.shrink();

    final l10n = context.l10n;
    final colors = context.colors;
    final currency = ref.watch(currencyCodeProvider);
    final today = DateUtils.dateOnly(ref.watch(nowProvider)());
    final dayFormat = DateFormat.MMMd(context.localeName);
    final ground = Theme.of(context).scaffoldBackgroundColor;

    const ticks = [0, 7, 14, 21, 28];
    final labelStyle = monoStyle(
      size: 9.5,
    ).copyWith(color: colors.onSurfaceVariant, letterSpacing: 1);

    return LayoutBuilder(
      builder: (context, box) {
        final width = box.maxWidth;
        double x(int day) => day / 30 * width;
        final first = bills.first;

        return SizedBox(
          height: 78,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: x(first.daysAway.clamp(0, 30)).clamp(0.0, width - 170),
                top: 0,
                child: Text(
                  '${context.upper(first.subscription.name)} · ${l10n.dueLabel(first.daysAway)}',
                  style: monoStyle(size: 10.5).copyWith(letterSpacing: 0.4),
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
                    d == 0
                        ? context.upper(l10n.dueToday)
                        : context.upper(
                            dayFormat.format(
                              DateTime(today.year, today.month, today.day + d),
                            ),
                          ),
                    style: labelStyle,
                  ),
                ),
              for (final b in bills)
                Positioned(
                  left: x(b.daysAway.clamp(0, 30)) - 5,
                  top: 36,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: b.subscription.currencyCode == currency
                          ? colors.primary
                          : ground,
                      border: Border.all(color: colors.primary, width: 2),
                    ),
                  ),
                ),
              Positioned(
                left: x(first.daysAway.clamp(0, 30)) - 10,
                top: 31,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.primary, width: 1.5),
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
