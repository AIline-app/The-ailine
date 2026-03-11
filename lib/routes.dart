import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:theIline/core/widgets/skeleton_container.dart';
import 'package:theIline/presentation/admin/screens/add_car.dart';
import 'package:theIline/presentation/admin/screens/add_washer.dart';
import 'package:theIline/presentation/admin/screens/archives.dart';
import 'package:theIline/presentation/admin/screens/box_detail_screen.dart';
import 'package:theIline/presentation/admin/screens/main_screen.dart';
import 'package:theIline/presentation/admin/screens/washers.dart';
import 'package:theIline/presentation/auth/screens/login_screen.dart';
import 'package:theIline/presentation/auth/screens/otp_signup_screen.dart';
import 'package:theIline/presentation/auth/screens/phone_signup_screen.dart';
import 'package:theIline/presentation/client/screens/car_wash_detail_screen.dart';
import 'package:theIline/presentation/client/screens/map_home_screen.dart';
import 'package:theIline/presentation/client/screens/on_boarding.dart';
import 'package:theIline/presentation/owner/screens/add_auto_category.dart';
import 'package:theIline/presentation/owner/screens/add_bank_card.dart';
import 'package:theIline/presentation/owner/screens/add_company.dart';
import 'package:theIline/presentation/owner/screens/add_the_car_wash.dart';
import 'package:theIline/presentation/owner/screens/analytics.dart';
import 'package:theIline/presentation/owner/screens/owner_home.dart';

import 'data/bloc/carwash_detail_store/carwash_detail_cubit.dart';
import 'data/bloc/carwash_store/carwash_repository.dart';
import 'data/bloc/login_view_model/login_repository_imp.dart';

class AppRoutes {
  static const String home = '/';
  static const String reg =
      '/reg_phone_and_password';
  static const String details = '/details';
  static const String onboard = '/onboard';
  static const String archives = '/archives';
  static const String adminHome = '/admin';
  static const String boxDetail = '/boxDetail';
  static const String addCar = '/addCar';
  static const String washers = '/washers';
  static const String addWashers = '/addWashers';
  static const String addCarWash = '/addCarWash';
  static const String ownerHome = '/ownerHome';
  static const String analytics = '/analytics';
  static const String addCarCategory = '/addCarCategory';
  static const String addCard = '/addCard';
  static const String addCompany = '/addCompany';
  static const String login = '/login';
  static const String verifyPhone = '/verifyPhone';
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case verifyPhone:
        return MaterialPageRoute(builder: (_) => OtpSignupScreen());
      case addCompany:
        return MaterialPageRoute(builder: (_) => SkeletonContainer(child: AddCompanyDataPage()));
      case login:
        return MaterialPageRoute(builder: (_) => SkeletonContainer(child: LoginPage(repo: AuthRepositoryImpl())));
      case addCard:
        return MaterialPageRoute(builder: (_) => SkeletonContainer(child: AddBankCardPage()));
      case addCarCategory:
        return MaterialPageRoute(builder: (_) => SkeletonContainer(child: AddCarCategoryPage()));
      case analytics:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => SkeletonContainer(child: AnalyticsPage()),
        );
      case ownerHome:
        return MaterialPageRoute(builder: (_) => SkeletonContainer(child: OwnerHome()));
      case addCarWash:
        return MaterialPageRoute(builder: (_) => SkeletonContainer(child: AddCarwashPage()));
      case addWashers:
        return MaterialPageRoute(builder: (_) => SkeletonContainer(child: AddWashersPage()));
      case washers:
        return MaterialPageRoute(builder: (_) => SkeletonContainer(child: WashersPage()));
      case addCar:
        return MaterialPageRoute(builder: (_) => SkeletonContainer(child: AddCarPage()));
      case archives:
        return MaterialPageRoute(builder: (_) => SkeletonContainer(child: AdminArchives()));
      case boxDetail:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => SkeletonContainer(child: BoxDetailPage()),
        );
      case adminHome:
        return MaterialPageRoute(builder: (_) => SkeletonContainer(child: AdminMainPage()));
      case onboard:
        return MaterialPageRoute(builder: (_) => OnboardingPage());
      case home:
        return MaterialPageRoute(builder: (_) => SkeletonContainer(child: MapHomeScreen()));
      case reg:
        return MaterialPageRoute(builder: (_) => PhoneSignupScreen());
      case AppRoutes.details:
        final id = settings.arguments as String;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (context) => CarWashDetailCubit(context.read<CarWashRepository>())
              ..load(id),
            child: SkeletonContainer(child: const CarWashDetailScreen()),
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Маршрут не найден: ${settings.name}')),
          ),
        );
    }
  }
}
