import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../app/theme/app_palette.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../subscriptions/presentation/widgets/subscription_card.dart';

/// Soft pulsing light behind a visual, in the theme's accent.
class _Glow extends StatelessWidget {
  const _Glow();

  @override
  Widget build(BuildContext context) =>
      Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  context.colors.primary.withValues(alpha: 0.26),
                  Colors.transparent,
                ],
              ),
            ),
          )
          .animate(onPlay: (c) => c.repeat(reverse: true, count: 6))
          .scaleXY(begin: 0.9, end: 1.08, duration: 2400.ms)
          .fade(begin: 0.7, end: 1, duration: 2400.ms);
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({
    required this.name,
    required this.price,
    required this.color,
  });

  final String name;
  final String price;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDark;

    return Container(
      width: 270,
      height: 150,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        gradient: walletGradient(color, isDark: isDark),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : colors.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: context.text.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(price, style: monoStyle(size: 13.5)),
        ],
      ),
    );
  }
}

/// Page 1: three cards fan up into a wallet, a light sweep crosses the front.
class CardsVisual extends StatelessWidget {
  const CardsVisual({super.key});

  @override
  Widget build(BuildContext context) {
    const cards = [
      ('Spotify', '₺69,99', Color(0xFF1DB954)),
      ('YouTube', '₺79,99', Color(0xFFFF0033)),
      ('Netflix', '₺299,99', Color(0xFFE50914)),
    ];

    return SizedBox(
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const _Glow(),
          for (var i = 0; i < cards.length; i++)
            Positioned(
              top: 40.0 + i * 62,
              child:
                  _MiniCard(
                        name: cards[i].$1,
                        price: cards[i].$2,
                        color: cards[i].$3,
                      )
                      .animate(delay: (260 * i).ms)
                      .fadeIn(duration: 420.ms)
                      .slideY(
                        begin: 0.9,
                        duration: 620.ms,
                        curve: Curves.easeOutCubic,
                      )
                      .then(delay: 400.ms)
                      .shimmer(
                        duration: 1600.ms,
                        color: Colors.white.withValues(alpha: 0.35),
                      ),
            ),
        ],
      ),
    );
  }
}

/// Page 2: a reminder drops in over a faint timeline and the bell rings.
class RemindersVisual extends StatelessWidget {
  const RemindersVisual({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;

    return SizedBox(
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const _Glow(),
          Positioned(
            bottom: 70,
            left: 20,
            right: 20,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(height: 1.5, color: colors.outlineVariant),
                for (final x in const [0.1, 0.34, 0.58, 0.86])
                  Align(
                    alignment: Alignment(x * 2 - 1, 0),
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.primary,
                      ),
                    ),
                  ).animate(delay: (300 + x * 600).ms).scaleXY(
                    begin: 0,
                    duration: 360.ms,
                    curve: Curves.easeOutBack,
                  ),
              ],
            ),
          ),
          Positioned(
            top: 50,
            child:
                Container(
                      width: 290,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.cardRadius,
                        ),
                        border: Border.all(color: colors.outlineVariant),
                        boxShadow: AppShadows.card(
                          Theme.of(context).brightness,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colors.primary,
                                ),
                                child: Icon(
                                  Icons.notifications_active_rounded,
                                  size: 22,
                                  color: colors.onPrimary,
                                ),
                              )
                              .animate(delay: 900.ms)
                              .shake(hz: 5, duration: 700.ms, rotation: 0.3),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Netflix',
                                  style: context.text.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${l10n.dueLabel(1)} · ₺299,99',
                                  style: monoStyle(size: 12).copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideY(
                      begin: -1.4,
                      duration: 800.ms,
                      curve: Curves.elasticOut,
                    ),
          ),
        ],
      ),
    );
  }
}

/// Page 3: bars grow from the baseline and a share bar fills.
class InsightsVisual extends StatelessWidget {
  const InsightsVisual({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const values = [0.35, 0.5, 0.62, 0.62, 0.74, 1.0];
    const shares = [0.55, 0.25, 0.12, 0.08];
    final tones = [
      colors.primary,
      colors.primary.withValues(alpha: 0.65),
      colors.primary.withValues(alpha: 0.4),
      colors.primary.withValues(alpha: 0.22),
    ];

    return SizedBox(
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const _Glow(),
          Positioned(
            left: 24,
            right: 24,
            top: 40,
            child: Column(
              children: [
                SizedBox(
                  height: 130,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (var i = 0; i < values.length; i++)
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child:
                                Container(
                                      width: 28,
                                      height: 130 * values[i],
                                      decoration: BoxDecoration(
                                        color: i == values.length - 1
                                            ? colors.primary
                                            : colors.outlineVariant,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    )
                                    .animate(delay: (160 * i).ms)
                                    .scaleY(
                                      begin: 0,
                                      alignment: Alignment.bottomCenter,
                                      duration: 560.ms,
                                      curve: Curves.easeOutCubic,
                                    ),
                          ),
                        ),
                    ],
                  ),
                ),
                Container(height: 1.5, color: colors.onSurface),
                const SizedBox(height: 28),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: SizedBox(
                    height: 16,
                    child: Row(
                      children: [
                        for (var i = 0; i < shares.length; i++) ...[
                          if (i > 0) const SizedBox(width: 2),
                          Expanded(
                            flex: (shares[i] * 100).round(),
                            child: ColoredBox(color: tones[i])
                                .animate(delay: (1000 + 140 * i).ms)
                                .scaleX(
                                  begin: 0,
                                  alignment: Alignment.centerLeft,
                                  duration: 520.ms,
                                  curve: Curves.easeOutCubic,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
