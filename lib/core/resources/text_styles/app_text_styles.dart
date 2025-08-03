import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gghgggfsfs/core/resources/colors/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

final TextTheme customTextTheme = GoogleFonts.interTextTheme().copyWith(
  displayLarge: TextStyle(
    fontSize: 32.sp,
    fontWeight: FontWeight.w700,
    height: 1.h,

    color: customColorScheme.onSurface,
  ),
  displayMedium: TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.w700,
    color: customColorScheme.onSurface,
  ),

  displaySmall: TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w700,
    color: customColorScheme.onSurface,
  ),

  headlineLarge: TextStyle(
    fontSize: 44.sp,
    fontWeight: FontWeight.w500,
    color: customColorScheme.onSurface,
  ),

  bodyMedium: TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: customColorScheme.onSurface,
  ),

  labelLarge: TextStyle(
    fontSize: 30.sp,
    fontWeight: FontWeight.w600,
    color: customColorScheme.onPrimary,
  ),
  labelMedium: TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.w600,
    color: customColorScheme.primary,
  ),
  labelSmall: TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w600,
    color: customColorScheme.primary,
  ),
);
