import 'package:gghgggfsfs/features/auth/screens/car_signup_screen.dart';
import 'package:gghgggfsfs/features/auth/screens/otp_signup_screen.dart';
import 'package:gghgggfsfs/features/auth/screens/phone_signup_screen.dart';
import 'package:go_router/go_router.dart';

final authRoutes = [
  GoRoute(path: '/auth', builder: (context, state) => const PhoneSignupScreen()),
  GoRoute(path: '/auth/otp', builder: (context, state) => const OtpSignupScreen()),
  GoRoute(
    path: '/auth/car_signup',
    builder: (context, state) => const CarSignupScreen(),
  ),
];
