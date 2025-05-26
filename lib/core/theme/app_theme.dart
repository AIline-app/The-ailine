import 'package:flutter/material.dart';
import 'package:gghgggfsfs/core/theme/color_schemes.dart';
import 'package:gghgggfsfs/core/theme/text_theme.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: customColorScheme.surface,
  colorScheme: customColorScheme,
  textTheme: GoogleFonts.interTextTheme(customTextTheme),
  appBarTheme: AppBarTheme(backgroundColor: customColorScheme.surface),

);
