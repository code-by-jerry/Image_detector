import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Milk Mirror brand tokens — see ui_plan.md
abstract final class AppColors {
  static const background = Color(0xFFFAF8F2);
  static const surface = Color(0xFFFFFFFF);

  static const primary = Color(0xFF556B2F);
  static const primaryDark = Color(0xFF3F4F24);
  static const primarySoft = Color(0xFFE8EFE0);

  static const accentGold = Color(0xFFC89B3C);

  static const textPrimary = Color(0xFF1F2937);
  static const textSecondary = Color(0xFF6B7280);

  static const border = Color(0xFFE5E7EB);
  static const success = Color(0xFF4D7C3A);
  static const successSoft = Color(0xFFDFF0D8);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  // Legacy aliases for existing enterprise widgets
  static const canvas = background;
  static const lavender = primarySoft;

  static const aiGlow = BoxShadow(
    color: Color(0x33556B2F),
    blurRadius: 24,
    offset: Offset(0, 8),
  );

  static const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, Color(0xFFF5F2EA)],
  );

  static const backgroundDecoration = BoxDecoration(
    color: background,
  );
}

abstract final class AppTheme {
  static ThemeData build() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.accentGold,
        surface: AppColors.surface,
      ),
      textTheme: GoogleFonts.interTextTheme(),
      dividerColor: AppColors.border,
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.2),
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
