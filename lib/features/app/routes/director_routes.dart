import 'package:gghgggfsfs/features/admin/presentation/screens/create_manual_queue_screen.dart';
import 'package:gghgggfsfs/features/director/screens/add_service.dart';
import 'package:gghgggfsfs/features/director/screens/director_auth.dart';
import 'package:go_router/go_router.dart';

final directorRoutes = [
  GoRoute(
    path: '/',
    builder: (context, state) => const DirectorAuth(),
  ),
  GoRoute(
    path: '/add_service',
    builder: (context, state) => const AddService(),
  ),
];
