import 'package:go_router/go_router.dart';
import 'auth_routes.dart';
import 'client_routes.dart';
import 'admin_routes.dart';
import 'director_routes.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      ...authRoutes,
      ...clientRoutes,
      ...adminRoutes,
      ...directorRoutes,
    ],
  );
}
