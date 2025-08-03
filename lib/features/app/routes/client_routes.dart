import 'package:gghgggfsfs/data/model_car_wash/model_car_wash.dart';
import 'package:gghgggfsfs/features/client/screens/car_wash_detail_screen.dart';
import 'package:gghgggfsfs/features/client/screens/map_home_screen.dart';
import 'package:go_router/go_router.dart';

final clientRoutes = [
  GoRoute(path: '/', builder: (context, state) => MapHomeScreen()),
  GoRoute(
    path: '/car_details',
    builder: (context, state) {
      final carWash = state.extra as CarWashModel;
      return CarWashDetailScreen(carWash: carWash);
    },
  ),
];
