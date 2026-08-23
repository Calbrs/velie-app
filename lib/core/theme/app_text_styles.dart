import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography tokens. Headings use Space Grotesk, body uses Inter.
abstract class AppTextStyles {
  static TextStyle get _base => GoogleFonts.spaceGrotesk(color: AppColors.textPrimary);
  static TextStyle get _headingBase => GoogleFonts.spaceGrotesk(color: AppColors.textPrimary);

  static TextStyle get displayLarge => _headingBase.copyWith(
        fontSize: 32, 
        fontWeight: FontWeight.w700, 
        letterSpacing: -0.5
      );

  static TextStyle get sectionHeader => _base.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
      );

  static TextStyle get titleMedium => _headingBase.copyWith(
        fontSize: 18, 
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3
      );

  static TextStyle get bodyMedium => _base.copyWith(
        fontSize: 14, 
        fontWeight: FontWeight.w400
      );

  static TextStyle get caption => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get buttonLabel => _base.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textOnButton,
      );

  static TextStyle get pairingCode => _headingBase.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: 8,
      );
}
