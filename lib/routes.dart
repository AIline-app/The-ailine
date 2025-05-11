import 'package:flutter/material.dart';
import 'package:gghgggfsfs/presentation/client/screens/map_home_screen.dart';
import 'package:gghgggfsfs/presentation/client/screens/reg_phone_password.dart';

class AppRoutes {
  static const String home = '/';
  static const String reg =
      '/reg_phone_and_password'; // Регистрация с номер телефона и пароль

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => MapHomeScreen());
      case reg:
        return MaterialPageRoute(builder: (_) => RegPhonePassword());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Маршрут не найден: ${settings.name}')),
          ),
        );
    }
  }
}
