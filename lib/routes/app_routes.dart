import 'package:gghgggfsfs/data/models/model_car_wash/model_car_wash.dart';
import 'package:gghgggfsfs/features/auth/screens/car_signup_screen.dart';
import 'package:gghgggfsfs/features/auth/screens/otp_signup_screen.dart';
import 'package:gghgggfsfs/features/auth/screens/phone_signup_screen.dart';
import 'package:gghgggfsfs/features/client/pages/car_wash_detail_screen.dart';
import 'package:gghgggfsfs/features/director/ui/screens/add_service.dart';
import 'package:gghgggfsfs/features/director/ui/screens/create_admin.dart';
import 'package:gghgggfsfs/features/director/ui/screens/create_card_data.dart';
import 'package:gghgggfsfs/features/director/ui/screens/add_wash.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => AddWash(),
    ), 
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
      path: '/add_wash',
      builder: (context, state) {
        return AddWash();
      },
    ),
    GoRoute(
      path: '/add_service',
      builder: (context, state) {
        return AddService();
      },
    ),
    GoRoute(
      path: '/create_card',
      builder: (context, state) {
        return CreateCardData();
      },
    ),
    GoRoute(
      path: '/create_admin',
      builder: (context, state) {
        return CreateAdmin();
      },
    ),
  ],
);
