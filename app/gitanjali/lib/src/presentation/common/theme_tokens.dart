import 'package:flutter/material.dart';

/// Design tokens for Gitanjali app
/// Based on VDD visual specifications v1.2
class AppColors {
  AppColors._();

  // Reader backgrounds
  static const Color readerBackground = Color(0xFFF6EFE3); // off-white "paper"
  static const Color readerBackgroundDark = Color(0xFF1E1E1E);

  // Surface colors
  static const Color cardBackground = Colors.white;
  static const Color cardBackgroundDark = Color(0xFF2C2C2C);

  // Primary / Accent
  static const Color primary = Color(0xFF6F4E37); // warm brown
  static const Color accent = Color(0xFF008080); // teal for decorative elements

  // Text colors
  static const Color textPrimary = Color(0xDD000000); // 87% opacity black
  static const Color textSecondary = Color(0x99000000); // 60% opacity (translations)
  static const Color textPrimaryDark = Color(0xDDFFFFFF);
  static const Color textSecondaryDark = Color(0x99FFFFFF);

  // Verse number
  static const Color verseNumber = Color(0x66000000); // 40% opacity
  static const Color verseNumberDark = Color(0x66FFFFFF);

  // UI elements
  static const Color divider = Color(0x1F000000);
  static const Color dividerDark = Color(0x1FFFFFFF);
}

/// Typography tokens
class AppTypography {
  AppTypography._();

  static const String fontFamilyDefault = 'MurariChandUni';

  // Cover / Splash title (H0)
  static TextStyle coverTitle(BuildContext context) => TextStyle(
        fontFamily: fontFamilyDefault,
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: AppColors.accent,
        letterSpacing: 2,
      );

  // Page title (H1)
  static TextStyle pageTitle(BuildContext context) => TextStyle(
        fontFamily: fontFamilyDefault,
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: _textPrimary(context),
      );

  // Byline ("by Author Name")
  static TextStyle byline(BuildContext context) => TextStyle(
        fontFamily: fontFamilyDefault,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: _textSecondary(context),
      );

  // Original verse text
  static TextStyle originalVerse(BuildContext context) => TextStyle(
        fontFamily: fontFamilyDefault,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: _textPrimary(context),
        height: 1.6,
      );

  // Translation text
  static TextStyle translation(BuildContext context) => TextStyle(
        fontFamily: fontFamilyDefault,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: _textSecondary(context),
        height: 1.5,
      );

  // Verse number
  static TextStyle verseNumber(BuildContext context) => TextStyle(
        fontFamily: fontFamilyDefault,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.verseNumberDark
            : AppColors.verseNumber,
      );

  // Quote block
  static TextStyle quote(BuildContext context) => TextStyle(
        fontFamily: fontFamilyDefault,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
        color: _textSecondary(context),
        height: 1.7,
      );

  // TOC category item
  static TextStyle tocItem(BuildContext context) => TextStyle(
        fontFamily: fontFamilyDefault,
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: Colors.white,
        shadows: const [
          Shadow(color: Colors.black54, blurRadius: 4),
        ],
      );

  static Color _textPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColors.textPrimaryDark
          : AppColors.textPrimary;

  static Color _textSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColors.textSecondaryDark
          : AppColors.textSecondary;
}

/// Spacing tokens
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  // Vertical rhythm between elements
  static const double paragraphGap = 18;
  static const double verseGap = 24;
  static const double sectionGap = 32;
}

/// Layout tokens
class AppLayout {
  AppLayout._();

  // Max content width for readability
  static const double maxContentWidth = 800;

  // Mini player height
  static const double miniPlayerHeight = 64;

  // Tab bar height
  static const double tabBarHeight = 56;

  // Toolbar height
  static const double toolbarHeight = 56;

  // Verse number column width
  static const double verseNumberWidth = 40;
}

/// Theme data factory
class AppTheme {
  AppTheme._();

  static ThemeData light() => ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.readerBackground,
        fontFamily: AppTypography.fontFamilyDefault,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
        ),
      );

  static ThemeData dark() => ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: AppColors.readerBackgroundDark,
        fontFamily: AppTypography.fontFamilyDefault,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.cardBackgroundDark,
          selectedItemColor: AppColors.accent,
          unselectedItemColor: Colors.grey.shade600,
        ),
      );
}
