import 'package:flutter/material.dart';
import 'package:theIline/core/theme/color_schemes.dart';
import 'package:theIline/core/theme/text_theme.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: Colors.white,
  colorScheme: customColorScheme,
  textTheme: GoogleFonts.interTextTheme(customTextTheme),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    shadowColor: Colors.transparent,
  ),
);