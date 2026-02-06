import 'package:flutter/material.dart';
import 'package:gghgggfsfs/presentation/client/themes/main_colors.dart';

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
}
