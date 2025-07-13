import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gghgggfsfs/core/theme/app_theme.dart';
import 'package:gghgggfsfs/features/client/map_event.dart';
import 'package:gghgggfsfs/features/director/ui/bloc/director_bloc.dart';
import 'package:gghgggfsfs/routes/app_routes.dart';
import 'package:gghgggfsfs/data/repository/car_wash_repository.dart';
import 'package:gghgggfsfs/core/api_client/api_client.dart';
import 'package:gghgggfsfs/features/client/map_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(AilineApp());
}

class AilineApp extends StatelessWidget {
  AilineApp({super.key});

  final CarWashRepository _carWashRepository = CarWashRepository(
    apiClient: ApiClient(),
  );

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => DirectorBloc(),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Ailine',
        theme: appTheme,
        routerConfig: router,
      ),
    );
  }
}
