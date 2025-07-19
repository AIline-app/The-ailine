import 'package:flutter/material.dart';
import 'package:gghgggfsfs/core/resources/colors/app_colors.dart';
import 'package:gghgggfsfs/core/resources/text_styles/app_text_styles.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: customColorScheme.surface,
  colorScheme: customColorScheme,
  textTheme: GoogleFonts.interTextTheme(customTextTheme),
  appBarTheme: AppBarTheme(backgroundColor: customColorScheme.surface),

);
