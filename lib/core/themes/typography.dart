import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

class MetroTypography {
  const MetroTypography._();

  static TextStyle get headerLight => GoogleFonts.ibmPlexSans(
    color: MetroColors.textPrimary,
    fontSize: 40,
    fontWeight: FontWeight.w300,
  );

  static TextStyle get headerBold => GoogleFonts.ibmPlexSans(
    color: MetroColors.textPrimary,
    fontSize: 30,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get titleNormal => GoogleFonts.ibmPlexSans(
    color: MetroColors.textPrimary,
    fontSize: 22,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get subtitle => GoogleFonts.ibmPlexSans(
    color: MetroColors.textSecondary,
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get body => GoogleFonts.ibmPlexSans(
    color: MetroColors.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get caption => GoogleFonts.ibmPlexSans(
    color: MetroColors.textSecondary,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get button => GoogleFonts.ibmPlexSans(
    color: MetroColors.textPrimary,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
  );
}
