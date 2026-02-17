import 'package:flutter/material.dart';
import 'package:theIline/core/theme/color_schemes.dart';
import 'package:google_fonts/google_fonts.dart';

final TextTheme customTextTheme = GoogleFonts.interTextTheme().copyWith(
  displayLarge: TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: customColorScheme.onBackground,
  ),
  displayMedium: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: customColorScheme.onBackground,
  ),

  displaySmall: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: customColorScheme.onSurface,
  ),

  headlineLarge: TextStyle(
    fontSize: 44,
    fontWeight: FontWeight.w500,
    color: customColorScheme.onSurface,
  ),

  bodyMedium: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: customColorScheme.onSurface,
  ),

  labelLarge: TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w600,
    color: customColorScheme.onPrimary,
  ),
  labelMedium: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: customColorScheme.primary,
  ),
  labelSmall: TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: customColorScheme.primary,
  ),
);
