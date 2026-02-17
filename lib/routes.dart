import 'package:flutter/material.dart';
import 'package:theIline/core/widgets/skeleton_container.dart';
import 'package:theIline/presentation/admin/screens/archives.dart';
import 'package:theIline/presentation/admin/screens/box_detail_screen.dart';
import 'package:theIline/presentation/admin/screens/main_screen.dart';
import 'package:theIline/presentation/auth/screens/phone_signup_screen.dart';
import 'package:theIline/presentation/client/screens/car_wash_detail_screen.dart';
import 'package:theIline/presentation/client/screens/map_home_screen.dart';
import 'package:theIline/presentation/client/screens/on_boarding.dart';

class AppRoutes {
  static const String home = '/';
  static const String reg =
      '/reg_phone_and_password';
  static const String details = '/details';
  static const String onboard = '/onboard';
  static const String archives = '/archives';
  static const String adminHome = '/admin';
  static const String boxDetail = '/boxDetail';
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case archives:
        return MaterialPageRoute(builder: (_) => SkeletonContainer(child: AdminArchives()));
      case boxDetail:
        return MaterialPageRoute(builder: (_) => SkeletonContainer(child: BoxDetailPage()));
      case adminHome:
        return MaterialPageRoute(builder: (_) => SkeletonContainer(child: AdminMainPage()));
      case onboard:
        return MaterialPageRoute(builder: (_) => OnboardingPage());
      case home:
        return MaterialPageRoute(builder: (_) => SkeletonContainer(child: MapHomeScreen()));
      case reg:
        return MaterialPageRoute(builder: (_) => PhoneSignupScreen());
      case details:
        return MaterialPageRoute(builder: (_) => SkeletonContainer(child: CarWashDetailScreen()));
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Маршрут не найден: ${settings.name}')),
          ),
        );
    }
  }
}
