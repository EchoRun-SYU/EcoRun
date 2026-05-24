import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF006E2F);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF22C55E);
  static const onPrimaryContainer = Color(0xFF004B1E);
  static const secondary = Color(0xFF9D4300);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFFD761A);
  static const onSecondaryContainer = Color(0xFF5C2400);
  static const background = Color(0xFFF7F9FB);
  static const surface = Color(0xFFF7F9FB);
  static const surfaceLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF2F4F6);
  static const surfaceContainer = Color(0xFFECEEF0);
  static const onBackground = Color(0xFF191C1E);
  static const onSurface = Color(0xFF191C1E);
  static const onSurfaceVariant = Color(0xFF3D4A3D);
  static const outline = Color(0xFF6D7B6C);
  static const outlineVariant = Color(0xFFBCCBB9);
}

class AppTheme {
  static ThemeData get theme {
    final base = GoogleFonts.plusJakartaSansTextTheme();
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: Color(0xFF565E74),
        onTertiary: Color(0xFFFFFFFF),
        tertiaryContainer: Color(0xFFA4ABC4),
        onTertiaryContainer: Color(0xFF383F54),
        error: Color(0xFFBA1A1A),
        onError: Color(0xFFFFFFFF),
        errorContainer: Color(0xFFFFDAD6),
        onErrorContainer: Color(0xFF93000A),
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        inverseSurface: Color(0xFF2D3133),
        onInverseSurface: Color(0xFFEFF1F3),
        inversePrimary: Color(0xFF4AE176),
        surfaceTint: AppColors.primary,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: base.copyWith(
        displaySmall: base.displaySmall?.copyWith(
          fontSize: 36,
          fontWeight: FontWeight.w800,
          color: AppColors.onSurface,
        ),
        headlineLarge: base.headlineLarge?.copyWith(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          color: AppColors.onSurface,
        ),
        headlineMedium: base.headlineMedium?.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
        bodyLarge: base.bodyLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        bodyMedium: base.bodyMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurface,
        ),
        labelLarge: base.labelLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        labelMedium: base.labelMedium?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurfaceVariant,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLowest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryContainer, width: 2),
        ),
        hintStyle: const TextStyle(color: AppColors.outline, fontSize: 15),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: AppColors.onPrimaryContainer,
          shape: const StadiumBorder(),
          minimumSize: const Size(double.infinity, 52),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          elevation: 0,
        ),
      ),
    );
  }
}
