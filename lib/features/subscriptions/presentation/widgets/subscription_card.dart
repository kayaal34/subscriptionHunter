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
    final today = DateUtils.dateOnly(DateTime.now());
    final nextDate = DateTime(today.year, today.month, today.day + daysAway);

    const radius = BorderRadius.all(Radius.circular(AppSpacing.cardRadius));
    final urgent = daysAway <= 3;

    return SizedBox(
      height: walletCardHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: walletGradient(brand),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x80000000),
              blurRadius: 24,
              offset: Offset(0, -10),
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
                          Colors.white.withValues(alpha: 0.16),
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
                                color: Colors.white,
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
                            ).copyWith(color: Colors.white),
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
                                  DateFormat.MMMd(
                                    context.localeName,
                                  ).format(nextDate).toUpperCase(),
                                  style: monoStyle(
                                    size: 15,
                                  ).copyWith(color: Colors.white),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  l10n.dueLabel(daysAway),
                                  style: context.text.labelMedium?.copyWith(
                                    color: urgent
                                        ? AppPalette.champagne
                                        : Colors.white.withValues(alpha: 0.72),
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
      color: Colors.white.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(
      label,
      style: monoStyle(
        size: 10.5,
      ).copyWith(color: Colors.white, letterSpacing: 1),
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

/// Brand colour darkened toward graphite so white text always has contrast,
/// even for light brand colours such as yellow.
LinearGradient walletGradient(Color brand) {
  final start = brand.computeLuminance() > 0.55
      ? Color.lerp(brand, Colors.black, 0.35)!
      : brand;
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      start,
      Color.lerp(start, Colors.black, 0.55)!,
      const Color(0xFF0B0B0D),
    ],
    stops: const [0, 0.68, 1],
  );
}
