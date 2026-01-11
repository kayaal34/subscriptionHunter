import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Language enum
enum AppLanguage { turkish, english, russian }

/// Language state notifier
class LanguageNotifier extends StateNotifier<AppLanguage> {
  LanguageNotifier() : super(AppLanguage.turkish);

  AppLanguage get language => state;

  set language(AppLanguage language) {
    state = language;
  }

  void toggleLanguage() {
    state = state == AppLanguage.turkish ? AppLanguage.english : AppLanguage.turkish;
  }
}

/// Language provider
final languageProvider = StateNotifierProvider<LanguageNotifier, AppLanguage>((ref) => LanguageNotifier());

/// App theme data provider (Light mode only - Apple Design System)
final appThemeProvider = Provider<ThemeData>((ref) => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: const Color(0xFF007AFF), // Apple Blue
    primaryColorLight: const Color(0xFF34C759), // Apple Green
    scaffoldBackgroundColor: const Color(0xFFFFFFFF), // Pure White
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFFFFFF),
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFFFFFFFF),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: Color(0xFFE5E5EA),
          width: 1,
        ),
      ),
      shadowColor: Colors.black.withValues(alpha: 0.08),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF2F2F7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E5EA)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E5EA)),
      ),
    ),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF007AFF), // Apple Blue
      secondary: Color(0xFF34C759), // Apple Green
      tertiary: Color(0xFFFF9500), // Apple Orange
      surface: Color(0xFFFFFFFF),
      error: Color(0xFFFF3B30), // Apple Red
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: Colors.black,
        letterSpacing: -0.5,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black,
        letterSpacing: -0.3,
      ),
      titleSmall: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Color(0xFF3C3C43),
        letterSpacing: -0.2,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Color(0xFF000000),
        letterSpacing: -0.2,
      ),
      bodyMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: Color(0xFF3C3C43),
        letterSpacing: -0.2,
      ),
      bodySmall: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: Color(0xFF8E8E93),
      ),
      labelSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Color(0xFF8E8E93),
      ),
    ),
  ));
