import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gghgggfsfs/core/localization/generated/l10n.dart';
import 'package:gghgggfsfs/core/resources/theme/app_theme.dart';
import 'package:gghgggfsfs/data/model_car_wash/model_car_wash.dart';
import 'package:gghgggfsfs/presentation/auth/screens/car_signup_screen.dart';
import 'package:gghgggfsfs/presentation/auth/screens/otp_signup_screen.dart';
import 'package:gghgggfsfs/presentation/auth/screens/phone_signup_screen.dart';
import 'package:gghgggfsfs/presentation/client/screens/car_wash_detail_screen.dart';
import 'package:gghgggfsfs/presentation/client/screens/map_home_screen.dart';
import 'package:gghgggfsfs/presentation/director/screens/add_service.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(AilineApp());
}

class AilineApp extends StatelessWidget {
  AilineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Ailine',
      theme: appTheme,
      routerConfig: _router,
      locale: Locale('kk'),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: [Locale('ru'), Locale('kk')],
    );
  }

  final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => MapHomeScreen(),
      ), // changing MapHomeScreen into DirectorAuth()
      GoRoute(
        path: '/car_details',
        builder: (context, state) {
          final carWash = state.extra as CarWashModel;
          return CarWashDetailScreen(carWash: carWash);
        },
      ),
      GoRoute(
        path: '/reg',
        builder: (context, state) {
          return PhoneSignupScreen();
        },
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          return OtpSignupScreen();
        },
      ),
      GoRoute(
        path: '/car_signup',
        builder: (context, state) {
          return CarSignupScreen();
        },
      ),
      //derector control
      GoRoute(
        path: '/add_service',
        builder: (context, state) {
          return AddService();
        },
      ),
    ],
  );
}
