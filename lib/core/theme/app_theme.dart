import 'package:flutter/material.dart';
import 'package:gghgggfsfs/core/theme/color_schemes.dart';
import 'package:gghgggfsfs/core/theme/text_theme.dart';

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: customColorScheme.onBackground,
  colorScheme: customColorScheme,
  textTheme: customTextTheme,
);
