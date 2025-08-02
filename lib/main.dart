import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gghgggfsfs/core/localization/generated/l10n.dart';
import 'package:gghgggfsfs/core/resources/theme/app_theme.dart';
import 'package:gghgggfsfs/data/model_car_wash/model_car_wash.dart';
import 'package:gghgggfsfs/features/admin/presentation/screens/create_manual_queue_screen.dart';
import 'package:gghgggfsfs/features/admin/presentation/screens/main_screen_admin.dart';
import 'package:gghgggfsfs/features/auth/screens/car_signup_screen.dart';
import 'package:gghgggfsfs/features/auth/screens/otp_signup_screen.dart';
import 'package:gghgggfsfs/features/auth/screens/phone_signup_screen.dart';
import 'package:gghgggfsfs/features/client/screens/car_wash_detail_screen.dart';
import 'package:gghgggfsfs/features/director/screens/add_service.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(AilineApp());
}

class AilineApp extends StatelessWidget {
  AilineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(360.w, 903.h),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,

          debugShowCheckedModeBanner: false,
          title: 'Ailine',
          theme: appTheme,
          routerConfig: _router,
        );
      },
    );
  }

  final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => CreateManualQueueScreen(),
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
      //ADMIN
      GoRoute(
        path: '/main_admin',
        builder: (context, state) {
          return MainScreenAdmin();
        },
      ),
      GoRoute(
        path: '/create_manual_queue',
        builder: (context, state) {
          return CreateManualQueueScreen();
        },
      ),
    ],
  );
}
