import 'package:flutter/material.dart';

import 'vision_os_colors.dart';
import 'vision_os_typography.dart';

class VisionOSTheme {
  const VisionOSTheme._();

  static ThemeData get lightTheme {
    final scheme = const ColorScheme.light(
      primary: VisionOSColors.accentBlue,
      secondary: VisionOSColors.accentBlueLight,
      surface: VisionOSColors.surface,
      error: VisionOSColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: VisionOSColors.textPrimary,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: VisionOSColors.background,
      primaryColor: VisionOSColors.accentBlue,
      textTheme: TextTheme(
        displayLarge: VisionOSTypography.headerLarge,
        displayMedium: VisionOSTypography.headerMedium,
        displaySmall: VisionOSTypography.headerSmall,
        titleLarge: VisionOSTypography.titleLarge,
        titleMedium: VisionOSTypography.titleMedium,
        titleSmall: VisionOSTypography.titleSmall,
        bodyLarge: VisionOSTypography.bodyLarge,
        bodyMedium: VisionOSTypography.bodyMedium,
        bodySmall: VisionOSTypography.bodySmall,
        labelLarge: VisionOSTypography.button,
        labelMedium: VisionOSTypography.captionStrong,
        labelSmall: VisionOSTypography.caption,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: VisionOSColors.textPrimary,
        titleTextStyle: VisionOSTypography.titleMedium,
      ),
      cardTheme: CardThemeData(
        color: VisionOSColors.glassSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: VisionOSColors.glassStroke, width: 0.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: VisionOSColors.divider,
        thickness: 0.5,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: VisionOSColors.glassSurface,
        hintStyle: VisionOSTypography.bodyMedium.copyWith(
          color: VisionOSColors.textTertiary,
        ),
        labelStyle: VisionOSTypography.bodyMedium.copyWith(
          color: VisionOSColors.textSecondary,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: VisionOSColors.glassStroke,
            width: 0.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: VisionOSColors.glassStroke,
            width: 0.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: VisionOSColors.accentBlue,
            width: 1,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: VisionOSColors.accentBlue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: VisionOSColors.surfaceTertiary,
          disabledForegroundColor: VisionOSColors.textTertiary,
          textStyle: VisionOSTypography.button,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: VisionOSColors.accentBlue,
          side: const BorderSide(color: VisionOSColors.accentBlue),
          textStyle: VisionOSTypography.button,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: VisionOSColors.surfaceSecondary,
        selectedColor: VisionOSColors.accentBlue.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: VisionOSColors.glassStroke, width: 0.5),
        ),
        labelStyle: VisionOSTypography.bodySmall,
        secondaryLabelStyle: VisionOSTypography.bodySmall.copyWith(
          color: VisionOSColors.accentBlueDark,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),
    );
  }
}
