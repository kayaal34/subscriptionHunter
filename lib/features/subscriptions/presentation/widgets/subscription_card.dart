import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../domain/subscription.dart';
import 'subscription_avatar.dart';

/// Height of one wallet card. The home stack overlaps cards so that only
/// [walletCardPeek] of every card except the front one stays visible.
const double walletCardHeight = 176;
const double walletCardPeek = 66;

/// A subscription drawn as a pass in a wallet: the service colour, a metallic
/// edge light and the price in mono.
///
/// The header row (logo, name, price) is what stays visible when the card is
/// overlapped in the stack; the footer is only seen on the front card.
class SubscriptionCard extends StatelessWidget {
  const SubscriptionCard({
    required this.subscription,
    required this.daysAway,
    this.onTap,
    super.key,
  });

  final Subscription subscription;
  final int daysAway;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final brand = Color(subscription.brandColor);
    final colors = context.colors;
    final isDark = context.isDark;
    final ink = colors.onSurface;
    final today = DateUtils.dateOnly(DateTime.now());
    final nextDate = DateTime(today.year, today.month, today.day + daysAway);

    const radius = BorderRadius.all(Radius.circular(AppSpacing.cardRadius));
    final urgent = daysAway <= 3;

    return SizedBox(
      height: walletCardHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: walletGradient(brand, isDark: isDark),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.10)
                : colors.outlineVariant,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? const Color(0x80000000)
                  : const Color(0x1A0E1116),
              blurRadius: 24,
              offset: const Offset(0, -10),
              spreadRadius: -12,
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          borderRadius: radius,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: Stack(
              children: [
                // Edge light across the top-left, like a metallic card.
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: radius,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.center,
                        colors: [
                          Colors.white.withValues(alpha: isDark ? 0.10 : 0.6),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Hero(
                            tag: 'logo-${subscription.id}',
                            child: SubscriptionAvatar(
                              subscription: subscription,
                              size: 36,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              subscription.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.titleMedium?.copyWith(
                                color: ink,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            MoneyFormatter.format(
                              amount: subscription.price,
                              currencyCode: subscription.currencyCode,
                              localeName: context.localeName,
                            ),
                            style: monoStyle(
                              size: 14.5,
                            ).copyWith(color: ink),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.upper(
                                    DateFormat.MMMd(
                                      context.localeName,
                                    ).format(nextDate),
                                  ),
                                  style: monoStyle(
                                    size: 15,
                                  ).copyWith(color: ink),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  l10n.dueLabel(daysAway),
                                  style: context.text.labelMedium?.copyWith(
                                    color: urgent
                                        ? colors.primary
                                        : colors.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _Pill(label: subscription.billingCycle.label(l10n)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: context.colors.onSurface.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(
      label,
      style: monoStyle(
        size: 10.5,
      ).copyWith(color: context.colors.onSurface, letterSpacing: 1),
    ),
  );
}

/// IBM Plex Mono for amounts and dates, so digits line up like a card number.
TextStyle monoStyle({double size = 14}) => TextStyle(
  fontFamily: AppFonts.mono,
  fontWeight: FontWeight.w500,
  fontSize: size,
  letterSpacing: -0.3,
);

/// Card surface that belongs to the theme: graphite on dark, white on light.
/// The service colour only tints one corner, so a stack of cards stays calm.
LinearGradient walletGradient(Color brand, {required bool isDark}) {
  final base = isDark ? const Color(0xFF17171C) : Colors.white;
  final end = isDark ? const Color(0xFF0F0F13) : const Color(0xFFF1F2F5);
  return LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color.lerp(base, brand, isDark ? 0.34 : 0.16)!,
      base,
      end,
    ],
    stops: const [0, 0.55, 1],
  );
}
