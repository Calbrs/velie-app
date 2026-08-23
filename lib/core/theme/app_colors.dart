import 'package:flutter/material.dart';

/// Which color palette is currently active across the app.
///
/// The app is dark-only, so [AppColorMode.mode] stays on dark permanently.
enum AppColorMode { dark, light }

/// Velie — theme-aware palette.
///
/// Each token exposes the color for the *active* mode (dark by default),
/// matching the approved light/dark design spec. Brand gold stays identical in
/// both modes so the identity is preserved; only surfaces, text and borders
/// change.
class AppColors {
  AppColors._();

  /// Always dark (the app is dark-only); forced in `VelieApp.build`.
  static AppColorMode mode = AppColorMode.dark;

  // ---- Light palette (warm white) ----
  static const Color lightBackground = Color(0xFFF8F7F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceMuted = Color(0xFFF0EEEA);
  static const Color lightBorder = Color(0xFFDDD9D3);
  static const Color lightTextPrimary = Color(0xFF211F1C);
  static const Color lightTextSecondary = Color(0xFF6F6A64);
  static const Color lightTextOnButton = Color(0xFF1B1917);
  static const Color lightPrimaryDisabled = Color(0xFFD8D1C5);
  static const Color lightShadow = Color(0x14000000);
  static const Color lightShimmerBase = Color(0xFFE9E6E0);
  static const Color lightShimmerHighlight = Color(0xFFF6F4F0);

  // ---- Dark palette (charcoal) ----
  static const Color darkBackground = Color(0xFF121212); // Deep Charcoal
  static const Color darkSurface = Color(0xFF1E1E1E); // Elevated
  static const Color darkSurfaceMuted = Color(0xFF252525);
  static const Color darkBorder = Color(0xFF333333);
  static const Color darkTextPrimary = Color(0xFFF2EFEA);
  static const Color darkTextSecondary = Color(0xFF9B9792);
  static const Color darkTextOnButton = Color(0xFF1B1917);
  static const Color darkPrimaryDisabled = Color(0xFF4A4438);
  static const Color darkShadow = Color(0x59000000);
  static const Color darkShimmerBase = Color(0xFF2C2926);
  static const Color darkShimmerHighlight = Color(0xFF3A3632);

  // Brand — identical in both modes.
  static const Color primary = Color(0xFFD4AF37); // Premium Gold
  static const Color primaryPressed = Color(0xFFB5952F);

  /// Semantic status colors — constant across modes.
  static const Color statusPending = Color(0xFFC99A43); // maps to "primary"
  static const Color statusSent = Color(0xFF3E9B61); // "success"
  static const Color statusFailed = Color(0xFFC9524C); // "danger"
  static const Color statusDeleted = Color(0xFF7A746D);

  // ---- Surfaces ----
  static Color get background =>
      mode == AppColorMode.light ? lightBackground : darkBackground;
  static Color get surface =>
      mode == AppColorMode.light ? lightSurface : darkSurface;
  static Color get surfaceMuted =>
      mode == AppColorMode.light ? lightSurfaceMuted : darkSurfaceMuted;
  static Color get border =>
      mode == AppColorMode.light ? lightBorder : darkBorder;

  // ---- Text ----
  static Color get textPrimary =>
      mode == AppColorMode.light ? lightTextPrimary : darkTextPrimary;
  static Color get textSecondary =>
      mode == AppColorMode.light ? lightTextSecondary : darkTextSecondary;
  static Color get textOnButton =>
      mode == AppColorMode.light ? lightTextOnButton : darkTextOnButton;
  static Color get ash => textSecondary; // secondary icons

  // ---- Component states ----
  static Color get primaryDisabled =>
      mode == AppColorMode.light ? lightPrimaryDisabled : darkPrimaryDisabled;

  // ---- Backward-compatible aliases ----
  static Color get buttonPrimary => primary;
  static Color get buttonPrimaryPressed => primaryPressed;
  static Color get buttonDisabled => primaryDisabled;

  // ---- Elevation / loading ----
  static Color get shadow =>
      mode == AppColorMode.light ? lightShadow : darkShadow;
  static Color get shimmerBase =>
      mode == AppColorMode.light ? lightShimmerBase : darkShimmerBase;
  static Color get shimmerHighlight =>
      mode == AppColorMode.light ? lightShimmerHighlight : darkShimmerHighlight;
}