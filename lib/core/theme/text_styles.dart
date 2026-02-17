import 'package:flutter/material.dart';
import 'package:theIline/presentation/client/themes/main_colors.dart';

abstract class AppTextStyles {

  static const TextStyle title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyBold = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
     color: Color.fromRGBO(31, 61, 89, 1)
  );

   static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
     color: Color.fromRGBO(31, 61, 89, 1)
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Colors.white
  );
  static const TextStyle normal14 = TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color: Color.fromRGBO(31, 61, 89, 1)
                                  );
  static const TextStyle normal14white = TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 14,
      color: Colors.white);
  static const TextStyle bold28 = TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 28,
                            color: Colors.white,
                    );
  static const TextStyle bold22 = TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 22,
                            color: Colors.white,
                    );
  static const TextStyle bold18 = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 18,
    color: Colors.white,
  );
  static const TextStyle bold18Black = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 18,
    color: Color.fromRGBO(31, 61, 89, 1),
  );
  static const TextStyle bold28Black = TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 28,
                            color: Color.fromRGBO(31, 61, 89, 1),
                );
  static TextStyle normalLightGrey = TextStyle(
    color: Color.fromRGBO(183, 183, 183, 1),
    fontSize: 12,
    fontWeight: FontWeight.bold
  );

  static const TextStyle bold40 = TextStyle(
                                height: 0.9,
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.w600,
                              );
  
  static const TextStyle bold28w600 = TextStyle(
                                height: 0.9,
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.w600,
                              );

  static const normal22w500 = TextStyle(
    color: Colors.white,
    fontSize: 22,
    fontWeight: FontWeight.w500,
    height: 1.0,
    shadows: [
      Shadow(color: Colors.black54, offset: Offset(2, 2)),
    ],
  );

  static const bold14w800 = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.w800,
  );

  static const bold16w600 = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const bold14w700grey = TextStyle(
    color: Colors.white70,
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  static const bold22w700grey = TextStyle(
    color: Colors.white70,
    fontSize: 22,
    fontWeight: FontWeight.w700,
  );

  static const bold16w700 = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  static const timer = TextStyle(
    color: Colors.white,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.0,
  );

  static const normal16w500 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Color(0xFF1F3D59),
  );

  static const queuePlate = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: Color(0xFF1F3D59),
    height: 1.0,
  );

  static const status = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.w800,
  );

  static const buttonPrimary = TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const miniButton = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
}
