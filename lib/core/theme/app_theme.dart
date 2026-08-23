import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

/// Central ThemeData builders for Velie.
///
/// `AppTheme.light` and `AppTheme.dark` build from the explicit light/dark
/// palettes so they are stable regardless of the runtime `AppColors.mode`
/// switch (which drives individual widget colors).
abstract class AppTheme {
  static ThemeData get light => _build(Brightness.light, AppColors.lightBackground,
        AppColors.lightSurface, AppColors.lightSurfaceMuted,
        AppColors.lightBorder, AppColors.lightTextPrimary,
        AppColors.lightTextSecondary, AppColors.lightTextOnButton,
        AppColors.lightPrimaryDisabled);

  static ThemeData get dark => _build(Brightness.dark, AppColors.darkBackground,
        AppColors.darkSurface, AppColors.darkSurfaceMuted,
        AppColors.darkBorder, AppColors.darkTextPrimary,
        AppColors.darkTextSecondary, AppColors.darkTextOnButton,
        AppColors.darkPrimaryDisabled);

  static ThemeData _build(
    Brightness brightness,
    Color background,
    Color surface,
    Color surfaceMuted,
    Color border,
    Color textPrimary,
    Color textSecondary,
    Color textOnButton,
    Color primaryDisabled,
  ) {
    final base = ThemeData(
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
        surface: surface,
        error: AppColors.statusFailed,
      ).copyWith(
        primary: AppColors.primary,
        onPrimary: textOnButton,
        surface: surface,
        onSurface: textPrimary,
        outline: border,
      ),
      scaffoldBackgroundColor: background,
      textTheme: GoogleFonts.spaceGroteskTextTheme(ThemeData(brightness: brightness).textTheme).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: textOnButton,
          disabledBackgroundColor: primaryDisabled,
          disabledForegroundColor: textOnButton,
          textStyle: AppTextStyles.buttonLabel,
          minimumSize: const Size.fromHeight(56), // slightly taller for pill
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        hintStyle: AppTextStyles.caption,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: const BorderSide(color: AppColors.statusFailed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: const BorderSide(color: AppColors.statusFailed),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceMuted,
        contentTextStyle: TextStyle(
          color: textPrimary,
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        behavior: SnackBarBehavior.floating,
      ),
      dividerColor: border,
      splashFactory: InkSparkle.splashFactory,
    );
    return base.copyWith(
      textTheme: GoogleFonts.spaceGroteskTextTheme(base.textTheme),
    );
  }
}