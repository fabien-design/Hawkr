import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: AppColors.brandPrimary,
      secondary: AppColors.brandSecondary,
      surface: AppColors.light.backgroundSurface,
      error: AppColors.light.statusError,
    ),
    scaffoldBackgroundColor: AppColors.light.backgroundApp,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.light.backgroundSurface,
      foregroundColor: AppColors.light.textPrimary,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: AppColors.light.backgroundCard,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.light.borderDefault),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.light.borderDefault),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.light.borderFocused, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brandPrimary,
        foregroundColor: AppColors.light.textInverse,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.light.backgroundCard,
      selectedItemColor: AppColors.brandPrimary,
      unselectedItemColor: AppColors.light.textSecondary,
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.brandPrimary,
      secondary: AppColors.brandSecondary,
      surface: AppColors.dark.backgroundSurface,
      error: AppColors.dark.statusError,
    ),
    scaffoldBackgroundColor: AppColors.dark.backgroundApp,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.dark.backgroundSurface,
      foregroundColor: AppColors.dark.textPrimary,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: AppColors.dark.backgroundCard,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.dark.borderDefault),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.dark.borderDefault),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.dark.borderFocused, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brandPrimary,
        foregroundColor: AppColors.dark.textInverse,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.dark.backgroundCard,
      selectedItemColor: AppColors.brandPrimary,
      unselectedItemColor: AppColors.dark.textSecondary,
    ),
  );

  AppTheme._();
}
