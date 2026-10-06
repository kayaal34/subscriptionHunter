import 'package:flutter/material.dart';

/// Colour tokens for the wallet identity.
///
/// Dark is graphite with champagne metal; light is a cool Swiss paper with ink
/// and a deep ultramarine, plus a bronze that echoes the champagne. Everything
/// visual resolves through here or through the [ColorScheme] built from it.
abstract final class AppPalette {
  /// Kept for code that still needs a single brand seed.
  static const Color seed = Color(0xFF1F3AE0);

  // Dark
  static const Color graphite = Color(0xFF0B0B0D);
  static const Color graphiteRaised = Color(0xFF15151A);
  static const Color graphiteHigh = Color(0xFF1D1D24);
  static const Color pearl = Color(0xFFF3EFE6);
  static const Color champagne = Color(0xFFE7D3A7);
  static const Color champagneDeep = Color(0xFFB9985C);

  // Light
  static const Color paper = Color(0xFFF6F7F9);
  static const Color ink = Color(0xFF0E1116);
  static const Color ultramarine = Color(0xFF1F3AE0);
  static const Color bronze = Color(0xFF8E6F35);

  /// Semantic accents, identical across themes.
  static const Color success = Color(0xFF2E9E6B);
  static const Color warning = Color(0xFFE59A2F);
  static const Color danger = Color(0xFFD9473F);

  /// Metallic gradient used for primary actions and hero figures.
  static const List<Color> champagneGradient = [
    Color(0xFFF6E7C1),
    Color(0xFFC9A96A),
  ];

  /// Chart series colours, ordered for maximum adjacent contrast.
  static const List<Color> chartSeries = [
    Color(0xFFE7D3A7),
    Color(0xFF7C8CFF),
    Color(0xFF4FD1B5),
    Color(0xFFFF8A65),
    Color(0xFFC792EA),
    Color(0xFF64B5F6),
    Color(0xFFF06292),
    Color(0xFFAED581),
  ];

  /// Light-theme series: deeper tones that hold contrast on white.
  static const List<Color> chartSeriesLight = [
    Color(0xFF1F3AE0),
    Color(0xFF8E6F35),
    Color(0xFF0E9F85),
    Color(0xFFE0582F),
    Color(0xFF7B4FD6),
    Color(0xFF1E88E5),
    Color(0xFFD81B60),
    Color(0xFF558B2F),
  ];

  static Color chartColorAt(int index, [Brightness? brightness]) {
    final list = brightness == Brightness.light ? chartSeriesLight : chartSeries;
    return list[index % list.length];
  }
}

/// Soft elevation for cards.
abstract final class AppShadows {
  static List<BoxShadow> card(Brightness brightness) =>
      brightness == Brightness.light
      ? const [
          BoxShadow(
            color: Color(0x0D0E1116),
            blurRadius: 24,
            offset: Offset(0, 10),
            spreadRadius: -8,
          ),
          BoxShadow(color: Color(0x080E1116), blurRadius: 3, offset: Offset(0, 1)),
        ]
      : const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 22,
            offset: Offset(0, 10),
            spreadRadius: -10,
          ),
        ];
}

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  static const double cardRadius = 22;
  static const double sheetRadius = 28;
}

/// Font families bundled in assets/fonts.
abstract final class AppFonts {
  static const String display = 'Outfit';
  static const String mono = 'IBMPlexMono';
}
