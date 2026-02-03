import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const Color brandPrimary = Color(0xFFF26A2E);
  static const Color brandSecondary = Color(0xFFD93A2F);
  static const Color brandSuccess = Color(0xFF3DBE8B);

  // Light Theme
  static const AppColorScheme light = LightColors();

  // Dark Theme
  static const AppColorScheme dark = DarkColors();

  AppColors._();
}

abstract class AppColorScheme {
  const AppColorScheme();

  // Background
  Color get backgroundApp;
  Color get backgroundSurface;
  Color get backgroundGreyInformation;
  Color get backgroundCard;

  // Text
  Color get textPrimary;
  Color get textSecondary;
  Color get textDisabled;
  Color get textInverse;

  // Border
  Color get borderDefault;
  Color get borderFocused;

  // Status
  Color get statusOpen;
  Color get statusClosed;
  Color get statusSponsored;
  Color get statusError;

  // Action
  Color get actionUpvote;
  Color get actionDownvote;
  Color get actionFavorite;
  Color get actionInactive;

  // Map
  Color get mapHawkerCenterPin;
  Color get mapStreetFoodPin;
}

class LightColors extends AppColorScheme {
  const LightColors();

  @override
  Color get backgroundApp => const Color(0xFFFAF7F2);
  @override
  Color get backgroundSurface => const Color(0xFFFAF7F2);
  @override
  Color get backgroundGreyInformation => const Color(0xFFF1EEEA);
  @override
  Color get backgroundCard => const Color(0xFFFFFFFF);

  @override
  Color get textPrimary => const Color(0xFF1F1F1F);
  @override
  Color get textSecondary => const Color(0xFF6B6B6B);
  @override
  Color get textDisabled => const Color(0xFF9E9E9E);
  @override
  Color get textInverse => const Color(0xFFFFFFFF);

  @override
  Color get borderDefault => const Color(0xFFD9D6CF);
  @override
  Color get borderFocused => const Color(0xFFF26A2E);

  @override
  Color get statusOpen => const Color(0xFF3DBE8B);
  @override
  Color get statusClosed => const Color(0xFFD93A2F);
  @override
  Color get statusSponsored => const Color(0xFFF26A2E);
  @override
  Color get statusError => const Color(0xFFD93A2F);

  @override
  Color get actionUpvote => const Color(0xFF3DBE8B);
  @override
  Color get actionDownvote => const Color(0xFFD93A2F);
  @override
  Color get actionFavorite => const Color(0xFFD93A2F);
  @override
  Color get actionInactive => const Color(0xFFD9D6CF);

  @override
  Color get mapHawkerCenterPin => const Color(0xFFF26A2E);
  @override
  Color get mapStreetFoodPin => const Color(0xFF3DBE8B);
}

class DarkColors extends AppColorScheme {
  const DarkColors();

  @override
  Color get backgroundApp => const Color(0xFF121212);
  @override
  Color get backgroundSurface => const Color(0xFF1E1E1E);
  @override
  Color get backgroundGreyInformation => const Color(0xFF1E1E1E);
  @override
  Color get backgroundCard => const Color(0xFF242424);

  @override
  Color get textPrimary => const Color(0xFFFFFFFF);
  @override
  Color get textSecondary => const Color(0xFFA0A0A0);
  @override
  Color get textDisabled => const Color(0xFF6F6F6F);
  @override
  Color get textInverse => const Color(0xFF1F1F1F);

  @override
  Color get borderDefault => const Color(0xFF2E2E2E);
  @override
  Color get borderFocused => const Color(0xFFF26A2E);

  @override
  Color get statusOpen => const Color(0xFF3DBE8B);
  @override
  Color get statusClosed => const Color(0xFFD93A2F);
  @override
  Color get statusSponsored => const Color(0xFFF26A2E);
  @override
  Color get statusError => const Color(0xFFD93A2F);

  @override
  Color get actionUpvote => const Color(0xFF3DBE8B);
  @override
  Color get actionDownvote => const Color(0xFFD93A2F);
  @override
  Color get actionFavorite => const Color(0xFFD93A2F);
  @override
  Color get actionInactive => const Color(0xFF2E2E2E);

  @override
  Color get mapHawkerCenterPin => const Color(0xFFF26A2E);
  @override
  Color get mapStreetFoodPin => const Color(0xFF3DBE8B);
}
