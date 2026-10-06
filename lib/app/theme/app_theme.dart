import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Builds the light and dark Material 3 themes.
///
/// Both are generated from a single seed so the two modes stay in lockstep -
/// adding a colour to one can no longer leave the other unstyled, which is how
/// the previous theme drifted into an unusable dark mode.
abstract final class AppTheme {
  static const ColorScheme _dark = ColorScheme(
    brightness: Brightness.dark,
    primary: AppPalette.champagne,
    onPrimary: Color(0xFF1A1407),
    primaryContainer: Color(0xFF3A3020),
    onPrimaryContainer: AppPalette.champagne,
    secondary: AppPalette.champagneDeep,
    onSecondary: Color(0xFF1A1407),
    secondaryContainer: Color(0xFF26262E),
    onSecondaryContainer: AppPalette.pearl,
    tertiary: Color(0xFF7C8CFF),
    onTertiary: Color(0xFF0B0B0D),
    error: AppPalette.danger,
    onError: Colors.white,
    surface: AppPalette.graphite,
    onSurface: AppPalette.pearl,
    onSurfaceVariant: Color(0x99F3EFE6),
    outline: Color(0x3DF3EFE6),
    outlineVariant: Color(0x1FF3EFE6),
    surfaceContainerLowest: Color(0xFF070708),
    surfaceContainerLow: Color(0xFF101013),
    surfaceContainer: AppPalette.graphiteRaised,
    surfaceContainerHigh: AppPalette.graphiteHigh,
    surfaceContainerHighest: Color(0xFF26262E),
    inverseSurface: AppPalette.pearl,
    onInverseSurface: AppPalette.graphite,
    inversePrimary: AppPalette.bronze,
  );

  static const ColorScheme _light = ColorScheme(
    brightness: Brightness.light,
    primary: AppPalette.ultramarine,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFE6EAFF),
    onPrimaryContainer: Color(0xFF0F1E8F),
    secondary: AppPalette.bronze,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFEDEFF3),
    onSecondaryContainer: AppPalette.ink,
    tertiary: Color(0xFF0E9F85),
    onTertiary: Colors.white,
    error: AppPalette.danger,
    onError: Colors.white,
    surface: Colors.white,
    onSurface: AppPalette.ink,
    onSurfaceVariant: Color(0xFF656C7A),
    outline: Color(0xFFC9CDD6),
    outlineVariant: Color(0xFFE4E6EB),
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: Color(0xFFFAFAFB),
    surfaceContainer: Color(0xFFF1F2F5),
    surfaceContainerHigh: Color(0xFFECEEF2),
    surfaceContainerHighest: Color(0xFFE4E6EB),
    inverseSurface: AppPalette.ink,
    onInverseSurface: Colors.white,
    inversePrimary: AppPalette.champagne,
  );

  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final scheme = isLight ? _light : _dark;

    final base = ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      brightness: brightness,
      fontFamily: AppFonts.display,
    );

    return base.copyWith(
      scaffoldBackgroundColor: isLight ? AppPalette.paper : AppPalette.graphite,

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: scheme.onSurface,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: scheme.onSurface,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        // Shadows are drawn manually by the card widgets via AppShadows so the
        // blur can be softer than Material's default.
        color: isLight ? Colors.white : scheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        margin: EdgeInsets.zero,
      ),

      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        elevation: 0,
        backgroundColor: isLight ? AppPalette.paper : AppPalette.graphite,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.secondaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: scheme.onSurface,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight
            ? scheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : scheme.surfaceContainerHigh,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.lg),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.lg),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.lg),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.lg),
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.lg),
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.lg),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.lg),
          ),
        ),
      ),

      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.lg),
            ),
          ),
          side: WidgetStatePropertyAll(
            BorderSide(color: scheme.outlineVariant),
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? scheme.primary
                : Colors.transparent,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? scheme.onPrimary
                : scheme.onSurface,
          ),
        ),
      ),

      chipTheme: ChipThemeData(
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.md),
        ),
        backgroundColor: scheme.surfaceContainerHighest,
        selectedColor: scheme.secondaryContainer,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
      ),

      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.xl),
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isLight ? scheme.surface : scheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.sheetRadius),
          ),
        ),
        showDragHandle: true,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.md),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.5),
        thickness: 1,
        space: 1,
      ),

      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.md),
        ),
      ),

      textTheme: base.textTheme.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ).copyWith(
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.6,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        labelLarge: base.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),

      // Predictive back on Android 14+; older devices (including the API 29
      // test device) fall back to the platform default automatically.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
