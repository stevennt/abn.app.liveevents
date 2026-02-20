import 'package:flutter/material.dart';

import 'colors.dart';
import 'typography.dart';

class MetroTheme {
  const MetroTheme._();

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: MetroColors.background,
      colorScheme: const ColorScheme.dark(
        primary: MetroColors.primary,
        secondary: MetroColors.surfaceLight,
        surface: MetroColors.surface,
        error: MetroColors.accentRed,
      ),
      textTheme: TextTheme(
        displayLarge: MetroTypography.headerLight,
        displayMedium: MetroTypography.headerBold,
        titleLarge: MetroTypography.titleNormal,
        titleMedium: MetroTypography.subtitle,
        bodyLarge: MetroTypography.body,
        bodyMedium: MetroTypography.caption,
        labelLarge: MetroTypography.button,
      ),
    );
  }
}
