import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'vision_os_colors.dart';

class VisionOSTypography {
  const VisionOSTypography._();

  static TextStyle get headerLarge => GoogleFonts.ibmPlexSans(
    fontSize: 34,
    height: 1.1,
    fontWeight: FontWeight.w700,
    color: VisionOSColors.textPrimary,
  );

  static TextStyle get headerMedium => GoogleFonts.ibmPlexSans(
    fontSize: 28,
    height: 1.15,
    fontWeight: FontWeight.w700,
    color: VisionOSColors.textPrimary,
  );

  static TextStyle get headerSmall => GoogleFonts.ibmPlexSans(
    fontSize: 22,
    height: 1.2,
    fontWeight: FontWeight.w600,
    color: VisionOSColors.textPrimary,
  );

  static TextStyle get titleLarge => GoogleFonts.ibmPlexSans(
    fontSize: 22,
    height: 1.2,
    fontWeight: FontWeight.w600,
    color: VisionOSColors.textPrimary,
  );

  static TextStyle get titleMedium => GoogleFonts.ibmPlexSans(
    fontSize: 17,
    height: 1.25,
    fontWeight: FontWeight.w600,
    color: VisionOSColors.textPrimary,
  );

  static TextStyle get titleSmall => GoogleFonts.ibmPlexSans(
    fontSize: 15,
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: VisionOSColors.textPrimary,
  );

  static TextStyle get bodyLarge => GoogleFonts.ibmPlexSans(
    fontSize: 17,
    height: 1.3,
    fontWeight: FontWeight.w400,
    color: VisionOSColors.textPrimary,
  );

  static TextStyle get bodyMedium => GoogleFonts.ibmPlexSans(
    fontSize: 15,
    height: 1.35,
    fontWeight: FontWeight.w400,
    color: VisionOSColors.textPrimary,
  );

  static TextStyle get bodySmall => GoogleFonts.ibmPlexSans(
    fontSize: 13,
    height: 1.35,
    fontWeight: FontWeight.w400,
    color: VisionOSColors.textSecondary,
  );

  static TextStyle get caption => GoogleFonts.ibmPlexSans(
    fontSize: 12,
    height: 1.3,
    fontWeight: FontWeight.w400,
    color: VisionOSColors.textTertiary,
  );

  static TextStyle get captionStrong => GoogleFonts.ibmPlexSans(
    fontSize: 12,
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: VisionOSColors.textSecondary,
  );

  static TextStyle get button => GoogleFonts.ibmPlexSans(
    fontSize: 15,
    height: 1.2,
    fontWeight: FontWeight.w600,
    color: VisionOSColors.textPrimary,
  );
}
