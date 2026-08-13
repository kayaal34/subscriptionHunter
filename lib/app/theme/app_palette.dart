import 'package:flutter/material.dart';

/// Seed colours and the hand-tuned tokens the Material 3 scheme cannot express.
///
/// Everything visual resolves through here or through [ColorScheme]; no widget
/// hardcodes a hex value.
abstract final class AppPalette {
  /// Brand seed. Material 3 derives the full tonal palette from this.
  static const Color seed = Color(0xFF6750A4);

  /// Semantic accents, kept identical across themes so a "due soon" chip means
  /// the same thing in light and dark.
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFED6C02);
  static const Color danger = Color(0xFFD32F2F);

  /// Chart series colours, ordered for maximum adjacent contrast.
  ///
  /// Category slices fall back to these when a subscription has no brand
  /// colour, so a pie chart never renders two indistinguishable neighbours.
  static const List<Color> chartSeries = [
    Color(0xFF6750A4),
    Color(0xFF00A8E1),
    Color(0xFF2E7D32),
    Color(0xFFED6C02),
    Color(0xFFD32F2F),
    Color(0xFF00897B),
    Color(0xFF7B1FA2),
    Color(0xFF5D4037),
    Color(0xFF0288D1),
    Color(0xFFC2185B),
  ];

  static Color chartColorAt(int index) =>
      chartSeries[index % chartSeries.length];
}

/// Soft elevation used by the subscription cards.
///
/// Material 3 replaces shadows with tonal elevation, which reads flat on the
/// dense list this app shows. These reinstate a soft, diffuse shadow while
/// keeping the M3 surface tints.
abstract final class AppShadows {
  static List<BoxShadow> card(Brightness brightness) =>
      brightness == Brightness.light
      ? const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 18,
            offset: Offset(0, 6),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ]
      : const [
          // Shadows are nearly invisible on dark surfaces, so depth in dark
          // mode comes from a slightly stronger, tighter shadow plus the
          // surface tint applied by the theme.
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 16,
            offset: Offset(0, 6),
            spreadRadius: -6,
          ),
        ];
}

/// Consistent spacing scale. Using named steps instead of magic numbers keeps
/// rhythm consistent as screens get added.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  static const double cardRadius = 20;
  static const double sheetRadius = 28;
}
