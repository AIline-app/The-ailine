import 'package:flutter/material.dart';
import 'package:gghgggfsfs/presentation/auth/screens/phone_signup_screen.dart';
import 'package:gghgggfsfs/presentation/client/screens/car_wash_detail_screen.dart';
import 'package:gghgggfsfs/presentation/client/screens/map_home_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String reg =
      '/reg_phone_and_password'; // Регистрация с номер телефона и пароль
  static const String details = '/details';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => MapHomeScreen());
      case reg:
        return MaterialPageRoute(builder: (_) => PhoneSignupScreen());
      case details:
        return MaterialPageRoute(builder: (_) => CarWashDetailScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Маршрут не найден: ${settings.name}')),
          ),
        );
    }
  }
}
