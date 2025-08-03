import 'package:gghgggfsfs/features/admin/presentation/screens/create_manual_queue_screen.dart';
import 'package:gghgggfsfs/features/admin/presentation/screens/main_screen_admin.dart';
import 'package:go_router/go_router.dart';

final adminRoutes = [
  GoRoute(
    path: '/',
    builder: (context, state) => const MainScreenAdmin(),
  ),
  GoRoute(
    path: '/create_manual_queue',
    builder: (context, state) => const CreateManualQueueScreen(),
  ),
];
