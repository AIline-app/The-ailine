
import 'package:go_router/go_router.dart';
import '../data/model_car_wash/model_car_wash.dart';
import '../presentation/auth/screens/car_signup_screen.dart';
import '../presentation/auth/screens/otp_signup_screen.dart';
import '../presentation/auth/screens/phone_signup_screen.dart';
import '../presentation/client/screens/car_wash_detail_screen.dart';
import '../presentation/director/screens/add_service.dart';
import '../presentation/director/screens/director_auth.dart';


final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => DirectorAuth(),
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
      path: '/add_service',
      builder: (context, state) {
        return AddService();
      },
    ),
  ],
);